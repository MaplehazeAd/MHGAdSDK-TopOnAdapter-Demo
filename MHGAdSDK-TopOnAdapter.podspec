Pod::Spec.new do |s|
  s.name         = 'MHGAdSDK-TopOnAdapter'
  s.version      = '1.0.0'
  s.summary      = 'TopOn (TopOn) custom adapter for MHGAdSDK (Global).'
  s.description  = <<-DESC
    MHGAdSDK-TopOnAdapter is a custom network adapter for MHGAdSDK on the TopOn mediation platform.
    Supports Splash, Native, Interstitial, and RewardedVideo ad formats.
  DESC

  s.homepage     = 'https://github.com/MaplehazeAd/MHGAdSDK-TopOnAdapter-Demo'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'MaplehazeAd' => 'rd@maplehaze.cn' }

  s.source       = { :git => 'https://github.com/MaplehazeAd/MHGAdSDK-TopOnAdapter-Demo.git', :tag => s.version.to_s }

  s.platform     = :ios, '13.0'
  s.requires_arc = true
  s.static_framework = true

  s.source_files = 'MHGAdSDK-TopOnAdapter/**/*.{h,m}'
  s.public_header_files = 'MHGAdSDK-TopOnAdapter/**/*.h'

  s.dependency 'MHGAdSDK'
  s.dependency 'TPNiOS', '~> 6.5.73'

  s.frameworks   = 'UIKit', 'Foundation'
end
