//
//  FollowerCell.swift
//  Eventful
//
//  Created by Shawn Miller on 6/1/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit


class FollowerCell: UITableViewCell {
    var user: User? {
        didSet{
            guard let profilePic = user?.profilePic else {
                return
            }
            guard let userName = user?.username else {
                return
            }
            guard let displayName = user?.name else {
                return
            }
            self.profileImageView.loadImage(urlString: profilePic)
            let attributedText = NSMutableAttributedString(string: userName, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "\n", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 4)]))
            attributedText.append(NSAttributedString(string: displayName, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12), NSAttributedStringKey.foregroundColor: UIColor.gray]))
            textView.attributedText = attributedText
            textViewDidChange(textView)
            
        }
    }
    
    lazy var profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        //        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileTransition)))
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.isScrollEnabled = false
        textView.textContainer.maximumNumberOfLines = 0
        textView.isEditable = false
        return textView
    }()
    
    lazy var unfollowButton: UIButton = {
        let unfollowButton = UIButton()
        unfollowButton.setTitle("Unfollow", for: .normal)
        unfollowButton.layer.borderWidth = 0.5
        unfollowButton.layer.borderColor = UIColor.lightGray.cgColor
        unfollowButton.setTitleColor(.black, for: .normal)
        unfollowButton.titleLabel?.font =  UIFont(name: "Avenir-Heavy", size: 15)
        unfollowButton.addTarget(self, action: #selector(unfollowTapped), for: .touchUpInside)
        return unfollowButton
    }()
    
    @objc func unfollowTapped(){
        //will deny the users friend request and remove it
        print("deny tapped")
        //will unfollow the user
        if let user = user {
            FollowService.setIsFollowing(false, fromCurrentUserTo: user) { (success) in
                if success {
                    print("unfollowed user")
                }
            }
        }
        
    }
    
    
    
    @objc func setupViews(){
        addSubview(profileImageView)
        addSubview(textView)
        addSubview(unfollowButton)
        profileImageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top).inset(8)
            make.left.equalTo(self.snp.left).offset(8)
            make.height.width.equalTo(40)
        }
        profileImageView.layer.cornerRadius = 40/2
        textView.delegate = self
        textView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(4)
            make.height.equalTo(50)
            make.left.equalTo(profileImageView.snp.right).offset(4)
        }
        unfollowButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.safeAreaLayoutGuide.snp.right).inset(10)
            make.top.bottom.equalTo(self).inset(10)
        }
        
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

extension FollowerCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: self.frame.width - 5, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
    }
    
}
