//! Validated, immutable startup profiles for the unmanaged Snowflake transport.

use std::collections::{HashMap, HashSet};

use arti_client::config::BridgeConfigBuilder;
use flutter_rust_bridge::frb;
use url::Url;

use super::client::SNOWFLAKE_BRIDGES;
use super::error::TorFailure;

/// A startup-only Snowflake bridge profile. Raw bridge values are never exported.
///
/// The host owns discovery, consent and persistence. Constructing a profile does
/// not contact its endpoints or change a running client's configuration.
#[frb(opaque)]
pub struct SnowflakeBridgeProfile {
    pub(crate) bridges: Vec<BridgeConfigBuilder>,
}

impl SnowflakeBridgeProfile {
    /// Keep the existing bundled defaults without fetching configuration.
    #[frb(sync)]
    pub fn bundled() -> Result<Self, TorFailure> {
        Self::from_bridge_lines(SNOWFLAKE_BRIDGES.iter().map(|s| (*s).to_owned()).collect())
    }

    /// Validate 1–16 HTTPS-fronted Snowflake bridge lines before starting Tor.
    ///
    /// Supports the bundled profile's fingerprint, url, fronts (or front), ice
    /// and optional utls-imitate parameters. Other rendezvous modes require a
    /// separately supported profile contract. Errors never contain input values.
    #[frb(sync)]
    pub fn from_bridge_lines(bridge_lines: Vec<String>) -> Result<Self, TorFailure> {
        if bridge_lines.is_empty() || bridge_lines.len() > 16 {
            return Err(invalid());
        }
        if bridge_lines.iter().map(String::len).sum::<usize>() > 16_384 {
            return Err(invalid());
        }
        let mut bridges = Vec::with_capacity(bridge_lines.len());
        let mut unique = HashSet::new();
        for line in bridge_lines {
            if line.len() > 4096 || line.chars().any(char::is_control) {
                return Err(invalid());
            }
            let mut bridge: BridgeConfigBuilder = line.trim().parse().map_err(|_| invalid())?;
            if bridge.get_transport() != Some("snowflake") {
                return Err(invalid());
            }
            let settings = bridge.settings();
            let mut args = HashMap::new();
            for (key, value) in settings.iter() {
                if !matches!(
                    key.as_str(),
                    "fingerprint" | "url" | "fronts" | "front" | "ice" | "utls-imitate"
                ) || value.is_empty()
                    || value.contains([';', '\\'])
                    || args.insert(key.as_str(), value.as_str()).is_some()
                {
                    return Err(invalid());
                }
            }
            // Arti encodes PT arguments into at most two 255-byte SOCKS fields.
            let encoded_len = settings
                .iter()
                .map(|(k, v)| k.len() + 1 + v.len())
                .sum::<usize>()
                + settings.len().saturating_sub(1);
            if encoded_len > 510 {
                return Err(invalid());
            }
            let fingerprint = args.get("fingerprint").ok_or_else(invalid)?;
            if fingerprint.len() != 40 || !fingerprint.bytes().all(|b| b.is_ascii_hexdigit()) {
                return Err(invalid());
            }
            let broker = Url::parse(args.get("url").ok_or_else(invalid)?).map_err(|_| invalid())?;
            if broker.scheme() != "https"
                || broker.host_str().is_none()
                || !broker.username().is_empty()
                || broker.password().is_some()
                || broker.fragment().is_some()
            {
                return Err(invalid());
            }
            if args.contains_key("front") && args.contains_key("fronts") {
                return Err(invalid());
            }
            let fronts = args
                .get("fronts")
                .or_else(|| args.get("front"))
                .ok_or_else(invalid)?;
            for front in fronts.split(',') {
                if front.is_empty()
                    || front.contains(['/', '@', ':', '?', '#'])
                    || Url::parse(&format!("https://{front}"))
                        .ok()
                        .and_then(|u| u.host_str().map(str::to_owned))
                        .is_none()
                {
                    return Err(invalid());
                }
            }
            for server in args.get("ice").ok_or_else(invalid)?.split(',') {
                let address = server.strip_prefix("stun:").ok_or_else(invalid)?;
                let stun = Url::parse(&format!("stun://{address}")).map_err(|_| invalid())?;
                if stun.host_str().is_none()
                    || !stun.username().is_empty()
                    || stun.password().is_some()
                    || stun.query().is_some()
                    || stun.fragment().is_some()
                    || !stun.path().is_empty()
                {
                    return Err(invalid());
                }
            }
            let expected_fingerprint = (*fingerprint).to_owned();
            if !bridge.ids().iter().any(|id| {
                id.as_bytes().len() == 20
                    && id.as_bytes().iter().enumerate().all(|(index, byte)| {
                        u8::from_str_radix(&expected_fingerprint[index * 2..index * 2 + 2], 16)
                            == Ok(*byte)
                    })
            }) {
                return Err(invalid());
            }
            let built = bridge.build().map_err(|_| invalid())?;
            if !unique.insert(built) {
                return Err(invalid());
            }
            bridges.push(bridge);
        }
        Ok(Self { bridges })
    }

