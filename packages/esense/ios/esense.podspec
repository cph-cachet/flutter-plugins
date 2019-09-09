#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'esense'
  s.version          = '0.2.0'
  s.summary          = 'The eSense Flutter Plugin.'
  s.description      = <<-DESC
The eSense Flutter Plugin.
                       DESC
  s.homepage         = 'https://pub.dev/packages/esense'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Copenhagen Center for Health Technology' => 'cph.cachet@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  # the following is needed, but the name conflicts w. the name of this pod - both called 'esense'...?
  s.dependency 'ESense'

  s.ios.deployment_target = '10.0'
end

