//
//  NewUserEventAttendingCell.swift
//  Eventful
//
//  Created by Shawn Miller on 6/14/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit

class NewUserEventAttendingCell: BaseRoundedCardCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        label.font =  UIFont(name:"HelveticaNeue", size: 20)
        label.text = "some name"
        return label
    }()
    
    lazy var eventCityLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name:"HelveticaNeue", size: 16)
        label.text = "some city"
        return label
    }()
    
    lazy var eventTimeLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name:"HelveticaNeue", size: 14.5)
        label.text = "some time"
        return label
    }()
    
    @objc func setupViews(){
        backgroundColor = .clear
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
            make.height.equalTo(self.frame.height - 20)
            make.width.equalTo(self.frame.width / 3)
        }
        eventImageView.backgroundColor = .red
        
        cellView.addSubview(eventNameLabel)
        eventNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(eventImageView.snp.right).offset(18)
            make.top.equalTo(self.snp.top).inset(10)
        }
        cellView.addSubview(eventCityLabel)
        eventCityLabel.snp.makeConstraints { (make) in
            make.top.equalTo(eventNameLabel.snp.bottom).offset(10)
            make.left.equalTo(eventImageView.snp.right).offset(18)
        }
        
        cellView.addSubview(eventTimeLabel)
        eventTimeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(eventCityLabel.snp.bottom).offset(10)
            make.left.equalTo(eventImageView.snp.right).offset(18)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
