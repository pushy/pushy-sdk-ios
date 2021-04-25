Pod::Spec.new do |s|
s.name              = 'Pushy'
s.version           = '1.0.32' # Also update sdkVersionCode in PushyConfig.swift
s.summary           = 'The official Pushy SDK for native iOS apps.'
s.description       = 'Pushy is the most reliable push notification gateway, perfect for real-time, mission-critical applications.'
s.homepage          = 'https://pushy.me/'

s.author            = { 'Pushy' => 'contact@pushy.me' }
s.license           = { :type => 'Apache-2.0', :file => 'LICENSE' }

s.platform          = :ios
s.source            = { :git => 'https://github.com/pushy-me/pushy-sdk-ios.git', :tag => s.version }
s.source_files      = 'PushySDK/*.swift', 'PushySDK/SwiftSocket/*.{h,c,swift}'

s.swift_version         = '5.0'
s.ios.deployment_target = '8.0'
end
