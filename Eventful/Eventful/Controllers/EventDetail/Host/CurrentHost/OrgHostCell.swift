//
//  OrgHostCell.swift
//  Eventful
//
//  Created by Shawn Miller on 9/26/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

class OrgHostCell: UICollectionViewCell {
    let cellView: UIView = {
        let cellView = UIView()
        cellView.backgroundColor = .white
        cellView.setCellShadow()
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
