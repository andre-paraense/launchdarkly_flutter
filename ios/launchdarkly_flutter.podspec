#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint launchdarkly_flutter.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'launchdarkly_flutter'
  s.version          = '1.0.2'
  s.summary          = 'A Flutter LaunchDarkly SDK.'
  s.description      = <<-DESC
This is an unofficial LaunchDarkly SDK for Flutter, for anyone willing to use LaunchDarkly in a Flutter app.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Oakam Ltd' => 'andre.paraense@oakam.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'LaunchDarkly', '~> 5.4'
  s.platform = :ios, '10.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
