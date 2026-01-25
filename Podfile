# Uncomment the next line to define a global platform for your project
platform :ios, '16.0'

target 'testv1' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Firebase
  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'
  pod 'FirebaseMessaging'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
    end
  end
end
