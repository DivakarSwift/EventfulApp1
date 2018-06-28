import Foundation
import UIKit
import AVFoundation
import AVKit
import Firebase
import Photos
import SnapKit


class VideoViewController: UIViewController {
    
    public var eventKey = ""
    
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "Close"), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    let saveToAlbum: UIButton = {
        let saveToAlbum = UIButton(type: .system)
        saveToAlbum.setImage(UIImage(named: "save_shadow"), for: .normal)
        saveToAlbum.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return saveToAlbum
    }()
    
    
    
    let shareButton: UIButton = {
        let shareButton = UIButton(type: .system)
        shareButton.setImage(#imageLiteral(resourceName: "icons8-circled-right-48").withRenderingMode(.alwaysOriginal), for: .normal)
        shareButton.addTarget(self, action: #selector(handleAdd), for: .touchUpInside)
        return shareButton
    }()
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //URL of video to save to Firebase storage. URL is being passed from CameraViewController
    var videoURL: URL?
    
    // Allows you to play the actual mp4 or video
    var player: AVPlayer?
    // Allows you to display the video content of a AVPlayer
    var playerController : AVPlayerViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.gray
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
        
        // Added an observer for when the video stops playing so it can be on a continuous loop
        
        setupViews()
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player!.currentItem)
        
    }
    
    @objc func setupViews(){
        player = AVPlayer(url: videoURL!)
        
        
        playerController = AVPlayerViewController()
        
        guard player != nil && playerController != nil else {
            return
        }
        playerController!.showsPlaybackControls = false
        // Setting AVPlayer to the player property of AVPlayerViewController
        playerController!.player = player!
        self.addChildViewController(playerController!)
        self.view.addSubview(playerController!.view)
        
        playerController!.view.frame = view.frame
        self.view.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(10)
            make.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).inset(15)
            make.height.width.equalTo(40)
        }
        self.view.addSubview(shareButton)
        shareButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(10)
            make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).inset(10)
            make.height.width.equalTo(35)
        }
        
        self.view.addSubview(saveToAlbum)
        saveToAlbum.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(10)
            make.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).inset(10)
            make.height.width.equalTo(40)
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player?.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
        player?.play()
        
    }
    
    
    @objc func handleCancel() {
        player?.pause()
        player = nil
        dismiss(animated: true, completion: nil)
    }
    
    // Takes you to AddPostViewController
    @objc func handleAdd()
    {
        print("Next Button pressed")
        
        // Setting nil to the player so video will stop playing
        let alertController = UIAlertController(title: "Add To The Hype??", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let addAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            self.handleAddToStory()
        }
        alertController.addAction(addAction)
        let cancelAction = UIAlertAction(title: "No", style: .default) { (_) in
            self.handleDontAddToStory()
        }
        alertController.addAction(cancelAction)
        
        present(alertController, animated:true, completion: nil)
        
    }
    
    func handleAddToStory(){
        print("Attempting to add to story")
        print(self.eventKey)
        let dateFormatter = ISO8601DateFormatter()
        let timeStamp = dateFormatter.string(from: Date())
        let uid = User.current.uid
        let storageRef = Storage.storage().reference().child("event_stories").child(self.eventKey).child(uid).child(timeStamp + ".MOV")
        StorageService.uploadVideo(self.videoURL!, at: storageRef) { (downloadUrl) in
            guard let downloadUrl = downloadUrl else {
                return
            }
            
            let videoUrlString = downloadUrl.absoluteString
            print(videoUrlString)
            PostService.create(for: self.eventKey, for: videoUrlString)
            
        }
        //svprogresshud insert here
        //        _ = self.navigationController?.popViewController(animated: true)
        dismiss(animated: true) {
            self.player!.replaceCurrentItem(with: nil)
        }
        
        
    }
    
    func handleDontAddToStory(){
        //      _ = self.navigationController?.popViewController(animated: true)
        dismiss(animated: true) {
            self.player!.replaceCurrentItem(with: nil)
        }
        
    }
    
    
    
    
    // Allows the video to keep playing on a loop
    @objc fileprivate func playerItemDidReachEnd(_ notification: Notification) {
        if self.player != nil {
            self.player!.seek(to: kCMTimeZero)
            self.player!.play()
        }
    }
}

//will hold all of the functions that correspond to the buttons
extension VideoViewController {
    @objc func handleSave(){
        print("Attempting to save photo")
        guard let outputFileURL = videoURL else {
            return
        }
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                // Save the movie file to the photo library and cleanup.
                PHPhotoLibrary.shared().performChanges({
                    let options = PHAssetResourceCreationOptions()
                    options.shouldMoveFile = true
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    creationRequest.addResource(with: .video, fileURL: outputFileURL, options: options)
                }, completionHandler: { success, error in
                    if !success {
                        print("Could not save movie to photo library: \(String(describing: error))")
                    }
                    
                    DispatchQueue.main.async {
                        let savedLabel = UILabel()
                        savedLabel.text = "Saved Successfully"
                        savedLabel.font = UIFont.boldSystemFont(ofSize: 18)
                        savedLabel.textColor = .white
                        savedLabel.numberOfLines = 0
                        savedLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
                        savedLabel.textAlignment = .center
                        
                        savedLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
                        savedLabel.center = self.view.center
                        
                        self.view.addSubview(savedLabel)
                        
                        savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
                        
                        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                            
                            savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
                            
                        }, completion: { (completed) in
                            //completed
                            
                            UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                                
                                savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                                savedLabel.alpha = 0
                                
                            }, completion: { (_) in
                                
                                savedLabel.removeFromSuperview()
                                //self.removeFromSuperview()
                            })
                            
                        })
                    }
                    
                }
                )
            } else {
            }
        }
    }
}
