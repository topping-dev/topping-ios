#
# Be sure to run `pod lib lint topping.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ToppingIOSKotlinHelper'
  s.version          = '0.6.0'
  s.summary          = 'ToppingEngine is a library helps you create mobile applications using one type of layout code and one type of backend code.'
  s.description      = <<-DESC
ToppingEngine is a library helps you create mobile applications using one type of layout code and one type of backend code.
All you need to know is how Android layout XML works and basic Lua or Kotlin knowledge.
If you know how to write Android code, learning curve of this engine is very simple. Layout is the same of Android. Backend functions are similar to Android functions too.
                       DESC

  s.homepage         = 'https://topping.dev'
  s.license          = { :type => 'Creative Commons License', :file => 'LICENSE' }
  s.author           = { 'topping dev' => 'toppingdev@gmail.com' }
  s.platform         = :ios
  #s.source           = { :http => 'https://github.com/topping-dev/topping-ios/releases/download/v0.5.3/topping.zip' }
  s.source = { :http=> 'https://localhost:8080/ToppingIOSKotlinHelper.zip' }
  #s.social_media_url = 'https://www.twitter.com/toppingdev'
  
  s.vendored_frameworks = 'ToppingIOSKotlinHelper.xcframework'
  s.ios.deployment_target = '13.0'
  s.swift_versions = '4.0'
  
  s.pod_target_xcconfig = {
    #'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'IPHONEOS_DEPLOYMENT_TARGET' => '13.0'
  }
  s.user_target_xcconfig = {
    #'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'IPHONEOS_DEPLOYMENT_TARGET' => '13.0'
  }

end
