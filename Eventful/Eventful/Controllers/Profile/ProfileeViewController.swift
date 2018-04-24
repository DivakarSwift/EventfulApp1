    //
    //  ProfileeViewController.swift
    //  Eventful
    //
    //  Created by Shawn Miller on 7/30/17.
    //  Copyright © 2017 Make School. All rights reserved.
    //
    
    import UIKit
    import SwiftyJSON
    import  AlamofireImage
    import Alamofire
    import AlamofireNetworkActivityIndicator
    import Foundation
    import Firebase
    import FirebaseDatabase
    import FirebaseStorage
    
    
    class ProfileeViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
        var profileHandle: DatabaseHandle = 0
        var profileRef: DatabaseReference?
        let cellID = "cellID"
        var userEvents = [Event]()
        var userId: String?
        var user: User?
        var emptyLabel: UILabel?
        
        var currentUserName: String = ""
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            collectionView?.backgroundColor = UIColor.white
            user = self.user ?? User.current
            
            profileHandle = UserService.observeProfile(for: user!) { [unowned self](ref, user, events) in
                self.profileRef = ref
                self.user = user
                self.userEvents = events
                // self.jobs = allJobs
                // self.reciepts = allReciepts
                
                // print(self.userEvents)
                //  print(self.reciepts)
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
                
            }
            
            // fetchUser()
            
            self.collectionView?.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
            navigationItem.title = user?.username
            collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerID")
            
            collectionView?.register(EventsAttendingCell.self, forCellWithReuseIdentifier: cellID)
            //        fetchEvents()
            collectionView?.alwaysBounceVertical = true
        }
        
        deinit {
            profileRef?.removeObserver(withHandle: profileHandle)
            print("removed from memory")
        }
        
        
        override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerID", for: indexPath) as! UserProfileHeader
            header.profileeSettings.addTarget(self, action: #selector(profileSettingsTapped), for: .touchUpInside)
            header.profileViewController = self
            header.user = self.user
            header.backButton.addTarget(self, action: #selector(GoBack), for: .touchUpInside)
            return header
        }
        
        @objc func GoBack(){
            dismiss(animated: true, completion: nil)
            
        }
        

        
        @objc func profileSettingsTapped(){
            var profileSetupTransition = AlterProfileViewController()
            let navController = UINavigationController(rootViewController: profileSetupTransition)
            present(navController, animated: true, completion: nil)
            //        self.navigationController?.pushViewController(profileSetupTransition, animated: true)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
            return CGSize(width: view.frame.width, height: 195)
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            //self.navigationController?.isNavigationBarHidden = true
            
            self.collectionView?.reloadData()
        }
        
        
        
        override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            
            if userEvents.isEmpty == false {
                self.collectionView?.backgroundView = nil
                return userEvents.count
                
            } else{
                emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
                let paragraph = NSMutableParagraphStyle()
                paragraph.lineBreakMode = .byWordWrapping
                paragraph.alignment = .center
                
                let attributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): UIFont.systemFont(ofSize: 14.0), NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.lightGray, NSAttributedStringKey(rawValue: NSAttributedStringKey.paragraphStyle.rawValue): paragraph]
                let myAttrString = NSAttributedString(string:  "Go Attend Some Events", attributes: attributes)

                emptyLabel?.attributedText = myAttrString
                emptyLabel?.textAlignment = .center
                self.collectionView?.backgroundView = emptyLabel
                return 0
            }
        }
        
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 1
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 1
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = (view.frame.width - 2)/3
            return CGSize(width: width, height: width)
            
        }
        
        override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! EventsAttendingCell
            cell.layer.cornerRadius = 70/2
            cell.event = userEvents[indexPath.item]
            
            return cell
        }
        //custom zoom logic
        var blackBackgroundView: UIView?
        var startingFrame: CGRect?
        var startingImageView: UIImageView?

        @objc func performZoomInForStartingImageView(startingImageView: UIImageView){
            self.startingImageView = startingImageView
            self.startingImageView?.isHidden = true
            startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
            let zoomingImageView = UIImageView(frame: startingFrame!)
            zoomingImageView.layer.cornerRadius = 100/2
            zoomingImageView.isUserInteractionEnabled = true
            zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))

            //zoomingImageView.backgroundColor = UIColor.red
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
                    zoomingImageView.image = image
                }
                
                }.resume()
            if let keyWindow = UIApplication.shared.keyWindow {
                blackBackgroundView = UIView(frame: keyWindow.frame)
                blackBackgroundView?.backgroundColor = UIColor.black
                blackBackgroundView?.alpha = 0
                keyWindow.addSubview(blackBackgroundView!)
                keyWindow.addSubview(zoomingImageView)

                UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.blackBackgroundView?.alpha = 1
                    // math?
                    // h2 / w1 = h1 / w1
                    // h2 = h1 / w1 * w1
                    let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                    
                    zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                    
                    zoomingImageView.center = keyWindow.center
                    
                }, completion: { (completed) in
                    //                    do nothing
                })

            }
        }
        
        @objc func handleZoomOut(_ tapGesture: UITapGestureRecognizer){
            if let zoomOutImageView = tapGesture.view {
                //need to animate back out to controller
                zoomOutImageView.layer.cornerRadius = 100/2
                zoomOutImageView.clipsToBounds = true
                UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    
                    zoomOutImageView.frame = self.startingFrame!
                    self.blackBackgroundView?.alpha = 0
                }, completion: { (completed) in
                    zoomOutImageView.removeFromSuperview()
                    self.startingImageView?.isHidden = false
                })
                
            }
        }
        
        
    }
    
    

    
    
