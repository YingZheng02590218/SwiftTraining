//
//  Database.swift
//  RSSReaderApp
//
//  Created by Hisashi Ishihara on 2021/02/07.
//

import Foundation
import RealmSwift

class Database: RObject {
    
    @objc dynamic var User = ""
    @objc dynamic var RSSFeed = ""
    @objc dynamic var RSSFeedTitle = ""
    @objc dynamic var RSSFavorite = false

}

class DatabaseArticle: RObject {
    
    @objc dynamic var User = ""
    @objc dynamic var ArticleRSSFeed = ""
    @objc dynamic var ArticleLink = ""
    @objc dynamic var ArticlePubDate = ""
    @objc dynamic var ArticleTitle = ""
    @objc dynamic var ArticleHasRead = false
    @objc dynamic var ArticleIsFavorite = false

}

class RObject: Object {
    @objc dynamic var number: Int = 0
    // データを保存
    func save() -> Int {
        let realm = try! Realm()
        if realm.isInWriteTransaction {
            if self.number == 0 { self.number = self.createNewId() }
            realm.add(self, update: .error)
        } else {
            try! realm.write {
                if self.number == 0 { self.number = self.createNewId() }
                realm.add(self, update: .error)
            }
        }
        return number
    }
    // 新しいIDを採番
    private func createNewId() -> Int {
        let realm = try! Realm()
        return (realm.objects(type(of: self).self).sorted(byKeyPath: "number", ascending: false).first?.number ?? 0) + 1
    }
    // プライマリーキーの設定
    override static func primaryKey() -> String? {
        return "number"
    }
}
