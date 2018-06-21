//
//  NewProfileVC.swift
//  Eventful
//
//  Created by Shawn Miller on 6/14/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class NewProfileVC: UIViewController,UIScrollViewDelegate {
    let cellID = "cellID"
    let headerID = "headerID"
    var profileHandle: DatabaseHandle = 0
    var profileRef: DatabaseReference?
    var userEvents = [Event]()
    var userId: String?
    var user: User?
    var isFollowed = false

    lazy var myCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .white
        return cv
    }()
    

    let titleView = UILabel()
    
    


    override func viewDidLoad() {
        super.viewDidLoad()
        myCollectionView.register(NewUserHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerID)
        myCollectionView.register(NewUserEventAttendingCell.self, forCellWithReuseIdentifier: cellID)
        setupVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        if let user = user{
            grabFollowers(user: user)
        }
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        
        if parent != nil && self.navigationItem.titleView == nil {
            initNavigationItemTitleView()
        }
    }
    
    deinit {
        profileRef?.removeObserver(withHandle: profileHandle)
        FriendService.system.removeFriendObserver()
        FriendService.system.removeFollowingObserver()
        print("removed from memory")
    }
    
    private func initNavigationItemTitleView() {
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 500))
        titleView.textAlignment = .center;
        titleView.text = self.user?.username
        self.navigationItem.titleView = titleView
        self.titleView.font = UIFont(name: "Futura-CondensedMedium", size: 18)
        self.titleView.adjustsFontSizeToFitWidth = true
        
    }
    
    @objc func setupVC(){
    //will be responsible for setting up vc
        user = self.user ?? User.current
        if let user = user {
            checkFollowStatus(user: user)
            //grabFollowers(user: user)

        }
        view.addSubview(myCollectionView)
        myCollectionView.snp.makeConstraints { (make) in
           make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
    }
    
    @objc func grabFollowers(user: User){
        FriendService.system.addFollowingObserver(userID: user.uid) {
            FriendService.system.addFriendObserver(userID: user.uid, {
                DispatchQueue.main.async {
                    self.myCollectionView.reloadData()
                }
                
            })
        }
    }
    
    

    
    @objc func checkFollowStatus(user: User){
        FollowService.isUserFollowed(user) { (success) in
            if success {
                //will enter here if the user is followed
                self.profileHandle = UserService.observeProfile(for: self.user!) { [unowned self](ref, user, events) in
                    self.profileRef = ref
                    self.user = user
                    self.userEvents = events
                    self.isFollowed = true
                    DispatchQueue.main.async {
                        self.myCollectionView.reloadData()
                    }
                }
            }else{
                //will go here if your not following the user and there private and there not current user
                self.isFollowed = false
                if (self.user?.isPrivate)! && self.isFollowed == false && self.user != User.current{
                    //show nothing because you have to add them first
                    DispatchQueue.main.async {
                        self.myCollectionView.reloadData()
                    }
                    
                }else{
                    //if user isn't private or user is you show it anyway because they dont care
                    self.profileHandle = UserService.observeProfile(for: self.user!) { [unowned self](ref, user, events) in
                        self.profileRef = ref
                        self.user = user
                        self.userEvents = events
                        DispatchQueue.main.async {
                            self.myCollectionView.reloadData()
                        }
                        
                        
                    }
                }
            }
        }
        
    }
    
}

extension NewProfileVC: UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return userEvents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! NewUserEventAttendingCell
        cell.event = userEvents[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 1.0, bottom: 1.0, right: 1.0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let kWhateverHeightYouWant = 169
        return CGSize(width: collectionView.bounds.size.width - 30, height: CGFloat(kWhateverHeightYouWant))
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width - 20, height: 350)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let eventDetails = EventDetailViewController()
        eventDetails.currentEvent = userEvents[indexPath.item]
        self.navigationController?.pushViewController(eventDetails, animated: true)
    }
    
    fileprivate func setupHeaderLabel(count: String, type: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "\(count)\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: type, attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
        return attributedText
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerID, for: indexPath) as! NewUserHeader
        header.user = user
        header.profileViewController = self
        header.eventsLabel.attributedText = setupHeaderLabel(count: String(userEvents.count), type: "events")
        header.followersLabel.attributedText = setupHeaderLabel(count: String(FriendService.system.followerList.count), type: "followers")
        header.followingLabel.attributedText = setupHeaderLabel(count: String(FriendService.system.followingList.count), type: "following")
        return header
    }
    
    
}
