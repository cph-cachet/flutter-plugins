#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint empatica_e4link.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'empatica_e4link'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for the Empatica E4 wristband'
  s.description      = <<-DESC
Flutter plugin for the Empatica E4 wristband
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Copenhagen Center for Health Technology' => 'cph.cachet@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  s.vendored_frameworks = 'E4Link.framework'
end
