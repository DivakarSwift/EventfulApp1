//
//  AppDelegate.swift
//  Eventful
//
//  Created by Shawn Miller on 7/24/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import Firebase
import Fabric
import Crashlytics
import UserNotifications
import NotificationBannerSwift
import GooglePlaces


typealias FIRUser = FirebaseAuth.User

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    var window: UIWindow?
    var pushNotificationsPermission = true
    var strDeviceToken = ""
    var hasNotification = false
    var appRef : UIApplication!
    var notifBanner = NotifBannerView()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        self.appRef = application
        //1 Configure app for firebase
        FirebaseApp.configure()
        //2
        // Configure messaging
        Messaging.messaging().delegate = self
        //configure google places api
        GMSPlacesClient.provideAPIKey("AIzaSyD-IAnUrSttIChacXhY_f_Sa2OA-d6AueE")

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.backgroundColor = UIColor.white
        configureInitialRootViewController(for: window)
            // 3
       // Will make the navigation bar white
//       UINavigationBar.appearance().backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
       // Will make the tab bar white
        UITabBar.appearance().backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        UITabBar.appearance().tintColor = .black


        // 4
        // here so firebase will work
        // Override point for customization after application launch.
        //5
        
        // Get Device Token
        self.registerForPushNotifications()
        
        //6
        // Handle push when app invoked from notification
        if launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] != nil {
            let dict : [String:Any] = launchOptions![UIApplicationLaunchOptionsKey.remoteNotification] as! [String:Any]
            print(dict)
            self.hasNotification = true
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
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    

}



extension AppDelegate {
    func configureInitialRootViewController(for window: UIWindow?) {
       // print("Look for current user here")
       // print(Auth.auth().currentUser ?? "")
        let defaults = UserDefaults.standard
        var initialViewController: UIViewController
       // print(Auth.auth().currentUser ?? "")
        if Auth.auth().currentUser != nil,
            let userData = defaults.object(forKey: "currentUser") as? Data,
            let user = NSKeyedUnarchiver.unarchiveObject(with: userData) as? User {
            
            User.setCurrent(user, writeToUserDefaults: true)
           // print("root view controller set to home view controller")
            initialViewController = HomeViewController()
            
        } else {
           // print("root view controller set to login view controller")
            initialViewController = LoginViewController()
        }
        window?.rootViewController = initialViewController
        window?.makeKeyAndVisible()
    }
}

extension AppDelegate{
    //MARK: Push Registeration
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            
            guard granted else {
                self.pushNotificationsPermission = false
                return
            }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async(execute: {
                UIApplication.shared.registerForRemoteNotifications()
            })
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        pushNotificationsPermission = true
        
        Messaging.messaging().apnsToken = deviceToken
        
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
        self.strDeviceToken = "123456789"
        pushNotificationsPermission = false
    }
    
    // listen for user notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
//        _ = userInfo["content"] as! String
        notifBanner.userInfoForNotif = userInfo

        if application.applicationState == .active{
            let banner = NotificationBanner(customView: notifBanner)
            banner.bannerHeight = 40
            banner.show()
            self.hasNotification = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didReceivePush"), object: nil, userInfo: nil)
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        self.strDeviceToken = fcmToken
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print(messaging)
    }
    
}

extension UIApplication {
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}





