//! A host subscriber must never be overwritten or cause a panic.

use onion::api::error::TorFailureKind;
use onion::api::log::open_log_stream;

#[test]
fn reports_an_existing_subscriber_as_a_configuration_failure() {
    tracing::subscriber::set_global_default(tracing_subscriber::Registry::default())
        .expect("host subscriber");
    for _ in 0..2 {
        let failure = match open_log_stream(None) {
            Ok(_) => panic!("must preserve the host subscriber"),
            Err(failure) => failure,
        };
        assert_eq!(failure.kind, TorFailureKind::Configuration);
        assert_eq!(
            failure.log_message,
            "A native tracing subscriber is already installed"
        );
    }
}
