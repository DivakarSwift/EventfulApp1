//
//  UserCell.swift
//  Eventful
//
//  Created by Shawn Miller on 6/26/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

class UserCell: BaseCell {
    var user: User?{
        didSet{
            userNameLabel.text = user?.username
            
            guard let userProfilePic = user?.profilePic else{
                return
            }
            
            userImageView.loadImage(urlString: userProfilePic)
        }
    }
    let userImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let userNameLabel : UILabel = {
        let label = UILabel()
        label.text = "EventName"
        guard let customFont = UIFont(name: "ProximaNovaSoft-Regular", size: 22) else {
            fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        label.font = UIFontMetrics.default.scaledFont(for: customFont)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    let cellView: UIView = {
        let cellView = UIView()
        cellView.backgroundColor = .white
        cellView.setupShadow2()
        return cellView
    }()
    
    override func setupViews() {
        backgroundColor = .white
        addSubview(cellView)
        cellView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        cellView.addSubview(userImageView)
        userImageView.backgroundColor = .red
        userImageView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(self).inset(5)
            make.left.equalTo(self.snp.left).inset(5)
            make.width.equalTo(self.frame.width / 3)
        }
    }
    
}
