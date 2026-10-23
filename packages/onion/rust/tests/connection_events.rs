//! Hermetic TCP/SOCKS tests for the diagnostic surface; no Tor bootstrap.
use std::sync::atomic::{AtomicU64, Ordering};
use std::time::Duration;

use onion::api::connection::{
    ConnectionEventBatch, ConnectionEventKind as Event, ConnectionFailureKind as Failure,
};
use onion::api::{SocksPolicy, TorService};
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::TcpStream;

async fn service() -> TorService {
    static NEXT: AtomicU64 = AtomicU64::new(0);
    let path = std::env::temp_dir().join(format!(
        "onion_connection_{}_{}",
        std::process::id(),
        NEXT.fetch_add(1, Ordering::Relaxed)
    ));
    TorService::start(
        &path.join("state").to_string_lossy(),
        &path.join("cache").to_string_lossy(),
        0,
        SocksPolicy::Any,
    )
    .await
    .expect("start")
}

async fn request(port: u16, command: u8) -> u8 {
    let mut socket = TcpStream::connect(("127.0.0.1", port))
        .await
        .expect("connect");
    socket.write_all(&[5, 1, 0]).await.expect("greeting");
    let mut greeting = [0; 2];
    socket
        .read_exact(&mut greeting)
        .await
        .expect("greeting reply");
    assert_eq!(greeting, [5, 0]);
    let mut request = vec![5, command, 0, 3, 11];
    request.extend_from_slice(b"example.com");
    request.extend_from_slice(&80u16.to_be_bytes());
    socket.write_all(&request).await.expect("request");
    let mut response = [0; 10];
    socket.read_exact(&mut response).await.expect("reply");
    assert_eq!(response[0], 5);
    response[1]
}

async fn wait_for(service: &TorService, kind: Event) -> ConnectionEventBatch {
    tokio::time::timeout(Duration::from_secs(2), async {
        loop {
            let batch = service.connection_events(0).expect("events");
            if batch.events.iter().any(|event| event.kind == kind) {
                return batch;
            }
            tokio::task::yield_now().await;
        }
    })
    .await
    .expect("diagnostic must arrive")
}

#[tokio::test]
async fn sessions_have_independent_history_and_keep_standard_socks_replies() {
    let service = service().await;
    let isolated = service
        .open_session(0, SocksPolicy::OnionOnly)
        .await
        .expect("session");
    assert!(service
        .connection_events(0)
        .expect("empty")
        .events
        .is_empty());
    // The real unbootstrapped Arti client supplies a typed error without network I/O.
    assert_eq!(request(service.socks_port(), 1).await, 3);
    let batch = service.connection_events(0).expect("events");
    assert_eq!(
        batch.events.iter().map(|e| e.kind).collect::<Vec<_>>(),
        [Event::Accepted, Event::Connecting, Event::Failed]
    );
    assert_eq!(batch.events[2].failure, Some(Failure::BootstrapRequired));
    assert!(batch.events.iter().all(|e| e.attempt_id == 1));
    assert!(batch
        .events
        .windows(2)
        .all(|pair| pair[0].elapsed_ms <= pair[1].elapsed_ms));
    assert!(isolated
        .connection_events(0)
        .expect("isolated")
        .events
        .is_empty());
    assert_eq!(request(isolated.socks_port(), 1).await, 2);
    let isolated_batch = isolated.connection_events(0).expect("isolated events");
    assert_eq!(isolated_batch.events.len(), 2);
    assert_eq!(
        isolated_batch.events[1].failure,
        Some(Failure::PolicyDenied)
    );
    assert_eq!(request(service.socks_port(), 0xF0).await, 7);
    let last = service
        .connection_events(batch.latest_sequence)
        .expect("cursor");
    assert_eq!(last.events.len(), 2);
    assert_eq!(last.events[1].attempt_id, 2);
    assert_eq!(last.events[1].failure, Some(Failure::UnsupportedCommand));
    assert!(service.connection_events(last.latest_sequence + 1).is_err());
    service.stop().await;
    assert_eq!(
        isolated.connection_events(0).expect("after stop").events,
        isolated_batch.events
    );
}

#[tokio::test]
async fn malformed_handshake_and_service_stop_have_distinct_terminal_events() {
    let service = service().await;
    let mut socket = TcpStream::connect(("127.0.0.1", service.socks_port()))
        .await
        .expect("connect");
    socket
        .write_all(&[1, 1, 0])
        .await
        .expect("invalid greeting");
    let failed = wait_for(&service, Event::Failed).await;
    assert_eq!(
        failed.events.last().expect("failed").failure,
        Some(Failure::HandshakeFailed)
    );
    let pending = TcpStream::connect(("127.0.0.1", service.socks_port()))
        .await
        .expect("pending");
    tokio::time::timeout(Duration::from_secs(2), async {
        while service
            .connection_events(failed.latest_sequence)
            .expect("events")
            .events
            .is_empty()
        {
            tokio::task::yield_now().await;
        }
    })
    .await
    .expect("accepted");
    service.stop().await;
    let stopped = wait_for(&service, Event::Cancelled).await;
    let terminal = stopped.events.last().expect("cancelled");
    assert_eq!(terminal.kind, Event::Cancelled);
    assert_eq!(terminal.attempt_id, 2);
    assert_eq!(terminal.failure, None);
    drop(pending);
}

#[tokio::test(start_paused = true)]
async fn stalled_handshake_reports_its_own_timeout() {
    let service = service().await;
    let mut socket = TcpStream::connect(("127.0.0.1", service.socks_port()))
        .await
        .expect("connect");
    let mut response = Vec::new();
    socket
        .read_to_end(&mut response)
        .await
        .expect("handshake closes");
    let batch = service.connection_events(0).expect("events");
    assert_eq!(
        batch.events.last().expect("failed").failure,
        Some(Failure::HandshakeTimeout)
    );
    service.stop().await;
}

#[tokio::test]
async fn connection_limit_is_visible_without_growing_the_history() {
    let service = service().await;
    let mut sockets = Vec::new();
    for _ in 0..64 {
        sockets.push(
            TcpStream::connect(("127.0.0.1", service.socks_port()))
                .await
                .expect("connect"),
        );
    }
    tokio::time::timeout(Duration::from_secs(2), async {
        while service
            .connection_events(0)
            .expect("events")
            .latest_sequence
            < 64
        {
            tokio::task::yield_now().await;
        }
    })
    .await
    .expect("accepted connections");
    let mut rejected = TcpStream::connect(("127.0.0.1", service.socks_port()))
        .await
        .expect("connect at limit");
    let mut response = Vec::new();
    tokio::time::timeout(Duration::from_secs(2), rejected.read_to_end(&mut response))
        .await
        .expect("limit closes socket")
        .expect("closed");
    assert!(response.is_empty());
    let batch = service.connection_events(0).expect("events");
    assert_eq!(batch.events.len(), 64);
    assert_eq!(batch.latest_sequence, 66);
    assert_eq!(batch.dropped, 2);
    let terminal = batch.events.last().expect("rejected attempt");
    assert_eq!(terminal.attempt_id, 65);
    assert_eq!(terminal.failure, Some(Failure::ConnectionLimit));
    service.stop().await;
    drop(sockets);
}
