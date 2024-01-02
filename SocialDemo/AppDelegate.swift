//
//  AppDelegate.swift
//  SocialDemo
//
//  Created by STL on 01/01/2024.
//

import UIKit
import GoogleSignIn
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //        GIDSignIn.sharedInstance.clientID = "515646462947-gaasfnrmjf0mb4q1cf29tiq0m02cfcpe.apps.googleusercontent.com"
        
        
        //Client ID : 515646462947-gaasfnrmjf0mb4q1cf29tiq0m02cfcpe.apps.googleusercontent.com
        //        iOS URL scheme : com.googleusercontent.apps.515646462947-gaasfnrmjf0mb4q1cf29tiq0m02cfcpe
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
                // signed-out state.
            } else {
                // signed-in state.
            }
        }
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var handled: Bool
        
        handled = GIDSignIn.sharedInstance.handle(url)
        if handled {
            return true
        }
        
        // If not handled by this app, return false.
        return false
    }
    
    var window: UIWindow?
        
        lazy var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "CDModal")
            container.loadPersistentStores(completionHandler: { (_, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }()
    
}

