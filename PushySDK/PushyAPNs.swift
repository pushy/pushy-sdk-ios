//
//  PushyAPNs.swift
//  PushySDK
//
//  Created by Pushy on 5/23/20.
//  Copyright © 2020 Pushy. All rights reserved.
//

import Foundation

class PushyAPNs : NSObject {
    // APNs courier hostname (prefixed by number)
    static let apnsCourierHostname = "-courier.push.apple.com"
    
    // APNs courier port number
    static let apnsCourierPort:Int32 = 5223
    
    // APNs courier range (0-50 inclusive)
    static let apnsCourierServerRange = 0..<51
    
    // APNs courier connection timeout
    static let apnsCourierTimeoutSeconds = 10
    
    static public func checkConnectivity(_ callback: @escaping (Error?) -> Void) {
        // Get random courier server as integer
        let randomCourierServer = Int.random(in: apnsCourierServerRange)
        
        // Try to establish TCP connection to APNs on port 5223
        let client = TCPClient(address: String(randomCourierServer) + apnsCourierHostname, port: apnsCourierPort)
        
        // Try connecting with a timeout
        switch client.connect(timeout: apnsCourierTimeoutSeconds) {
        case .success:
            // Close client
            client.close()
            
            // Invoke callback with nil error
            callback(nil)
        case .failure(let error):
            // Close client
            client.close()
            
            // Invoke callback with connection error
            callback(PushyRegistrationException.Error("APNs server *\(apnsCourierHostname) is unreachable on port \(apnsCourierPort) due to lack of Internet connection or restrictive firewall: \(error)"))
        }
    }
}
