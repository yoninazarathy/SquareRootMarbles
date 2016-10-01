//
//  AppDelegate.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 2/09/2016.
//  Copyright © 2016 oneonepsilon. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //QQQQ bPlistManager.sharedInstance.startPlistManager()
        
        
        GameAnalytics.configureBuild(buildStringForGA)
        GameAnalytics.initialize(withGameKey: "1e75a275b87ca5a01120b4b550842b78", gameSecret: "6859815157d477b16031b3b91bb0d28e96b9bdc4")
                
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        SKTAudio.sharedInstance().pauseBackgroundMusic()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        let defaults = UserDefaults.standard
        defaults.synchronize()
        SKTAudio.sharedInstance().pauseBackgroundMusic()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        SKTAudio.sharedInstance().onEnteringForegroud()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        SKTAudio.sharedInstance().onEnteringForegroud()

    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        let defaults = UserDefaults.standard
        defaults.synchronize()
    }


}

