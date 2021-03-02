//
//  ListCollectionViewCell.swift
//  RSSReaderApp
//
//  Created by Hisashi Ishihara on 2021/02/19.
//

import UIKit

class ListCollectionViewCell: UICollectionViewCell {
    
    var textLabel: UILabel?
    var detailTextLabel: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // UILabelを生成.
        textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height*0.5))
        textLabel?.textColor = .blue
        textLabel?.backgroundColor = UIColor.green
        textLabel?.textAlignment = NSTextAlignment.left
        textLabel?.numberOfLines = 0
        // UILabelを生成.
        detailTextLabel = UILabel(frame: CGRect(x: 0, y: frame.height*0.5, width: frame.width, height: frame.height*0.5))
        detailTextLabel?.textColor = .black
        detailTextLabel?.backgroundColor = UIColor.lightGray
        detailTextLabel?.textAlignment = NSTextAlignment.left
        detailTextLabel?.numberOfLines = 0
        // Cellに追加.
        self.contentView.addSubview(textLabel!)
        self.contentView.addSubview(detailTextLabel!)
    }
}
