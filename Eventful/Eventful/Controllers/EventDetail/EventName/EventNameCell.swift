//
//  EventNameCell.swift
//  Eventful
//
//  Created by Shawn Miller on 9/23/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

class EventNameCell: UICollectionViewCell {
    lazy var eventNameLabel: UILabel = {
        let eventNameLabel = UILabel()
        guard let customFont = UIFont(name: "NoirPro-SemiBold", size: 28) else {
            fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        eventNameLabel.textColor = .black
        eventNameLabel.textAlignment = .left
        eventNameLabel.font = customFont
        eventNameLabel.numberOfLines = 0
        return eventNameLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    fileprivate func setupViews(){
        addSubview(eventNameLabel)
        eventNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(5)
            make.right.equalTo(self.snp.right)
            make.top.bottom.equalTo(self)
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
