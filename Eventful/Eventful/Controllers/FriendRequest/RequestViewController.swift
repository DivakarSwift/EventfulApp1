//
//  RequestViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 5/29/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit
import DZNEmptyDataSet


class RequestViewController: UITableViewController {
    let requestCell = "requestCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
          setupVc()
        print(FriendService.system.requestList)
        
        FriendService.system.addRequestObserver {
            print(FriendService.system.requestList)
            self.tableView.reloadData()
        }
    }
    @objc func setupVc(){
        view.backgroundColor = UIColor.white
        navigationItem.title = "Pending Friend Request"
        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(GoBack))
        self.navigationItem.leftBarButtonItem = backButton
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.allowsSelection = false
        self.tableView.register(FriendRequestCell.self, forCellReuseIdentifier: requestCell)
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        //NotificationCenter.default.post(name: heartAttackNotificationName, object: nil)
    }
    
    deinit {
        //will remove observer here
        FriendService.system.removeRequestObserver()
    }
    
    @objc func GoBack(){
        print("BACK TAPPED")
        self.navigationController?.popViewController(animated: true)
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FriendService.system.requestList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: requestCell, for: indexPath) as! FriendRequestCell
         cell.user = FriendService.system.requestList[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
}


extension RequestViewController: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attribute = [NSAttributedStringKey.font: UIFont(name: "NoirPro-Light", size: 20),NSAttributedStringKey.foregroundColor: UIColor.black]
        let str = "No request to show."
        return NSAttributedString(string: str, attributes: attribute as [NSAttributedStringKey : Any])
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attribute = [NSAttributedStringKey.font: UIFont(name: "NoirPro-Light", size: 15),NSAttributedStringKey.foregroundColor: UIColor.black]
        let str = "Users have the ability to make their profile private. When you do that you will have to grant users permession to connect with you. Those request will be listed here"
        return NSAttributedString(string: str, attributes: attribute as [NSAttributedStringKey : Any])
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "icons8-handshake-heart-50")
    }
    
}
