//
//  AppDelegate.swift
//  GaldenApp
//
//  Created by 1080 on 25/9/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit
import KeychainSwift
import PKHUD
import GoogleMobileAds
import IQKeyboardManagerSwift
import URLNavigator
import SwiftyStoreKit
import RealmSwift
import Apollo

let navigator = Navigator()
let keychain = KeychainSwift()
var apollo: ApolloClient = {
    let configuration = URLSessionConfiguration.default
    // Add additional headers as needed
    configuration.httpAdditionalHeaders = ["Authorization": "Bearer \(keychain.get("userKey") ?? "")"] // Replace `<token>`
    
    let url = URL(string: "https://hkgalden.org/_")!
    
    return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
}()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let keychain = KeychainSwift()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Override point for customization after application launch.
        
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 3,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 3) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        URLNavigationMap.initialize(navigator: navigator)
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        GADMobileAds.configure(withApplicationID: "ca-app-pub-6919429787140423~6701059788")
        
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }
        
        PKHUD.sharedHUD.dimsBackground = false
        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false
        
        UIApplication.shared.statusBarStyle = .lightContent
        UIApplication.shared.isStatusBarHidden = false
        
        UINavigationBar.appearance().barStyle = .black
        UINavigationBar.appearance().tintColor = UIColor(hexRGB: "#568064")
        UIBarButtonItem.appearance().tintColor = UIColor(hexRGB: "#568064")
        
        UITabBar.appearance().barStyle = .black
        UITabBar.appearance().tintColor = UIColor(hexRGB: "#568064")
        
        let root = LaunchViewController()
        window?.rootViewController = root
        
        //development use(remove before publish)
        keychain.set(true,forKey: "noAd")
        
        if (keychain.getBool("noAd") == nil) {
            keychain.set(false, forKey: "noAd")
        }
        
        if let url = launchOptions?[.url] as? URL {
            let opened = navigator.open(url)
            if !opened {
                navigator.present(url)
            }
        }
        
        window?.makeKeyAndVisible()
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

