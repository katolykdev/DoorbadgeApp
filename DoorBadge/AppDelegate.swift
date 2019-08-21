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

