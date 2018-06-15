//
//  NewUserHeader.swift
//  Eventful
//
//  Created by Shawn Miller on 6/14/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit

class NewUserHeader: UICollectionViewCell {
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
    
    lazy var followersLabel : UILabel = {
       let followersLabel = UILabel()
        let attributedText = NSMutableAttributedString(string: "11\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
        followersLabel.attributedText = attributedText
        followersLabel.textAlignment = .center
        followersLabel.numberOfLines = 0
        return followersLabel
    }()
    
    
    lazy var followingLabel : UILabel = {
        let followingLabel = UILabel()
        let attributedText = NSMutableAttributedString(string: "10\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
        followingLabel.attributedText = attributedText
        followingLabel.numberOfLines = 0
        followingLabel.textAlignment = .center
        return followingLabel
    }()
    
    
    lazy var eventsLabel : UILabel = {
        let eventsLabel = UILabel()
        let attributedText = NSMutableAttributedString(string: "12\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "events", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
        eventsLabel.attributedText = attributedText
        eventsLabel.numberOfLines = 0
        eventsLabel.textAlignment = .center
        return eventsLabel
    }()
    
    lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        return button
    }()
    
    
    @objc func setupViews(){
        backgroundColor = .clear
        addSubview(cellView)
        cellView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self).inset(4)
            make.top.bottom.equalTo(self).inset(4)
        }
        
        setupUserStatsView()
        
     
    }
    
    @objc func setupUserStatsView(){
        let stackView = UIStackView(arrangedSubviews: [eventsLabel,followersLabel,followingLabel])
        stackView.distribution = .fillEqually
        cellView.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.left.right.equalTo(cellView)
            make.bottom.equalTo(cellView.snp.bottom)
            make.height.equalTo(50)
        }
        
        cellView.addSubview(followButton)
        
        followButton.snp.makeConstraints { (make) in
            make.left.right.equalTo(cellView).inset(15)
            make.top.equalTo(cellView.snp.top)
            make.height.equalTo(30)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
