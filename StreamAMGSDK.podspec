
Pod::Spec.new do |spec|

  spec.name         = "StreamAMGSDK"
  spec.version      = "0.10"
  spec.summary      = "Stream AMG SDK"
  spec.swift_versions = "5"

  spec.description  = <<-DESC
  Core dependency for the Stream AMG SDK. Includes CloudMatrix, StreamPlay, Authentication and AMGPlayKit
                   DESC

  spec.homepage     = "https://github.com/StreamAMG/StreamAMGSDK-iOS"

  spec.license      = { :type => 'AGPLv3', :text => 'AGPLv3' }

  spec.author       = "StreamAMG"

  spec.platform     = :ios
  spec.ios.deployment_target = '11.0'
  spec.source_files  = "Source/**/*.swift"

  spec.source = { :git => 'https://github.com/StreamAMG/streamamg-sdk-ios-internal', :branch => 'development', :submodules => true}

  spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

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
playkit.dependency 'PlayKit', '3.20.0'
playkit.dependency 'PlayKit_IMA', '1.10.0'
playkit.dependency 'PlayKitProviders', '1.11.0'
playkit.dependency 'PlayKitYoubora', '1.9.0'
playkit.resource_bundles = { 'AMGPlayKitBundle' => 'Source/Media/*.*'}
end

spec.subspec 'PlayKit2Go' do |playkit2go|
playkit2go.source_files  = "Source/StreamSDKPlayKit2Go/**/*.*"
playkit2go.dependency "StreamAMGSDK/PlayKit"
playkit2go.dependency 'DownloadToGo', '3.15.0'
end

end
