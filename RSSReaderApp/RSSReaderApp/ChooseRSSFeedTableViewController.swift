//
//  ChooseRSSFeedTableViewController.swift
//  RSSReaderApp
//
//  Created by Hisashi Ishihara on 2021/02/10.
//

import UIKit

class ChooseRSSFeedTableViewController: UITableViewController {

    /// ニュース種別
    private var newsType: NewsType = .main

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // RSSフィード　仮登録
        UserDefaults.standard.set("andyoutoobrutus@yahoo.com", forKey: "userName")
        UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NewsType.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        switch indexPath.row {
        case 0:
            newsType = .main
            break
        case 1:
            newsType = .grobal
            break
        case 2:
            newsType = .entertainment
            break
        case 3:
            newsType = .informationTechnology
            break
        case 4:
            newsType = .local
            break
        case 5:
            newsType = .domestic
            break
        case 6:
            newsType = .economics
            break
        case 7:
            newsType = .sports
            break
        case 8:
            newsType = .science
            break
        default:
            break
        }
        cell.textLabel?.text = newsType.itemInfo
        // チェックマークを入れる
        // データベース
        let databaseManager = DatabaseManager()
        if databaseManager.check(RSSFeed: newsType.urlStr) {
            cell.accessoryType = .none
        }else {
            cell.accessoryType = .checkmark
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            newsType = .main
            break
        case 1:
            newsType = .grobal
            break
        case 2:
            newsType = .entertainment
            break
        case 3:
            newsType = .informationTechnology
            break
        case 4:
            newsType = .local
            break
        case 5:
            newsType = .domestic
            break
        case 6:
            newsType = .economics
            break
        case 7:
            newsType = .sports
            break
        case 8:
            newsType = .science
            break
        default:
            break
        }
        // データベース
        let databaseManager = DatabaseManager()
        if databaseManager.check(RSSFeed: newsType.urlStr) {
            // フィードを登録
            databaseManager.add(RSSFeed: newsType.urlStr, RSSFeedTitle: newsType.itemInfo)
        }else {
            // フィードを削除
            databaseManager.delete(RSSFeed: newsType.urlStr)
        }
        // フィードを登録していればDoneボタンを有効とする
        if databaseManager.getRSSFeeds().count > 0 {
            doneButton.isEnabled = true
        }else {
            doneButton.isEnabled = false
        }
        tableView.reloadData()
    }
    
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBAction func doneButtonTapped(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
}
