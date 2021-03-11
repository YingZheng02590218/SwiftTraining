//
//  SettingsTableViewController.swift
//  RSSReaderApp
//
//  Created by Hisashi Ishihara on 2021/02/04.
//

import UIKit
import LineSDK

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
        // ビルドモード
        #if DEBUGSECURE || DEBUGNONSECURE // アクセストークン更新機能
        print("[コードブロック debug-secure]")
        print("[コードブロック debug-non-secure]")
        return 7
        #else
        print("[コードブロック それ以外]")
        return 6
        #endif
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
        case 5:
            cell.textLabel?.text = "Logout  (\(UserDefaults.standard.string(forKey: "userName")!))"
            break
        case 6:
            // ビルドモード
            #if DEBUGSECURE || DEBUGNONSECURE // アクセストークン更新機能
            print("[コードブロック debug-secure]")
            print("[コードブロック debug-non-secure]")
            cell.textLabel?.text = "アクセストークンを更新する"
            #endif
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
        }else if indexPath.row == 5 {
            // ログアウト機能
            // ログイン情報
            print(UserDefaults.standard.string(forKey: "userName"))
            print(UserDefaults.standard.bool(forKey: "isUserLoggedIn"))
            UserDefaults.standard.set("", forKey: "userName")
            UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
            // ログイン画面コントローラからログイン画面コントローラへSegueを繋ぎ、そのIdentiferを"toLoginViewController"と設定する
            self.performSegue(withIdentifier: "toLoginViewController", sender: nil)
        }else if indexPath.row == 6 {
            // ビルドモード
            #if DEBUGSECURE || DEBUGNONSECURE // アクセストークン更新機能
            print("[コードブロック debug-secure]")
            print("[コードブロック debug-non-secure]")
            // LINE SDKから貰えるリフレッシュトークンを使用してアクセストークンを洗い替えできる機能の追加、イメージとしてはログアウトボタンの下にトークン更新ボタンの配置的な感じです。
            if let token = AccessTokenStore.shared.current {
                print("アクセストークン: Token expires at: \(token.expiresAt)")
                print("アクセストークン: Token right now: \(token.value)")
            }
            API.Auth.refreshAccessToken { result in
                switch result {
                case .success(let token):
                    print("アクセストークン: Token Refreshed: \(token.value)")
                    if let email = token.IDToken?.payload.email {
                        print("User Email: \(email)")
                        // ビルドモード
                        #if DEBUGSECURE  // アクセストークン更新機能
                        print("[コードブロック debug-secure]")
                        // ユーザー情報を新規作成 もしくは、更新
                        let result = KeyChain.saveKeyChain(id: email, password: token.value)
                        if result {
                            // アラートを出す
                            DispatchQueue.main.async {
                                let dialog: UIAlertController = UIAlertController(title: "アクセストークン ", message: "更新しました。", preferredStyle: .alert)
                                self.present(dialog, animated: true)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                        }
                        #elseif DEBUGNONSECURE // アクセストークン更新機能
                        print("[コードブロック debug-non-secure]")
                        // ユーザー情報 辞書型
                        // ID(email)が登録されているかどうかをUserDefaults内で検索して、なければ新規登録する
                        var dictionary = UserDefaults.standard.dictionary(forKey: "userInformation")
                        print(dictionary)
                        if dictionary == nil { // ユーザー情報を新規作成
                            let userInformation: [String: String] = [ // 『辞書』を初期化しつつ宣言します。
                                email : token.value,
                            ]
                            UserDefaults.standard.set(userInformation, forKey: "userInformation")
                        }else {
                            // IDが同じユーザーが既に登録されている場合
                            print(dictionary?[email])
                            print(token.value)
                            dictionary![email] = token.value // ユーザー情報　パスワード(アクセストークン)
                            UserDefaults.standard.set(dictionary, forKey: "userInformation")
                        }
                        // アラートを出す
                        DispatchQueue.main.async {
                            let dialog: UIAlertController = UIAlertController(title: "アクセストークン ", message: "更新しました。", preferredStyle: .alert)
                            self.present(dialog, animated: true)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                        #endif
                    }
                case .failure(let error):
                    print(error)
                    // アラートを出す
                    DispatchQueue.main.async {
                        let dialog: UIAlertController = UIAlertController(title: "アクセストークン ", message: "更新できませんでした。", preferredStyle: .alert)
                        self.present(dialog, animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
            #endif
        }else {
            // 設定詳細画面 へ遷移
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailSettingsTableViewController") as! DetailSettingsTableViewController
            secondViewController.settingsType = indexPath.row // どの設定詳細画面かを判別する値を渡す
            self.present(secondViewController, animated: true, completion: nil)
        }
    }

}
