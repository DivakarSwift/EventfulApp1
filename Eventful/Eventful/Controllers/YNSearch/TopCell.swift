//
//  TopCell.swift
//  Eventful
//
//  Created by Mohammed Abubaker on 7/23/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import Foundation

class TopCell: UICollectionViewCell {
    
    lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font =  UIFont.boldSystemFont(ofSize: 14.0)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    @objc func setupViews(){
        layer.cornerRadius = 3.0
        backgroundColor = UIColor.rgb(red: 45, green: 162, blue: 232)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(8.0)
            make.trailing.equalToSuperview().offset(-8.0)
            make.centerY.equalTo(self.contentView.snp.centerY)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cellInit(text:String) {
        self.titleLabel.text = text
    }
    
}
