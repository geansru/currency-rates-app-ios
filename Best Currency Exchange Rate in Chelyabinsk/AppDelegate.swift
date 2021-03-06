//
//  AppDelegate.swift
//  Best Currency Exchange Rate in Chelyabinsk
//
//  Created by Dmitriy Roytman on 15.09.15.
//  Copyright (c) 2015 Dmitriy Roytman. All rights reserved.
//

import UIKit
import CoreData
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties
    // Controllers
    var firstViewController: FirstViewController!
    var mapViewController: MapViewController!
    var window: UIWindow?
    var banks: [Bank] = [Bank]() {
        didSet {
            firstViewController?.banks = banks
            firstViewController?.sortBanks()
//            firstViewController?.tableView.reloadData()
            firstViewController?.task = taskBanks
            mapViewController?.banks = banks
        }
    }
    var taskBanks: NSURLSessionDataTask!
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let tabBarController = window!.rootViewController as! UITabBarController
        
        if let tabBarViewControllers = tabBarController.viewControllers {
            let firstNavController = tabBarViewControllers[0] as! UINavigationController
            if let firstViewController = firstNavController.topViewController as? FirstViewController {
                self.firstViewController = firstViewController
            }
            
            let mapNavController = tabBarViewControllers[2] as! UINavigationController
            if let mapViewController = firstNavController.topViewController as? MapViewController {
                self.mapViewController = mapViewController
            }
        }
        let completion: ([AnyObject])->() = { results in
            if let banks = results as? [Bank] {
                self.banks = banks
            }
        }
        taskBanks = Downloader.load(completion)
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

