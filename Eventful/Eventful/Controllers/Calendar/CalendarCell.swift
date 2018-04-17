//
//  CalendarCell.swift
//  Eventful
//
//  Created by Shawn Miller on 4/16/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit
import JTAppleCalendar

class CalendarCell: JTAppleCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func setupViews() {
        backgroundColor = .clear
        addSubview(daySelectionOverlay)
        addSubview(sectionNameLabel)
        daySelectionOverlay.snp.makeConstraints { (make) in
            make.center.equalTo(self.snp.center)
            make.height.width.equalTo(40)
        }
        daySelectionOverlay.layer.cornerRadius = 40/2

        sectionNameLabel.snp.makeConstraints { (make) in
            make.center.equalTo(self.snp.center)
        }
    }
    
    let daySelectionOverlay : UIView = {
        let daySelection = UIView()
        daySelection.backgroundColor = UIColor.rgb(red: 45, green: 162, blue: 232)
        return daySelection
    }()
    
    let sectionNameLabel : UILabel =  {
        let sectionNameLabel = UILabel()
        sectionNameLabel.font = UIFont(name:"Helvetica-Light", size: 16.5)
        return sectionNameLabel
    }()
    
}
