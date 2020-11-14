Pod::Spec.new do |s|
  s.summary          = 'Dummy/Placeholder needed to build for iOS.  Plugin itself is not supported on iOS, so make sure to guard calls with Platform.isAndroid.'
  s.name             = 'flutter_foreground_service'
  s.version          = '0.0.1'
  s.author           = { 'Michael Cheung' => 'michael.cheung@thebus.org' }
  s.license          = { :file => '../LICENSE' }
  s.homepage         = 'https://github.com/michael-cheung-thebus/flutter_foreground_service'
  s.source           = { :path => '.' }
  s.dependency 'Flutter'
end

