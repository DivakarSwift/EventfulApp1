//
//  HostCell.swift
//  Eventful
//
//  Created by Shawn Miller on 9/23/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import AMPopTip

class HostCell: UICollectionViewCell, UICollectionViewDelegateFlowLayout {
    let userHostID = "userHostID"
    let orgHostID = "orgHostID"
    
    var userHost: [String]? {
        didSet{
            guard let users = userHost else {
                return
            }
            grabUsers(userHost: users)
        }
    }
    var orgHost: [String]? {
        didSet{
        }
        
    }
    
    var users:[User]?{
        didSet{
            self.host.reloadData()
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
    
    lazy var hostLabel: UILabel = {
        let hostLabel = UILabel()
        hostLabel.text = "Host"
        guard let customFont = UIFont(name: "NoirPro-SemiBold", size: 15) else {
            fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        hostLabel.textColor = .black
        hostLabel.textAlignment = .left
        hostLabel.font = customFont
        hostLabel.numberOfLines = 0
        return hostLabel
    }()
    
    lazy var host: UICollectionView = {
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
        addSubview(hostLabel)
        hostLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top).offset(5)
            make.left.equalTo(self.snp.left).offset(5)
        }
        addSubview(host)
        host.snp.makeConstraints { (make) in
            make.top.equalTo(hostLabel.snp.bottom).offset(5)
            make.left.right.equalTo(self)
            make.bottom.equalTo(self.snp.bottom)
        }
        host.register(UserHostCell.self, forCellWithReuseIdentifier: userHostID)
        //orgHostID
        host.register(OrgHostCell.self, forCellWithReuseIdentifier: orgHostID)

    }
    
    @objc func grabUsers(userHost: [String]){
        UserService.showUsers(for: userHost) { (users) in
            self.users = users
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension HostCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
     return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            guard let userCount = users?.count else {
                return 0
            }
            
            return userCount
        }else {
            guard let orgCount = orgHost?.count else {
                return 0
            }
            
            return orgCount

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userHostID, for: indexPath) as! UserHostCell
            cell.layer.cornerRadius = 10
            guard let users = users else  {
                return cell
            }
            cell.user = users[indexPath.item]
            return cell
        }else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: orgHostID, for: indexPath) as! OrgHostCell
            cell.layer.cornerRadius = 10
            return cell
        }
        

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 5, 0, 0)
    }
    
    
}

extension HostCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let userName = users?[indexPath.item].username {
                guard let cell = collectionView.cellForItem(at: indexPath) else {
                    return
                }
                self.popTip.show(text: userName, direction: .up, maxWidth: 200, in: self, from: cell.frame)
            }
        }
    }
    
}
