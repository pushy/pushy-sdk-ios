//
//  AppDelegate.swift
//  Demo
//
//  Created by Pushy on 7/2/17.
//  Copyright © 2017 Pushy. All rights reserved.
//

import UIKit
import PushySDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize Pushy SDK
        let pushy = Pushy(UIApplication.shared)
        
        // Register the device for push notifications
        pushy.register({ (error, deviceToken) in
            // Handle registration errors
            if error != nil {
                return print ("Registration failed: \(error!.localizedDescription)")
            }
            
            // Print device token to console
            print("Pushy device token: \(deviceToken)")
            
            // Persist the device token locally and send it to your backend later
            UserDefaults.standard.set(deviceToken, forKey: "pushyToken")
        })
        
        // Handle push notifications
        pushy.setNotificationHandler({ (data, completionHandler) in
            // Print notification payload data
            print("Received notification: \(data)")
            
            // Fallback message containing data payload
            var message = "\(data)"
            
            // Attempt to extract "message" key from APNs payload
            if let aps = data["aps"] as? [AnyHashable : Any] {
                if let payloadMessage = aps["alert"] as? String {
                    message = payloadMessage
                }
            }
            
            // Display the notification as an alert
            let alert = UIAlertController(title: "Incoming Notification", message: message, preferredStyle: UIAlertController.Style.alert)
            
            // Add an action button
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // Show the alert dialog
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
            
            // Reset iOS badge number
            UIApplication.shared.applicationIconBadgeNumber = 0
            
            // Call this completion handler when you finish processing
            // the notification (after fetching background data, if applicable)
            completionHandler(UIBackgroundFetchResult.newData)
        })
        
        // Override point for customization after application launch.
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

