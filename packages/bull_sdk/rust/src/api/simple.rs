// Mirror types that FRB would otherwise generate as opaque
// when scanning external crate dependencies

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
    log::set_max_level(log::LevelFilter::Info);
}

#[flutter_rust_bridge::frb(mirror(boltz::api::fees::TxFee))]
pub enum TxFee {
    Absolute(u64),
    Relative(f64),
}

impl From<TxFee> for boltz::api::fees::TxFee {
    fn from(val: TxFee) -> boltz::api::fees::TxFee {
        match val {
            TxFee::Absolute(v) => boltz::api::fees::TxFee::Absolute(v),
            TxFee::Relative(v) => boltz::api::fees::TxFee::Relative(v),
        }
    }
}

// dart_bwk SP enums carrying associated data render as opaque through the
// aggregator unless the primary crate (bull_sdk) declares mirrors. CoinSource
// is field-less and already rendered concretely, so it is identity-mapped.
#[flutter_rust_bridge::frb(mirror(dart_bwk::api::types::SpNotification))]
pub enum SpNotification {
    ScanStarted {
        from: u32,
        to: u32,
    },
    ScanReceiveProgress {
        current: u32,
        end: u32,
    },
    ScanCompleted,
    ScanStopped,
    ScanFailed {
        message: String,
    },
    NewOutput {
        outpoint: String,
        amount_sat: u64,
    },
    OutputSpent {
        outpoint: String,
    },
    Broadcasted {
        txid: String,
    },
    BroadcastFailed {
        message: String,
    },
    BackendOffline,
    ElectrumTx {
        kind: dart_bwk::api::types::CoinSource,
        txid: String,
        amount_sat: u64,
        height: Option<u32>,
    },
    ScanSpendProgress {
        current: u32,
        end: u32,
    },
    HeaderProgressStarted {
        phase: dart_bwk::api::types::HeaderProgressPhase,
        start: u32,
        end: u32,
    },
    HeaderProgress {
        phase: dart_bwk::api::types::HeaderProgressPhase,
        current: u32,
        end: u32,
    },
    HeaderProgressCompleted {
        phase: dart_bwk::api::types::HeaderProgressPhase,
    },
    HeaderProgressFailed {
        phase: dart_bwk::api::types::HeaderProgressPhase,
    },
    PaymentHistoryUpdated,
}

impl From<dart_bwk::api::types::SpNotification> for SpNotification {
    fn from(val: dart_bwk::api::types::SpNotification) -> SpNotification {
        match val {
            dart_bwk::api::types::SpNotification::ScanStarted { from, to } => {
                SpNotification::ScanStarted { from, to }
            }
            dart_bwk::api::types::SpNotification::ScanReceiveProgress { current, end } => {
                SpNotification::ScanReceiveProgress { current, end }
            }
            dart_bwk::api::types::SpNotification::ScanSpendProgress { current, end } => {
                SpNotification::ScanSpendProgress { current, end }
            }
            dart_bwk::api::types::SpNotification::ScanCompleted => SpNotification::ScanCompleted,
            dart_bwk::api::types::SpNotification::ScanStopped => SpNotification::ScanStopped,
            dart_bwk::api::types::SpNotification::ScanFailed { message } => {
                SpNotification::ScanFailed { message }
            }
            dart_bwk::api::types::SpNotification::NewOutput {
                outpoint,
                amount_sat,
            } => SpNotification::NewOutput {
                outpoint,
                amount_sat,
            },
            dart_bwk::api::types::SpNotification::OutputSpent { outpoint } => {
                SpNotification::OutputSpent { outpoint }
            }
            dart_bwk::api::types::SpNotification::Broadcasted { txid } => {
                SpNotification::Broadcasted { txid }
            }
            dart_bwk::api::types::SpNotification::BroadcastFailed { message } => {
                SpNotification::BroadcastFailed { message }
            }
            dart_bwk::api::types::SpNotification::BackendOffline => SpNotification::BackendOffline,
            dart_bwk::api::types::SpNotification::ElectrumTx {
                kind,
                txid,
                amount_sat,
                height,
            } => SpNotification::ElectrumTx {
                kind,
                txid,
                amount_sat,
                height,
            },
            dart_bwk::api::types::SpNotification::HeaderProgressStarted { phase, start, end } => {
                SpNotification::HeaderProgressStarted { phase, start, end }
            }
            dart_bwk::api::types::SpNotification::HeaderProgress {
                phase,
                current,
                end,
            } => SpNotification::HeaderProgress {
                phase,
                current,
                end,
            },
            dart_bwk::api::types::SpNotification::HeaderProgressCompleted { phase } => {
                SpNotification::HeaderProgressCompleted { phase }
            }
            dart_bwk::api::types::SpNotification::HeaderProgressFailed { phase } => {
                SpNotification::HeaderProgressFailed { phase }
            }
            dart_bwk::api::types::SpNotification::PaymentHistoryUpdated => {
                SpNotification::PaymentHistoryUpdated
            }
        }
    }
}

