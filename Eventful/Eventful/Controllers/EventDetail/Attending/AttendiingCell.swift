//
//  AttendiingCell.swift
//  Eventful
//
//  Created by Shawn Miller on 9/26/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import AMPopTip
import DTPagerController
import DZNEmptyDataSet

class AttendiingCell: UICollectionViewCell,UICollectionViewDelegateFlowLayout {
    let attendingID = "attendingID"
    let seeMoreID = "seeMoreID"
    weak var homeRef: NewEventDetailViewController?
    var pagerController: DTPagerController?
    var eventKey: String? {
        didSet{
            guard let key = eventKey else {
                return
            }
            fetchAttendes(eventKey: key)
        }
    }
    
    lazy var popTip: PopTip = {
        let popTip = PopTip()
        popTip.shouldDismissOnTap = true
        popTip.shouldDismissOnTapOutside = true
        popTip.edgeMargin = 5
        popTip.edgeInsets = UIEdgeInsetsMake(0, 10, 0, 10)
        popTip.bubbleColor = UIColor.rgb(red: 44, green: 152, blue: 229)
        return popTip
    }()
    
    var users:[User]?{
        didSet{
            self.attending.reloadData()
        }
    }
    
    lazy var attendingLabel: UILabel = {
        let attendingLabel = UILabel()
        attendingLabel.text = "Attending Users"
        guard let customFont = UIFont(name: "NoirPro-SemiBold", size: 15) else {
            fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        attendingLabel.textColor = .black
        attendingLabel.textAlignment = .left
        attendingLabel.font = customFont
        attendingLabel.numberOfLines = 0
        return attendingLabel
    }()
    
    lazy var attending: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    fileprivate func setupViews(){
        addSubview(attendingLabel)
        attendingLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top).offset(5)
            make.left.equalTo(self.snp.left).offset(5)
        }
        addSubview(attending)
        attending.snp.makeConstraints { (make) in
            make.top.equalTo(attendingLabel.snp.bottom).offset(5)
            make.left.right.equalTo(self)
            make.bottom.equalTo(self.snp.bottom)
        }
        attending.register(AttendeeCell.self, forCellWithReuseIdentifier: attendingID)
        attending.register(SeeMoreCell.self, forCellWithReuseIdentifier: seeMoreID)
        attending.emptyDataSetSource = self
        attending.emptyDataSetDelegate = self
    }
    

    
    @objc func fetchAttendes(eventKey: String){
        AttendService.fetchAttendingUsers(for: eventKey) { (users) in
            self.users = users
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AttendiingCell: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let userName = users?[indexPath.item].username {
                guard let cell = collectionView.cellForItem(at: indexPath) else {
                    return
                }
                self.popTip.show(text: userName, direction: .up, maxWidth: 200, in: self, from: cell.frame)
            }
        }else {
            let allAttending = AllAttending(collectionViewLayout: UICollectionViewFlowLayout())
            allAttending.users = users
            let allFriends = FriendsAttending(collectionViewLayout: UICollectionViewFlowLayout())
            allFriends.users = users
            allAttending.title = "Attending"
            allFriends.title = "Friends Attending"
            pagerController = DTPagerController(viewControllers: [allAttending,allFriends])
            pagerController?.font = UIFont(name: "NoirPro-Regular", size: 14)!
            pagerController?.selectedFont = UIFont(name: "NoirPro-SemiBold", size: 14)!
            pagerController?.selectedTextColor =  UIColor.black
            pagerController?.perferredScrollIndicatorHeight = 1.8
            pagerController?.preferredSegmentedControlHeight = 40
            pagerController?.scrollIndicator.backgroundColor = UIColor.black
            pagerController?.title = "Attending"
            pagerController?.navigationItem.hidesBackButton = true
            let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(GoBack))
            pagerController?.navigationItem.leftBarButtonItem = backButton

            guard let home = homeRef else {
                return
            }
            guard let page = pagerController else {
                return
            }
            home.navigationController?.pushViewController(page, animated: true)
        }
    }
    
    @objc func GoBack(){
        guard let page = pagerController else {
            return
        }
        page.navigationController?.popViewController(animated: true)
    }
    
}

extension AttendiingCell: UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let userCount = users?.count else {
            return 0
        }
        
        if section == 0 {
            if userCount >= 5 {
                return 5
            }else{
                return userCount
            }
        }else {
            if userCount == 0 {
                return 0
            }else {
                return 1
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: attendingID, for: indexPath) as! AttendeeCell
            cell.layer.cornerRadius = cell.frame.size.width / 2
            cell.layer.masksToBounds = true
            guard let users = users else  {
                return cell
            }
            cell.user = users[indexPath.item]
            return cell
        }else {
             let cell = collectionView.dequeueReusableCell(withReuseIdentifier: seeMoreID, for: indexPath) as! SeeMoreCell
            guard let userCount = users?.count else{
                return cell
            }
            cell.layer.cornerRadius = cell.frame.size.width / 2
            cell.layer.masksToBounds = true
            cell.layer.borderWidth = 0.50
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.seeMoreLabel.text = "\(userCount)+"
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 5, 0, 5)
    }
    
}

extension AttendiingCell: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attribute = [NSAttributedStringKey.font: UIFont(name: "NoirPro-Regular", size: 15),NSAttributedStringKey.foregroundColor: UIColor.black]
        let str = "No Users to show."
        return NSAttributedString(string: str, attributes: attribute as [NSAttributedStringKey : Any])
    }

    
}
