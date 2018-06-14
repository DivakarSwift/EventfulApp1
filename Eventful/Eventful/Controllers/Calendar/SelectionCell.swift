//
//  SelectionCellTableViewCell.swift
//  Eventful
//
//  Created by Shawn Miller on 6/12/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

class SelectionCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        
    }
    
    let cellView: UIView = {
        let cellView = UIView()
        cellView.backgroundColor = .white
        cellView.setCellShadow()
        return cellView
    }()
    
    lazy var eventImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var eventNameLabel : UILabel = {
        let label = UILabel()
        label.font =  UIFont(name:"HelveticaNeue", size: 12)
        label.text = "some name"
        return label
    }()
    
    lazy var eventTimeLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name:"HelveticaNeue", size: 12)
        label.text = "some time"
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func setupViews(){
        print("setting up views")
        addSubview(cellView)
        cellView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self).inset(4)
            make.top.bottom.equalTo(self).inset(4)
        }
        cellView.addSubview(eventImageView)
        eventImageView.snp.makeConstraints { (make) in
            make.left.equalTo(cellView.snp.left).inset(4)
            make.top.bottom.equalTo(cellView).inset(4)
            make.centerY.equalTo(cellView.snp.centerY)
            make.height.width.equalTo(40)
        }
        eventImageView.backgroundColor = .red
        
        cellView.addSubview(eventNameLabel)
        eventNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(eventImageView.snp.right).offset(8)
            make.centerY.equalTo(cellView.snp.centerY)
        }
        
        cellView.addSubview(eventTimeLabel)
        eventTimeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(cellView.snp.right).inset(4)
            make.centerY.equalTo(cellView.snp.centerY)
        }
        
    }
  
    

}
