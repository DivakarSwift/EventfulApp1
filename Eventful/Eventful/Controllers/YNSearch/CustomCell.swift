//
//  CustomCell.swift
//  Eventful
//
//  Created by Shawn Miller on 7/19/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

open class CustomCell: UITableViewCell {
    
    var objectID: String?
    
    lazy var resultImageView : UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 5.0
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.font =  UIFont(name:"HelveticaNeue-Medium", size: 16)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    lazy var detailLabel : UILabel = {
        let label = UILabel()
        label.font =  UIFont(name:"HelveticaNeue-Medium", size: 13)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func setupViews(){
        separatorInset = UIEdgeInsetsMake(0, 100, 0, 0)
        backgroundColor = UIColor.groupTableViewBackground.withAlphaComponent(0.5)
        selectionStyle = .none
        
        let cornerView = UIView()
        cornerView.materialDesign = true
        addSubview(cornerView)
        
        cornerView.snp.makeConstraints { (make) in
            make.left.equalTo(self).inset(20)
            make.height.equalTo(70)
            make.width.equalTo(70)
            make.centerY.equalTo(self.contentView.snp.centerY)
        }
        
        cornerView.addSubview(resultImageView)
        resultImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(cornerView.snp.height)
            make.centerX.equalTo(cornerView.snp.centerX)
            make.centerY.equalTo(cornerView.snp.centerY)
        }
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel,detailLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 4.0
        
        addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.left.equalTo(cornerView.snp.right).offset(10)
            make.right.equalTo(contentView.snp.right).offset(-10)
            make.centerY.equalTo(cornerView.snp.centerY)
        }
        
    }
    
    func cellInit(obj:resultObj) {
        self.titleLabel.text = obj.name.capitalized
        self.objectID = obj.objectID
        self.detailLabel.text = obj.desc
        self.resultImageView.kf.indicatorType = .activity
        if let url = URL(string: obj.img) {
            self.resultImageView.kf.setImage(with: url, placeholder: UIImage(named: "PL"), options: nil, progressBlock: nil, completionHandler: nil)
        }
    }
    
}

extension StringProtocol {
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
}

