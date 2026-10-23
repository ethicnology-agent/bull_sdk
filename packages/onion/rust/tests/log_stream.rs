//! Exercise the process-global public API in a dedicated test binary.

use onion::api::log::{open_log_stream, TorLogLevel};

#[tokio::test]
async fn global_capture_can_be_replaced_and_closed_without_reinstalling_tracing() {
    let first = open_log_stream(Some("onion=info,off".into())).expect("first capture");
    tracing::info!(target: "onion", "first");
    assert_eq!(first.next_batch().await[0].message, "first");

    assert!(open_log_stream(Some("trace".into())).is_err());
    tracing::info!(target: "onion", "still active");
    assert_eq!(first.next_batch().await[0].message, "still active");

    let second = open_log_stream(Some("onion=debug,off".into())).expect("replacement");
    assert!(first.next_batch().await.is_empty());
    first.close();
    tracing::debug!(target: "onion", "second");
    let batch = second.next_batch().await;
    assert_eq!(batch[0].level, TorLogLevel::Debug);
    assert_eq!(batch[0].message, "second");

    drop(first);
    second.close();
    assert!(second.next_batch().await.is_empty());
    let third = open_log_stream(None).expect("restart after closing");
    tracing::info!(target: "tor_hsclient", "descriptor fetched");
    assert_eq!(third.next_batch().await[0].target, "tor_hsclient");
}
