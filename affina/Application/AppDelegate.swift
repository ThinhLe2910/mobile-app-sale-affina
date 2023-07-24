//
//  AppDelegate.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 11/05/2022.
//

import UIKit
import FirebaseCore
import FirebaseMessaging

import PayooPayment

import IntelinLoggerKit


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var crashedLastTime = true
    
    // lock Orientation
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask(rawValue: UIInterfaceOrientationMask.portrait.rawValue)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()

        Messaging.messaging().delegate = self
        configApplePush(application)

        setMainViewController()

        crashedLastTime = UserDefaults.standard.bool(forKey: Key.crashedNotificationKey.rawValue)
        if crashedLastTime == true {
            let vc = CrashViewController()
            window?.rootViewController?.navigationController?.pushViewController(vc, animated: true)

            UserDefaults.standard.set(true, forKey: "hideTabBar")
            IntelinLogger.sharedInstance.checkForErrorLog(errorTitle: "SORYY".localize(), errorDesc: "INCIDENT_HAS_OCCURRED".localize(), completion: {
                vc.navigationController?.popViewController(animated: true)
                UserDefaults.standard.set(false, forKey: "hideTabBar")
                NotificationCenter.default.post(name: Notification.Name(rawValue: "hideTabBar"), object: self)
                if UIApplication.topViewController(controller: self.window?.rootViewController) is InputPinCodeViewController {
                    (UIApplication.topViewController(controller: self.window?.rootViewController) as? InputPinCodeViewController)?.pinTextField.becomeFirstResponder()
                }
            })

            NotificationCenter.default.post(name: Notification.Name(rawValue: Key.crashedNotificationKey.rawValue), object: self)

        } else {
//            crashedLastTime = true
            UserDefaults.standard.set(true, forKey: Key.crashedNotificationKey.rawValue)
        }
        if UserDefaults.standard.array(forKey: Key.shownCongratsHome.rawValue) == nil {
            UserDefaults.standard.set([String](), forKey: Key.shownCongratsHome.rawValue)
        }
