//
//  Stories.swift
//  Eventful
//
//  Created by Shawn Miller on 8/21/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import AFDateHelper
import Firebase
import AZDialogView

class StoriesViewController: UIViewController {
    
    /// the event key
    var eventKey = ""
    
    /// Array of all the stories for this event
    var allStories = [Story]()
    
    /// Player Controller for the story that will contain the video if it has one
    var playerController: AVPlayerViewController!
    
    /// Loading indicator for loading a story
    var indicator: UIActivityIndicatorView!
    
    /// Blur View to make the transation for loading look nicer
    var blurView: UIVisualEffectView!
    
    /// Image view for the story if it contains an image
    var imageView: UIImageView!
    
    /// The current story index (allStories array)
    var currentIndex = 0
    //
    var eventDetailRef: EventDetailViewController?
    /// Flags for to see if using is rewinding/forwarding/or on repeat
    var isRewinding = false
    var isForwarding = false
    var onRepeat = false
    
    /// Array of all the durations for each story
    var durations = [TimeInterval]()
    
    /// Gesture recoginzers for taps and swipes
    var tapInfoView: UITapGestureRecognizer!
    var zoomVideoTap: UITapGestureRecognizer!
    var swipeInfoView: UISwipeGestureRecognizer!
    
    /// Views to detect if user is tapping back or forward
    var leftRect: CGRect! // back
    var rightRect: CGRect!  // forward
    
    //The Info View for the username/time/profile image
    var infoView: UIView!
    var infoImageView: UIImageView!
    var infoNameLabel: UILabel!
    var infoTimeLabel: UILabel!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // App enter in forground.
    @objc func applicationWillEnterForeground(_ notification: Notification) {
        playerController.player?.play()
    }
    
    // App enter in forground.
    @objc func applicationDidEnterBackground(_ notification: Notification) {
        playerController.player?.pause()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add the observers to stop the video from freezing when the app goes to the background
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)
        
        tapInfoView = UITapGestureRecognizer(target: self, action: #selector(self.tapInfoViewPressed(_:)))
        zoomVideoTap = UITapGestureRecognizer(target: self, action: #selector(self.zoomTapPressed(_:)))
        swipeInfoView = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedInfoView(_:)))
        
        zoomVideoTap.numberOfTapsRequired = 2
        tapInfoView.numberOfTapsRequired = 1
        swipeInfoView.direction = .down
        
        tapInfoView.require(toFail: zoomVideoTap)

        // Setup the views for detecting back and forward taps
        let width = self.view.frame.width / 4
        leftRect = CGRect(x: 0, y: 0, width: width, height: self.view.frame.height)
        rightRect = CGRect(x: self.view.frame.maxX - width, y: 0, width: width, height: self.view.frame.height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchStories()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove the observers
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
        
        // CLEAN EVERYTHING UP
       
        if playerController != nil, imageView != nil, infoView != nil {
            playerController.view.removeFromSuperview()
            imageView.removeFromSuperview()
            infoView.removeFromSuperview()
            
            infoImageView.image = nil
            playerController.player = nil
            playerController = nil
            imageView = nil
            
            infoNameLabel.text = ""
            infoTimeLabel.text = ""
        }

        // Since user is leaving stories we need to save their current index for what story they are on
        UserService.setCurrentIndexOfStory(currentIndex: currentIndex, eventId: eventKey, completion: { (user) in
            
            if user != nil {
                print("worked")
            }
        })
    }
    
    @IBAction func tapInfoViewPressed(_ sender: AnyObject) {
        let tapLocation = sender.location(in: self.view)
        handleTap(tappedLocation: tapLocation)
    }
    
