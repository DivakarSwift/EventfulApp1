//
//  FollowersViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 6/1/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit
import IGListKit
import DZNEmptyDataSet

class FollowingViewController: UITableViewController  {
    let friendCell = "friendCell"
    let emptyView = UIView()

    lazy var noFriendLabel: UILabel = {
        let noFriendLabel = UILabel()
        noFriendLabel.text = "You Are Currently Following No One"
        noFriendLabel.font = UIFont(name: "Avenir", size: 20)
        noFriendLabel.numberOfLines = 0
        noFriendLabel.textAlignment = .center
        return noFriendLabel
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVc()
    }
    
    @objc func setupVc(){
        view.backgroundColor = UIColor.white
        navigationItem.title = "Following"
        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(GoBack))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
         self.tableView.tableFooterView = UIView(frame: CGRect.zero)

        self.tableView.register(FollowerCell.self, forCellReuseIdentifier: friendCell)
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    //will leave the VC
    @objc func GoBack(){
        print("BACK TAPPED")
        self.navigationController?.popViewController(animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: friendCell, for: indexPath) as! FollowerCell
        cell.user = FriendService.system.followingList[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath) as! FollowerCell
        let userProfileVC = NewProfileVC()
        userProfileVC.user = currentCell.user
        userProfileVC.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(self.GoBack))
        userProfileVC.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath) as! FollowerCell
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FriendService.system.followingList.count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    deinit {
        //will remove observer here
        FriendService.system.removeFriendObserver()
    }
    
}


extension FollowingViewController: DZNEmptyDataSetSource,DZNEmptyDataSetDelegate{
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attribute = [NSAttributedStringKey.font: UIFont(name: "NoirPro-Light", size: 20),NSAttributedStringKey.foregroundColor: UIColor.black]
        let str = "No users to show."
        return NSAttributedString(string: str, attributes: attribute as [NSAttributedStringKey : Any])
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attribute = [NSAttributedStringKey.font: UIFont(name: "NoirPro-Light", size: 15),NSAttributedStringKey.foregroundColor: UIColor.black]
        let str = "When you begin to connect with and follow users in the app they will be listed here."
        return NSAttributedString(string: str, attributes: attribute as [NSAttributedStringKey : Any])
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "icons8-user-account-50")
    }
}



