//
//  AppDelegate.swift
//  Signal Process
//
//  Created by Aleksandr Grin on 8/30/18.
//  Copyright © 2018 AleksandrGrin. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SpriteKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var isGamePaused: Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        //Set up Google ad mob. Done on application launch. 
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        // Here we are initializing our own window and setting up a root view controller. This allows us to skip over using storyboards
        // and control our app directly.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = UINavigationController(rootViewController: OpeningScreenViewController())

        //Here we will handle state restoration by opening a shared instance object or closing it.

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        //We need to pause the other view controllers in the heirarchy because if the game minimizes,
        // even if we pause, they are resumed automatically on returning to the app. We will manually
        // handle pausing and unpausing views
        if isGamePaused == false {
            if (window?.rootViewController as! UINavigationController).visibleViewController is GameViewController {
                for vc in (window?.rootViewController as! UINavigationController).viewControllers {
                    if vc is OpeningScreenViewController {
                        ((vc as! OpeningScreenViewController).view as! SKView).isPaused = true
                    }
                    if vc is MainMenuViewController {
                        ((vc as! MainMenuViewController).view as! SKView).isPaused = true
                    }
                    isGamePaused = true
                }
            }
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        GameData.saveData()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        //We need to pause the other view controllers in the heirarchy because if the game minimizes,
        // even if we pause, they are resumed automatically on returning to the app. We will manually
        // handle pausing and unpausing views
        if isGamePaused == true {
            //Only pause the scenes if we are already in game otherwise the game will be frozen if minimizing
            // from menu
            if (window?.rootViewController as! UINavigationController).visibleViewController is GameViewController {
                for vc in (window?.rootViewController as! UINavigationController).viewControllers {
                    if vc is OpeningScreenViewController {
                        ((vc as! OpeningScreenViewController).view as! SKView).isPaused = true
                    }
                    if vc is MainMenuViewController {
                        ((vc as! MainMenuViewController).view as! SKView).isPaused = true
                    }
                    isGamePaused = false
                }
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

