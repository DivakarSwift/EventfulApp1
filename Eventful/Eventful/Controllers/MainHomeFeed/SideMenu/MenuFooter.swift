//
//  MenuFooter.swift
//  Eventful
//
//  Created by Shawn Miller on 9/18/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

class MenuFooter: UIView {
    let nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.text = "Settings"
        nameLabel.font = UIFont(name: "NoirPro-Regular", size: 15)
        nameLabel.textColor = UIColor.rgb(red: 53, green: 56, blue: 57)
        return nameLabel
    }()
//    icons8-Settings-50
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "icons8-Settings-50")
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func setupViews(){
        backgroundColor = .white
        addSubview(nameLabel)
        addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(5)
            make.centerY.equalTo(self.snp.centerY)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconImageView.snp.right).offset(5)
            make.centerY.equalTo(self.snp.centerY)
        }
        
        

    }

}
