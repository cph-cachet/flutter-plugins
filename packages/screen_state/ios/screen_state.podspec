#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint screen_state.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'screen_state'
  s.version          = '1.0.0'
  s.summary          = 'Base plugin for screen state detection.'
  s.description      = <<-DESC
https://github.com/cph-cachet/flutter-plugins/tree/master/packages/screen_state/ios.
                       DESC
  s.homepage         = 'https://github.com/cph-cachet/flutter-plugins/tree/master/packages/screen_state/ios'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Tokenlab' => 'luansilva@tokenlab.com.br' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
