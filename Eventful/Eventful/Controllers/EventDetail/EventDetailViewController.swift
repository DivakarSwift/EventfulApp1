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
import GoogleMaps
import CoreLocation
import MapKit
import SimpleImageViewer
import FirebaseMessaging
import OneSignal
import TagListView


class EventDetailViewController: UIViewController,UIScrollViewDelegate {
    var imageURL: URL?

    var currentEvent : Event?{
        didSet{
            
            guard let event = currentEvent else {
                return
            }
            eventNameLabel.text = event.currentEventName.capitalized
            imageURL = URL(string: (event.currentEventImage))
            
            DispatchQueue.main.async {
                self.currentEventImage.af_setImage(withURL: self.imageURL!, placeholderImage: nil, filter: nil, progress: nil, progressQueue: .main, imageTransition: .crossDissolve(0.5), runImageTransitionIfCached: false, completion: { (response) in
                    _ = response.result.value // UIImage Object
                })
            }
            
            //will create the address
            guard let currentZip = currentEvent?.currentEventZip else{
                return
            }
            
            let firstPartOfAddress = (event.currentEventStreetAddress)  + "" + (event.currentEventCity) + ", " + (event.currentEventState)
            let secondPartOfAddress = firstPartOfAddress + " " + String(describing: currentZip)
            
              let attributedText = NSMutableAttributedString(string:  "location\n".capitalized, attributes: [NSAttributedStringKey.font: UIFont(name: "NoirPro-SemiBold", size: 15) as Any, NSAttributedStringKey.foregroundColor: UIColor.rgb(red: 32, green: 32, blue: 32)])
            
            let attributedText2 = NSMutableAttributedString(string: secondPartOfAddress.capitalized, attributes: [NSAttributedStringKey.font: UIFont(name: "NoirPro-Light", size: 15) as Any, NSAttributedStringKey.foregroundColor: UIColor.rgb(red: 132, green: 132, blue: 132)])
            attributedText.append(attributedText2)
            addressLabel.attributedText = attributedText
            
            ///////////

            //tag list init
            
            guard let tags = event.eventTags else {
                return
            }
            
            populateTagList(tags: tags)
            //will get weather
            fetchWeatherData(location: attributedText2.string, time: event.startTime)
            ////will get the start date and start time
            guard let beginDate = event.currentEventDate else {
                return
            }
            let dateComponets = getDayAndMonthFromEvent(beginDate)

            let startTimeattributedText = NSMutableAttributedString(string:  "start time\n".capitalized, attributes: [NSAttributedStringKey.font: UIFont(name: "NoirPro-Regular", size: 13) as Any, NSAttributedStringKey.foregroundColor: UIColor.rgb(red: 185, green: 185, blue: 185)])
            
            let startTimeAttributedText2 = NSMutableAttributedString(string: "\(dateComponets.0) \(dateComponets.1) \(dateComponets.2) \(currentEvent?.currentEventTime ?? "")", attributes: [NSAttributedStringKey.font: UIFont(name: "NoirPro-Light", size: 13) as Any, NSAttributedStringKey.foregroundColor: UIColor.rgb(red: 32, green: 32, blue: 32)])
            
            startTimeattributedText.append(startTimeAttributedText2)
            
            startDateText.attributedText = startTimeattributedText
            
            guard let endDate = event.currentEventEndDate else {
                return
            }
            
            let dateComponets2 = getDayAndMonthFromEvent(endDate)
            
            let endTimeattributedText = NSMutableAttributedString(string:  "end time\n".capitalized, attributes: [NSAttributedStringKey.font: UIFont(name: "NoirPro-Regular", size: 13) as Any, NSAttributedStringKey.foregroundColor: UIColor.rgb(red: 185, green: 185, blue: 185)])
            
            let endTimeAttributedText2 = NSMutableAttributedString(string: "\(dateComponets2.0) \(dateComponets2.1) \(dateComponets2.2) \(currentEvent?.currentEventEndTime ?? "")", attributes: [NSAttributedStringKey.font: UIFont(name: "NoirPro-Light", size: 13) as Any, NSAttributedStringKey.foregroundColor: UIColor.rgb(red: 32, green: 32, blue: 32)])
            
            endTimeattributedText.append(endTimeAttributedText2)
            
            endDateText.attributedText = endTimeattributedText
            
            
            
            //will pass the event description to the corresponding label
            infoText.text = currentEvent?.currentEventDescription
            updateWithSpacing(lineSpacing: 10.0)

            
//            currentEventDate.text = "Date and Time: "+dateComponets.1 + " \(dateComponets.0), \(dateComponets.2) \(currentEvent?.currentEventTime?.lowercased() ?? "") - \(currentEvent?.currentEventEndTime?.lowercased() ?? "")"
            guard let key = event.key else {
                return
            }
            eventKey = key
            guard let promo = event.currentEventPromo else {
                return
            }
            eventPromo = promo
            setupAttendInteraction()
//            let price = event.eventPrice
//                let formatter = NumberFormatter()
//                formatter.locale = Locale.current // Change this to another locale if you want to force a specific locale, otherwise this is redundant as the current locale is the default already
//                formatter.numberStyle = .currency
//                if let formattedTipAmount = formatter.string(from:                     NSNumber(value: Int(price)!)) {
//                    costLabel.text = "Cost: \(formattedTipAmount)"
//                }

            
           
        }
    }
    let tagList = TagListView()
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    private let textContainer = UIView()
    private var userInteractStackView: UIStackView?
    private var userInteractStackView1: UIStackView?
    private var userInteractStackView2: UIStackView?

