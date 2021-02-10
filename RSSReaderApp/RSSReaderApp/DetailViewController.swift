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

    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        wkWebView.frame = view.frame
        wkWebView.navigationDelegate = self
        wkWebView.uiDelegate = self
        wkWebView.allowsBackForwardNavigationGestures = true
        let url = URLRequest(url: URL(string: urlStr!)!)
        wkWebView.load(url)
        view.addSubview(wkWebView)
    }
    // お気に入り機能
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        
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
