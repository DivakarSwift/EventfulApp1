//
//  MenuCell.swift
//  Eventful
//
//  Created by Shawn Miller on 9/18/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.text = "Settings"
        nameLabel.font = UIFont(name: "NoirPro-Regular", size: 15)
        nameLabel.textColor = UIColor.rgb(red: 53, green: 56, blue: 57)
        return nameLabel
    }()
    
    @objc func setupViews(){
        backgroundColor = .white
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.snp.centerY)
            make.left.equalTo(self.snp.left).offset(5)
        }

    }

}