    @IBAction func swipedInfoView(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func zoomTapPressed(_ sender: AnyObject){
        if playerController.videoGravity == AVLayerVideoGravity.resizeAspect.rawValue {
            playerController.videoGravity = AVLayerVideoGravity.resizeAspectFill.rawValue
        }else if playerController.videoGravity == AVLayerVideoGravity.resizeAspectFill.rawValue {
            playerController.videoGravity = AVLayerVideoGravity.resizeAspect.rawValue
        }
    }
    
    /// Handle left and right taps aka back and forward taps
    ///
    /// - Parameter tapLocation: where the user tapped
    private func handleTap(tappedLocation: CGPoint) {
        
        if rightRect.contains(tappedLocation) {
            // next pressed
            self.currentIndex = currentIndex + 1
            let tempIndex = currentIndex
            
            
            if tempIndex < allStories.count {
                
                // you can go to the next story
                playerController.player = nil
                infoImageView.image = nil
                infoNameLabel.text = ""
                infoTimeLabel.text = ""
                
                let story = allStories[tempIndex]
                getStoryInfo(story: story)
                playStory(story: story, isFirst: false)

                
            } else {
                // reached end of story so repeat
                currentIndex = 0
                onRepeat = true
            }
            
        } else if leftRect.contains(tappedLocation) {
            // back pressed
            self.currentIndex = currentIndex - 1

            let tempIndex = currentIndex

            if currentIndex >= 0 {
                
                // you can go back
                isRewinding = true
                
                playerController.player = nil
                infoImageView.image = nil
                infoNameLabel.text = ""
                infoTimeLabel.text = ""
                
                let story = allStories[tempIndex]
                getStoryInfo(story: story)
                playStory(story: story, isFirst: false)

                
            } else {
                //can't go back so leave the story vc
                self.currentIndex = 0
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    /// Get the stories
    fileprivate func fetchStories(){
        
        StoryService.showEvent(for: self.eventKey) { (stories) in
            
            // reset the current index
            self.currentIndex = 0
            
            // clear the arrays
            
            self.allStories = stories
            
            if self.allStories.count > 0 {
                self.playStories()
            } else {
                // No stories
                self.dismiss(animated: false, completion: {
                 let dialog = AZDialogViewController(title: "Sorry", message: "There is currently no video or image content associated with the story for this event")
                    
                    dialog.titleColor = .black
                    
                    //set the message color
                    dialog.messageColor = .black
                    
                    //set the dialog background color
                    dialog.alertBackgroundColor = .white
                    
                    //set the gesture dismiss direction
                    dialog.dismissDirection = .bottom
                    
                    //allow dismiss by touching the background
                    dialog.dismissWithOutsideTouch = true
                    //show seperator under the title
                    dialog.showSeparator = true
                    //set the seperator color
                    dialog.separatorColor = UIColor.rgb(red: 44, green: 152, blue: 229)
                    //enable/disable drag
                    dialog.allowDragGesture = true
                    //enable rubber (bounce) effect
                    dialog.rubberEnabled = true
                    //enable/disable backgroud blur
                    dialog.blurBackground = true
                    
                    //set the background blur style
                    dialog.blurEffectStyle = .prominent
                    dialog.imageHandler = { (imageView) in
                        imageView.image = UIImage(named: "appIcon")
                        imageView.contentMode = .scaleAspectFit
                        return true //must return true, otherwise image won't show.
                    }
                    
                    dialog.cancelButtonStyle = { (button,height) in
                        button.tintColor = UIColor.rgb(red: 44, green: 152, blue: 229)
                        button.setTitle("CANCEL", for: [])
                        return true //must return true, otherwise cancel button won't show.
                    }
                    
                    if let eventDetail = self.eventDetailRef {
                        dialog.show(in: eventDetail)
                    }
                    
                })
            }
        }
    }
    
    
    /// Setup the view for stories
    private func setupViews() {
        view.backgroundColor = .clear
        // Setup the blur view for loading
        blurView = UIVisualEffectView(frame: view.frame)
        blurView.effect = UIBlurEffect(style: .regular)
        
        self.view.addSubview(blurView)
        
        // Indicator for loading
        let indicatorFrame = CGRect(x: view.center.x - 20, y: view.center.y - 20, width: 40, height: 40)
        indicator = UIActivityIndicatorView(frame: indicatorFrame)
        indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = .whiteLarge
        
        blurView.contentView.addSubview(indicator)
        
        // Player Controller
        playerController = AVPlayerViewController()
        playerController.showsPlaybackControls = false
        
        self.addChildViewController(playerController)
        
        // Image view for the story
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        
        infoView = UIView(frame: self.view.frame)
        infoView.backgroundColor = UIColor.clear

        // The image view for the user of the current story
        infoImageView = UIImageView()
        self.view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        self.view.addSubview(playerController.view)
//        self.view.bringSubview(toFront: spb)
        
        self.view.addSubview(infoView)
        
        self.infoView.addSubview(infoImageView)
        
        infoImageView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(2)
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(10)
            make.height.width.equalTo(30)
        }
        infoImageView.layer.cornerRadius = 15
        infoImageView.layer.masksToBounds = true
        
        // The name for the user of the current story
        infoNameLabel = UILabel()
        infoNameLabel.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        infoNameLabel.textColor = UIColor.white
        infoNameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        infoNameLabel.adjustsFontSizeToFitWidth = true
        
        self.infoView.addSubview(infoNameLabel)
        
        infoNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(infoImageView.snp.right).offset(5)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(2)
            make.height.equalTo(30)
            make.width.equalTo(80)
        }
        
        // Time label for long ago the story was posted
        infoTimeLabel = UILabel()
        infoTimeLabel.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        infoTimeLabel.textColor = UIColor.white
        
        self.infoView.addSubview(infoTimeLabel)
        
        infoTimeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(infoNameLabel.snp.right).offset(5)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(2)
            make.height.equalTo(30)
            make.width.equalTo(50)
        }
        
        infoView.isUserInteractionEnabled = true
        infoView.addGestureRecognizer(tapInfoView)
        infoView.addGestureRecognizer(zoomVideoTap)
        infoView.addGestureRecognizer(swipeInfoView)
        
        infoTimeLabel.layer.cornerRadius = 10
        infoTimeLabel.layer.masksToBounds = true
        infoTimeLabel.textAlignment = .center
        
        infoNameLabel.layer.cornerRadius = 10
        infoNameLabel.layer.masksToBounds = true
        infoNameLabel.textAlignment = .center
        
        playerController.view.frame = view.bounds

        playerController.videoGravity = AVLayerVideoGravity.resizeAspect.rawValue

//        spb.durations = durations
    }
    
    private func playStories() {
        
        self.setupViews()
        
        if let uid = Auth.auth().currentUser?.uid {
            
            // Get the current index for what story the user left on if it exists
            UserService.getCurrentIndexOfStory(eventId: eventKey, userId: uid, completion: { (savedIndex) in
                
                if var savedIndex = savedIndex {
                    
                    if savedIndex >= self.allStories.count || savedIndex <= self.allStories.count {
                        savedIndex = 0
                    }
                    
                    
                    self.currentIndex = savedIndex
//                    self.spb.savedIndex = savedIndex
                    
                    // if the current index isn't equal to 0 then skip to the correct story and bar
                    if self.currentIndex != 0 {
//                        self.spb.skipBars(number: self.currentIndex - 1)
                    }
                }
                let story = self.allStories[self.currentIndex]
                
                self.getStoryInfo(story: story)
                self.playStory(story: story, isFirst: true)
            })
        }
    }
    
    
    /// Freeze the view until the video is loaded
    private func freezeViewsUntilLoaded() {
        if playerController != nil {
            playerController.view.isUserInteractionEnabled = false
            imageView.isUserInteractionEnabled = false
        }
    }
    
    /// Unfreeze the view
    private func unfreeze() {
        if playerController != nil {
            playerController.view.isUserInteractionEnabled = true
            imageView.isUserInteractionEnabled = true
        }
    }
    
    
    
    
    
    /// Get the user info from the story
    ///
    /// - Parameter story: the current story
    private func getStoryInfo(story: Story) {
        
        // setup the time label
        setupTimeLabel(date: story.date)
        
        UserService.show(forUID: story.uid) { (user) in
            
            if let user = user {
                // Set the name label to the username
                self.infoNameLabel.text = user.username
                
                let imageUrl = URL(string: user.profilePic!)
                
                if user.profilePic != "" {
                    print("Tried to load default pic")
                    // Set the image view to the current users profile image
                    self.infoImageView.af_setImage(withURL: imageUrl!)
                    
                } else {
                    print("Set image Url")
                    self.infoImageView.image = UIImage(named: "no-profile-pic")
                }
                
            } else {
                //user doesnt exist for some reason
                print("the user doesnt exist in the database...")
            }
            
        }
    }
    
    
    /// Play the story
    ///
    /// - Parameters:
    ///   - story: the current story
    ///   - isFirst: flag to see if its the first story
    private func playStory(story: Story, isFirst: Bool) {
        
        // Check if the url is a video or image
        if story.Url.contains(".mp4") {
            // video
            self.playerController.view.isHidden = false
            self.view.bringSubview(toFront: playerController.view)
//            self.view.bringSubview(toFront: spb)
            self.view.bringSubview(toFront: infoView)
            
            let videoUrl = URL(string: story.Url)
            playerController.player = AVPlayer(url: videoUrl!)
            
            // Freeze the view from user interaction and show the loader
            freezeViewsUntilLoaded()
            showLoader()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                self.unfreeze()
                
                self.hideLoader()
                
                if self.playerController != nil {
                    self.playerController.player?.play()
                    
                    // If this is the first story that the user is watching than start the animation
                    // for the progress bar else unpause the progress bar if its not the first story
                    if isFirst {
//                        self.spb.startAnimationAt(index: self.currentIndex)
                    } else {
//                        self.spb.isPaused = false
                    }
                }
                
            })
            
        } else {
            // photo
            self.view.bringSubview(toFront: imageView)
//            self.view.bringSubview(toFront: spb)
            self.view.bringSubview(toFront: infoView)
            
            let url = URL(string: story.Url)
            let data = try! Data(contentsOf: url!)
            let image = UIImage(data: data)
            
            showLoader()
            
//            self.spb.currentAnimationIndex = self.currentIndex
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                
                self.hideLoader()
                
                // If this is the first story that the user is watching than start the animation
                // for the progress bar else unpause the progress bar if its not the first story
                if isFirst {
//                    self.spb.startAnimationAt(index: self.currentIndex)
                } else {
//                    self.spb.isPaused = false
                }
                
                self.imageView.image = image
                
            })
            
        }
    }
    
    
    /// Setup up the time label for the current story
    ///
    /// - Parameter date: the upload date of the current story
    private func setupTimeLabel(date: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        let start = dateFormatter.date(from: date)
        let minutes = Int(Date().since(start!, in: .minute))
        
        // Format the date
        if minutes > 60 {
            let hours = minutes / 60
            
            if hours < 24 {
                infoTimeLabel.text = "\(hours)hr"
                
            } else {
                let days = Int(Date().since(start!, in: .day))
                infoTimeLabel.text = "\(days)d"
            }
            
        } else {
            infoTimeLabel.text = "\(minutes)min"
        }
    }
    
    private func showLoader() {
        blurView.alpha = 1
        self.view.bringSubview(toFront: blurView)
        indicator.startAnimating()
    }
    
    private func hideLoader() {
        UIView.animate(withDuration: 0.40, animations: {
            self.blurView.alpha = 0
            self.indicator.stopAnimating()
        }) { (complete) in
            self.view.sendSubview(toBack: self.blurView)
        }
        
    }
    
}
