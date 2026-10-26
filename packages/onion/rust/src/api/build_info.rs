//! Identity of this loaded native binary, without initializing Tor or its PT.

use flutter_rust_bridge::frb;

/// Values generated from this binary's manifest, lockfile and compiler.
/// Requested features are not the full Cargo-unified dependency feature graph.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TorBuildInfo {
    /// Wrapper crate version.
    pub wrapper_version: String,
    /// Resolved arti-client version from the committed lockfile.
    pub arti_client_version: String,
    /// Cargo target triple of this binary.
    pub target: String,
    /// Compiler identity used for this binary.
    pub rustc_version: String,
    /// Explicit manifest features; not the full unified dependency graph.
    pub arti_requested_features: Vec<String>,
}

/// Available before bootstrap. Snowflake's runtime version is a separate API.
#[frb(sync)]
pub fn tor_build_info() -> TorBuildInfo {
    TorBuildInfo {
        wrapper_version: env!("CARGO_PKG_VERSION").to_owned(),
        arti_client_version: env!("ONION_ARTI_VERSION").to_owned(),
        target: env!("ONION_BUILD_TARGET").to_owned(),
        rustc_version: env!("ONION_RUSTC_VERSION").to_owned(),
        arti_requested_features: env!("ONION_ARTI_REQUESTED_FEATURES")
            .split(',')
            .map(str::to_owned)
            .collect(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn build_identity_matches_the_lock_and_requested_capabilities() {
        let info = tor_build_info();
        let lock: toml::Value = include_str!("../../Cargo.lock").parse().expect("lock");
        let package = lock["package"]
            .as_array()
            .expect("packages")
            .iter()
            .find(|p| p["name"].as_str() == Some("arti-client"))
            .expect("Arti");
        assert_eq!(
            Some(info.arti_client_version.as_str()),
            package["version"].as_str()
        );
        assert_eq!(info.wrapper_version, env!("CARGO_PKG_VERSION"));
        assert!(info.rustc_version.starts_with("rustc "));
        assert!(!info.target.is_empty());
        for required in [
            "onion-service-client",
            "bridge-client",
            "pt-client",
            "compression",
        ] {
            assert!(info.arti_requested_features.iter().any(|f| f == required));
        }
    }
}
