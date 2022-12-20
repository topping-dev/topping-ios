# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

source 'https://github.com/CocoaPods/Specs.git'

target 'Topping' do
  # Comment the next line if you don't want to use dynamic frameworks
  # use_frameworks!
  use_frameworks! :linkage => :static
  #use_modular_headers!
   

  # Pods for luaios

  pod 'Toaster', '2.3.0'
  pod 'GDataXML-HTML', '~> 1.4.1'
  pod 'ActionSheetPicker-3.0'
  pod 'MBProgressHUD', '~> 1.2.0'

end

target 'Toppingtest' do
  # Comment the next line if you don't want to use dynamic frameworks
  # use_frameworks!
  use_frameworks! :linkage => :static
  #use_modular_headers!
   

  # Pods for luaiostest

  pod 'Toaster', '2.3.0'
  pod 'GDataXML-HTML', '~> 1.4.1'
  pod 'ActionSheetPicker-3.0'
  pod 'MBProgressHUD', '~> 1.2.0'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
    end
  end
end
