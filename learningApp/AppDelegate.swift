//
//  AppDelegate.swift
//  learningApp
//
//  Created by chinhang on 3/8/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

import UIKit


let kReachableWithWifi = "Reachable with WIFI"
let kNotReachableWithWifi = "Not Reachable"
let kReachableWithWWAN = "Reachable with WWAN"
var reachability:Reachability?
var reachabbilityStatus = kReachableWithWifi

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var internetReach: Reachability?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // MARK: Linking to the parse databse
    
        Parse.setApplicationId("clqZKCErTst9J8NUK19S9yi1f7xdudbFomxFxl1J", clientKey:"ecXf2kiNojdUObC5A0g5FsV2W8cK5RVZa4HW1jCh")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: kReachabilityChangedNotification, object: nil)
        
        internetReach = Reachability.reachabilityForInternetConnection()
        internetReach?.startNotifier()
        if internetReach != nil{
         
            self.statusChangedWithReachability(internetReach!)
        }
       /*
        if reachabbilityStatus == kNotReachableWithWifi{
            var addStatus = UILabel()
            addStatus.frame = CGRectMake(0, 64, 1000, 20)
            addStatus.backgroundColor = UIColorFromRGB(0xD83A31)
            addStatus.text = "No Internet Connection"
            addStatus.textColor = UIColorFromRGB(0xFFFFFF)
            addStatus.font = UIFont(name: "SanFranciscoDisplay-Medium", size: 15)
            
        }
        
        else if reachabbilityStatus == kReachableWithWifi{
            var addStatus = UILabel()
            addStatus.alpha = 1
            addStatus.frame = CGRectMake(0, 64, 1000, 50)
            addStatus.text = "Connected to Internet"
            addStatus.backgroundColor = UIColorFromRGB(0x69D2E7)
            addStatus.textAlignment = NSTextAlignment.Center
            addStatus.textColor = UIColorFromRGB(0xFFFFFF)
            addStatus.font = UIFont(name: "SanFranciscoDisplay-Medium", size: 18)
            self.window?.rootViewController?.view.addSubview(addStatus)
            springWithDelay(20, 6, {
            addStatus.alpha = 0
                
            })

        }*/
        /*
        var addStatusBar = UIView()
        addStatusBar.frame = CGRectMake(0, 0, 1000, 20);
        
        addStatusBar.backgroundColor = UIColorFromRGB(0x4FD7CE)
        self.window?.rootViewController?.view .addSubview(addStatusBar)
        */
        self.window?.tintColor = UIColorFromRGB(0x4FD7CE)
        return true
    }

    func reachabilityChanged(notification: NSNotification){
        println("Reachability status changed...")
        reachability = notification.object as? Reachability
        self.statusChangedWithReachability(reachability!)
    }
    
    func statusChangedWithReachability(currentReachabilityStatus: Reachability){
        
        var networkStatus:NetworkStatus = currentReachabilityStatus.currentReachabilityStatus()
        var statusString:String = ""
        
        println("Status Value: \(networkStatus.value)")
        
        if networkStatus.value == ReachableViaWiFi.value{
        println("Network is reachable with Wifi")
            reachabbilityStatus = kReachableWithWifi
        }
        
        else if networkStatus.value == NotReachable.value{
            println("Network not reachable...")
            reachabbilityStatus = kNotReachableWithWifi
        }
        
        else if networkStatus.value == ReachableViaWWAN.value {
        println("Network is reachable with WWAN")
        reachabbilityStatus = kReachableWithWWAN
        }
        
     
        NSNotificationCenter.defaultCenter().postNotificationName("ReachStatusChanged", object: nil)
    
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
    NSNotificationCenter.defaultCenter().removeObserver(self, name: kReachabilityChangedNotification, object: nil)
    }
    



}

