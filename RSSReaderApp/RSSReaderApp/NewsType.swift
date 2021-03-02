//
//  NewsType.swift
//  RSSReaderApp
//
//  Created by Hisashi Ishihara on 2021/02/04.
//

import Foundation

/// ニュースの種別
enum NewsType: CaseIterable {
    case main
    case grobal
    case entertainment
    case informationTechnology
    case local
    case domestic
    case economics
    case sports
    case science
    
    // RSS取得用url
    var urlStr: String {
        switch self {
        case .main:
            return "https://news.yahoo.co.jp/rss/topics/top-picks.xml"
        case .grobal:
            return "https://news.yahoo.co.jp/rss/topics/world.xml"
        case .entertainment:
            return "https://news.yahoo.co.jp/rss/topics/entertainment.xml"
        case .informationTechnology:
            return "https://news.yahoo.co.jp/rss/topics/it.xml"
        case .local:
            return "https://news.yahoo.co.jp/rss/categories/local.xml"
        case .domestic:
            return "https://news.yahoo.co.jp/rss/topics/domestic.xml"
        case .economics:
            return "https://news.yahoo.co.jp/rss/topics/business.xml"
        case .sports:
            return "https://news.yahoo.co.jp/rss/topics/sports.xml"
        case .science:
            return "https://news.yahoo.co.jp/rss/topics/science.xml"
        }
    }
    
    // ページメニュータイトル用文字列
    var itemInfo: String {
        switch self {
        case .main: return "主要"
        case .grobal: return "国際"
        case .entertainment: return "エンタメ"
        case .informationTechnology: return "IT"
        case .local: return "地域"
        case .domestic: return "国内"
        case .economics: return "経済"
        case .sports: return "スポーツ"
        case .science: return "科学"
        }
    }
}
