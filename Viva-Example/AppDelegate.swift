//
//  AppDelegate.swift
//  Viva-Example
//
//  Created by Txai Wieser on 18/10/17.
//

import UIKit
import ARKit
import Viva

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        guard ARWorldTrackingConfiguration.isSupported else {
            print("""
            ARKit is not available on this device. For apps that require ARKit
            for core functionality, use the `arkit` key in the key in the
            `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
            the app from installing. (If the app can't be installed, this error
            can't be triggered in a production scenario.)
            In apps where AR is an additive feature, use `isSupported` to
            determine whether to show UI for launching AR experiences.
            """)
            // For details, see https://developer.apple.com/documentation/arkit
            
            let intialViewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SCNViewController")
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window!.makeKeyAndVisible()
            self.window!.rootViewController = intialViewController
            return true
        }
        
        let intialViewController: UIViewController = ARViewController()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.makeKeyAndVisible()
        self.window!.rootViewController = intialViewController
        return true
    }
}

