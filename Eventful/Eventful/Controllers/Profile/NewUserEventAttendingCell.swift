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
    
    var event: Event? {
        didSet {
            if let currentEvent = event {
                eventImageView.loadImage(urlString: currentEvent.currentEventImage)
                eventNameLabel.text = currentEvent.currentEventName.capitalized
            }
            print("recieved event")
        }
    }
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
        iv.setCellShadow()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var eventNameLabel : UILabel = {
        let label = UILabel()
        label.font =  UIFont(name:"HelveticaNeue-Medium", size: 12)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.numberOfLines = 0
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
            make.top.left.right.bottom.equalTo(self.cellView)
        }
//
//        cellView.addSubview(eventNameLabel)
//        eventNameLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(eventImageView.snp.bottom).inset(4)
//            make.left.right.equalTo(cellView)
//        }
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}
