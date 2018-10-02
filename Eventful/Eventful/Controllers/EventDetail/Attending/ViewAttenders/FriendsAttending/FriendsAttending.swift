//
//  FriendsAttending.swift
//  Eventful
//
//  Created by Shawn Miller on 9/27/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

private let reuseIdentifier = "Cell"

class FriendsAttending: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var users:[User]?{
        didSet{
            filterUsers()
        }
    }
    
    var results:[User]?{
        didSet{
            self.collectionView?.reloadData()
        }
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    @objc func setupViews(){
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

    @objc func filterUsers(){
        UserService.following { (friends) in
            guard let users = self.users else {
                return
            }
            self.results = users.filter{ (user) -> Bool in
                return friends.contains(where:{$0.uid == user.uid})
            }
        }
        
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let userCount = results?.count else{
            return 0
        }
        return userCount
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FriendCell
        // Configure the cell
        guard let results = results else {
            return cell
        }
        cell.user = results[indexPath.item]
        return cell
    }

}

extension FriendsAttending: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attribute = [NSAttributedStringKey.font: UIFont(name: "NoirPro-Light", size: 20),NSAttributedStringKey.foregroundColor: UIColor.black]
        let str = "No Friends to show."
        return NSAttributedString(string: str, attributes: attribute as [NSAttributedStringKey : Any])
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "icons8-friends-51")
    }
    
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attribute = [NSAttributedStringKey.font: UIFont(name: "NoirPro-Light", size: 15),NSAttributedStringKey.foregroundColor: UIColor.black]
        let str = "When your friends indicate that they are attending the event you will see them here."
        return NSAttributedString(string: str, attributes: attribute as [NSAttributedStringKey : Any])
    }
    
    
    
}

