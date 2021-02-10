//
//  FilterTableViewController.swift
//  RSSReaderApp
//
//  Created by Hisashi Ishihara on 2021/02/03.
//

import UIKit

class FilterTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "フィルタ・ソート機能"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        case 2:
            // RSSフィードを取得　データベース
            let databaseManager = DatabaseManager()
            let objects = databaseManager.getRSSFeeds()
            return objects.count
        case 3: return 2
        default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "未読"
        case 1: return "お気に入り"
        case 2: return "任意のフィード"
        case 3: return "記事ソート"
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "未読のみ"
            // チェックマークを入れる
            if !FilterRead {
                cell.accessoryType = .none
            }else {
                cell.accessoryType = .checkmark
            }
            return cell
        case 1:
            cell.textLabel?.text = "お気に入りのみ"
            // チェックマークを入れる
            if !FilterFavorite {
                cell.accessoryType = .none
            }else {
                cell.accessoryType = .checkmark
            }
            return cell
        case 2:
            // RSSフィードを取得　データベース
            let databaseManager = DatabaseManager()
            let objects = databaseManager.getRSSFeeds()
            if !(FilterFeed == objects[indexPath.row].RSSFeed) {
                cell.accessoryType = .none
            }else {
                cell.accessoryType = .checkmark
            }
            cell.textLabel?.text = objects[indexPath.row].RSSFeedTitle
            return cell
        case 3:
            if indexPath.row == 0 {
                cell.textLabel?.text = "昇順"
                // チェックマークを入れる
                if SortByLatest {
                    cell.accessoryType = .none
                }else {
                    cell.accessoryType = .checkmark
                }
            }else if indexPath.row == 1 {
                cell.textLabel?.text = "降順"
                // チェックマークを入れる
                if SortByLatest {
                    cell.accessoryType = .checkmark
                }else {
                    cell.accessoryType = .none
                }
            }
            return cell
        default:
            return cell
        }
    }
    // セルが選択された時に呼び出される
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            // チェックマークを入れる
            let cell = tableView.cellForRow(at:indexPath)
            if FilterRead {
                cell?.accessoryType = .none
                FilterRead = false
            }else {
                cell?.accessoryType = .checkmark
                FilterRead = true
            }
            break
        case 1:
            // チェックマークを入れる
            let cell = tableView.cellForRow(at:indexPath)
            if FilterFavorite {
                cell?.accessoryType = .none
                FilterFavorite = false
            }else {
                cell?.accessoryType = .checkmark
                FilterFavorite = true
            }
            break
        case 2:
            // チェックマークを入れる
            // RSSフィードを取得　データベース
            let databaseManager = DatabaseManager()
            let objects = databaseManager.getRSSFeeds()
            if FilterFeed == objects[indexPath.row].RSSFeed {
                FilterFeed = ""
                RSSFeedTitle = "すべてのフィード"
            }else {
                FilterFeed = objects[indexPath.row].RSSFeed
                RSSFeedTitle = objects[indexPath.row].RSSFeedTitle
            }
            tableView.reloadData()
            break
        case 3:
            if indexPath.row == 0 { // 昇順
                SortByLatest = false
            }else if indexPath.row == 1 { // 降順
                SortByLatest = true
            }
            tableView.reloadData()
        default:
            break
        }
    }
    // フィルター
    var RSSFeedTitle = ""
    var FilterFeed = ""
    var FilterRead = false // true:未読のみ
    var FilterFavorite = false // true:お気に入りのみ
    // ソート
    var SortByLatest = false
    @IBAction func doneButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        let navigationController = self.presentingViewController as! UINavigationController
        let presentingViewController = navigationController.viewControllers[0] as! ListTableViewController
        self.dismiss(animated: true, completion: {
            [self, presentingViewController] () -> Void in
            presentingViewController.RSSFeedTitle = RSSFeedTitle
            presentingViewController.FilterFeed = FilterFeed
            presentingViewController.FilterRead = FilterRead
            presentingViewController.FilterFavorite = FilterFavorite
            presentingViewController.SortByLatest = SortByLatest
            presentingViewController.viewWillAppear(true)
        })
    }
    

}
