//
//  EventDetailViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 8/7/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SnapKit

class EventDetailViewController: UIViewController,UIScrollViewDelegate {
    var imageURL: URL?
    var currentEvent : Event?{
        didSet{
            imageURL = URL(string: (currentEvent?.currentEventImage)!)

            DispatchQueue.main.async {
                self.currentEventImage.af_setImage(withURL: self.imageURL!, placeholderImage: nil, filter: nil, progress: nil, progressQueue: .main, imageTransition: .crossDissolve(0.5), runImageTransitionIfCached: false, completion: { (response) in
                    let image = response.result.value // UIImage Object
                })
            }
            //will pass the event description to the corresponding label
            infoText.text = currentEvent?.currentEventDescription
            updateWithSpacing(lineSpacing: 5.0)
            guard let currentZip = currentEvent?.currentEventZip else{
                return
            }
            let firstPartOfAddress = (currentEvent?.currentEventStreetAddress)!  + "\n" + (currentEvent?.currentEventCity)! + ", " + (currentEvent?.currentEventState)!
            let secondPartOfAddress = firstPartOfAddress + " " + String(describing: currentZip)
            addressLabel.text = secondPartOfAddress
            
            let dateComponets = getDayAndMonthFromEvent(currentEvent!)
            currentEventDate.text = dateComponets.1 + ", \(dateComponets.0)\n\(currentEvent?.currentEventTime?.lowercased() ?? "")"
            eventKey = (currentEvent?.key)!
            eventPromo = (currentEvent?.currentEventPromo)!
            setupAttendInteraction()
            titleView.text = currentEvent?.currentEventName.uppercased()
        }
    }
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    private let textContainer = UIView()
    private var userInteractStackView: UIStackView?
    private var userInteractStackView1: UIStackView?
    private var eventKey = ""
    private var eventPromo = ""
    let titleView = UILabel()


    
    private let infoText: UILabel = {
        let infoText = UILabel()
        infoText.textColor = .black
        infoText.textAlignment = .natural
        infoText.font = UIFont(name: "GillSans", size: 16.5)
        infoText.numberOfLines = 0
        return infoText
    }()
    
    
    lazy var currentEventDate: UILabel = {
        let currentEventDate = UILabel()
        currentEventDate.numberOfLines = 0
        currentEventDate.textAlignment = .center
        currentEventDate.font = UIFont(name: "Futura-CondensedMedium", size: 15)
        return currentEventDate
    }()
    
