//
//  SceneDelegate.swift
//  RSSReaderApp
//
//  Created by Hisashi Ishihara on 2021/01/25.
//

import UIKit
import LineSDK
import BackgroundTasks

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    // LINE
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        _ = LoginManager.shared.application(.shared, open: URLContexts.first?.url)
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        // バックグラウンド起動に移ったときにスケジューリング登録
        scheduleAppRefresh()
    }
    // RSS取得間隔　更新通知
    private func scheduleAppRefresh() {
        // Info.plistで定義したIdentifierを指定
        let request = BGAppRefreshTaskRequest(identifier: "com.SwiftTraining.RSSReaderApp.refresh")
        // 最低で、どの程度の期間を置いてから実行するか指定
        print(UserDefaults.standard.double(forKey: "SyncInterval")) // RSS取得間隔
        request.earliestBeginDate = Date(timeIntervalSinceNow: (UserDefaults.standard.double(forKey: "SyncInterval") * 60) - (9 * 60))
        print(request)
        do {
            // スケジューラーに実行リクエストを登録
            try BGTaskScheduler.shared.submit(request) // シミュレーターではエラー発生するので実機で確認する
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    
}

