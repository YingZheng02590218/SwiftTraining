//
//  AppDelegate.swift
//  RSSReaderApp
//
//  Created by Hisashi Ishihara on 2021/01/25.
//

import UIKit
import LineSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // LINE
        // アプリの起動直後に、LoginManager.setupメソッドを呼び出す
        // https://developers.line.biz/ja/docs/ios-sdk/swift/integrate-line-login/
        // setupメソッドを呼び出した後で他のメソッドを呼び出したりすること
        LoginManager.shared.setup(channelID: "1655619021", universalLinkURL: nil)
        
        return true
    }
    // LINE
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return LoginManager.shared.application(app, open: url)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

