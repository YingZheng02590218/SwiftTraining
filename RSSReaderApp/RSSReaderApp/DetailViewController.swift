//
//  DetailViewController.swift
//  RSSReaderApp
//
//  Created by Hisashi Ishihara on 2021/02/04.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {

    // 記事表示用webView
    private let wkWebView = WKWebView()
    // 読み込むURL
    var urlStr: String?
    var ArticleNumber: Int = 0 // データベース記事のプライマリーキー

    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // お気に入り機能
        checkFlagOfFavorite()
        // 既読制御機能　データベース　既読フラグ 変更
        let databaseManagerArticle = DatabaseManagerArticle()
        databaseManagerArticle.changeArticleHasRead(number: self.ArticleNumber, ArticleHasRead: true)
        wkWebView.frame = view.frame
        wkWebView.navigationDelegate = self
        wkWebView.uiDelegate = self
        wkWebView.allowsBackForwardNavigationGestures = true
        let url = URLRequest(url: URL(string: urlStr!)!)
        wkWebView.load(url)
        view.addSubview(wkWebView)
    }
    // お気に入り機能
    @IBOutlet var favoriteButton: UIBarButtonItem!
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        // データベース　お気に入りフラグ 変更
        let databaseManagerArticle = DatabaseManagerArticle()
        databaseManagerArticle.changeArticleIsFavorite(number: ArticleNumber)
        checkFlagOfFavorite()
    }
    // お気に入り機能
    func checkFlagOfFavorite() {
        // データベース　お気に入りフラグ 参照
        let databaseManagerArticle = DatabaseManagerArticle()
        let article = databaseManagerArticle.getArticleByPrimaryKey(number: ArticleNumber)
        if article.ArticleIsFavorite {
            favoriteButton.image = UIImage(systemName: "star.fill")!
        }else {
            favoriteButton.image = UIImage(systemName: "star")!
        }
    }
    // シェア機能
    let shareText = "シェアするよ"
    @IBAction func shareButtonTapped(_ sender: Any) {
        //share(上の段)から遷移した際にシェアするアイテム
        let activityItems: [Any] = [shareText, self.urlStr]//shareUrl]
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: [LINEActivity(message: shareText, shareUrl: self.urlStr!)])
        self.present(activityViewController, animated: true, completion: nil)
    }
}
extension DetailViewController: WKNavigationDelegate {

}

extension DetailViewController: WKUIDelegate {

}
