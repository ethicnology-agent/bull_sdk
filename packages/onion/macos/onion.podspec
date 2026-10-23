#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint onion.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'onion'
  s.version          = '0.2.0'
  s.summary          = 'Embedded Tor client and loopback SOCKS5 proxy.'
  s.description      = <<-DESC
Embedded Tor client and loopback SOCKS5 proxy for Bull Bitcoin, built on Arti.
                       DESC
  s.homepage         = 'https://github.com/SatoshiPortal/bull_sdk'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Satoshi Portal' => 'https://bullbitcoin.com' }
  s.module_name      = 'onion'

  # The dummy C file makes CocoaPods create a framework for the Rust archive.
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.swift_version = '5.0'

  s.script_phase = {
    :name => 'Build Rust library',
    # First argument is relative path to the `rust` folder, second is name of rust library
    :script => 'sh "$PODS_TARGET_SRCROOT/../cargokit/build_pod.sh" ../rust onion',
    :execution_position => :before_compile,
    :input_files => ['${BUILT_PRODUCTS_DIR}/cargokit_phony'],
    # Let XCode know that the static library referenced in -force_load below is
    # created by this build step.
    :output_files => ["${PODS_CONFIGURATION_BUILD_DIR}/onion/libonion.a"],
  }
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'OTHER_LDFLAGS' => '-force_load ${PODS_CONFIGURATION_BUILD_DIR}/onion/libonion.a',
  }
end
