//
//  InteractCell.swift
//  Eventful
//
//  Created by Shawn Miller on 9/29/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

class InteractCell: UICollectionViewCell {
    lazy var actionLabel: UILabel = {
        let actionLabel = UILabel()
        guard let customFont = UIFont(name: "NoirPro-Regular", size: 15) else {
            fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        actionLabel.textColor = .black
        actionLabel.textAlignment = .center
        actionLabel.font = customFont
        actionLabel.numberOfLines = 0
        return actionLabel
    }()
    
    
    let cellView: UIView = {
        let cellView = UIView()
        cellView.backgroundColor = .white
        cellView.setCellShadow()
        cellView.layer.borderWidth = 0.75
        cellView.layer.borderColor = UIColor.lightGray.cgColor
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
        cellView.addSubview(actionLabel)
        actionLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(cellView.snp.centerX)
            make.centerY.equalTo(cellView.snp.centerY)
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
