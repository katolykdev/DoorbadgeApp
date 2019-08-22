//
//  AppDelegate.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 4/24/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import UIKit
import  Firebase
import FirebaseFirestore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var currentFacility: Facility!
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    override init() {
        super.init()
        FirebaseApp.configure()
        FirebaseApp.configure(name: "CreatingUsersApp", options: FirebaseApp.app()!.options)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Database.database().isPersistenceEnabled = false
        
        // Override point for customization after application launch.
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: "Gill Sans", size: 19)!
           
        ]
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Gill Sans", size: 14)!, ], for: .normal)
        
        if Auth.auth().currentUser != nil {
             let initialViewController = storyboard.instantiateViewController(withIdentifier: "tabBarAdminDoorBadge")

            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        } else {
            // No user is signed in.
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "createAccount")
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        
        return true
    }
}