//        UserDefaults.standard.set([String](), forKey: Key.readPopup.rawValue)
        return true
        
    }

    private func configApplePush(_ application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { success, error in
            if let error = error {
                Logger.Logs(message: error.localizedDescription)
                return
            }
        }
        Messaging.messaging().token { token, error in
            guard let token = token, error == nil else {
                Logger.Logs(message: error!.localizedDescription)
                return
            }

            Logger.Logs(message: "Token (Pushkey): \(token)")

            UserDefaults.standard.set(token, forKey: Key.pushKey.rawValue)

        }
        
        Messaging.messaging().subscribe(toTopic: "all") { error in
            if let error = error {
                Logger.Logs(message: error.localizedDescription)
            }
        }
        application.registerForRemoteNotifications()

//        if let token = Messaging.messaging().fcmToken {
//            print("FCM token: \(token)")
//            AppSession.shared.setFirebaseToken(token)
//        }
    }

    func setMainViewController() {
        window = UIWindow(frame: UIScreen.main.bounds)

        if let window = window {
            prepareLayout()
            let nav = UINavigationController()
            var mainView = UIViewController()

            window.backgroundColor = .white

            if UserDefaults.standard.bool(forKey: Key.notFirstTimeLogin.rawValue) {
                mainView = InputPinCodeViewController()
            }
            else {
                mainView = BaseTabBarViewController()
            }
            if !UserDefaults.standard.bool(forKey: Key.firstInstalled.rawValue) {
                mainView = OnboardingViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
            }
            nav.viewControllers = [mainView]
            nav.isNavigationBarHidden = true
            nav.navigationBar.setBackgroundImage(UIImage(), for: .default)
            nav.navigationBar.shadowImage = UIImage()
            nav.navigationBar.isTranslucent = true
            nav.view.backgroundColor = .clear
            window.rootViewController = nav
            window.makeKeyAndVisible()
        }
    }

    func prepareLayout() {
        let window = UIApplication.shared.windows[0]
        if #available(iOS 11.0, *) {
            let topPadding: CGFloat = window.safeAreaInsets.top == 0.0 ? 20 : window.safeAreaInsets.top
            let leftPadding: CGFloat = window.safeAreaInsets.left
            let bottomPadding: CGFloat = window.safeAreaInsets.bottom
            let rightPadding: CGFloat = window.safeAreaInsets.right
            UIConstants.Layout.setDefaultLayout(top: topPadding, left: leftPadding, bottom: bottomPadding, right: rightPadding)
        }
        else {
            UIConstants.Layout.setDefaultLayout(top: 20, left: 0, bottom: 0, right: 0)
        }
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return false
    }

    func applicationWillResignActive(_ application: UIApplication) { }

    func applicationDidEnterBackground(_ application: UIApplication) {
        UIConstants.isFromBackground = true
        crashedLastTime = false
        UserDefaults.standard.set(false, forKey: "hideTabBar")
        UserDefaults.standard.set(crashedLastTime, forKey: Key.crashedNotificationKey.rawValue)
    }

    func applicationWillEnterForeground(_ application: UIApplication) { }

    func applicationDidBecomeActive(_ application: UIApplication) {
        crashedLastTime = true
        UserDefaults.standard.set(crashedLastTime, forKey: Key.crashedNotificationKey.rawValue)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        crashedLastTime = false
        UserDefaults.standard.set(false, forKey: "hideTabBar")
        UserDefaults.standard.set(crashedLastTime, forKey: Key.crashedNotificationKey.rawValue)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return PaymentApplicationDelegate.shared.application(app, open: url, options: options)
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken

    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Logger.Logs(event: .error, message: "Failed to register with Firebase")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Logger.Logs(message: "Will gets called when app received remote notification")
        guard let _ = userInfo["aps"] as? [String: AnyObject] else {
            completionHandler(.failed)
            return
        }
        completionHandler(.newData)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        Logger.Logs(message: "Will gets called when app is in foreground and we want to show banner")
        completionHandler([.alert, .sound, .badge])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Logger.Logs(message: "Will gets called when user tap on notification")
        let userInfo = response.notification.request.content.userInfo
//        if let messageID = userInfo[gcmMessageIDKey] {
//                print("Message ID: \(messageID)")
//            }

        // Print full message.
        Logger.Logs(message: userInfo)
        if let _ = userInfo["aps"] as? [String: AnyObject],
           let id = userInfo["id"] as? String,
           let type = userInfo["type"] as? String
        {
            
            Logger.Logs(message: type)
            if !UIConstants.isLoggedIn {
                var vc: UIViewController = BaseViewController()

                if UserDefaults.standard.bool(forKey: Key.notFirstTimeLogin.rawValue) {
                    vc = InputPinCodeViewController()
                    (vc as? InputPinCodeViewController)?.loginCallback = {
                        let notiVC = NotificationDetailViewController()
                        if type == "EVENT" {
                            notiVC.eventId = id
                        } else {
                            notiVC.notificationId = id
                        }
                        UIApplication.topViewController()?.navigationController?.pushViewController(notiVC, animated: true)
                    }
                }
                else {
                    AppStateManager.shared.isOpeningNotificationDetail = true
                    vc = NotificationDetailViewController()
                    if type == "EVENT" {
                        (vc as? NotificationDetailViewController)?.eventId = id
                    } else {
                        (vc as? NotificationDetailViewController)?.notificationId = id
                    }
                }

                let nav = UINavigationController()

                nav.viewControllers = [vc]
                nav.isNavigationBarHidden = true
                nav.navigationBar.setBackgroundImage(UIImage(), for: .default)
                nav.navigationBar.shadowImage = UIImage()
                nav.navigationBar.isTranslucent = true
                nav.view.backgroundColor = .clear
                window?.rootViewController = nav
                window?.makeKeyAndVisible()
            }
            else {
                let vc = NotificationDetailViewController()
                if type == "EVENT" {
                    vc.eventId = id
                } else {
                    vc.notificationId = id
                }
                UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
            }
        }


        completionHandler()
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else {
            return
        }
        Logger.Logs(message: "Firebase registration token: \(String(describing: fcmToken))")
        UserDefaults.standard.set(fcmToken, forKey: Key.pushKey.rawValue)
        let tokenDict = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: tokenDict)
    }
}

extension AppDelegate: MessagingDelegate {

}
