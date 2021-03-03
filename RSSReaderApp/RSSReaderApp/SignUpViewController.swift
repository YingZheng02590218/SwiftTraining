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
        print(UserDefaults.standard.string(forKey: "userName"))
        print(UserDefaults.standard.string(forKey: "isUserLoggedIn"))
        // RSSフィード選択画面 へ遷移
        transfarViewController()
    }
}
