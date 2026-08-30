source 'https://cdn.cocoapods.org/'

platform :ios, '13.0'

target 'MHAdSDKDemo' do
  use_frameworks! :linkage => :static

  # TopOn SDK
  pod 'TPNiOS','6.5.73'
  #TPN Adx SDK(necessary)
  pod 'TPNMediationAdxSmartdigimktAdapter','6.5.75.2.2'

  # MHGAdSDK xcframework 本地分发
  # pod 'MHGAdSDK', :path => './'
  pod 'MHGAdSDK','1.0.0'

  # MHGAdSDK TopOn 自定义适配器（本地）
  pod 'MHGAdSDK-TopOnAdapter', :path => './'

  pod 'Google-Mobile-Ads-SDK', '~> 13.5.0'
end
