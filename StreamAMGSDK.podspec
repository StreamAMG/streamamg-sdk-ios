
Pod::Spec.new do |spec|

  spec.name         = "StreamAMGSDK"
  spec.version      = "0.1"
  spec.summary      = "Stream AMG SDK"
  spec.swift_versions = "5"

  spec.description  = <<-DESC
  Core dependency for the Stream AMG SDK. Includes CloudMatrix, StreamPlay, Authentication and AMGPlayKit
                   DESC

  spec.homepage     = "https://github.com/StreamAMG/streamamg-sdk-ios"

  spec.license      = { :type => 'AGPLv3', :text => 'AGPLv3' }

  spec.author       = "StreamAMG"

  spec.platform     = :ios
  spec.ios.deployment_target = '11.0'
    spec.source_files  = "Source/**/*.swift"

  spec.source = { :git => 'https://github.com/StreamAMG/streamamg-sdk-ios.git', :tag => spec.version }

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

spec.subspec 'PlayKit' do |playkit|
playkit.source_files  = "Source/StreamSDKPlayKit/**/*.*"
playkit.dependency 'PlayKit', '3.20.0'
playkit.dependency 'PlayKit_IMA', '1.10.0'
playkit.dependency 'PlayKitProviders', '1.11.0'
playkit.dependency 'google-cast-sdk-no-bluetooth', '4.5.3'
playkit.resource_bundles = { 'AMGPlayKitBundle' => 'Source/Media/*.xcassets'}
end


end
