//
//  SignUpViewController.swift
//  RSSReaderApp
//
//  Created by Hisashi Ishihara on 2021/01/29.
//

import UIKit
import LineSDK

class SignUpViewController: LoginViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet var registerButton: UIButton!

    override func validate() {
        guard let email = userNameTextField.text, let password = userPasswordTextField.text else {
            registerButton.isEnabled = false
            return
        }
        if self.validateEmail(candidate: email) {
            if self.validatePassword(candidate: password) {
                // パスワードが正しく入力された場合
                registerButton.isEnabled = true
            } else {
                // パスワードが正しく入力されなかった場合
                registerButton.isEnabled = false
            }
        } else {
            // メールアドレスが正しく入力されなかった場合
            registerButton.isEnabled = false
        }
    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        // ビルドモード
        #if RELEASE || DEBUGSECURE // ユーザに関する情報（メールアドレス、アクセストークン）を既存のUserDefaultからKeychainで管理する
        print("[コードブロック Release, debug-secure]")
        let result = KeyChain.saveKeyChain(id: userNameTextField.text!, password: userPasswordTextField.text!)
        if result {
            // UserDefaultsに保存 IDとパスワード　ログイン中のユーザーを識別する情報
            UserDefaults.standard.set(userNameTextField.text, forKey: "userName")
            UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
        }else {
            // IDが同じユーザーが既に登録されている場合
            // アラートを出す
            DispatchQueue.main.async {
                let dialog: UIAlertController = UIAlertController(title: "ユーザー登録失敗", message: "すでにIDが登録されています。", preferredStyle: .alert)
                self.present(dialog, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        #else
        print("[コードブロック それ以外]")
        // ユーザー情報　辞書型
        var dictionary = UserDefaults.standard.dictionary(forKey: "userInformation")
        let userInformation: [String: String] = [ // 『辞書』を初期化しつつ宣言します。
            userNameTextField.text! : userPasswordTextField.text!,
        ]
        if dictionary == nil { // ユーザー情報を新規作成
            UserDefaults.standard.set(userInformation, forKey: "userInformation")
            // UserDefaultsに保存 IDとパスワード　ログイン中のユーザーを識別する情報
            UserDefaults.standard.set(userNameTextField.text, forKey: "userName")
            UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
        }else {
            if dictionary?[userNameTextField.text!] == nil { // ユーザー情報を追加
                dictionary![userNameTextField.text!] = userPasswordTextField.text!
                UserDefaults.standard.set(dictionary, forKey: "userInformation")
                // UserDefaultsに保存 IDとパスワード　ログイン中のユーザーを識別する情報
                UserDefaults.standard.set(userNameTextField.text, forKey: "userName")
                UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
            }else {
                // IDが同じユーザーが既に登録されている場合
            }
        }
        #endif
        print(UserDefaults.standard.string(forKey: "userName"))
        print(UserDefaults.standard.string(forKey: "isUserLoggedIn"))
        // RSSフィード選択画面 へ遷移
        transfarViewController()
    }
}
// キーチェーン
class KeyChain {
    // 保存 ユーザー情報
    class func saveKeyChain(id: String, password: String) -> Bool {
        // ID
        let id = id
        // パスワード
        let data = password.data(using: .utf8)
        guard let _data = data else {
            return false
        }
        // APIを実行する際の引数設定
        // これをSecItemCopyMatching の第一引数に渡すと結果を受け取ることができる
        let dic: [String: Any] = [kSecClass as String: kSecClassGenericPassword, // パスワードクラス
                                  kSecAttrAccount as String: id,                 // アカウント（ログインID）
                                  kSecValueData as String: _data]                // パスワード本体
        // 検索用
        let search: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                     kSecAttrAccount as String: id,                 // アカウント（ログインID）
                                     kSecReturnAttributes as String: kCFBooleanTrue as Any,
                                     kSecMatchLimit as String: kSecMatchLimitOne]as [String : Any] // 1件表示する
        print(dic)
        var itemAddStatus: OSStatus?
        // 保存データが存在するかの確認
        print(search)
        let matchingStatus = SecItemCopyMatching(search as CFDictionary, nil)
        if matchingStatus == errSecItemNotFound {
            print("KeyChain saveKeyChain() 保存データが存在なし")
            // 保存
            itemAddStatus = SecItemAdd(dic as CFDictionary, nil)
        } else if matchingStatus == errSecSuccess {
            // キーチェーンにIDが存在する場合
            print("KeyChain saveKeyChain() 保存データが存在あり")
        } else {
            return false
        }
        // 保存・更新ステータス確認
        if itemAddStatus == errSecSuccess {
            print("KeyChain saveKeyChain() 正常終了")
        } else {
            print("KeyChain saveKeyChain() 異常終了")
            return false
        }
        return true
    }
}
