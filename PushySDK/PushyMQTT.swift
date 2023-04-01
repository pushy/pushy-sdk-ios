//
//  PushyMQTT.swift
//  PushySDK
//
//  Created by Pushy on 2/9/22.
//  Copyright © 2022 Pushy. All rights reserved.
//

#if canImport(CocoaMQTT)

import CocoaMQTT
import NetworkExtension

@available(iOS 14.0, *)
open class PushyMQTT: NEAppPushProvider, CocoaMQTTDelegate {
    // MQTT connection handle
    private var mqtt: CocoaMQTT?
    
    public override init() {
        super.init()
        
        // Log network extension init() called
        NSLog("PushyMQTT: init()")
    }

    public override func start(completionHandler: @escaping (Error?) -> Void) {
        // Log network extension start() called
        NSLog("PushyMQTT: start()")
        
        // Extract NEAppPushManager provider config params
        guard let host = providerConfiguration?["host"] as? String, let port = providerConfiguration?["port"] as? UInt16, let keepAlive = providerConfiguration?["keepAlive"] as? UInt16, let token = providerConfiguration?["token"] as? String, let auth = providerConfiguration?["auth"] as? String else {
            // Call completion handler and print error to log
            completionHandler(nil)
            return NSLog("PushyMQTT: Failed to start, the provider configuration is missing a required parameter.")
        }
        
        // Create new CocoaMQTT long-lived instance
        mqtt = CocoaMQTT(clientID: token, host: host, port: port)
        
        // Set device token & auth key as username and password
        mqtt?.username = token
        mqtt?.password = auth
        
        // TLS support
        mqtt?.enableSSL = true
        
        // Set keep alive (in seconds)
        mqtt?.keepAlive = keepAlive
        
        // Hook into MQTT lifecycle methods
        mqtt?.delegate = self
        
        // Auto reconnect on disconnect
        mqtt?.autoReconnect = true
        
        // Try establishing connection
        _ = mqtt?.connect()
        
        // Done starting extension
        completionHandler(nil)
    }
    
    public override func stop(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Log network extension stop() called
        NSLog("PushyMQTT: stop()")
        
        // If connected, disconnect forcibly
        if (mqtt?.connState == CocoaMQTTConnState.connected) {
            mqtt?.disconnect()
            mqtt = nil
        }
        
        // Done stopping extension
        completionHandler()
    }
    
    public override func handleTimerEvent() {
        // Log network extension handleTimerEvent() called
        NSLog("PushyMQTT: handleTimerEvent()")
        
        // Try to send keep alive
        mqtt?.ping()
    }

    public func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        // Log successful connection
        NSLog("PushyMQTT: Connected successfully")
    }
    
    public func mqttDidPing(_ mqtt: CocoaMQTT) {
        // Log keep alive packet sent
        NSLog("PushyMQTT: Sending keep alive")
    }
    
    public func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        // Log connection lost
        NSLog("PushyMQTT: Connection lost")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        // Log incoming notification received
        NSLog("PushyMQTT: Received notification")
        
        // Convert payload data to JSON
        if let data = message.string?.data(using: .utf8) {
            do {
                // Decode UTF-8 string into JSON
                let payload = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                
                // Dispatch local notification & invoke notification handler if app running
                displayLocalNotification(payload)
            }
            catch {
                // Print JSON parse error to console
                NSLog("PushyMQTT: Error decoding payload into JSON: " + error.localizedDescription)
            }
        }
    }
    
    func displayLocalNotification(_ payload: [AnyHashable : Any]) {
        // Create a content object
        let content = UNMutableNotificationContent()
        
        // Set title if passed in
        if let title = payload["title"] as? String {
            content.title = title
        }
        
        // Set message if passed in
        if let message = payload["message"] as? String {
            content.body = message
        }
        
        // Set badge if passed in
        if let badge = payload["badge"] as? Int {
            content.badge = NSNumber(value: badge)
        }
        
        // Set default sound
        content.sound = .default
        
        // Pass payload in user info
        content.userInfo = payload
        
        // Create a request to display a local notification
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        // Display the notification
        UNUserNotificationCenter.current().add(request) { error in
            // Log errors to console
            if let error = error {
                NSLog("PushyMQTT: Error posting local notification: \(error)")
            }
        }
    }
    
    // Configure an NEAppPushManager to enable Local Push Connectivity for the specified Wi-Fi SSIDs
    public static func setLocalPushConnectivityConfig(endpoint: String?, port: NSNumber?, keepAlive: NSNumber?, ssids: [String]?) {
        // Ensure device is registered and load token & auth
        guard let pushyToken = PushySettings.getString(PushySettings.pushyToken), let pushyTokenAuth = PushySettings.getString(PushySettings.pushyTokenAuth) else {
            return print("Configuring Local Push Connectivity failed: The device is not registered for notifications.")
        }
            
        // Load all existing push managers from preferences
        NEAppPushManager.loadAllFromPreferences { managers, error in
            // Failed?
            if let error = error {
                return print("Failed to load all NEAppPushManagers from preferences: \(error)")
            }
            
            // Are we passing in nil values to disable this feature?
            if (endpoint == nil || port == nil || keepAlive == nil || ssids == nil) {
                // Local Push Connectivity has been disabled
                PushySettings.setBoolean(PushySettings.pushyLocalPushConnectivity, false)
                
                // Traverse all managers & remove individually
                for manager in managers! {
                    manager.removeFromPreferences(completionHandler: {(Result) in})
                }
                
                // Stop execution
                return
            }
            
            // Only need a single push manager instance
            var pushManager: NEAppPushManager
            
            // Reuse existing manager if already defined
            if (managers?.first != nil) {
                pushManager = managers!.first!
            }
            else {
                // First time, create a new one
                pushManager = NEAppPushManager()
            }
            
            // Set description & bundle identifier
            pushManager.localizedDescription = Bundle.main.bundleIdentifier! + ".PushProvider"
            pushManager.providerBundleIdentifier = Bundle.main.bundleIdentifier! + ".PushProvider"
            
            // Enable push manager
            pushManager.isEnabled = true
            
            // Pass data to network extension
            pushManager.providerConfiguration = [
                "host": endpoint!,
                "port": port!,
                "token": pushyToken,
                "auth": pushyTokenAuth,
                "keepAlive": keepAlive!,
                "lastUpdated": NSDate().timeIntervalSince1970
            ]
            
            // Set matching SSIDs to activate under
            pushManager.matchSSIDs = ssids!
            
            // Save push manager config
            pushManager.saveToPreferences(completionHandler: { error in
                // Print error to console
                if let error = error {
                    return print("Error saving NEAppPushManager:  \(error)")
                }
                
                // Local Push Connectivity has been enabled
                PushySettings.setBoolean(PushySettings.pushyLocalPushConnectivity, true)
                
                // Print active status
                print("Successfully configured Local Push Connectivity")
                
                // Wait 10 seconds and print NEAppPushManager status
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    print("NEAppPushManager.isActive: \(pushManager.isActive)")
                }
            })
        }
    }
    
    // Unused callbacks
    public func mqttDidReceivePong(_ mqtt: CocoaMQTT) {}
    public func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {}
    public func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {}
    public func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {}
    public func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {}
}

#endif
