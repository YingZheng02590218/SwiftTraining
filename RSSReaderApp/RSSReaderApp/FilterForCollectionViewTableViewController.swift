//
//  FilterForCollectionViewTableViewController.swift
//  RSSReaderApp
//
//  Created by Hisashi Ishihara on 2021/02/19.
//

import UIKit

class FilterForCollectionViewTableViewController: FilterTableViewController {

    @IBAction override func doneButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        let navigationController = self.presentingViewController as! UINavigationController
        // todo collectionView or tableView
        let presentingViewController = navigationController.viewControllers[0] as! ListCollectionViewController
        self.dismiss(animated: true, completion: {
            [self, presentingViewController] () -> Void in
            presentingViewController.RSSFeedTitle = RSSFeedTitle
            presentingViewController.FilterFeed = FilterFeed
            presentingViewController.FilterRead = FilterRead
            presentingViewController.FilterFavorite = FilterFavorite
            presentingViewController.SortByLatest = SortByLatest
            presentingViewController.viewWillAppear(true)
        })
    }
}
