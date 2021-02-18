//
//  DetailSettingsTableViewController.swift
//  RSSReaderApp
//
//  Created by Hisashi Ishihara on 2021/02/17.
//

import UIKit

class DetailSettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        switch settingsType {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellWithSwitch", for: indexPath) as! DetailSettingsTableViewCell
            cell.textLabel?.text = "一覧画面の表示切り替え(TableView ↔︎ CollectionView)"
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellWithStepper", for: indexPath) as! DetailSettingsTableViewCell
            cell.textLabel?.text = "RSS取得間隔"
            return cell
        case 2:
            // RSSフィード選択画面へ遷移のため不要
            break
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellWithStepperCharSize", for: indexPath) as! DetailSettingsTableViewCell
            cell.textLabel?.text = "文字サイズ変更"
            print(UserDefaults.standard.double(forKey: "CharSize"))
            cell.textLabel?.font = cell.textLabel?.font.withSize(CGFloat(UserDefaults.standard.double(forKey: "CharSize")))
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellWithSwitchDarkMode", for: indexPath) as! DetailSettingsTableViewCell
            cell.textLabel?.text = "ダークモード"
            return cell
        default:
            break
        }
        return cell
    }
    // 0:TableViewOrCollectionView, 1:SyncInterval, 2:- 3:CharSize, 4:DarkMode
    var settingsType = 4 // todo 一覧画面から遷移する時に、値が渡される
    @IBAction func switchTapped(_ sender: UISwitch) {
        switch settingsType {
        case 0:
            UserDefaults.standard.set(sender.isOn, forKey: "TableViewOrCollectionView")
            print(UserDefaults.standard.bool(forKey: "TableViewOrCollectionView"))
            break
        case 4:
            UserDefaults.standard.set(sender.isOn, forKey: "DarkMode")
            print(UserDefaults.standard.bool(forKey: "DarkMode"))
            break
        default:
            break
        }
    }
    
    @IBAction func stepperTapped(_ sender: UIStepper) {
        // UIStepperが配置されたセルを探す
        var hoge = sender.superview // 親ビュー
        while(hoge!.isKind(of: DetailSettingsTableViewCell.self) == false) {
            hoge = hoge!.superview
        }
        let cell = hoge as! DetailSettingsTableViewCell
        switch settingsType {
        case 1:
            UserDefaults.standard.set(sender.value, forKey: "SyncInterval")
            print(UserDefaults.standard.double(forKey: "SyncInterval"))
            cell.label.text = "\(Int(sender.value)) min"
            break
        case 3:
            UserDefaults.standard.set(sender.value, forKey: "CharSize")
            print(UserDefaults.standard.double(forKey: "CharSize"))
            cell.label.text = "\(Int(sender.value))"
            cell.textLabel?.font = cell.textLabel?.font.withSize(CGFloat(sender.value))
            print(cell.textLabel?.font.pointSize)
            break
        default:
            break
        }
    }
}
