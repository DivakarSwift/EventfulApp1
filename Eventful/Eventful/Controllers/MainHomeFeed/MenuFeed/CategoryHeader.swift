//
//  CategoryHeader.swift
//  Eventful
//
//  Created by Shawn Miller on 8/29/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit

class CategoryHeader: UIView {
    
    let categoryLabel : UILabel =  {
        let categoryLabel = UILabel()
        categoryLabel.textAlignment = .center
        categoryLabel.adjustsFontSizeToFitWidth = true
        categoryLabel.adjustsFontForContentSizeCategory = true
        return categoryLabel
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func setupViews(){
        addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(5)
            make.top.equalTo(self.snp.top).offset(7)
        }
        
        
    }
}