impl From<SpNotification> for dart_bwk::api::types::SpNotification {
    fn from(val: SpNotification) -> dart_bwk::api::types::SpNotification {
        match val {
            SpNotification::ScanStarted { from, to } => {
                dart_bwk::api::types::SpNotification::ScanStarted { from, to }
            }
            SpNotification::ScanReceiveProgress { current, end } => {
                dart_bwk::api::types::SpNotification::ScanReceiveProgress { current, end }
            }
            SpNotification::ScanSpendProgress { current, end } => {
                dart_bwk::api::types::SpNotification::ScanSpendProgress { current, end }
            }
            SpNotification::ScanCompleted => dart_bwk::api::types::SpNotification::ScanCompleted,
            SpNotification::ScanStopped => dart_bwk::api::types::SpNotification::ScanStopped,
            SpNotification::ScanFailed { message } => {
                dart_bwk::api::types::SpNotification::ScanFailed { message }
            }
            SpNotification::NewOutput {
                outpoint,
                amount_sat,
            } => dart_bwk::api::types::SpNotification::NewOutput {
                outpoint,
                amount_sat,
            },
            SpNotification::OutputSpent { outpoint } => {
                dart_bwk::api::types::SpNotification::OutputSpent { outpoint }
            }
            SpNotification::Broadcasted { txid } => {
                dart_bwk::api::types::SpNotification::Broadcasted { txid }
            }
            SpNotification::BroadcastFailed { message } => {
                dart_bwk::api::types::SpNotification::BroadcastFailed { message }
            }
            SpNotification::BackendOffline => dart_bwk::api::types::SpNotification::BackendOffline,
            SpNotification::ElectrumTx {
                kind,
                txid,
                amount_sat,
                height,
            } => dart_bwk::api::types::SpNotification::ElectrumTx {
                kind,
                txid,
                amount_sat,
                height,
            },
            SpNotification::HeaderProgressStarted { phase, start, end } => {
                dart_bwk::api::types::SpNotification::HeaderProgressStarted { phase, start, end }
            }
            SpNotification::HeaderProgress {
                phase,
                current,
                end,
            } => dart_bwk::api::types::SpNotification::HeaderProgress {
                phase,
                current,
                end,
            },
            SpNotification::HeaderProgressCompleted { phase } => {
                dart_bwk::api::types::SpNotification::HeaderProgressCompleted { phase }
            }
            SpNotification::HeaderProgressFailed { phase } => {
                dart_bwk::api::types::SpNotification::HeaderProgressFailed { phase }
            }
            SpNotification::PaymentHistoryUpdated => {
                dart_bwk::api::types::SpNotification::PaymentHistoryUpdated
            }
        }
    }
}

#[flutter_rust_bridge::frb(mirror(dart_bwk::api::types::RecipientView))]
pub enum RecipientView {
    Sp {
        address: String,
        amount_sat: u64,
        label: Option<u32>,
        is_max: bool,
    },
    Standard {
        address: String,
        amount_sat: u64,
        is_max: bool,
    },
}

impl From<dart_bwk::api::types::RecipientView> for RecipientView {
    fn from(val: dart_bwk::api::types::RecipientView) -> RecipientView {
        match val {
            dart_bwk::api::types::RecipientView::Sp {
                address,
                amount_sat,
                label,
                is_max,
            } => RecipientView::Sp {
                address,
                amount_sat,
                label,
                is_max,
            },
            dart_bwk::api::types::RecipientView::Standard {
                address,
                amount_sat,
                is_max,
            } => RecipientView::Standard {
                address,
                amount_sat,
                is_max,
            },
        }
    }
}

