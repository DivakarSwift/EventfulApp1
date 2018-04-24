//
//  UserHeader.swift
//  Eventful
//
//  Created by Shawn Miller on 8/15/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SnapKit

class UserProfileHeader: UICollectionViewCell {
    var user: User?{
        didSet {
            setupProfileImage()
            //  userNameLabel.text = user?.username
            setupUserInteraction()
        }
    }
    var followNotificationData : Notifications!
    weak var profileViewController: ProfileeViewController!

    lazy var profileImage: UIImageView = {
        let profilePicture = UIImageView()
        profilePicture.layer.borderWidth = 1.0
        profilePicture.layer.borderColor = UIColor.black.cgColor
        profilePicture.clipsToBounds = true
        profilePicture.translatesAutoresizingMaskIntoConstraints = false
        profilePicture.contentMode = .scaleToFill
        profilePicture.isUserInteractionEnabled = true
        profilePicture.layer.shouldRasterize = true
        profilePicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        // will allow you to add a target to an image click
        profilePicture.layer.masksToBounds = true
        return profilePicture
    }()
    lazy var statsLabel : UILabel = {
        let statsLabel = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "Score", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
        statsLabel.attributedText = attributedText
        statsLabel.numberOfLines = 0
        statsLabel.textAlignment = .center
        return statsLabel
    }()

    // will be the button that the user clicks to edit there profile settings
    lazy var profileeSettings: UIButton = {
        let profileSetup = UIButton(type: .system)
        profileSetup.setImage(#imageLiteral(resourceName: "icons8-Edit-50").withRenderingMode(.alwaysOriginal), for: .normal)
        profileSetup.setTitleColor(.black, for: .normal)
        return profileSetup
    }()
    lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
       // button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(didTapFollowButton), for: .touchUpInside)
        return button
    }()
    lazy var backButton: UIButton = {
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "icons8-Back-64"), for: .normal)
        return backButton
    }()
    var userStackView: UIStackView?
    var currentUserDividerView: UIView?
    var notCurrentUserDividerView: UIView?

    fileprivate func setupUserInteraction (){
        guard let currentLoggedInUser = Auth.auth().currentUser?.uid else{
            return
        }
        guard let uid = user?.uid else{
            return
        }
//        self.notCurrentUserDividerView?.isHidden = true
//        self.currentUserDividerView?.isHidden = true
//        self.followButton.isHidden = true
//        self.userStackView?.isHidden = true
        self.profileeSettings.removeFromSuperview()
        self.currentUserDividerView?.removeFromSuperview()
        self.notCurrentUserDividerView?.removeFromSuperview()
        self.followButton.removeFromSuperview()
        self.userStackView?.removeFromSuperview()
        
        if currentLoggedInUser == uid {
            //will hide buttons related to user that is not current user
            setupCurrentLoggedInUserView()

        } else{
            addSubview(self.followButton)
            followButton.anchor(top: profileStackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 50, paddingBottom:0 , paddingRight: 50, width: 0, height: 0)
             notCurrentUserDividerView = UIView()
            notCurrentUserDividerView?.backgroundColor = UIColor.lightGray
            addSubview(notCurrentUserDividerView!)
            notCurrentUserDividerView?.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
            // check if following
            Database.database().reference().child("following").child(currentLoggedInUser).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                    
                    self.followButton.setTitle("Unfollow", for: .normal)
                    
                } else {
                    self.setupFollowStyle()
                }
                
            }, withCancel: { (err) in
                print("Failed to check if following:", err)
            })
            
        }
    }
    
    
    @objc func setupCurrentLoggedInUserView() {
        addSubview(profileeSettings)
        profileeSettings.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top)
            make.left.equalTo(self.snp.left).offset(4)
        }
        
      
        
        currentUserDividerView = UIView()
        currentUserDividerView?.backgroundColor = UIColor.lightGray
        addSubview(currentUserDividerView!)
        currentUserDividerView?.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    @objc func handleZoomTap(tapGesture: UITapGestureRecognizer){
        //Pro Tip: Dont perform a lot of custom logic inside a view class
        if let imageView = tapGesture.view as? UIImageView {
            //PRO Tip: don't perform a lot of custom logic inside of a view class
            self.profileViewController?.performZoomInForStartingImageView(startingImageView: imageView)
        }
    }
    
    @objc func didTapFollowButton(){
        print("function handled")
        followButton.isUserInteractionEnabled = false
        let followee = user
        
        
        //will check if the user if being followed or not
        if (followee?.isFollowed)! {
            //will unfollow the user
            FollowService.setIsFollowing(!(followee?.isFollowed)!, fromCurrentUserTo: followee!) { [unowned self] (success) in
                defer {
                    self.followButton.isUserInteractionEnabled = true
                }
                
                guard success else { return }
                followee?.isFollowed = !(followee?.isFollowed)!
                print(followee?.isFollowed ?? "true")
                print("Successfully unfollowed user:", self.user?.username ?? "")
                self.setupFollowStyle()
            }
        }else{
            //will follow the user
            FollowService.setIsFollowing(!(followee?.isFollowed)!, fromCurrentUserTo: followee!) { [unowned self] (success) in
                defer {
                    self.followButton.isUserInteractionEnabled = true
                }
                
                guard success else { return }
                print(followee?.isFollowed ?? "true")
                
                followee?.isFollowed = !(followee?.isFollowed)!
                print(followee?.isFollowed ?? "true")
                
                self.followNotificationData = Notifications.init(reciever: self.user!, content: User.current.username! + " has followed you", type: "follow")
                
                FollowService.sendFollowNotification(self.followNotificationData)
                print("Successfully followed user: ", self.user?.username ?? "")
                self.followButton.setTitle("Unfollow", for: .normal)
                self.followButton.backgroundColor = .white
                self.followButton.setTitleColor(.black, for: .normal)
            }
            
        }
        
        
    }
    
    fileprivate func setupFollowStyle() {
        self.followButton.setTitle("Follow", for: .normal)
        self.followButton.backgroundColor = UIColor.rgb(red: 231, green: 44, blue: 123)
        self.followButton.setTitleColor(.white, for: .normal)
        self.followButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
    }
    

    
    
    fileprivate func setupProfileImage() {
        
        
        print("Did set username \(user?.username ?? "")")
        
        
        guard let profileImageUrl = user?.profilePic else {return }
        
        guard let url = URL(string: profileImageUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            //check for the error, then construct the image using data
            if let err = err {
                print("Failed to fetch profile image:", err)
                return
            }
            
            //perhaps check for response status of 200 (HTTP OK)
            
            guard let data = data else { return }
            
            let image = UIImage(data: data)
            
            //need to get back onto the main UI thread
            DispatchQueue.main.async {
                self.profileImage.image = image
            }
            
            }.resume()
    }
    
    lazy var profileStackView = UIStackView(arrangedSubviews: [profileImage])
    
    fileprivate func setupProfileStack(){
        addSubview(profileStackView)
        profileStackView.anchor(top: topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 125, height: 125)
        profileStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        profileImage.layer.cornerRadius = 125/2
        
       // setupToolBar()
        setupProfileStack()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
