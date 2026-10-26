use std::{env, fs, process::Command};

fn main() {
    println!("cargo:rerun-if-changed=Cargo.lock");
    println!("cargo:rerun-if-changed=Cargo.toml");
    println!("cargo:rerun-if-env-changed=RUSTC");
    let lock: toml::Value = fs::read_to_string("Cargo.lock")
        .expect("read the committed dependency lockfile")
        .parse()
        .expect("parse Cargo.lock");
    let versions: Vec<_> = lock["package"]
        .as_array()
        .expect("lock packages")
        .iter()
        .filter(|p| p["name"].as_str() == Some("arti-client"))
        .map(|p| p["version"].as_str().expect("locked version"))
        .collect();
    assert_eq!(
        versions.len(),
        1,
        "build identity requires exactly one arti-client version"
    );
    println!("cargo:rustc-env=ONION_ARTI_VERSION={}", versions[0]);
    let manifest: toml::Value = fs::read_to_string("Cargo.toml")
        .expect("read manifest")
        .parse()
        .expect("parse manifest");
    let dependency = &manifest["dependencies"]["arti-client"];
    assert_eq!(dependency["default-features"].as_bool(), Some(false));
    let mut features: Vec<_> = dependency["features"]
        .as_array()
        .expect("explicit Arti features")
        .iter()
        .map(|f| f.as_str().expect("feature string"))
        .collect();
    features.sort_unstable();
    println!(
        "cargo:rustc-env=ONION_ARTI_REQUESTED_FEATURES={}",
        features.join(",")
    );
    println!(
        "cargo:rustc-env=ONION_BUILD_TARGET={}",
        env::var("TARGET").expect("Cargo target")
    );
    let compiler = Command::new(env::var_os("RUSTC").expect("Cargo Rust compiler"))
        .arg("--version")
        .output()
        .expect("Rust compiler version");
    assert!(compiler.status.success(), "Rust compiler version failed");
    let compiler = String::from_utf8(compiler.stdout).expect("compiler version UTF-8");
    println!("cargo:rustc-env=ONION_RUSTC_VERSION={}", compiler.trim());
}
