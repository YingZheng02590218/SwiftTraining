//
//  SettingsTableViewController.swift
//  RSSReaderApp
//
//  Created by Hisashi Ishihara on 2021/02/04.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillDisappear(_ animated: Bool) {
        // 遷移元のメソッドを実行
        if let navigationController = self.presentingViewController as? UINavigationController,
              let controller = navigationController.topViewController as? ListTableViewController {
            controller.changeScreens()
        }
        if let navigationController2 = self.presentingViewController as? UINavigationController,
              let controller2 = navigationController2.topViewController as? ListCollectionViewController {
            controller2.changeScreens()
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "一覧画面の表示切り替え"
            break
        case 1:
            cell.textLabel?.text = "RSS取得間隔"
            break
        case 2:
            cell.textLabel?.text = "購読RSS管理"
            break
        case 3:
            cell.textLabel?.text = "文字サイズ変更"
            break
        case 4:
            cell.textLabel?.text = "ダークモード"
            break
        default:
            break
        }
        return cell
    }
    

    override func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        // 購読RSS管理 RSSフィード選択画面を流用して、購読RSS管理として利用する
        if indexPath.row == 2 {
            // RSSフィード選択画面 へ遷移
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChooseRSSFeedTableViewController") as! ChooseRSSFeedTableViewController
            self.present(secondViewController, animated: true, completion: nil)
        }else {
            // 設定詳細画面 へ遷移
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailSettingsTableViewController") as! DetailSettingsTableViewController
            secondViewController.settingsType = indexPath.row // どの設定詳細画面かを判別する値を渡す
            self.present(secondViewController, animated: true, completion: nil)
        }
    }

}
