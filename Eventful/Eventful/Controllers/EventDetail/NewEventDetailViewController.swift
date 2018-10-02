//
//  NewEventDetailViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 9/22/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class NewEventDetailViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var currentEvent : Event?{
        didSet{
            guard currentEvent != nil else {
                return
            }
            self.collectionView?.reloadData()
            
        }
    }
    fileprivate let titleView = UILabel()
    fileprivate let headerID = "headerID"
    fileprivate let footerID = "footerID"
    fileprivate let nameID = "nameID"
    fileprivate let eventAddress = "addessID"
    fileprivate let weather = "weatherID"
    fileprivate let date = "dateID"
    fileprivate let host = "hostID"
    fileprivate let details = "detailID"
    fileprivate let attending = "attendingID"

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = false

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell classes
        setupCollectionView()
        
    }
    @objc func setupCollectionView(){
        guard let collection = self.collectionView else {
            return
        }
        collection.delegate = self
        collection.dataSource = self
        //header
          collection.register(EVHeader.self, forCellWithReuseIdentifier: headerID)
        //EventNameCell
        collection.register(EventNameCell.self, forCellWithReuseIdentifier: nameID)
        //EventAdress
        collection.register(LocationCell.self, forCellWithReuseIdentifier: eventAddress)
        //weather
        collection.register(WeatherCell.self, forCellWithReuseIdentifier: weather)
        //date
        collection.register(DateAndTimeCell.self, forCellWithReuseIdentifier: date)
        //host
         collection.register(HostCell.self, forCellWithReuseIdentifier: host)
        //details
        collection.register(DetailCell.self, forCellWithReuseIdentifier: details)
        //attending
        collection.register(AttendiingCell.self, forCellWithReuseIdentifier: attending)
        //footer
        collection.register(EVFooter.self, forCellWithReuseIdentifier: footerID)
        collection.backgroundColor = .white
        setupViews()
        
    }
    
    @objc func setupViews(){
        self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(GoBack))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func GoBack(){
        self.navigationController?.popViewController(animated: true)
    }
    deinit {
        print("view deallocated")
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        
        if parent != nil && self.navigationItem.titleView == nil {
            initNavigationItemTitleView()
        }
    }
    
    //will create title view
    private func initNavigationItemTitleView() {
        titleView.font = UIFont(name: "NoirPro-Medium", size: 18)
        titleView.text = "Event Details"
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 500))
        self.navigationItem.titleView = titleView
        
    }
}


extension NewEventDetailViewController {

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 9
    }
    


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if section == 0 {
            //HEADER
            return 1
        }else if section == 1{
            //EVENT NAME
            return 1
        }else if section == 2{
            //Address
            return 1
        }else if section == 3{
            //weather
            return 1
        }else if section == 4{
            //date
            return 1
        }else if section == 5 {
            //host
            return 1
        }else if section == 6 {
            //details
            return 1
        }else if section == 7 {
            return 1
        }else {
            //FOOTER
            return 1
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            //HEADER
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: headerID, for: indexPath) as! EVHeader
            
            // Configure the cell
            guard let event = currentEvent else {
                return cell
            }
            cell.imageURL = URL(string: (event.currentEventImage))
            cell.homeRef = self
            cell.eventPromo = event.currentEventPromo
            return cell
           
        } else if indexPath.section == 1 {
            //EVENTNAME
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nameID, for: indexPath) as! EventNameCell
            
            // Configure the cell
            guard let event = currentEvent else {
                return cell
            }
            
            cell.eventNameLabel.text = event.currentEventName.capitalized
            
            return cell
            
        }else  if indexPath.section == 2{
            //Address
             let cell = collectionView.dequeueReusableCell(withReuseIdentifier: eventAddress, for: indexPath) as! LocationCell
                        guard let event = currentEvent else {
                            return cell
                        }
            cell.streetAddress = event.currentEventStreetAddress
            cell.zip = event.currentEventZip
            cell.state = event.currentEventState.uppercased()
            cell.city = event.currentEventCity
            cell.tagList.removeAllTags()
            cell.tags = event.eventTags
            return cell
            
        }else if indexPath.section == 3{
            //weather
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: weather, for: indexPath) as! WeatherCell
            guard let event = currentEvent else {
                return cell
            }
            let firstPartOfAddress = (event.currentEventStreetAddress)  + "" + (event.currentEventCity) + ", " + (event.currentEventState)
            let secondPartOfAddress = firstPartOfAddress + " " + String(describing: event.currentEventZip)
            cell.location = secondPartOfAddress
            cell.date = event.startTime
            return cell
        }else if indexPath.section == 4 {
            //date
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: date, for: indexPath) as! DateAndTimeCell
            guard let event = currentEvent else {
                return cell
            }
            cell.startTime = event.currentEventTime
            cell.endTime = event.currentEventEndTime

            cell.startDate = event.currentEventDate
            cell.endDate = event.currentEventEndDate
            return cell
            
        }else if indexPath.section == 5 {
            //host
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: host, for: indexPath) as! HostCell
            guard let event = currentEvent else {
                return cell
            }
            cell.userHost = event.userHost
            cell.orgHost = event.orgHost
            return cell
        } else if indexPath.section == 6 {
            //details
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: details, for: indexPath) as! DetailCell
            guard let event = currentEvent else {
                return cell
            }
            cell.eventDescription = event.currentEventDescription
            return cell
        }else if indexPath.section == 7 {
        //attending
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: attending, for: indexPath) as! AttendiingCell
            guard let event = currentEvent else {
                return cell
            }
            cell.eventKey = event.key
            cell.homeRef = self
            return cell
        }else {
            //FOOTER
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: footerID, for: indexPath) as! EVFooter
            
            // Configure the cell
            guard let event = currentEvent else {
                return cell
            }
            cell.event = event
            cell.homeRef = self
            return cell

        }

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            //header
            return CGSize(width: collectionView.frame.width, height: 456.61)
        }else if indexPath.section == 1 {
            //event name
            return CGSize(width: collectionView.frame.width, height: 40.0)
        }else if indexPath.section == 2{
            //Address CELLS
            return CGSize(width: collectionView.frame.width, height: 70.0)
        }else if indexPath.section == 3{
            //weather
            return CGSize(width: collectionView.frame.width, height: 80.0)
        }else if indexPath.section == 4{
            //date
            return CGSize(width: collectionView.frame.width, height: 100.0)
        }else if indexPath.section == 5 {
            //host
            return CGSize(width: collectionView.frame.width, height: 110.0)
        }else if indexPath.section == 6{
            //details
            guard let event = currentEvent else {
                return CGSize(width: 0, height: 0)
            }
            guard let customFont = UIFont(name: "NoirPro-SemiBold", size: 15) else {
                fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
                )
            }
            let feature = event.currentEventDescription
            let height = feature.height(withConstrainedWidth: collectionView.frame.width,
                                        font:customFont)
            print(height)
            return CGSize(width: collectionView.frame.width, height: height + 50)
        }else if indexPath.section == 7{
            return CGSize(width: collectionView.frame.width, height: 90.0)
        }else  {
            //FOOTER
            return CGSize(width: collectionView.frame.width, height: 300.0)
        }
    }


}

extension NewEventDetailViewController {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 0, 0, 0)
        
    }
    
}

