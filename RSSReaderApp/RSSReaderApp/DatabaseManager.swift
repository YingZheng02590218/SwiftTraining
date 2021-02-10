//
//  DatabaseManager.swift
//  RSSReaderApp
//
//  Created by Hisashi Ishihara on 2021/02/07.
//

import Foundation
import RealmSwift

class DatabaseManager {
    
    // フィードを登録
    func add(RSSFeed: String, RSSFeedTitle: String) {
        if check(RSSFeed: RSSFeed) {
            let realm = try! Realm()
            try! realm.write {
                let database = Database()
                database.save()
                database.User = UserDefaults.standard.string(forKey: "userName")!
                database.RSSFeed = RSSFeed
                database.RSSFeedTitle = RSSFeedTitle
                database.RSSFavorite = false
                realm.add(database)
            }
        }
    }
    // フィードの重複チェック
    func check(RSSFeed: String) -> Bool {
        let realm = try! Realm()
        let object = realm.objects(Database.self)
            .filter("User LIKE '\(UserDefaults.standard.string(forKey: "userName")!)'")
            .filter("RSSFeed LIKE '\(RSSFeed)'")
        return object.count == 0
    }
    // 登録したフィードを取得 すべて
    func getRSSFeeds() -> Results<Database> {
        let realm = try! Realm()
        let objects = realm.objects(Database.self)
            .filter("User LIKE '\(UserDefaults.standard.string(forKey: "userName")!)'")
        return objects
    }
}

class DatabaseManagerArticle {
    
    // 記事をデータベースに登録する。
    func add(ArticleRSSFeed: String, ArticleLink: String, ArticlePubDate: String, ArticleTitle: String) {
        if check(ArticleLink: ArticleLink) {
            let realm = try! Realm()
            try! realm.write {
                // RSS (ユーザーID、登録するフィード、お気に入り)
                let database = DatabaseArticle()
                database.save()
                database.User = UserDefaults.standard.string(forKey: "userName")!
                database.ArticleRSSFeed = ArticleRSSFeed
                database.ArticleLink = ArticleLink
                database.ArticlePubDate = ArticlePubDate
                database.ArticleTitle = ArticleTitle
                database.ArticleHasRead = false
                database.ArticleIsFavorite = false
                print(database)
                realm.add(database)
            }
        }
    }
    // 記事の重複チェック
    func check(ArticleLink: String) -> Bool {
        let realm = try! Realm()
        let object = realm.objects(DatabaseArticle.self)
            .filter("User LIKE '\(UserDefaults.standard.string(forKey: "userName")!)'")
            .filter("ArticleLink LIKE '\(ArticleLink)'")
        return object.count == 0
    }
    // ダウンロードした記事を取得 すべて
    func getArticle() -> Results<DatabaseArticle> {
        let realm = try! Realm()
        let objects = realm.objects(DatabaseArticle.self)
            .filter("User LIKE '\(UserDefaults.standard.string(forKey: "userName")!)'")
        return objects
    }
    // ダウンロードした記事を取得 フィルター・ソート
    func getArticle(FilterFeed: String, FilterRead: Bool, FilterFavorite: Bool, SortByLatest: Bool) -> Results<DatabaseArticle> {
        let realm = try! Realm()
        var objects = realm.objects(DatabaseArticle.self)
            .filter("User LIKE '\(UserDefaults.standard.string(forKey: "userName")!)'")
        if FilterFeed != "" {
            objects = objects.filter("ArticleRSSFeed LIKE '\(FilterFeed)'")
        }
        if FilterRead { // true:未読のみ
            objects = objects.filter("ArticleHasRead == \(false)")
        }
        if FilterFavorite { // true:お気に入りのみ
            objects = objects.filter("ArticleIsFavorite == \(true)")
        }
        objects = objects.sorted(byKeyPath: "ArticlePubDate", ascending: SortByLatest) // true:降順　新しいものから
        return objects
    }
}
