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
        print(UserDefaults.standard.string(forKey: "userName"))
        print(UserDefaults.standard.string(forKey: "isUserLoggedIn"))
        print(UserDefaults.standard.dictionary(forKey: "userInformation"))
        print(UserDefaults.standard.array(forKey: "visited"))
        // 動作確認用
//        UserDefaults.standard.set(nil, forKey: "visited")
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
        // ログイン中のアカウントがLINEログインの場合、アクセストークンの検証を実行する
        verificationForAccessToken()
    }
    // ログイン中のアカウントがLINEログインの場合、アクセストークンの検証を実行する
    func verificationForAccessToken() {
        // LINE SDKに保存されたアクセストークン
        if let token = AccessTokenStore.shared.current {
            // ユーザー情報　辞書型
            var dictionary = UserDefaults.standard.dictionary(forKey: "userInformation")
            // ユーザー情報　現在ログイン中のIDのパスワード(アクセストークン)を取得
            guard let pw: String = dictionary?[UserDefaults.standard.string(forKey: "userName")!] as? String else { // ログイン情報　ID パスワード
                return
            }
            print(token.value)
            print(pw)
            // ログイン中のアカウントがLINEログインか判断 ログイン情報のパスワード(アクセストークン)　と　LINE SDKに保存されたアクセストークンを比較
            if pw == token.value {
                //　トークン検証
                API.Auth.verifyAccessToken { [self] result in
                    switch result {
                    case .success(let value): // 検証成功
                        print(value.channelID) // Bound channel ID of the token.
                        print(value.permissions) // The permissions of this token.
                        print(value.expiresIn) // How long it is before the token expires.
                    case .failure(let error): // 検証失敗　トークンは無効、失効、または期限切れであり、エラーが返されます。
                        print(error)
                        // ログアウト
                        lineLogout()
                        UserDefaults.standard.set("", forKey: "userName")
                        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
                    }
                }
            }
        } // LINEログアウトした場合
    }
    // ログイン中のアカウントがLINEログインの場合、ログアウトする
    func lineLogout() {
        // LINE SDKに保存されたアクセストークン
        if let token = AccessTokenStore.shared.current {
            
            LoginManager.shared.logout { result in
                switch result {
                case .success:
                    print("Logout from LINE")
                case .failure(let error):
                    print(error)
                }
            }
        } // LINEログアウトした場合
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // オートログイン
        // 動作確認用
//        UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
//        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        // ログイン判定
        let ud = UserDefaults.standard
        if let isUserLoggedIn = ud.object(forKey: "isUserLoggedIn") as? Bool {
            if !isUserLoggedIn { // 未ログインの場合
                // ログイン画面
            } else { // ログイン中の場合
                // 一覧画面 へ遷移
                transfarViewControllerToList()
            }
        }
    }
    // 一覧画面へ画面遷移
    func transfarViewControllerToList() {
        // TableView　か　CollectionView　を分岐する
        // 動作確認用
//            UserDefaults.standard.set(true, forKey: "TableViewOrCollectionView")
        UserDefaults.standard.set(false, forKey: "TableViewOrCollectionView")
        print(UserDefaults.standard.bool(forKey: "TableViewOrCollectionView"))
        if UserDefaults.standard.bool(forKey: "TableViewOrCollectionView") { // true: TableView
            // 一覧画面をマージ後に、設定詳細画面ブランチで　ログイン画面コントローラから一覧画面コントローラへSegueを繋ぎ、そのIdentiferを"toTableView"と設定する
            self.performSegue(withIdentifier: "toTableView", sender: nil)
        }else {
            // 一覧画面をマージ後に、設定詳細画面ブランチで　ログイン画面コントローラから一覧画面コントローラへSegueを繋ぎ、そのIdentiferを"toCollectionView"と設定する
            self.performSegue(withIdentifier: "toCollectionView", sender: nil)
        }
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
            // 一覧画面 へ遷移
            transfarViewControllerToList()
        }
    }
    // 初回ログイン時のみ表示　RSSフィード選択画面　へ遷移
    func transfarViewController() {
        // 初回ログイン array型
        print(UserDefaults.standard.array(forKey: "visited"))
        let id = UserDefaults.standard.string(forKey: "userName")! as String
        if UserDefaults.standard.array(forKey: "visited") == nil {
            // 最初回
            let visited: [String] = [id]
            UserDefaults.standard.set(visited, forKey: "visited")
        }else {
            var visited = UserDefaults.standard.array(forKey: "visited")
            for i in 0..<visited!.count { // 初回ログインではない場合
                if visited![i] as! String == id {
                    return // 画面遷移させない
                }
            }
            // 初回ログイン時にRSSフィード選択画面へ遷移済みとする
            visited!.append(id)
            UserDefaults.standard.set(visited, forKey: "visited")
        }
        print(UserDefaults.standard.array(forKey:"visited"))
        // RSSフィード選択画面 ブランチで　ナビゲーションコントローラのStoryboardIDを"NavigationController"と設定する
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
        secondViewController.modalPresentationStyle = .fullScreen
        self.present(secondViewController, animated: true, completion: nil)
    }
}
// LINE
extension LoginViewController: LoginButtonDelegate {
    func loginButton(_ button: LoginButton, didSucceedLogin loginResult: LoginResult) {
        if let email = loginResult.accessToken.IDToken?.payload.email {
            print("User Email: \(email)")
            let token = loginResult.accessToken.value
            // ユーザー情報 辞書型
            // ID(email)が登録されているかどうかをUserDefaults内で検索して、なければ新規登録する
            var dictionary = UserDefaults.standard.dictionary(forKey: "userInformation")
            print(dictionary)
            if dictionary == nil { // ユーザー情報を新規作成
                let userInformation: [String: String] = [ // 『辞書』を初期化しつつ宣言します。
                    email : token,
                ]
                UserDefaults.standard.set(userInformation, forKey: "userInformation")
                // UserDefaultsに保存 IDとパスワード　ログイン中のユーザーを識別する情報
                UserDefaults.standard.set(email, forKey: "userName")
                UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
            }else {
                // IDが同じユーザーが既に登録されている場合
                print(dictionary?[email])
                print(token)
                dictionary![email] = token // ユーザー情報　パスワード(アクセストークン)
                UserDefaults.standard.set(dictionary, forKey: "userInformation")
                // UserDefaultsに保存 IDとパスワード　ログイン中のユーザーを識別する情報
                UserDefaults.standard.set(email, forKey: "userName")
                UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
            }
            print(UserDefaults.standard.string(forKey: "userName"))
            print(UserDefaults.standard.string(forKey: "isUserLoggedIn"))
            print("Login Succeeded.")
            // RSSフィード選択画面 へ遷移
            transfarViewController()
            // 一覧画面 へ遷移
            transfarViewControllerToList()
        }else { // メールアドレスの使用を許可されなかった場合
            // アラートを出す
            let dialog: UIAlertController = UIAlertController(title: "ログイン失敗", message: "メールアドレスの使用を許可してください。", preferredStyle: .alert)
            self.present(dialog, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func loginButton(_ button: LoginButton, didFailLogin error: LineSDKError) {
        print("Error: \(error)")
    }
    
    func loginButtonDidStartLogin(_ button: LoginButton) {
        print("Login Started.")
    }
}
