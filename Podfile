# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/Deadknight/dk-specs.git'

target 'Topping' do
  # Comment the next line if you don't want to use dynamic frameworks
  # use_frameworks!
  pod 'ToppingIOSKotlinHelper', '0.6.0'
  use_frameworks! :linkage => :static
  #use_modular_headers!
end

target 'Toppingtest' do
  # Comment the next line if you don't want to use dynamic frameworks
  # use_frameworks!
  pod 'ToppingIOSKotlinHelper', '0.6.0'
  use_frameworks! :linkage => :static
  #use_modular_headers!
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
    end
  end
end
