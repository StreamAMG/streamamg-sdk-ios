
Pod::Spec.new do |spec|

  spec.name         = "StreamAMGSDK"
  spec.version      = "1.2.3"
  spec.summary      = "Stream AMG SDK"
  spec.swift_versions = "5"

  spec.description  = <<-DESC
  Core dependency for the Stream AMG SDK. Includes CloudMatrix, StreamPlay, Authentication, Purchases, PlayKit and PlayKit2Go
                   DESC

  spec.homepage     = "https://github.com/StreamAMG/streamamg-sdk-ios"

  spec.license      = { :type => 'AGPLv3', :text => 'AGPLv3' }

  spec.author       = "StreamAMG"

  spec.platform     = :ios
  spec.ios.deployment_target = '12.0'
  spec.source_files  = "Source/**/*.swift"

  spec.source = { :git => 'https://github.com/StreamAMG/streamamg-sdk-ios', :branch => 'master', :submodules => true}



  spec.subspec 'Core' do |sdkcore|
  spec.requires_arc = true
  spec.static_framework = true


  sdkcore.source_files  = "Source/StreamSDKCore/**/*.swift"
end

  spec.subspec 'StreamPlay' do |streamplay|
    streamplay.dependency "StreamAMGSDK/Core"
  streamplay.source_files  = "Source/StreamSDKStreamPlay/**/*.*"
end

spec.subspec 'CloudMatrix' do |cloudmatrix|
  cloudmatrix.dependency "StreamAMGSDK/Core"
cloudmatrix.source_files  = "Source/StreamSDKCloudMatrix/**/*.*"
end

spec.subspec 'Authentication' do |auth|
  auth.dependency "StreamAMGSDK/Core"
auth.source_files  = "Source/StreamSDKAuthentication/**/*.*"
end

spec.subspec 'Purchases' do |purchases|
  purchases.dependency "StreamAMGSDK/Core"
  purchases.dependency "StreamAMGSDK/Authentication"
  purchases.source_files  = "Source/StreamSDKPurchases/**/*.*"
end

spec.subspec 'PlayKit' do |playkit|
playkit.source_files  = "Source/StreamSDKPlayKit/**/*.*"
playkit.dependency 'PlayKit', '3.27.0'
playkit.dependency 'PlayKit_IMA', '1.14.0'
playkit.dependency 'PlayKitProviders', '1.18.0'
playkit.dependency 'PlayKitYoubora', '1.15.0'
playkit.resource_bundles = { 'AMGPlayKitBundle' => 'Source/Media/*.*'}
end

spec.subspec 'PlayKit2Go' do |playkit2go|
playkit2go.source_files  = "Source/StreamSDKPlayKit2Go/**/*.*"
playkit2go.dependency "StreamAMGSDK/PlayKit"
playkit2go.dependency 'DownloadToGo', '3.18.0'
end

end
