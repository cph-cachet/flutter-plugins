#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'esense_flutter'
  s.version          = '0.2.0'
  s.summary          = 'A Flutter plugin for the eSense devices.'
  s.description      = <<-DESC
A Flutter plugin for the eSense devices.
                       DESC
  s.homepage         = 'https://pub.dev/packages/esense_flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Copenhagen Center for Health Technology' => 'cph.cachet@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'ESense'

  s.ios.deployment_target = '10.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end

