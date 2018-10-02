//
//  AttendeeCell.swift
//  Eventful
//
//  Created by Shawn Miller on 9/26/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

class AttendeeCell: UICollectionViewCell {
    
    var user: User? {
        didSet{
            guard let user = user else {
                return
            }
            guard let profilePic = user.profilePic else {
                return
            }
            self.userImageView.loadImage(urlString: profilePic)
        }
    }
    
    lazy var userImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        return iv
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    fileprivate func setupViews(){
        addSubview(userImageView)
        userImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
