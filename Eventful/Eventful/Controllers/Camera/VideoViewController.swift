
import UIKit
import AVFoundation
import AVKit
import Firebase


class VideoViewController: UIViewController {
    
   public var eventKey = ""
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //URL of video to save to Firebase storage. URL is being passed from CameraViewController
    private var videoURL: URL
    
    // Allows you to play the actual mp4 or video
    var player: AVPlayer?
    // Allows you to display the video content of a AVPlayer
    var playerController : AVPlayerViewController?
    
    init(videoURL: URL) {
        self.videoURL = videoURL
        super.init(nibName: nil, bundle: nil)
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var nextButton: UIButton = {
        let nextButton = UIButton(frame: CGRect(x: 320, y: 600, width: 30, height: 30))
        nextButton.backgroundColor = UIColor.clear
        nextButton.setImage(#imageLiteral(resourceName: "next"), for: UIControlState())
        nextButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        nextButton.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
        return nextButton
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.gray
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])

        //Setting the video url of the AVPlayer
        player = AVPlayer(url: videoURL)
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
        // Added an observer for when the video stops playing so it can be on a continuous loop
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player!.currentItem)
        
        // Adding buttons programatically
        let cancelButton = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: 20.0, height: 20.0))
        cancelButton.setImage(#imageLiteral(resourceName: "cancel"), for: UIControlState())
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        //TODO: Need to fix frame of x and y
      
        view.addSubview(nextButton)
        
        //Constraints
        //        let margins = self.view.layoutMarginsGuide
        //        nextButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -20).isActive = true
        //        nextButton.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -20).isActive = true
        
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
    }
    
    
    @objc func cancel() {
               dismiss(animated: true, completion: nil)
//    _ = self.navigationController?.popViewController(animated: true)
    }
    
    // Takes you to AddPostViewController
    @objc func nextPressed()
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
        StorageService.uploadVideo(self.videoURL, at: storageRef) { (downloadUrl) in
            guard let downloadUrl = downloadUrl else {
                return
            }
            
            let videoUrlString = downloadUrl.absoluteString
            print(videoUrlString)
        PostService.create(for: self.eventKey, for: videoUrlString)
            
        }
        //svprogresshud insert here
        _ = self.navigationController?.popViewController(animated: true)
        player!.replaceCurrentItem(with: nil)

    }
    
    func handleDontAddToStory(){
      _ = self.navigationController?.popViewController(animated: true)
        player!.replaceCurrentItem(with: nil)

    }
    
    
    // Allows the video to keep playing on a loop
    @objc fileprivate func playerItemDidReachEnd(_ notification: Notification) {
        if self.player != nil {
            self.player!.seek(to: kCMTimeZero)
            self.player!.play()
        }
    }
}