impl From<RecipientView> for dart_bwk::api::types::RecipientView {
    fn from(val: RecipientView) -> dart_bwk::api::types::RecipientView {
        match val {
            RecipientView::Sp {
                address,
                amount_sat,
                label,
                is_max,
            } => dart_bwk::api::types::RecipientView::Sp {
                address,
                amount_sat,
                label,
                is_max,
            },
            RecipientView::Standard {
                address,
                amount_sat,
                is_max,
            } => dart_bwk::api::types::RecipientView::Standard {
                address,
                amount_sat,
                is_max,
            },
        }
    }
}

// Same reason as the SP enums above: an error type carrying associated data
// renders as an opaque handle through the aggregator unless the primary crate
// mirrors it. Without this, a consumer gets a `SpError` it cannot inspect,
// which is the string-sniffing problem again in a different shape.
#[flutter_rust_bridge::frb(mirror(dart_bwk::api::types::SpError))]
pub enum SpError {
    ScannerAlreadyRunning,
    DisposeTimedOut,
    SimulationDrifted { detail: String },
    TooManyCoins { count: u32, max: u32 },
    NothingToSendAfterFee { remainder_sat: u64 },
    InvalidDescriptor { reason: String },
    Signing { reason: String },
    SignedPsbtMismatch { detail: String },
    Verification { reason: String },
    Other { message: String },
}

impl From<dart_bwk::api::types::SpError> for SpError {
    fn from(val: dart_bwk::api::types::SpError) -> SpError {
        use dart_bwk::api::types::SpError as E;
        match val {
            E::ScannerAlreadyRunning => SpError::ScannerAlreadyRunning,
            E::DisposeTimedOut => SpError::DisposeTimedOut,
            E::SimulationDrifted { detail } => SpError::SimulationDrifted { detail },
            E::TooManyCoins { count, max } => SpError::TooManyCoins { count, max },
            E::NothingToSendAfterFee { remainder_sat } => {
                SpError::NothingToSendAfterFee { remainder_sat }
            }
            E::InvalidDescriptor { reason } => SpError::InvalidDescriptor { reason },
            E::Signing { reason } => SpError::Signing { reason },
            E::SignedPsbtMismatch { detail } => SpError::SignedPsbtMismatch { detail },
            E::Verification { reason } => SpError::Verification { reason },
            E::Other { message } => SpError::Other { message },
        }
    }
}

// Where a simulated output pays: carries data, so it needs a mirror for the
// same reason as the enums above.
#[flutter_rust_bridge::frb(mirror(dart_bwk::api::types::OutputDestination))]
pub enum OutputDestination {
    SilentPayment {
        address: String,
        scan_key: String,
        spend_key: String,
        label: Option<u32>,
    },
    Address { address: String },
    Script { script_hex: String },
}

impl From<OutputDestination> for dart_bwk::api::types::OutputDestination {
    fn from(val: OutputDestination) -> dart_bwk::api::types::OutputDestination {
        use dart_bwk::api::types::OutputDestination as D;
        match val {
            OutputDestination::SilentPayment {
                address,
                scan_key,
                spend_key,
                label,
            } => D::SilentPayment {
                address,
                scan_key,
                spend_key,
                label,
            },
            OutputDestination::Address { address } => D::Address { address },
            OutputDestination::Script { script_hex } => D::Script { script_hex },
        }
    }
}

impl From<dart_bwk::api::types::OutputDestination> for OutputDestination {
    fn from(val: dart_bwk::api::types::OutputDestination) -> OutputDestination {
        use dart_bwk::api::types::OutputDestination as D;
        match val {
            D::SilentPayment {
                address,
                scan_key,
                spend_key,
                label,
            } => OutputDestination::SilentPayment {
                address,
                scan_key,
                spend_key,
                label,
            },
            D::Address { address } => OutputDestination::Address { address },
            D::Script { script_hex } => OutputDestination::Script { script_hex },
        }
    }
}
