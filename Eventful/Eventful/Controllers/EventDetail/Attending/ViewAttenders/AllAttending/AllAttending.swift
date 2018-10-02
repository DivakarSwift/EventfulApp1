//
//  AllAttending.swift
//  Eventful
//
//  Created by Shawn Miller on 9/27/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

private let reuseIdentifier = "Cell"

class AllAttending: UICollectionViewController,UICollectionViewDelegateFlowLayout {
    
    var users:[User]?{
        didSet{
            self.collectionView?.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    @objc func setupViews(){
        self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(GoBack))
        self.navigationItem.leftBarButtonItem = backButton
        
        guard let collection = collectionView else {
            return
        }
        collection.backgroundColor = .white
        collection.delegate = self
        collection.dataSource = self
        collection.emptyDataSetSource = self
        collection.emptyDataSetDelegate = self
        collection.register(FriendCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    @objc func GoBack(){
        self.navigationController?.popViewController(animated: true)
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        guard let userCount = users?.count else{
            return 0
        }
        return userCount
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FriendCell
        // Configure the cell
        guard let users = users else {
            return cell
        }
        cell.user = users[indexPath.item]
        return cell
    }

}

extension AllAttending: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attribute = [NSAttributedStringKey.font: UIFont(name: "NoirPro-Light", size: 20),NSAttributedStringKey.foregroundColor: UIColor.black]
        let str = "No users to show."
        return NSAttributedString(string: str, attributes: attribute as [NSAttributedStringKey : Any])
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "icons8-friends-50")
    }
    
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attribute = [NSAttributedStringKey.font: UIFont(name: "NoirPro-Light", size: 15),NSAttributedStringKey.foregroundColor: UIColor.black]
        let str = "When users indicate that they are attending the event you will see them here."
        return NSAttributedString(string: str, attributes: attribute as [NSAttributedStringKey : Any])
    }
    
  
    
}
