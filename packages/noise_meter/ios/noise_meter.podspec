#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'noise_meter'
  s.version          = '1.0.1'
  s.summary          = 'Measure noise in decibel.'
  s.description      = <<-DESC
Measure noise in decibel.
                       DESC
  s.homepage         = 'https://pub.dev/packages/noise_meter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Copenhagen Center for Health Technology' => 'cph.cachet@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.ios.deployment_target = '8.0'
end

