//
//  CurrentHostCell.swift
//  Eventful
//
//  Created by Shawn Miller on 9/24/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

class UserHostCell: UICollectionViewCell {
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
        iv.layer.cornerRadius = 5
        iv.clipsToBounds = true
        return iv
    }()
    
    let cellView: UIView = {
        let cellView = UIView()
        cellView.backgroundColor = .white
        cellView.setCellShadow()
        return cellView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    fileprivate func setupViews(){
        addSubview(cellView)
        cellView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        cellView.addSubview(userImageView)
        userImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(cellView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
    

