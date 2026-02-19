//
//  PushySettings.swift
//  Pushy
//
//  Created by Pushy on 10/8/16.
//  Copyright © 2016 Pushy. All rights reserved.
//

import Foundation

public class PushySettings {
    static let pushyApns = "_pushyApns"
    static let pushyToken = "_pushyToken"
    static let apnsToken = "_pushyApnsToken"
    static let pushyTokenAuth = "_pushyTokenAuth"
    static let pushyAppId = "_pushyAppId"
    static let pushyEnterpriseApi = "_pushyEnterpriseApi"
    static let pushyProxyEndpoint = "_pushyProxyEndpoint"
    static let pushyInAppBanner = "_pushyInAppBanner"
    static let pushyMethodSwizzling = "_pushyMethodSwizzling"
    static let pushyLocalPushConnectivity = "_pushyLocalPushConnectivity"
    static let pushyApnsConnectivityCheck = "_pushyApnsConnectivityCheck"

    // Cross-reinstall key-value store
    nonisolated(unsafe) static let keychain = Keychain()
    
    class func getString(_ key: String, userDefaultsOnly: Bool = false) -> String? {
        // Fetch value from Keychain
        let keychainValue = keychain[key]
        
        // Fetch value from UserDefaults
        let userDefaultsValue = UserDefaults.standard.string(forKey: key)
        
        // No value in either?
        if (keychainValue == nil && userDefaultsValue == nil) {
            return nil
        }
        
        // No Keychain value but UserDefaults has one?
        if (keychainValue == nil && userDefaultsValue != nil) {
            // Synchronize it to Keychain for improved persistence
            keychain[key] = userDefaultsValue
            
            // Return it
            return userDefaultsValue
        }
        
        // No UserDefaults value but Keychain has one?
        if (userDefaultsValue == nil && keychainValue != nil && !userDefaultsOnly) {
            // Synchronize it to UserDefaults for improved persistence
            UserDefaults.standard.set(keychainValue, forKey: key)
            
            // Return it
            return keychainValue
        }
        
        // Value exists in both of them, return UserDefaults
        return userDefaultsValue
    }
    
    class func setString(_ key: String, _ value: String?) {
        // Store it in UserDefaults
        UserDefaults.standard.set(value, forKey: key)
        
        // Save it in Keychain for improved persistence
        keychain[key] = value
    }
    
    class func getBoolean(_ key: String, _ defaultValue: Bool) -> Bool {
        // Support for default value
        if (UserDefaults.standard.object(forKey: key) == nil) {
            return defaultValue
        }
        
        // Fetch value from UserDefaults
        return UserDefaults.standard.bool(forKey: key)
    }
    
    class func setBoolean(_ key: String, _ value: Bool?) {
        // Store value in UserDefaults
        UserDefaults.standard.set(value, forKey: key)
    }
}
