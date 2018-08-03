//
//  NewUserHeader.swift
//  Eventful
//
//  Created by Shawn Miller on 6/14/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit
import SimpleImageViewer
import Firebase

class NewUserHeader: UICollectionViewCell {
    var isFollowed: Bool?
    var isRequestPresent: Bool?
    var followNotificationData : Notifications!
    var user: User?{
        didSet {
            nameLabel.text = user?.name
            bioLabel.text = user?.bio
            if let profilePic = user?.profilePic {
                currentImage.loadImage(urlString: profilePic)

            }
            setupEditFollowButton()
        }
    }
    weak var profileViewController: NewProfileVC!

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
    //creatas a UILabel
    let nameLabel: UILabel = {
        let nameLabel = UILabel()
//        nameLabel.text = "Josh Hart"
        nameLabel.textColor = UIColor.black
        nameLabel.font = UIFont.boldSystemFont(ofSize: 15)
        return nameLabel
    }()
    
    //creatas a UILabel
    let bioLabel: UILabel = {
        let bioLabel = UILabel()
//        bioLabel.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse nunc massa, laoreet id sapien non, vehicula dapibus mi. Nam placerat lacinia diam, sed scelerisque dolor mollis sit amet"
        bioLabel.textColor = UIColor.lightGray
        bioLabel.numberOfLines = 0
        bioLabel.font = UIFont.systemFont(ofSize: 13)
        return bioLabel
    }()
    
    
    lazy var currentImage : CustomImageView = {
        let currentImage = CustomImageView()
        currentImage.setCellShadow()
        currentImage.clipsToBounds = true
        currentImage.translatesAutoresizingMaskIntoConstraints = false
        currentImage.contentMode = .scaleToFill
        currentImage.isUserInteractionEnabled = true
        currentImage.layer.masksToBounds = true
        let singleTap =  UITapGestureRecognizer(target: self, action: #selector(handleImageZoom))
        singleTap.numberOfTapsRequired = 1
        currentImage.addGestureRecognizer(singleTap)
        return currentImage
    }()
    
    @objc func handleImageZoom(){
        print("double tap recognized")
        let configuration = ImageViewerConfiguration { config in
            config.imageView = currentImage
        }
        let imageViewerController = ImageViewerController(configuration: configuration)
        profileViewController.present(imageViewerController, animated: true)
        
    }

    
    lazy var followersLabel : UILabel = {
       let followersLabel = UILabel()
        followersLabel.textAlignment = .center
        followersLabel.numberOfLines = 0
        followersLabel.isUserInteractionEnabled = true
        let singleTap =  UITapGestureRecognizer(target: self, action: #selector(presentFollowers))
        singleTap.numberOfTapsRequired = 1
        followersLabel.addGestureRecognizer(singleTap)
        return followersLabel
    }()
    
    
    lazy var followingLabel : UILabel = {
        let followingLabel = UILabel()
        followingLabel.numberOfLines = 0
        followingLabel.textAlignment = .center
        followingLabel.isUserInteractionEnabled = true
        let singleTap =  UITapGestureRecognizer(target: self, action: #selector(presentFollowing))
        singleTap.numberOfTapsRequired = 1
        followingLabel.addGestureRecognizer(singleTap)
        return followingLabel
    }()
    
    
    lazy var eventsLabel : UILabel = {
        let eventsLabel = UILabel()
        eventsLabel.numberOfLines = 0
        eventsLabel.textAlignment = .center
        return eventsLabel
    }()
    
    lazy var editFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.setupShadow2()
        button.setTitleColor(UIColor.darkText, for: .normal)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.layer.borderWidth = 0.4
         button.addTarget(self, action: #selector(didTapEditFollowButton), for: .touchUpInside)
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
    
    @objc func presentFollowing(){
        print("showing following")
        let following = FollowingViewController()
        profileViewController.navigationController?.pushViewController(following, animated: true)
        
    }
    
    @objc func presentFollowers(){
        let followers = FollowersViewController()
        profileViewController.navigationController?.pushViewController(followers, animated: true)
        print("showing followers")
    }
    
    @objc func setupUserStatsView(){
        
        cellView.addSubview(currentImage)
        currentImage.snp.makeConstraints { (make) in
            make.left.equalTo(cellView.snp.left).offset(15)
            make.top.equalTo(cellView.snp.top).offset(15)
            make.height.width.equalTo(80)
        }
        currentImage.layer.cornerRadius = 80/2
        
        cellView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(cellView.snp.left).offset(15)
            make.top.equalTo(currentImage.snp.bottom).offset(15)
            make.right.equalTo(cellView.snp.right).inset(70)
        }
        cellView.addSubview(bioLabel)
        bioLabel.snp.makeConstraints { (make) in
            make.left.equalTo(cellView.snp.left).offset(15)
            make.top.equalTo(nameLabel.snp.bottom).offset(15)
            make.right.equalTo(cellView.snp.right).inset(20)
        }
        
        
        cellView.addSubview(editFollowButton)

        editFollowButton.snp.makeConstraints { (make) in
            make.right.equalTo(cellView.snp.right).inset(15)
            make.left.equalTo(currentImage.snp.right).offset(90)
            make.top.equalTo(cellView.snp.top).offset(30)
            make.height.equalTo(40)
        }
        editFollowButton.layer.cornerRadius = 20

        let stackView = UIStackView(arrangedSubviews: [eventsLabel,followersLabel,followingLabel])
        stackView.distribution = .fillEqually
        cellView.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.left.right.equalTo(cellView)
            make.bottom.equalTo(cellView.snp.bottom)
            make.height.equalTo(30)
        }
     
    }
    
    
    fileprivate func setupEditFollowButton(){
        guard let currentLoggedInUser = Auth.auth().currentUser?.uid else{
            return
        }
        
        guard let uid = user?.uid else{
            return
        }
        
        if currentLoggedInUser == uid {
            //edit profile
        }else{
            //set title to follow
            // check if following
            if let user = user {
                FollowService.isUserFollowed(user) { (followStatus) in
                    if followStatus{
                        self.isFollowed = followStatus
                        self.editFollowButton.setTitle("Unfollow", for: .normal)
                    } else {
                        self.isFollowed = false
                        //check if there is a request present
                        //if so show request sent if not show the follow style
                        FriendService.system.checkForRequest(uid, success: { (success) in
                            //will return true if there is a request
                            self.isRequestPresent = success
                            if success{
                                self.setupRequestStyle()
                            }else{
                                //if there is no request show regular follow style
                                self.setupFollowStyle()
                            }
                        })
                    }
                }
            }
            
        }

        
    }
    
    @objc func didTapEditFollowButton(){
        //execute edit profile or follow or unfollow
        guard let currentLoggedInUser = Auth.auth().currentUser?.uid else{
            return
        }
        
        guard let uid = user?.uid else{
            return
        }
        
        if currentLoggedInUser == uid {
            //edit profile
            editFollowButton.isUserInteractionEnabled = false
            let profileSetupTransition = EditProfile()
            if let image = currentImage.image {
                profileSetupTransition.currentProfilePic = image
            }
            let navController = UINavigationController(rootViewController: profileSetupTransition)
            profileViewController.present(navController, animated: true, completion: nil)
            self.editFollowButton.isUserInteractionEnabled = true

        }else{
            editFollowButton.isUserInteractionEnabled = false
            let followee = user
            if let followStatus = self.isFollowed {
                if followStatus {
                    //if your following them and you tap the follow button unfollow the user
                    FollowService.setIsFollowing((followee?.isFollowed)!, fromCurrentUserTo: followee!) { [unowned self] (success) in
                        defer {
                            self.editFollowButton.isUserInteractionEnabled = true
                        }
                        
                        guard success else { return }
                        followee?.isFollowed = !(followee?.isFollowed)!
                        print(followee?.isFollowed ?? "true")
                        print("Successfully unfollowed user:", self.user?.username ?? "")
                        self.setupFollowStyle()
                        self.isFollowed = false
                    }
                    
                }else{
                    //first check if the user is private
                    if let privateStatus = user?.isPrivate {
                        if privateStatus {
                            //will first check if a request is present because if it is and you click it again it should delete the request
                            if self.isRequestPresent! {
                                if let followeeUID = followee?.uid{
                                    FriendService.system.removeFriendRequest(followeeUID)
                                    self.setupFollowStyle()
                                    self.editFollowButton.isUserInteractionEnabled = true
                                    self.isRequestPresent = false
                                }
                            }else{
                                //send the user a friend request because they want to make sure they know who they are following
                                if let followeeUID = followee?.uid {
                                    //will send the user a friend request and wait for them to accept it
                                    FriendService.system.sendRequestToUser(followeeUID)
                                    self.isRequestPresent = true
                                    setupRequestStyle()
                                    self.editFollowButton.isUserInteractionEnabled = true
                                }
                            }
                            
                        }else{
                            //if they are not private you can just follow them because they don't care
                            FollowService.setIsFollowing(!(followee?.isFollowed)!, fromCurrentUserTo: followee!) { [unowned self] (success) in
                                defer {
                                    self.editFollowButton.isUserInteractionEnabled = true
                                }
                                
                                guard success else { return }
                                print(followee?.isFollowed ?? "true")
                                
                                followee?.isFollowed = !(followee?.isFollowed)!
                                print(followee?.isFollowed ?? "true")
                                if let uid = self.user?.uid {
                                    self.followNotificationData = Notifications.init(reciever: uid, content: User.current.username! + " has followed you", type: notiType.follow.rawValue)
                                    
                                    FollowService.sendFollowNotification(self.followNotificationData)
                                }
                                
                                
                                print("Successfully followed user: ", self.user?.username ?? "")
                                self.editFollowButton.setTitle("Unfollow", for: .normal)
                                self.editFollowButton.backgroundColor = .white
                                self.editFollowButton.setTitleColor(.black, for: .normal)
                                self.isFollowed = true
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    //will setup the style change for when you first enter the screen and you have to follow the user
    fileprivate func setupFollowStyle() {
        self.editFollowButton.setTitle("Follow", for: .normal)
        self.editFollowButton.backgroundColor = UIColor.rgb(red: 44, green: 152, blue: 229)
        self.editFollowButton.setTitleColor(.white, for: .normal)
        self.editFollowButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
    }
    
    //will setup the button style for when you send the friend request for the user
    fileprivate func setupRequestStyle() {
        self.editFollowButton.setTitle("Request Sent", for: .normal)
        self.editFollowButton.backgroundColor = UIColor.rgb(red: 255, green: 255, blue: 255)
        self.editFollowButton.setTitleColor(.black, for: .normal)
        self.editFollowButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
