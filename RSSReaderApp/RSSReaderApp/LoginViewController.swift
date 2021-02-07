//
//  LoginViewController.swift
//  RSSReaderApp
//
//  Created by Hisashi Ishihara on 2021/01/28.
//

import UIKit
import LineSDK

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        print(UserDefaults.standard.string(forKey: "userName"))
        print(UserDefaults.standard.string(forKey: "isUserLoggedIn"))
        userNameTextField.delegate = self
        userPasswordTextField.delegate = self
        // 入力された文字を非表示モードにする.
        userPasswordTextField.isSecureTextEntry = true
        userNameTextField.addTarget(self, action: #selector(onExitAction), for: .editingDidEndOnExit)
        userPasswordTextField.addTarget(self, action: #selector(onExitAction), for: .editingDidEndOnExit)
        // LINE
        // Create Login Button.
        let loginButton = LoginButton()
        loginButton.delegate = self
        // Configuration for permissions and presenting.
        loginButton.permissions = [.openID, .email]
        loginButton.presentingViewController = self
        // Add button to view and layout it.
        view.addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //下部からマージン100を指定
        loginButton.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
    }
    @IBOutlet var loginButton: UIButton!
    
    // .editingDidEndOnExit イベントが送信されると呼ばれる
    @objc func onExitAction(sender: Any) {
        validate()
    }
    
    func validate() {
        guard let email = userNameTextField.text, let password = userPasswordTextField.text else {
            loginButton.isEnabled = false
            return
        }
        if self.validateEmail(candidate: email) {
            if self.validatePassword(candidate: password) {
                // パスワードが正しく入力された場合
                loginButton.isEnabled = true
            } else {
                // パスワードが正しく入力されなかった場合
                loginButton.isEnabled = false
            }
        } else {
            // メールアドレスが正しく入力されなかった場合
            loginButton.isEnabled = false
        }
    }
    //　バリデーションチェック　ID
    func validateEmail(candidate: String) -> Bool {
        // 大文字と小文字の英数字
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }
    //　バリデーションチェック　Password
    func validatePassword(candidate: String) -> Bool {
        // 0〜9の文字、かつ4〜6桁
        let emailRegex = "[0-9]{4,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        let userName = userNameTextField.text;
        let userPassword = userPasswordTextField.text;
        // ユーザー情報 辞書型
        guard let dictionary = UserDefaults.standard.dictionary(forKey: "userInformation") else {
            return
        }
        print(dictionary)
        print(UserDefaults.standard.string(forKey: "userName"))
        print(UserDefaults.standard.string(forKey: "isUserLoggedIn"))
        guard let userInformationPassword = dictionary[userName!] else {
            return
        }
        print(dictionary[userName!] as! String)
        if( userInformationPassword as! String == userPassword!) {
            UserDefaults.standard.set(userNameTextField.text, forKey: "userName")
            UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
            self.dismiss(animated: true, completion:nil)
        }
    }
}
// LINE
extension LoginViewController: LoginButtonDelegate {
    func loginButton(_ button: LoginButton, didSucceedLogin loginResult: LoginResult) {
        if let email = loginResult.accessToken.IDToken?.payload.email {
            print("User Email: \(email)")
            // ユーザー情報 辞書型
            // ID(email)が登録されているかどうかをUserDefaults内で検索して、なければ新規登録する
            let dictionary = UserDefaults.standard.dictionary(forKey: email)
            print(dictionary)
            if dictionary == nil {
                let userInformation: [String: String] = [ // 『辞書』を初期化しつつ宣言します。
                    email : "", // SNSログインの場合は、Passwordを空白とする
                ]
                UserDefaults.standard.set(userInformation, forKey: email)
                // UserDefaultsに保存 IDとパスワード　ログイン中のユーザーを識別する情報
                UserDefaults.standard.set(email, forKey: "userName")
                UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
            }else {
                // IDが同じユーザーが既に登録されている場合
            }
            print(UserDefaults.standard.string(forKey: "userName"))
            print(UserDefaults.standard.string(forKey: "isUserLoggedIn"))
        }
        print("Login Succeeded.")
    }
    
    func loginButton(_ button: LoginButton, didFailLogin error: LineSDKError) {
        print("Error: \(error)")
    }
    
    func loginButtonDidStartLogin(_ button: LoginButton) {
        print("Login Started.")
    }
}