    /// Number of validated bridges, without disclosing their identities.
    #[frb(sync)]
    pub fn bridge_count(&self) -> u32 {
        self.bridges.len() as u32
    }
}

fn invalid() -> TorFailure {
    TorFailure::configuration("Invalid or unsupported Snowflake bridge profile")
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::api::error::TorFailureKind;

    #[test]
    fn bundled_profile_retains_both_existing_bridges() {
        let profile = SnowflakeBridgeProfile::bundled().expect("bundled profile");
        assert_eq!(profile.bridge_count(), 2);
        for (bridge, original) in profile.bridges.iter().zip(SNOWFLAKE_BRIDGES) {
            let expected: BridgeConfigBuilder = original.parse().expect("original");
            assert_eq!(
                bridge.build().expect("validated"),
                expected.build().expect("original")
            );
        }
    }

    #[test]
    fn a_custom_profile_does_not_change_the_bundled_defaults() {
        let custom = SNOWFLAKE_BRIDGES[0].replace("1098762253.rsc.cdn77.org", "broker.example");
        let profile =
            SnowflakeBridgeProfile::from_bridge_lines(vec![custom]).expect("custom profile");
        assert_eq!(profile.bridge_count(), 1);
        assert_eq!(
            SnowflakeBridgeProfile::bundled()
                .expect("bundled")
                .bridge_count(),
            2
        );
    }

    #[test]
    fn malformed_profiles_are_rejected_without_echoing_configuration() {
        let valid = SNOWFLAKE_BRIDGES[0];
        let cases = vec![
            vec![],
            vec![valid.to_owned(); 17],
            vec![valid.to_owned(); 2],
            vec!["sensitive-invalid-input".to_owned()],
            vec![valid.replace("snowflake", "obfs4")],
            vec![valid.replace("https://", "http://")],
            vec![valid.replace(
                "fingerprint=2B280B23E1107BB62ABFC40DDCC8824814F80A72",
                "fingerprint=8838024498816A039FCBBAB14E6F40A0843051FA",
            )],
            vec![valid.replace("url=https://", "url=https://secret:password@")],
            vec![format!("{valid}\n")],
            vec![format!("{valid} arbitrary=secret")],
            vec![format!("{valid} url=https://duplicate.invalid/")],
            vec![valid.replace("fronts=", "fronts=bad/path,")],
            vec![valid.replace("ice=stun:", "ice=turn:")],
            vec![valid.replace("utls-imitate=", "utls-imitate=bad;")],
            vec![format!("{valid}{}", "x".repeat(4096))],
        ];
        for input in cases {
            let failure = SnowflakeBridgeProfile::from_bridge_lines(input)
                .err()
                .expect("rejected");
            assert_eq!(failure.kind, TorFailureKind::Configuration);
            assert_eq!(
                failure.log_message,
                "Invalid or unsupported Snowflake bridge profile"
            );
        }
    }
}
