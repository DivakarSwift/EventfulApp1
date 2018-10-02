//
//  SeeMoreCell.swift
//  Eventful
//
//  Created by Shawn Miller on 9/26/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

class SeeMoreCell: UICollectionViewCell {
    
    lazy var seeMoreLabel: UILabel = {
        let seeMoreLabel = UILabel()
        guard let customFont = UIFont(name: "NoirPro-SemiBold", size: 15) else {
            fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        seeMoreLabel.textColor = .black
        seeMoreLabel.adjustsFontSizeToFitWidth = true
        seeMoreLabel.textAlignment = .center
        seeMoreLabel.font = customFont
        seeMoreLabel.numberOfLines = 0
        return seeMoreLabel
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    fileprivate func setupViews(){
        addSubview(seeMoreLabel)
        seeMoreLabel.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