    private var eventKey = ""
    private var eventPromo = ""
    let titleView = UILabel()
    
    

    lazy var eventNameLabel: UILabel = {
       let eventNameLabel = UILabel()
        guard let customFont = UIFont(name: "NoirPro-SemiBold", size: 28) else {
            fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        eventNameLabel.textColor = .black
        eventNameLabel.textAlignment = .left
        eventNameLabel.font = customFont
        eventNameLabel.numberOfLines = 0
        return eventNameLabel
    }()
    
    lazy var weatherLabel: UILabel = {
        let weatherLabel = UILabel()
        weatherLabel.text = "Weather"
        guard let customFont = UIFont(name: "NoirPro-SemiBold", size: 15) else {
            fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        weatherLabel.textColor = .black
        weatherLabel.textAlignment = .left
        weatherLabel.font = customFont
        weatherLabel.numberOfLines = 0
        return weatherLabel
    }()
    
    lazy var degreesLabel: UILabel = {
        let degreesLabel = UILabel()
        guard let customFont = UIFont(name: "NoirPro-Medium", size: 20) else {
            fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        degreesLabel.textColor = UIColor.rgb(red: 32, green: 32, blue: 32)
        degreesLabel.textAlignment = .left
        degreesLabel.font = customFont
        degreesLabel.numberOfLines = 0
        return degreesLabel
    }()
    
    lazy var summaryLabel: UILabel = {
        let summaryLabel = UILabel()
        guard let customFont = UIFont(name: "NoirPro-Light", size: 13) else {
            fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        summaryLabel.textColor = UIColor.rgb(red: 132, green: 132, blue: 132)
        summaryLabel.textAlignment = .left
        summaryLabel.font = customFont
        summaryLabel.numberOfLines = 0
        return summaryLabel
    }()
    
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    lazy var dateAndTimeLabel: UILabel = {
        let dateAndTimeLabel = UILabel()
        dateAndTimeLabel.text = "Date & Time"
        guard let customFont = UIFont(name: "NoirPro-Medium", size: 15) else {
            fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        dateAndTimeLabel.textColor = UIColor.rgb(red: 32, green: 32, blue: 32)
        dateAndTimeLabel.textAlignment = .left
        dateAndTimeLabel.font = customFont
        dateAndTimeLabel.numberOfLines = 0
        return dateAndTimeLabel
    }()
    
    
    lazy var startDateText: UILabel = {
        let startDateText = UILabel()
        startDateText.textAlignment = .left
        startDateText.numberOfLines = 0
        return startDateText
    }()
    
    lazy var endDateText: UILabel = {
        let endDateText = UILabel()
        endDateText.textAlignment = .left
        endDateText.numberOfLines = 0
        return endDateText
    }()
    
    
    lazy var hostLabel: UILabel = {
        let hostLabel = UILabel()
        hostLabel.text = "Host"
        guard let customFont = UIFont(name: "NoirPro-Medium", size: 15) else {
            fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        hostLabel.textColor = UIColor.rgb(red: 32, green: 32, blue: 32)
        hostLabel.textAlignment = .left
        hostLabel.font = customFont
        hostLabel.numberOfLines = 0
        return hostLabel
    }()
    
    
    lazy var aboutEventLabel: UILabel = {
        let aboutEventLabel = UILabel()
        aboutEventLabel.text = "About Event"
        guard let customFont = UIFont(name: "NoirPro-Medium", size: 15) else {
            fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        aboutEventLabel.textColor = UIColor.rgb(red: 32, green: 32, blue: 32)
        aboutEventLabel.textAlignment = .left
        aboutEventLabel.font = customFont
        aboutEventLabel.numberOfLines = 0
        return aboutEventLabel
    }()
    
    
    
    
    
    private let infoText: UILabel = {
        let infoText = UILabel()
        guard let customFont = UIFont(name: "NoirPro-Light", size: 13) else {
            fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        infoText.textColor = UIColor.rgb(red: 32, green: 32, blue: 32)
        infoText.textAlignment = .natural
        infoText.font = customFont
        infoText.numberOfLines = 0
        return infoText
    }()

    
    lazy var currentEventImage : UIImageView = {
        let currentEvent = UIImageView()
        currentEvent.setupShadow2()
        currentEvent.clipsToBounds = true
        currentEvent.translatesAutoresizingMaskIntoConstraints = false
        currentEvent.contentMode = .scaleToFill
        currentEvent.layer.masksToBounds = true
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handlePromoVid))
        singleTap.numberOfTapsRequired = 1
        
        currentEvent.isUserInteractionEnabled = true
        currentEvent.addGestureRecognizer(singleTap)
        let doubleTap =  UITapGestureRecognizer(target: self, action: #selector(handleImageZoom))
        doubleTap.numberOfTapsRequired = 2
        currentEvent.addGestureRecognizer(doubleTap)
        singleTap.require(toFail: doubleTap)
        return currentEvent
    }()
    
    
    fileprivate func extractedFunc(_ url: URL?) -> EventPromoVideoPlayer {
        return EventPromoVideoPlayer(videoURL: url!)
    }
    
    @objc func handleImageZoom(){
        print("double tap recognized")
        let configuration = ImageViewerConfiguration { config in
            config.imageView = currentEventImage
        }
        let imageViewerController = ImageViewerController(configuration: configuration)
        present(imageViewerController, animated: true)
        
        
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
        currentAddressLabel.font = UIFont.boldSystemFont(ofSize: 14)
        currentAddressLabel.isUserInteractionEnabled = true
        currentAddressLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openMaps)))
        return currentAddressLabel
    }()
    
    
    @objc func openMaps() {
        print("Trying to open a map")
        guard let currentZip = currentEvent?.currentEventZip else{
            return
        }
        let geoCoder = CLGeocoder()
        
        let addressString = (currentEvent?.currentEventStreetAddress)! + ", "+(currentEvent?.currentEventCity)! +  ", "+(currentEvent?.currentEventState)! + " "+String(describing: currentZip)
        print(addressString)
        geoCoder.geocodeAddressString(addressString) { (placeMark, err) in
            guard let currentPlaceMark = placeMark?.first else{
                return
            }
            guard let lat = currentPlaceMark.location?.coordinate.latitude else {
                return
            }
            guard let long = currentPlaceMark.location?.coordinate.longitude else {
                return
            }
            print(lat)
            print(long)
            if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
                let addressParse = (self.currentEvent?.currentEventStreetAddress)!.components(separatedBy: " ")
                print(addressParse[0])
                print(addressParse[1])
                print(addressParse[2])
                let directionsRequest = "comgooglemaps-x-callback://" +
                    "?daddr=\(addressParse[0])+\(addressParse[1])+\(addressParse[2]),+\((self.currentEvent?.currentEventCity)!),+\((self.currentEvent?.currentEventState)!)+\(String(describing: currentZip))" +
                "&x-success=sourceapp://?resume=true&x-source=Haipe"
                
                let directionsURL = URL(string: directionsRequest)!
                UIApplication.shared.open(directionsURL, options: [:], completionHandler: nil)
                
            } else {
                print("Opening in Apple Map")
                
                let coordinate = CLLocationCoordinate2DMake(lat, long)
                let region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.01, 0.02))
                let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
                let mapItem = MKMapItem(placemark: placemark)
                let options = [
                    MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
                    MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)]
                mapItem.name = addressString
                mapItem.openInMaps(launchOptions: options)
            }
        }
    }
    
