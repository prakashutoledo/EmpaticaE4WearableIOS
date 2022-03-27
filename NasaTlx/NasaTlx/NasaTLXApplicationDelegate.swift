//
//  NasaTlxAppDelegate.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 6/3/21.
//

import Foundation
import SwiftUI

class NasaTLXApplicationDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        print("Application Launched")
        EmpaticaAPI.initialize()
        return true;
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("Application Entered Background")
        EmpaticaAPI.prepareForBackground()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("Application Active")
        EmpaticaAPI.prepareForResume()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
}
