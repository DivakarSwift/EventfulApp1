//
//  MenuHeader.swift
//  Eventful
//
//  Created by Shawn Miller on 9/18/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import Firebase

class MenuHeader: UITableViewCell {
    var userHandle: DatabaseHandle = 0
    var userRef: DatabaseReference?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = UIFont(name: "NoirPro-Regular", size: 15)
        nameLabel.textColor = UIColor.rgb(red: 53, green: 56, blue: 57)
        return nameLabel
    }()
    
    lazy var userImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        return iv
    }()
    
    @objc func setupViews(){
        backgroundColor = .white
        let dividerView = UIView()
        addSubview(dividerView)
        addSubview(nameLabel)
        addSubview(userImageView)
        
        userImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(5)
            make.height.width.equalTo(30)
            make.centerY.equalTo(self.snp.centerY)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(userImageView.snp.right).offset(5)
            make.centerY.equalTo(self.snp.centerY)
        }
        
        dividerView.backgroundColor = UIColor.lightGray
        dividerView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.top.equalTo(self.snp.bottom)
            make.height.greaterThanOrEqualTo(0.75)
        }
        
        observeUser()
    }
    
    deinit {
        userRef?.removeObserver(withHandle: userHandle)

    }
    
    @objc func observeUser(){
        self.userHandle = UserService.observeProfile(for: User.current, completion: { (userRef, user, nil) in
            self.userRef = userRef
            self.nameLabel.text = user?.username
            guard let userProfilePic = user?.profilePic else{
                return
            }
            
            self.userImageView.loadImage(urlString: userProfilePic)
        })
    }


}