    lazy var currentEventImage : UIImageView = {
        let currentEvent = UIImageView()
        currentEvent.clipsToBounds = true
        currentEvent.translatesAutoresizingMaskIntoConstraints = false
        currentEvent.contentMode = .scaleToFill
        currentEvent.layer.masksToBounds = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handlePromoVid))
        currentEvent.isUserInteractionEnabled = true
        currentEvent.addGestureRecognizer(tapGestureRecognizer)
        return currentEvent
    }()
    fileprivate func extractedFunc(_ url: URL?) -> EventPromoVideoPlayer {
        return EventPromoVideoPlayer(videoURL: url!)
    }
    
    @objc func handlePromoVid(){
        let url = URL(string: eventPromo)
        let videoLauncher = extractedFunc(url)
        present(videoLauncher, animated: true, completion: nil)
    }

    //wil be responsible for creating the address  label
    lazy var addressLabel : UILabel = {
        let currentAddressLabel = UILabel()
        currentAddressLabel.numberOfLines = 0
        currentAddressLabel.textColor = UIColor.lightGray
        currentAddressLabel.font = UIFont(name:"GillSans", size: 14.0)
        return currentAddressLabel
    }()
    //will ad the location marker to potentially bring up google maps
    lazy var LocationMarkerViewButton : UIButton = {
        let locationMarker = UIButton(type: .system)
        locationMarker.setImage(#imageLiteral(resourceName: "icons8-marker-80 (1)").withRenderingMode(.alwaysOriginal), for: .normal)
        return locationMarker
    }()
    
    lazy var commentsViewButton : UIButton = {
        let viewComments = UIButton(type: .system)
        viewComments.setImage(#imageLiteral(resourceName: "commentBubble-1").withRenderingMode(.alwaysOriginal), for: .normal)
        viewComments.layer.cornerRadius = 5
        viewComments.setTitle("Comments", for: .normal)
        viewComments.setTitleColor(.white, for: .normal)
        viewComments.backgroundColor = UIColor.rgb(red: 33, green: 154, blue: 233)
        viewComments.layer.borderWidth = 0.5
        viewComments.layer.borderColor = UIColor.black.cgColor
        viewComments.addTarget(self, action: #selector(presentComments), for: .touchUpInside)
        return viewComments
    }()
    
    @objc func presentComments(){
        let newCommentsController = NewCommentsViewController()
        var navController = UINavigationController(rootViewController: newCommentsController)
        newCommentsController.eventKey = eventKey
        newCommentsController.comments.removeAll()
        newCommentsController.adapter.reloadData { (updated) in
        }
        present(navController, animated: true, completion: nil)
    }
    
    lazy var attendingButton: UIButton = {
        let attendButton = UIButton(type: .system)
        attendButton.setImage(#imageLiteral(resourceName: "walkingNotFiled").withRenderingMode(.alwaysOriginal), for: .normal)
        attendButton.layer.cornerRadius = 5
        attendButton.setTitle("Attending", for: .normal)
        attendButton.setTitleColor(.black, for: .normal)
        attendButton.backgroundColor = .white
        attendButton.layer.borderWidth = 0.5
        attendButton.layer.borderColor = UIColor.black.cgColor
        attendButton.addTarget(self, action: #selector(handleAttend), for: .touchUpInside)
        return attendButton
    }()
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        
        if parent != nil && self.navigationItem.titleView == nil {
            initNavigationItemTitleView()
        }
    }
    
    private func initNavigationItemTitleView() {
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 500))
        titleView.textAlignment = .center;
        self.navigationItem.titleView = titleView
        self.titleView.font = UIFont(name: "Futura-CondensedMedium", size: 18)
        self.titleView.adjustsFontSizeToFitWidth = true
        
//        let recognizer = UITapGestureRecognizer(target: self, action: #selector(YourViewController.titleWasTapped))
//        titleView.userInteractionEnabled = true
//        titleView.addGestureRecognizer(recognizer)
    }

    @objc func handleAttend(){
        // 2
        attendingButton.isUserInteractionEnabled = false
        print(currentEvent?.isAttending)
       
        if (currentEvent?.isAttending)! {
            
            AttendService.setIsAttending(!((currentEvent?.isAttending)!), from: currentEvent) { [unowned self] (success) in
                // 5
                
                defer {
                    self.attendingButton.isUserInteractionEnabled = true
                }
                
                // 6
                guard success else { return }
                
                // 7
                self.currentEvent?.isAttending = !((self.currentEvent!.isAttending))
                
                self.currentEvent?.currentAttendCount += !((self.currentEvent!.isAttending)) ? 1 : -1
                self.attendingButton.setImage(#imageLiteral(resourceName: "walkingNotFiled").withRenderingMode(.alwaysOriginal), for: .normal)
            }
            
        }else{
            
            AttendService.setIsAttending(!((currentEvent?.isAttending)!), from: currentEvent) {[unowned self] (success) in
                // 5
                
                defer {
                    self.attendingButton.isUserInteractionEnabled = true
                }
                
                // 6
                guard success else { return }
                
                // 7
                self.currentEvent?.isAttending = !((self.currentEvent!.isAttending))
                
                self.currentEvent?.currentAttendCount += !((self.currentEvent!.isAttending)) ? 1 : -1
                self.attendingButton.setImage(#imageLiteral(resourceName: "walkingFilled").withRenderingMode(.alwaysOriginal), for: .normal)
            }
            
        }
        
    }
    
    fileprivate func setupAttendInteraction(){
        Database.database().reference().child("attending").child(eventKey).child(User.current.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            if let isAttending = snapshot.value as? Int, isAttending == 1 {
                print("User is attending")
                self.currentEvent?.isAttending = true
                self.attendingButton.setImage(#imageLiteral(resourceName: "walkingFilled").withRenderingMode(.alwaysOriginal), for: .normal)
            }else{
                print("User is not attending")
                self.currentEvent?.isAttending = false
                self.attendingButton.setImage(#imageLiteral(resourceName: "walkingNotFiled").withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }) { (err) in
            print("Failed to check if attending", err)
        }
    }
    
    lazy var addToStoryButton : UIButton =  {
        let addToStory = UIButton(type: .system)
        addToStory.setImage(#imageLiteral(resourceName: "photo-camera").withRenderingMode(.alwaysOriginal), for: .normal)
        addToStory.layer.cornerRadius = 5

        addToStory.setTitle("Add to Story", for: .normal)
        addToStory.setTitleColor(.black, for: .normal)
        addToStory.backgroundColor = .white
        addToStory.layer.borderWidth = 0.5
        addToStory.layer.borderColor = UIColor.black.cgColor
        addToStory.addTarget(self, action: #selector(beginAddToStory), for: .touchUpInside)
        return addToStory
    }()
    
    @objc func beginAddToStory(){
        let camera = CameraViewController()
        camera.eventKey = self.eventKey
        present(camera, animated: true, completion: nil)
    }
    
    lazy var viewStoryButton : UIButton = {
        let viewStoryButton = UIButton(type: .system)
        viewStoryButton.setImage(#imageLiteral(resourceName: "icons8-Logout Rounded Up-50").withRenderingMode(.alwaysOriginal), for: .normal)
        viewStoryButton.layer.cornerRadius = 5
        viewStoryButton.setTitle("View Story", for: .normal)
        viewStoryButton.setTitleColor(.black, for: .normal)
        viewStoryButton.backgroundColor = .white
        viewStoryButton.layer.borderWidth = 0.50
        viewStoryButton.layer.borderColor = UIColor.black.cgColor
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleViewStory))
//        viewStoryButton.addGestureRecognizer(tapGesture)
        return viewStoryButton
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       setupVc()
    }
    @objc func GoBack(){
        print("BACK TAPPED")
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func setupVc(){
        self.navigationController?.navigationBar.isTranslucent = false

    let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(GoBack))
        self.navigationItem.leftBarButtonItem = backButton
    view.backgroundColor = .white
    
    scrollView.contentInsetAdjustmentBehavior = .never
    scrollView.delegate = self
    scrollView.showsVerticalScrollIndicator = false
    
    
//    infoText.text = text + text + text
    
    let imageContainer = UIView()
    imageContainer.backgroundColor = .darkGray
    
    textContainer.backgroundColor = .clear
    
    let textBacking = UIView()
    textBacking.backgroundColor = .white
    
        
    userInteractStackView = UIStackView(arrangedSubviews: [commentsViewButton, attendingButton])
        userInteractStackView?.translatesAutoresizingMaskIntoConstraints = false
        userInteractStackView?.distribution = .fillEqually
        userInteractStackView?.axis = .horizontal
        userInteractStackView?.spacing = 5.0
        
    userInteractStackView1 = UIStackView(arrangedSubviews: [addToStoryButton,viewStoryButton])
        userInteractStackView1?.translatesAutoresizingMaskIntoConstraints = false
        userInteractStackView1?.distribution = .fillEqually
        userInteractStackView1?.axis = .horizontal
        userInteractStackView1?.spacing = 5.0


        
    view.addSubview(scrollView)
    
    scrollView.addSubview(imageContainer)
    scrollView.addSubview(textBacking)
    scrollView.addSubview(textContainer)
    scrollView.addSubview(currentEventImage)
    
//    textContainer.addSubview(eventNameLabel)
    textContainer.addSubview(addressLabel)
    textContainer.addSubview(currentEventDate)
    textContainer.addSubview(LocationMarkerViewButton)
    textContainer.addSubview(infoText)
    textContainer.addSubview(userInteractStackView!)
    textContainer.addSubview(userInteractStackView1!)
    scrollView.snp.makeConstraints {
    make in
    
    make.edges.equalTo(view.safeAreaLayoutGuide)
    }
    
    imageContainer.snp.makeConstraints {
    make in
    
    make.top.equalTo(scrollView)
    make.left.right.equalTo(view)
    make.height.equalTo(imageContainer.snp.width).multipliedBy(1.3)
    }
    
    currentEventImage.snp.makeConstraints {
    make in
    
    make.left.right.equalTo(imageContainer)
    
    //** Note the priorities
    make.top.equalTo(view).priority(.high)
    
    //** We add a height constraint too
    make.height.greaterThanOrEqualTo(imageContainer.snp.height).priority(.required)
    
    //** And keep the bottom constraint
    make.bottom.equalTo(imageContainer.snp.bottom)
    }
    
    textContainer.snp.makeConstraints {
    make in
    make.top.equalTo(imageContainer.snp.bottom)
    make.left.right.equalTo(view)
    make.bottom.equalTo(scrollView)
    }
    
    textBacking.snp.makeConstraints {
    make in
    
    make.left.right.equalTo(view)
    make.top.equalTo(textContainer)
    make.bottom.equalTo(view)
    }
        
    LocationMarkerViewButton.snp.makeConstraints { (make) in
            make.top.equalTo(textContainer.snp.top).offset(2)
            make.left.equalTo(textContainer.snp.left)
        }
        currentEventDate.snp.makeConstraints { (make) in
            make.top.equalTo(textContainer.snp.top)
            make.right.equalTo(textContainer).inset(5)
        }
    addressLabel.snp.makeConstraints { (make) in
            make.top.equalTo(textContainer.snp.top).offset(5)
            make.left.equalTo(LocationMarkerViewButton.snp.right).offset(1.5)
        }
        
    infoText.snp.makeConstraints {
    make in
        make.top.equalTo(addressLabel.snp.bottom).offset(20)
        make.left.right.equalTo(textContainer).inset(10)
    }
    
        userInteractStackView?.snp.makeConstraints { (make) in
            make.top.equalTo(infoText.snp.bottom).offset(30)
            make.height.equalTo(40)
            make.left.right.equalTo(textContainer).inset(5)
        }
        
        userInteractStackView1?.snp.makeConstraints({ (make) in
            make.top.equalTo((userInteractStackView?.snp.bottom)!).offset(5)
            make.height.equalTo(40)
            make.left.right.equalTo(textContainer).inset(5)
            make.bottom.equalTo(textContainer.snp.bottom)
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.scrollIndicatorInsets = view.safeAreaInsets
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: view.safeAreaInsets.bottom, right: 0)
    }
    
    //MARK: - Update Line Spacing
    func updateWithSpacing(lineSpacing: Float) {
        // The attributed string to which the
        // paragraph line spacing style will be applied.
        let attributedString = NSMutableAttributedString(string: infoText.text!)
        let mutableParagraphStyle = NSMutableParagraphStyle()
        // Customize the line spacing for paragraph.
        mutableParagraphStyle.lineSpacing = CGFloat(lineSpacing)
        mutableParagraphStyle.alignment = .justified
        if let stringLength = infoText.text?.count {
            attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: mutableParagraphStyle, range: NSMakeRange(0, stringLength))
        }
        // textLabel is the UILabel subclass
        // which shows the custom text on the screen
        infoText.attributedText = attributedString
        
    }
    
    //MARK: - Date Componets

    fileprivate func getDayAndMonthFromEvent(_ event:Event) -> (String, String) {
        let apiDateFormat = "MM/dd/yyyy"
        let df = DateFormatter()
        df.dateFormat = apiDateFormat
        let eventDate = df.date(from: event.currentEventDate!)!
        df.dateFormat = "dd"
        let dayElement = df.string(from: eventDate)
        df.dateFormat = "MMM"
        let monthElement = df.string(from: eventDate)
        return (dayElement, monthElement)
    }
    
    //MARK: - Scroll View Delegate
    
    private var previousStatusBarHidden = false
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if previousStatusBarHidden != shouldHideStatusBar {
            
            UIView.animate(withDuration: 0.2, animations: {
                self.setNeedsStatusBarAppearanceUpdate()
            })
            
            previousStatusBarHidden = shouldHideStatusBar
        }
    }
    
    //MARK: - Status Bar Appearance
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override var prefersStatusBarHidden: Bool {
        return shouldHideStatusBar
    }
    
    private var shouldHideStatusBar: Bool {
        let frame = textContainer.convert(textContainer.bounds, to: nil)
        return frame.minY < view.safeAreaInsets.top
    }
 
}
