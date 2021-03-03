//
//  ListTableViewController.swift
//  RSSReaderApp
//
//  Created by Hisashi Ishihara on 2021/01/29.
//

import UIKit

class ListTableViewController: UITableViewController, XMLParserDelegate {

    var parser:XMLParser!
    var items = [Item]()
    var item:Item?
    var currentString = ""
    var ArticleRSSFeed = "" // 解析中のXML
    // フィルター
    var RSSFeedTitle = "すべてのフィード"
    var FilterFeed = ""
    var FilterRead = false // true:未読のみ
    var FilterFavorite = false // true:お気に入りのみ
    // ソート
    var SortByLatest = false
    /// ニュース種別
    private var newsType: NewsType = .main
    
    @IBOutlet var navigationItemm: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        // RSSフィード　仮登録
//        UserDefaults.standard.set("andyoutoobrutus@yahoo.com", forKey: "userName")
//        UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
//        let databaseManager = DatabaseManager()
//        databaseManager.add(RSSFeed: newsType.urlStr, RSSFeedTitle: newsType.itemInfo)
//        newsType = .science
//        databaseManager.add(RSSFeed: newsType.urlStr, RSSFeedTitle: newsType.itemInfo)
//        newsType = .sports
//        databaseManager.add(RSSFeed: newsType.urlStr, RSSFeedTitle: newsType.itemInfo)
        // テーブルをスワイプすることで、記事を更新することができる
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector(("refreshTable")), for: UIControl.Event.valueChanged)
        self.refreshControl = refreshControl
    }
    // テーブルをスワイプすることで、記事を更新することができる
    @objc func refreshTable() {
        // 記事更新時は、更新した記事をデータベースに登録する。
        feedDownload()
        self.tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(FilterFeed)
        print(FilterRead)
        print(FilterFavorite)
        print(SortByLatest)
        navigationItem.title = RSSFeedTitle
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // 初回起動時はサーバのデータを取得し、記事をデータベースに登録する。
        feedDownload()
    }
    
    func feedDownload() {
        // RSSフィードを取得　データベース
        let databaseManager = DatabaseManager()
        let objects = databaseManager.getRSSFeeds()
        // フィードをダウンロード
        for i in 0..<objects.count {
            startDownload(RSSFeed: objects[i].RSSFeed)
        }
    }
    // XMLの取得・解析
    func startDownload(RSSFeed: String) {
        self.items = []
        // httpではじまる、安全性の低いURLにアクセスする場合は、App Transport Securityのセキュリティの設定を下げる必要がある。Info.plist
        if let url = URL(string: RSSFeed) {
            self.ArticleRSSFeed = RSSFeed
            if let parser = XMLParser(contentsOf: url) {
                self.parser = parser
                self.parser.delegate = self
                self.parser.parse()
            }
        }
    }
    //解析_要素の開始時
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        self.currentString = ""
        if elementName == "item" {
            self.item = Item()
        }
    }
    //解析_要素内の値取得
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        self.currentString += string
    }
    //解析_要素の終了時
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "title": self.item?.title = currentString
        case "link": self.item?.link = currentString
        case "pubDate": self.item?.pubDate = currentString
        case "description": self.item?.description = currentString
        case "item":
            self.items.append(self.item!)
            // 記事をデータベースに保存
            let databaseManagerArticle = DatabaseManagerArticle()
            databaseManagerArticle.add(ArticleRSSFeed: self.ArticleRSSFeed, ArticleLink: self.item!.link, ArticlePubDate: self.item!.pubDate, ArticleTitle: self.item!.title)
        default: break
        }
    }
    //解析_終了時
    func parserDidEndDocument(_ parser: XMLParser) {
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 記事をデータベースから取得
        let databaseManagerArticle = DatabaseManagerArticle()
        let objects = databaseManagerArticle.getArticle(FilterFeed: FilterFeed, FilterRead: FilterRead, FilterFavorite: FilterFavorite, SortByLatest: SortByLatest)
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 記事をデータベースから取得
        let databaseManagerArticle = DatabaseManagerArticle()
        let objects = databaseManagerArticle.getArticle(FilterFeed: FilterFeed, FilterRead: FilterRead, FilterFavorite: FilterFavorite, SortByLatest: SortByLatest)
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        if objects[indexPath.row].ArticleTitle != nil {
            cell.textLabel?.text = objects[indexPath.row].ArticleTitle
        }
        if objects[indexPath.row].ArticlePubDate != nil {
            cell.detailTextLabel?.text = objects[indexPath.row].ArticlePubDate
        }
        return cell
    }
    // 画面遷移の準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // フィルター画面へ遷移
        if segue.identifier == "buttonTapped" {
            // 遷移先のコントローラに値を渡す
            guard let navigationController = segue.destination as? UINavigationController,
                  let controller = navigationController.topViewController as? FilterTableViewController else {
                fatalError()
            }
            controller.RSSFeedTitle = RSSFeedTitle
            controller.FilterFeed = FilterFeed
            controller.FilterRead = FilterRead
            controller.FilterFavorite = FilterFavorite
            controller.SortByLatest = SortByLatest
        }
        // 記事画面へ遷移
        if segue.identifier == "cellSelected" {
            // 記事をデータベースから取得
            let databaseManagerArticle = DatabaseManagerArticle()
            let objects = databaseManagerArticle.getArticle(FilterFeed: FilterFeed, FilterRead: FilterRead, FilterFavorite: FilterFavorite, SortByLatest: SortByLatest)
            // 遷移先のコントローラに値を渡す
            guard let navigationController2 = segue.destination as? UINavigationController,
                  let controller2 = navigationController2.topViewController as? DetailViewController else {
                fatalError()
            }
            let indexPath = self.tableView.indexPathForSelectedRow
            controller2.urlStr = objects[indexPath!.row].ArticleLink
            controller2.ArticleNumber = objects[indexPath!.row].number
        }
    }
    // セルをスワイプ
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 記事をデータベースから取得
        let databaseManagerArticle = DatabaseManagerArticle()
        let objects = databaseManagerArticle.getArticle(FilterFeed: FilterFeed, FilterRead: FilterRead, FilterFavorite: FilterFavorite, SortByLatest: SortByLatest)
        // お気に入りボタン
        print(objects[indexPath.row].number, objects[indexPath.row].ArticleIsFavorite)
        let action = UIContextualAction(style: .destructive, title: "お気に入り") { (action, view, completionHandler) in
            // データベース　お気に入りフラグ 変更
            databaseManagerArticle.changeArticleIsFavorite(number: objects[indexPath.row].number)
            completionHandler(true) // 処理成功時はtrue/失敗時はfalseを設定する
        }
        action.image = UIImage(systemName: "star.fill") // 画像設定（タイトルは非表示になる）
        if objects[indexPath.row].ArticleIsFavorite {
            action.backgroundColor = .systemGray
        }else {
            action.backgroundColor = .systemYellow
        }
        // 後で読むボタン
        let action2 = UIContextualAction(style: .destructive, title: "後で読む") { (action, view, completionHandler) in
            completionHandler(true)
        }
        action2.image = UIImage(systemName: "bookmark.fill")
        action2.backgroundColor = .systemGreen
        let configuration = UISwipeActionsConfiguration(actions: [action, action2])
        return configuration
    }
}