    lazy var commentsViewButton : UIButton = {
        let viewComments = UIButton(type: .system)
        viewComments.setCellShadow()
        viewComments.setImage(#imageLiteral(resourceName: "icons8-chat-50").withRenderingMode(.alwaysOriginal), for: .normal)
        viewComments.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10)
        viewComments.layer.cornerRadius = 5
        viewComments.setTitle("Comments", for: .normal)
        viewComments.titleLabel?.font = UIFont(name: "NoirPro-Regular", size: 15)
        viewComments.setTitleColor(.white, for: .normal)
        viewComments.backgroundColor = UIColor.rgb(red: 44, green: 152, blue: 229)
        viewComments.layer.borderWidth = 0.1
        viewComments.layer.borderColor = UIColor.clear.cgColor
        viewComments.addTarget(self, action: #selector(presentComments), for: .touchUpInside)
        return viewComments
    }()
    
    @objc func presentComments(){
        let newCommentsController = NewCommentsViewController()
        newCommentsController.eventKey = eventKey
        newCommentsController.comments.removeAll()
        newCommentsController.adapter.reloadData { (updated) in
        }
        self.navigationController?.pushViewController(newCommentsController, animated: true)
    }
    
    lazy var attendingButton: UIButton = {
        let attendButton = UIButton(type: .system)
        attendButton.setCellShadow()
        attendButton.setImage(#imageLiteral(resourceName: "icons8-walking-50").withRenderingMode(.alwaysOriginal), for: .normal)
        attendButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10)
        attendButton.layer.cornerRadius = 5
        attendButton.titleLabel?.font = UIFont(name: "NoirPro-Regular", size: 15)
        attendButton.setTitleColor(.white, for: .normal)
        attendButton.backgroundColor = UIColor.rgb(red: 44, green: 152, blue: 229)
        attendButton.layer.borderWidth = 0.1
        attendButton.layer.borderColor = UIColor.clear.cgColor
        attendButton.addTarget(self, action: #selector(handleAttend), for: .touchUpInside)
        return attendButton
    }()
    
    lazy var shareButton: UIButton = {
        let shareButton = UIButton(type: .system)
        shareButton.setImage(UIImage(named: "icons8-share-filled-50")?.withRenderingMode(.alwaysOriginal), for: .normal)
        shareButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10)
        shareButton.layer.cornerRadius = 5
        shareButton.setTitle("Share", for: .normal)
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.titleLabel?.font = UIFont(name: "NoirPro-Regular", size: 15)
        shareButton.backgroundColor = UIColor.rgb(red: 44, green: 152, blue: 229)
        shareButton.setCellShadow()
        shareButton.layer.borderWidth = 0.1
        shareButton.layer.borderColor = UIColor.clear.cgColor
        shareButton.addTarget(self, action: #selector(shareWithFollowers), for: .touchUpInside)
        return shareButton
    }()

    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        
        if parent != nil && self.navigationItem.titleView == nil {
            initNavigationItemTitleView()
        }
    }
    
    private func initNavigationItemTitleView() {
        titleView.font = UIFont(name: "NoirPro-Medium", size: 18)
        titleView.text = "Event Details"
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 500))
        self.navigationItem.titleView = titleView
        
    }
    
    @objc func populateTagList(tags : [String]){
        for tag in tags {
            tagList.addTag(tag)
        }
        
        guard let customFont = UIFont(name: "NoirPro-Light", size: 15) else {
            fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        tagList.textFont = customFont
        tagList.textColor = UIColor.rgb(red: 132, green: 132, blue: 132)
        tagList.alignment = .left
        tagList.tagBackgroundColor = UIColor.white
        tagList.borderColor = UIColor.rgb(red: 185, green: 185, blue: 185)
        tagList.borderWidth = 1
        tagList.cornerRadius = 7

    }
    
    @objc func fetchWeatherData(location: String, time: Date){
        LocationService.getEventLocation(address: location) { (place) in
            guard let places = place else  {
                return
            }
            
            for place in places {
                print(place.coordinates?.latitude as Any)
                print(place.coordinates?.longitude as Any)
                let jsonURLString = "https://api.darksky.net/forecast/d455ebdd2abdcb5160adc4e70919367c/\(place.coordinates?.latitude ?? 0),\(place.coordinates?.longitude ?? 0),\(Int(time.timeIntervalSince1970))?exclude=minutely,flags,hourly,daily,alerts"
                print(jsonURLString)
                guard let url = URL(string: jsonURLString) else {
                    return
                }
                URLSession.shared.dataTask(with: url, completionHandler: { (data, response, err) in
                    guard let data = data else {
                        return
                    }
                    do {
                        let weather = try JSONDecoder().decode(Weather.self, from: data)
                        print(weather)
                        print(weather.currently.icon)
                        DispatchQueue.main.async {
                            self.iconImageView.image = UIImage(named: weather.currently.icon)
                            self.degreesLabel.text = String(Int(weather.currently.temperature)) + " °"
                            self.summaryLabel.text = weather.currently.summary
                        }
                    } catch let jsonErr {
                        print("Error serializing json:", jsonErr)

                    }
                    
                }).resume()

            }
        }
    }
    @objc func handleAttend(){
        // 2
        attendingButton.isUserInteractionEnabled = false
        
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
                self.attendingButton.setImage(#imageLiteral(resourceName: "icons8-walking-50").withRenderingMode(.alwaysOriginal), for: .normal)
                self.attendingButton.setTitle("Not Attending", for: .normal)
                OneSignal.deleteTag(self.currentEvent?.currentEventName)
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
                self.attendingButton.setImage(#imageLiteral(resourceName: "icons8-walking-filled-50").withRenderingMode(.alwaysOriginal), for: .normal)
                
                self.attendingButton.setTitle("Attending", for: .normal)
                OneSignal.sendTag(self.currentEvent?.currentEventName, value: "1")
            }
            
        }
        
    }

    
    fileprivate func setupAttendInteraction(){
        Database.database().reference().child("attending").child(eventKey).child(User.current.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            if let isAttending = snapshot.value as? Int, isAttending == 1 {
                print("User is attending")
                self.currentEvent?.isAttending = true
                self.attendingButton.setImage(#imageLiteral(resourceName: "icons8-walking-filled-50").withRenderingMode(.alwaysOriginal), for: .normal)
                self.attendingButton.setTitle("Attending", for: .normal)
            }else{
                print("User is not attending")
                self.currentEvent?.isAttending = false
                self.attendingButton.setImage(#imageLiteral(resourceName: "icons8-walking-50").withRenderingMode(.alwaysOriginal), for: .normal)
                self.attendingButton.setTitle("Not Attending", for: .normal)
                
            }
        }) { (err) in
            print("Failed to check if attending", err)
        }
    }
    
    lazy var addToStoryButton : UIButton =  {
        let addToStory = UIButton(type: .system)
        addToStory.setCellShadow()
        addToStory.setImage(#imageLiteral(resourceName: "icons8-screenshot-filled-50").withRenderingMode(.alwaysOriginal), for: .normal)
        addToStory.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10)
        addToStory.layer.cornerRadius = 5
        addToStory.titleLabel?.font = UIFont(name: "NoirPro-Regular", size: 15)
        addToStory.setTitle("Add to Story", for: .normal)
        addToStory.setTitleColor(.white, for: .normal)
        addToStory.backgroundColor = UIColor.rgb(red: 44, green: 152, blue: 229)
        addToStory.layer.borderWidth = 0.1
        addToStory.layer.borderColor = UIColor.clear.cgColor
        addToStory.addTarget(self, action: #selector(beginAddToStory), for: .touchUpInside)
        return addToStory
    }()
    
    
    @objc func beginAddToStory(){
        //Animation 1
        let transition = CATransition()
        transition.duration = 0.4
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromBottom
        view.window!.layer.add(transition, forKey: kCATransition)
         let camera = TempCameraViewController()
        camera.event = currentEvent
        present(camera, animated: false, completion: nil)
    }
    
    lazy var viewStoryButton : UIButton = {
        let viewStoryButton = UIButton(type: .system)
        viewStoryButton.setCellShadow()
        viewStoryButton.setImage(#imageLiteral(resourceName: "icons8-next-50").withRenderingMode(.alwaysOriginal), for: .normal)
        viewStoryButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10)
        viewStoryButton.layer.cornerRadius = 5
        viewStoryButton.setTitle("View Story", for: .normal)
        viewStoryButton.titleLabel?.font = UIFont(name: "NoirPro-Regular", size: 15)
        viewStoryButton.setTitleColor(.white, for: .normal)
        viewStoryButton.backgroundColor = UIColor.rgb(red: 44, green: 152, blue: 229)
        viewStoryButton.layer.borderWidth = 0.1
        viewStoryButton.layer.borderColor = UIColor.clear.cgColor
        viewStoryButton.addTarget(self, action: #selector(handleViewStory), for: .touchUpInside)
        return viewStoryButton
    }()

    
    
    @objc func handleViewStory(){
        let vc = StoriesViewController()
//        vc.eventDetailRef = self
        vc.eventKey = self.eventKey
        present(vc, animated: false, completion: nil)
    }
    
    

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        if let start = currentEvent?.startTime, let end = currentEvent?.endTime {
            print(start)
            print(end)
        }
        setupVc()
    }
    @objc func GoBack(){
        print("BACK TAPPED")
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func favorite(){
        print("favorite pressed")
    }
    
    @objc func shareWithFollowers(){
        print("Attempting to share with friends")
        let share = ShareViewController()
        print(eventKey)
        share.eventKey = eventKey
        self.navigationController?.pushViewController(share, animated: true)
    }
    
    @objc func setupVc(){
        self.navigationController?.navigationBar.isTranslucent = false
        
        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-back-48"), style: .plain, target: self, action: #selector(GoBack))
        self.navigationItem.leftBarButtonItem = backButton
        
        let favoriteButton = UIBarButtonItem(image: UIImage(named: "icons8-romance-50"), style: .plain, target: self, action: #selector(favorite))
        self.navigationItem.rightBarButtonItem = favoriteButton

        
        view.backgroundColor = .white
        
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        
        let imageContainer = UIView()
        imageContainer.backgroundColor = UIColor.rgb(red: 245, green: 255, blue: 250)
        
        textContainer.backgroundColor = .clear
        
        let textBacking = UIView()
        textBacking.backgroundColor = .white
        
        
        
//        addToStoryButton,viewStoryButton,commentsViewButton,shareButton
    
        userInteractStackView = UIStackView(arrangedSubviews: [attendingButton])
        userInteractStackView?.translatesAutoresizingMaskIntoConstraints = false
        userInteractStackView?.distribution = .fillEqually
        userInteractStackView?.axis = .horizontal
        userInteractStackView?.spacing = 5.0
        
        userInteractStackView1 = UIStackView(arrangedSubviews: [commentsViewButton,shareButton])
        userInteractStackView1?.translatesAutoresizingMaskIntoConstraints = false
        userInteractStackView1?.distribution = .fillEqually
        userInteractStackView1?.axis = .horizontal
        userInteractStackView1?.spacing = 5.0
        
        userInteractStackView2 = UIStackView(arrangedSubviews: [addToStoryButton,viewStoryButton])
        userInteractStackView2?.translatesAutoresizingMaskIntoConstraints = false
        userInteractStackView2?.distribution = .fillEqually
        userInteractStackView2?.axis = .horizontal
        userInteractStackView2?.spacing = 5.0
        
//        addToStoryButton,viewStoryButton,commentsViewButton,shareButton


        view.addSubview(scrollView)
        
        scrollView.addSubview(imageContainer)
        scrollView.addSubview(textBacking)
        scrollView.addSubview(textContainer)
        scrollView.addSubview(currentEventImage)
        
        textContainer.addSubview(eventNameLabel)
        textContainer.addSubview(addressLabel)
        textContainer.addSubview(tagList)
        //weather
        textContainer.addSubview(weatherLabel)
        textContainer.addSubview(degreesLabel)
        textContainer.addSubview(summaryLabel)
        textContainer.addSubview(iconImageView)
        //date and time
        textContainer.addSubview(dateAndTimeLabel)
        textContainer.addSubview(startDateText)
        textContainer.addSubview(endDateText)
        //host
        textContainer.addSubview(hostLabel)
        
        //event info
        textContainer.addSubview(aboutEventLabel)
        textContainer.addSubview(infoText)
        
        textContainer.addSubview(userInteractStackView!)
        textContainer.addSubview(userInteractStackView1!)
        textContainer.addSubview(userInteractStackView2!)

        scrollView.snp.makeConstraints {
            make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(5)
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
//            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        imageContainer.snp.makeConstraints {
            make in
            
            make.top.equalTo(scrollView)
            make.left.right.equalTo(view)
            make.height.equalTo(imageContainer.snp.width).multipliedBy(1.3)
        }
        
        currentEventImage.snp.makeConstraints {
            make in
            
            make.left.right.equalTo(imageContainer).inset(10)
            
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
        
        eventNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(textContainer.snp.top).offset(10)
            make.left.right.equalTo(textContainer).inset(10)
        }
        
        addressLabel.snp.makeConstraints { (make) in
            make.top.equalTo(eventNameLabel.snp.bottom).offset(10)
            make.left.equalTo(textContainer).inset(10)
        }
        
        tagList.snp.makeConstraints { (make) in
            make.top.equalTo(addressLabel.snp.bottom).offset(10)
            make.left.right.equalTo(textContainer).inset(10)
        }
        weatherLabel.snp.makeConstraints { (make) in
            make.top.equalTo(tagList.snp.bottom).offset(15)
            make.left.right.equalTo(textContainer).inset(10)
        }
        
        degreesLabel.snp.makeConstraints { (make) in
            make.top.equalTo(weatherLabel.snp.bottom).offset(10)
            make.left.equalTo(textContainer).inset(10)
        }
        
        summaryLabel.snp.makeConstraints { (make) in
            make.top.equalTo(degreesLabel.snp.bottom).offset(5)
            make.left.equalTo(textContainer).inset(10)
        }
        iconImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(degreesLabel.snp.centerY)
            make.left.equalTo(degreesLabel.snp.right).offset(35)
        }
        
        dateAndTimeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(summaryLabel.snp.bottom).offset(15)
            make.left.equalTo(textContainer.snp.left).inset(10)
        }
        
        startDateText.snp.makeConstraints { (make) in
            make.top.equalTo(dateAndTimeLabel.snp.bottom).offset(15)
            make.left.equalTo(textContainer.snp.left).inset(10)
        }
        
        endDateText.snp.makeConstraints { (make) in
            make.top.equalTo(startDateText.snp.bottom).offset(8)
            make.left.equalTo(textContainer.snp.left).inset(10)
        }
        
        hostLabel.snp.makeConstraints { (make) in
            make.top.equalTo(endDateText.snp.bottom).offset(15)
            make.left.equalTo(textContainer.snp.left).inset(10)
        }
        
        aboutEventLabel.snp.makeConstraints { (make) in
            make.top.equalTo(hostLabel.snp.bottom).offset(15)
            make.left.equalTo(textContainer.snp.left).inset(10)
        }
        
        infoText.snp.makeConstraints {
            make in
            make.top.equalTo(aboutEventLabel.snp.bottom).offset(15)
            make.left.right.equalTo(textContainer).inset(10)
        }

        userInteractStackView?.snp.makeConstraints { (make) in
            make.top.equalTo(infoText.snp.bottom).offset(30)
            make.height.equalTo(40)
            make.left.right.equalTo(textContainer).inset(55)
        }
        
        userInteractStackView1?.snp.makeConstraints({ (make) in
            make.top.equalTo((userInteractStackView?.snp.bottom)!).offset(15)
            make.height.equalTo(45)
            make.left.right.equalTo(textContainer).inset(10)
        })
        
        userInteractStackView2?.snp.makeConstraints({ (make) in
            make.top.equalTo((userInteractStackView1?.snp.bottom)!).offset(15)
            make.height.equalTo(45)
            make.left.right.equalTo(textContainer).inset(10)
            make.bottom.equalTo(textContainer.snp.bottom).inset(10)
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
    
    fileprivate func getDayAndMonthFromEvent(_ event:String?) -> (String, String, String) {
        guard let eventdateParam = event else {
            return ("","","")
        }
        let apiDateFormat = "MM/dd/yyyy"
        let df = DateFormatter()
        df.dateFormat = apiDateFormat
        guard let eventDate = df.date(from: eventdateParam) else {
             return ("","","")
        }
        df.dateFormat = "dd"
        let dayElement = df.string(from: eventDate)
        df.dateFormat = "MMM"
        let monthElement = df.string(from: eventDate)
        df.dateFormat = "yyyy"
        let yearElement = df.string(from: eventDate)
        return (dayElement, monthElement, yearElement)
    }
}
