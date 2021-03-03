//
//  ListCollectionViewController.swift
//  RSSReaderApp
//
//  Created by Hisashi Ishihara on 2021/02/19.
//

import UIKit

private let reuseIdentifier = "Cell"

class ListCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, XMLParserDelegate {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        // レイアウトを調整
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        collectionView.collectionViewLayout = layout
//        // RSSフィード　仮登録
//        UserDefaults.standard.set("andyoutoobrutus@yahoo.com", forKey: "userName")
//        UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
        // RSS取得間隔　確認用
        print(UserDefaults.standard.double(forKey: "SyncInterval"))
        UserDefaults.standard.set(1, forKey: "SyncInterval")

        let databaseManager = DatabaseManager()
        databaseManager.add(RSSFeed: newsType.urlStr, RSSFeedTitle: newsType.itemInfo)
        newsType = .science
        databaseManager.add(RSSFeed: newsType.urlStr, RSSFeedTitle: newsType.itemInfo)
        newsType = .sports
        databaseManager.add(RSSFeed: newsType.urlStr, RSSFeedTitle: newsType.itemInfo)
        newsType = .economics
        databaseManager.add(RSSFeed: newsType.urlStr, RSSFeedTitle: newsType.itemInfo)
        // テーブルをスワイプすることで、記事を更新することができる
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector(("refreshTable")), for: UIControl.Event.valueChanged)
        self.collectionView.refreshControl = refreshControl
    }
    // テーブルをスワイプすることで、記事を更新することができる
    @objc func refreshTable() {
        // 記事更新時は、更新した記事をデータベースに登録する。
        feedDownload()
        self.collectionView.reloadData()
        collectionView.refreshControl?.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(FilterFeed)
        print(FilterRead)
        print(FilterFavorite)
        print(SortByLatest)
        navigationItem.title = RSSFeedTitle
        collectionView.reloadData()
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
        self.collectionView.reloadData()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 記事をデータベースから取得
        let databaseManagerArticle = DatabaseManagerArticle()
        let objects = databaseManagerArticle.getArticle(FilterFeed: FilterFeed, FilterRead: FilterRead, FilterFavorite: FilterFavorite, SortByLatest: SortByLatest)
        return objects.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 記事をデータベースから取得
        let databaseManagerArticle = DatabaseManagerArticle()
        let objects = databaseManagerArticle.getArticle(FilterFeed: FilterFeed, FilterRead: FilterRead, FilterFavorite: FilterFavorite, SortByLatest: SortByLatest)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuseIdentifier", for: indexPath) as! ListCollectionViewCell
        if objects[indexPath.row].ArticleTitle != nil {
            cell.textLabel?.text = objects[indexPath.row].ArticleTitle
        }
        if objects[indexPath.row].ArticlePubDate != nil {
            cell.detailTextLabel?.text = objects[indexPath.row].ArticlePubDate
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalSpace : CGFloat = 20
        let cellSize : CGFloat = self.view.bounds.width / 2 - horizontalSpace
        return CGSize(width: cellSize, height: cellSize)
    }
    // 画面遷移の準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navigationController = segue.destination as? UINavigationController,
              let controller = navigationController.topViewController as? FilterForCollectionViewTableViewController else {
            fatalError()
        }
        // 遷移先のコントローラに値を渡す
        if segue.identifier == "buttonTapped" {
            controller.RSSFeedTitle = RSSFeedTitle
            controller.FilterFeed = FilterFeed
            controller.FilterRead = FilterRead
            controller.FilterFavorite = FilterFavorite
            controller.SortByLatest = SortByLatest
        }
    }
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
