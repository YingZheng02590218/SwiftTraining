//
//  AppDelegate.swift
//  RSSReaderApp
//
//  Created by Hisashi Ishihara on 2021/01/25.
//

import UIKit
import LineSDK
import BackgroundTasks
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // LINE
        // アプリの起動直後に、LoginManager.setupメソッドを呼び出す
        // https://developers.line.biz/ja/docs/ios-sdk/swift/integrate-line-login/
        // setupメソッドを呼び出した後で他のメソッドを呼び出したりすること
        LoginManager.shared.setup(channelID: "1655619021", universalLinkURL: nil)
        // RSS取得間隔　更新通知
        // 第一引数: Info.plistで定義したIdentifierを指定
        // 第二引数: タスクを実行するキューを指定。nilの場合は、デフォルトのバックグラウンドキューが利用されます。
        // 第三引数: 実行する処理
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.SwiftTraining.RSSReaderApp.refresh", using: nil) { task in
            // バックグラウンド処理したい内容 ※後述します
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        // 1日の間、何度も実行したい場合は、1回実行するごとに新たにスケジューリングに登録します
        scheduleAppRefresh()
        // 通知許可の取得
        UNUserNotificationCenter.current().requestAuthorization(
        options: [.alert, .sound, .badge]){
            (granted, _) in
            if granted{
                UNUserNotificationCenter.current().delegate = self
            }
        }
        return true
    }
    // 更新通知 バックグラウンドで通知を受け取った場合
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        let trigger = response.notification.request.trigger

        switch trigger {
        case is UNPushNotificationTrigger:
            print("UNPushNotificationTrigger")
        case is UNTimeIntervalNotificationTrigger:
            print("UNTimeIntervalNotificationTrigger")
        case is UNCalendarNotificationTrigger:
            print("UNCalendarNotificationTrigger")
        case is UNLocationNotificationTrigger:
            print("UNLocationNotificationTrigger")
        default:
            break
        }
        completionHandler()
    }
    // 更新通知 フォアグラウンドで通知を受け取った時
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // アプリ起動時も通知を行う
        completionHandler([ .badge, .sound, .alert ])
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
    // RSS取得間隔　更新通知
    private func scheduleAppRefresh() {
        // Info.plistで定義したIdentifierを指定
        let request = BGAppRefreshTaskRequest(identifier: "com.SwiftTraining.RSSReaderApp.refresh")
        // 最低で、どの程度の期間を置いてから実行するか指定
        print(UserDefaults.standard.double(forKey: "SyncInterval")) // RSS取得間隔
        request.earliestBeginDate = Date(timeIntervalSinceNow: UserDefaults.standard.double(forKey: "SyncInterval") * 60)
        print(request)
        do {
            // スケジューラーに実行リクエストを登録
            try BGTaskScheduler.shared.submit(request) // シミュレーターではエラー発生するので実機で確認する
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    // RSS取得間隔　更新通知
    private func handleAppRefresh(task: BGAppRefreshTask) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        // 時間内に実行完了しなかった場合は、処理を解放します
        // バックグラウンドで実行する処理は、次回に回しても問題ない処理のはずなので、これでOK
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        // 実行したい処理
        let bGOperation = BGOperation()
        bGOperation.feedDownload()
        // 最後の処理が完了したら、必ず完了したことを伝える必要があります
        task.setTaskCompleted(success: bGOperation.isFinished)
        queue.addOperation(bGOperation)
        let content = UNMutableNotificationContent()
        content.title = "更新通知"
        content.subtitle = "最後の処理が完了"
        content.sound = UNNotificationSound.default
        // 直ぐに通知を表示
        let request = UNNotificationRequest(identifier: "immediately", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        // 処理が終了したら次の処理を登録する
        // 1日の間、何度も実行したい場合は、1回実行するごとに新たにスケジューリングに登録します
        scheduleAppRefresh()
    }
}
// RSS取得間隔　更新通知
class BGOperation: Operation, XMLParserDelegate {
    
    var parser:XMLParser!
    var items = [Item]()
    var item:Item?
    var currentString = ""
    var ArticleRSSFeed = "" // 解析中のXML
    var rSSFeedTitle = "" // 解析中のRSSフィードのタイトル

    func feedDownload() {
        print(#function)
        // RSSフィードを取得　データベース お気に入り
        let databaseManager = DatabaseManager()
        let objects = databaseManager.getFavoriteRSSFeeds()
        // フィードをダウンロード
        for i in 0..<objects.count {
            self.rSSFeedTitle = objects[i].RSSFeedTitle
            startDownload(RSSFeed: objects[i].RSSFeed)
        }
    }
    // XMLの取得・解析
    func startDownload(RSSFeed: String) {
        print(#function)
        self.items = []
        // httpではじまる、安全性の低いURLにアクセスする場合は、App Transport Securityのセキュリティの設定を下げる必要がある。Info.plist
        if let url = URL(string: RSSFeed) {
            self.ArticleRSSFeed = RSSFeed
            if let parser = XMLParser(contentsOf: url) {
                self.parser = parser
                self.parser.delegate = self
                self.parser.parse()
            }
        }
    }
    //解析_要素の開始時
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        print(#function)
        self.currentString = ""
        if elementName == "item" {
            self.item = Item()
        }
    }
    //解析_要素内の値取得
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        print(#function)
        self.currentString += string
    }
    //解析_要素の終了時
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        print(#function)
        switch elementName {
        case "title": self.item?.title = currentString
        case "link": self.item?.link = currentString
        case "pubDate": self.item?.pubDate = currentString
        case "description": self.item?.description = currentString
        case "item":
            self.items.append(self.item!)
            // 記事をデータベースに保存
            let databaseManagerArticle = DatabaseManagerArticle()
            let result = databaseManagerArticle.add(ArticleRSSFeed: self.ArticleRSSFeed, ArticleLink: self.item!.link, ArticlePubDate: self.item!.pubDate, ArticleTitle: self.item!.title)
            // 更新通知
            if result {
                let content = UNMutableNotificationContent()
                content.title = "更新通知"
                content.subtitle = "お気に入りのフィードで記事の更新があった場合通知を表示する。"
                content.body = "\(self.rSSFeedTitle) \(self.item!.title)"
                content.sound = UNNotificationSound.default
                // 直ぐに通知を表示
                let request = UNNotificationRequest(identifier: "immediately", content: content, trigger: nil)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }
        default: break
        }
    }
    //解析_終了時
    func parserDidEndDocument(_ parser: XMLParser) {
        print(#function)
    }
}
