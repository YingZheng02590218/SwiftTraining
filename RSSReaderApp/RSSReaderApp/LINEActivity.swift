//
//  LINEActivity.swift
//  RSSReaderApp
//
//  Created by Hisashi Ishihara on 2021/02/04.
//

import UIKit

class LINEActivity: UIActivity {
    let urlScheme: String = "https://line.me/R/msg/text/?"
    //シェアしたいメッセージ
    var message = "LINEにシェアするよ。"
    var shareUrl = NSURL(string: "https://www.apple.com/jp/")!

    init(message: String, shareUrl: String) {
        self.message = message
        self.shareUrl = NSURL(string: "\(shareUrl)")!
    }

    override class var activityCategory: UIActivity.Category {
        //actionだと下の段, shareだと上の段に表示される
        return .action
    }

    override var activityTitle: String? {
        //表示の際のテキスト
        return "LINEでシェア"
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }

    override func perform() {
        //urlSheme + / + message (+ image or url) のフォーマット
        let urlstring = "\(urlScheme)/\(message)\n\(shareUrl)"
        //日本語などをエンコード
        let encodedURL = urlstring.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: encodedURL!)
        guard let openUrl = url else { return }
        UIApplication.shared.open(openUrl, options: .init(), completionHandler: nil)
        activityDidFinish(true)
    }
}
