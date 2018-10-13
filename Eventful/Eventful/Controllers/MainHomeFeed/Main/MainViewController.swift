//
//  MainViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 8/29/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import Parchment
import CoreLocation
import SwiftLocation
import GooglePlaces
import SVProgressHUD
import SideMenuSwift
import TransitionButton



class MainViewController: CustomTransitionViewController,ContentViewControllerDelegate {
    fileprivate let items = [
        ImageItem(index: 1, title: "City", headerImage: UIImage(named: "city")!),
        ImageItem(index: 2, title: "Concert", headerImage: UIImage(named: "concert")!),
        ImageItem(index: 4, title: "Sports", headerImage: UIImage(named: "sports")!),
        ImageItem(index: 5, title: "University", headerImage: UIImage(named: "university")!)
    ]
    let pagingViewController = CustomPagingViewController()
    let customLeftBar = LocationManager()
    var placesClient = GMSPlacesClient()

    private let menuInsets = UIEdgeInsets(top: 12, left: 5, bottom: 12, right: 5)
    private let menuItemSize = CGSize(width: 85, height: 70)
    private var menuHeight: CGFloat {
        return menuItemSize.height + menuInsets.top + menuInsets.bottom
    }
    var savedLocation: CLLocation?
    var lastSelectedDate: Date?
    var finalCategoryEvents:[String:[Event]] = [:]
    var featuredEvents:[String:[Event]] = [:]
    let dateFormatter = DateFormatter()
    var isFromLoginOrSignUp: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false

    }
    
    @objc func setupViews(){
        view.backgroundColor = .white
        setupBarButtonItems()
        setupPagingController()
        grabUserLocation()
    }
    
    private func calculateMenuHeight(for scrollView: UIScrollView) -> CGFloat {
        // Calculate the height of the menu view based on the scroll view
        // content offset.
        let maxChange: CGFloat = 30
        let offset = min(maxChange, scrollView.contentOffset.y + menuHeight) / maxChange
        let height = menuHeight - (offset * maxChange)
        return height
    }
    
    private func updateMenu(height: CGFloat) {
        guard let menuView = pagingViewController.view as? CustomPagingView else { return }
        
        // Update the height constraint of the menu view.
        menuView.menuHeightConstraint?.constant = height
        
        // Update the size of the menu items.
        pagingViewController.menuItemSize = .sizeToFit(
            minWidth: menuItemSize.width,
            height: height - menuInsets.top - menuInsets.bottom
        )
        
        // Invalidate the collection view layout and call layoutIfNeeded
        // to make sure the collection is updated.
        pagingViewController.collectionViewLayout.invalidateLayout()
        pagingViewController.collectionView.layoutIfNeeded()
    }
    
    
    /// Calculate the menu offset based on the content offset of the
    /// scroll view.
    private func menuOffset(for scrollView: UIScrollView) -> CGFloat {
        return min(pagingViewController.options.menuHeight, max(0, scrollView.contentOffset.y))
    }
    
    func contentViewControllerDidScroll(menuFeed : MenuFeedController) {
        if let menuView = pagingViewController.view as? CustomPagingView {
            menuView.menuTopConstraint?.constant = -menuOffset(for: menuFeed.collectionView)
        }
        let height = calculateMenuHeight(for: menuFeed.collectionView)
        updateMenu(height: height)
    }
    
    
    
    @objc func setupPagingController(){
        pagingViewController.menuItemSource =  .class(type: ImagePagingCell.self)
        pagingViewController.menuItemSize = .sizeToFit(minWidth: menuItemSize.width, height: menuItemSize.height)
        pagingViewController.menuItemSpacing = 8
        pagingViewController.menuInsets = menuInsets
        pagingViewController.borderColor = UIColor(white: 0, alpha: 0.1)
        pagingViewController.indicatorColor = UIColor.rgb(red: 44, green: 152, blue: 229)
        pagingViewController.contentInteraction = .none
        
        
        pagingViewController.indicatorOptions = .visible(
            height: 1,
            zIndex: Int.max,
            spacing: UIEdgeInsets.zero,
            insets: UIEdgeInsets.zero)
        
        pagingViewController.borderOptions = .visible(
            height: 1,
            zIndex: Int.max - 1,
            insets: UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18))
        
        addChildViewController(pagingViewController)
        view.addSubview(pagingViewController.view)
        pagingViewController.view.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        
        pagingViewController.didMove(toParentViewController: self)
        
        // Set our custom data source.
        pagingViewController.dataSource = self
        pagingViewController.delegate = self
        
        // Set the first item as the selected paging item.
        pagingViewController.select(index: 0)
    }
    
    @objc func setupBarButtonItems(){
        let sideMenuButton = UIBarButtonItem(image: UIImage(named: "icons8-Menu-48")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.rightBarPressed))
        let calendarButton = UIBarButtonItem(image: UIImage(named: "icons8-calendar-50")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.presentCalendar))
        navigationItem.rightBarButtonItems = [sideMenuButton,calendarButton]
    }
    
    //will present the dropdown/side menu
    @objc func rightBarPressed(){
        print("right bar tapped")
        self.sideMenuController?.revealMenu(animated: true, completion: nil)
    }
    
    //will present search vc
    @objc func leftBarPressed(){
        print("left bar tapped")
        let searchController = PlacesSearchController()
        searchController.mainVC = self
        self.navigationController?.pushViewController(searchController, animated: false)
    }
    
    //will present the calendar
    @objc func presentCalendar(){
        print("calendar pressed")
        let calendar = CalendarViewController()
        if let lastDate = lastSelectedDate {
            calendar.passedDate = lastDate
        }
        calendar.mainVC = self
        calendar.savedLocation1 = self.savedLocation
          self.navigationController?.pushViewController(calendar, animated: true)
    }

}


extension MainViewController: PagingViewControllerDataSource {
    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController {
        let menu = MenuFeedController()
        menu.featuredEvents = self.featuredEvents[items[index].title.lowercased()]
        menu.finalCategoryEvents = self.finalCategoryEvents[items[index].title.lowercased()]
        let menuHeight = pagingViewController.options.menuHeight
        let insets = UIEdgeInsets(top: menuHeight, left: 0, bottom: 0, right: 0)
        menu.collectionView.contentInset = insets
        menu.ContentViewControllerDelegate = self
        menu.collectionView.scrollIndicatorInsets = insets
        menu.rootRef = self
        return menu
    }
    
    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T {
        return items[index] as! T
    }
    
    func numberOfViewControllers<T>(in: PagingViewController<T>) -> Int{
        return items.count
    }
    
}

extension MainViewController: PagingViewControllerDelegate {
    // We want to transition the menu offset smoothly to it correct
    // position when we are swiping between pages.
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, isScrollingFromItem currentPagingItem: T, toItem upcomingPagingItem: T?, startingViewController: UIViewController, destinationViewController: UIViewController?, progress: CGFloat) {
        guard let destinationViewController = destinationViewController as? UICollectionViewController else { return }
        guard let startingViewController = startingViewController as? UICollectionViewController else { return }
        guard let menuView = pagingViewController.view as? CustomPagingView else { return }
        
        // Tween between the current menu offset and the menu offset of
        // the destination view controller.
        let from = menuOffset(for: startingViewController.collectionView!)
        let to = menuOffset(for: destinationViewController.collectionView!)
        let offset = ((to - from) * abs(progress)) + from
        
        
        let from1 = calculateMenuHeight(for: startingViewController.collectionView!)
        let to1 = calculateMenuHeight(for: destinationViewController.collectionView!)
        let height1 = ((to1 - from1) * abs(progress)) + from1
        updateMenu(height: height1)
        
        menuView.menuTopConstraint?.constant = -offset
    }
}

extension FixedPagingViewController {
    
    var selectedIndex: Int? {
        if let selected = pageViewController.selectedViewController, let index = viewControllers.index(of: selected) {
            return index
        }
        return nil
    }
}


extension MainViewController {
    
    @objc func getSelectedDateFromCal(from selectedDate: Date){
        lastSelectedDate = selectedDate
        print(selectedDate.description)
        dateFormatter.dateFormat = "MM/dd/yyyy"
        SVProgressHUD.show(withStatus: "Grabbing Events")
        self.finalCategoryEvents.removeAll()
        self.featuredEvents.removeAll()
        if let location = self.savedLocation {
            fetchEvents(currentLocation: location, selectedDate: selectedDate)
        }
        
    }
    
    
    @objc func fetchEvents(currentLocation: CLLocation, selectedDate: Date){
        
        PostService.showEvent(cameFromeHomeFeed: true, passedDate: selectedDate,for: currentLocation, completion: {(events) in
         
            
          
            for event in events {
                if self.finalCategoryEvents[event.category] == nil {
                    self.finalCategoryEvents[event.category] = []
                }
                
                if var arr = self.finalCategoryEvents[event.category]{
                    arr.append(event)
                    print(arr)
                    self.finalCategoryEvents[event.category] = arr.sorted(by: { (event1, event2) -> Bool in
                        return event1.startTime.compare(event2.startTime) == .orderedAscending
                    })
                }
            }
            
            
            PostService.showFeaturedEvent(cameFromHomeFeed: true, passedDate: selectedDate,for: currentLocation, completion: { [weak self] (events) in
                
                for event in events {
                    if self?.featuredEvents[event.category] == nil {
                        self?.featuredEvents[event.category] = []
                    }
                    
                    if var arr = self?.featuredEvents[event.category]{
                        arr.append(event)
                        self?.featuredEvents[event.category] = arr.sorted(by: { (event1, event2) -> Bool in
                            return event1.startTime.compare(event2.startTime) == .orderedAscending
                        })                    }
                }
                
                self?.pagingViewController.reloadData()
                
                }
            )
            
        })
    }
    
}




extension MainViewController {
    @objc func grabUserLocation(placeId: String? = nil){
        
        //will perform this if the user tries to change location
        
        if let placeIDParam = placeId {
            
            placesClient.lookUpPlaceID(placeIDParam) { (place, error) in
                if error != nil {
                    print("lookup place id query error: \(error!.localizedDescription)")
                    return
                }
                if let p = place {
                    let currentLocation = CLLocation(latitude: p.coordinate.latitude, longitude: p.coordinate.longitude)
                    self.savedLocation = currentLocation
                    ///remove all events
                    self.finalCategoryEvents.removeAll()
                    self.featuredEvents.removeAll()
                    //grab featured events
                    PostService.showFeaturedEvent(cameFromHomeFeed: true, for: currentLocation, completion: { [weak self] (events) in
                        
                        for event in events {
                            if self?.featuredEvents[event.category] == nil {
                                self?.featuredEvents[event.category] = []
                            }
                            
                            if var arr = self?.featuredEvents[event.category]{
                                arr.append(event)
                                self?.featuredEvents[event.category] = arr.sorted(by: { (event1, event2) -> Bool in
                                    return event1.startTime.compare(event2.startTime) == .orderedAscending
                                })                    }
                        }
                        
                        //grab all other category events
                        PostService.showEvent(cameFromeHomeFeed: true, for: currentLocation, completion: { (events) in
                            
                            for event in events {
                                if self?.finalCategoryEvents[event.category] == nil {
                                    self?.finalCategoryEvents[event.category] = []
                                }
                                
                                if var arr = self?.finalCategoryEvents[event.category]{
                                    arr.append(event)
                                    print(arr)
                                    self?.finalCategoryEvents[event.category] = arr.sorted(by: { (event1, event2) -> Bool in
                                        return event1.startTime.compare(event2.startTime) == .orderedAscending
                                    })
                                }
                            }
                            
                            self?.pagingViewController.reloadData()
                            
                        })
                        
                    })
                    
                }else {
                    print("No place details for \(placeIDParam)")
                }
                
            }
            
            
            
        }else{
            
            LocationService.getUserLocation { (currentLocation) in
                guard let savedLocation = currentLocation else {
                    return
                }
                
                self.savedLocation = savedLocation
                
                CLGeocoder().reverseGeocodeLocation(savedLocation, completionHandler: {(placemarks, error) -> Void in
                    if error != nil {
                        print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                        return
                    }
                    if placemarks!.count > 0 {
                        let pm = placemarks![0]
                        self.customLeftBar.viewController = self
                        self.customLeftBar.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.leftBarPressed)))
                        self.navigationItem.leftBarButtonItem = self.customLeftBar
                        self.customLeftBar.cityText.text = "\(pm.locality!), \(pm.administrativeArea!)"
                        self.grabEvents(location: savedLocation)
                    }
                    else {
                        print("Problem with the data received from geocoder")
                    }
                })
                
            }
        }
        
    }
    
    
    
    @objc func grabEvents(location: CLLocation){
        PostService.showEvent(cameFromeHomeFeed: true, for: location) { (events) in
            for event in events {
                if self.finalCategoryEvents[event.category] == nil {
                    self.finalCategoryEvents[event.category] = []
                }
                
                if var arr = self.finalCategoryEvents[event.category]{
                    arr.append(event)
                    print(arr)
                    self.finalCategoryEvents[event.category] = arr.sorted(by: { (event1, event2) -> Bool in
                        return event1.startTime.compare(event2.startTime) == .orderedAscending
                    })
                }
            }
            print(self.finalCategoryEvents.count)
            
            PostService.showFeaturedEvent(cameFromHomeFeed: true, for: location, completion: { [weak self] (events) in
                
                for event in events {
                    if self?.featuredEvents[event.category] == nil {
                        self?.featuredEvents[event.category] = []
                    }
                    
                    if var arr = self?.featuredEvents[event.category]{
                        arr.append(event)
                        self?.featuredEvents[event.category] = arr.sorted(by: { (event1, event2) -> Bool in
                            return event1.startTime.compare(event2.startTime) == .orderedAscending
                        })                    }
                }
                self?.pagingViewController.reloadData()
                    NotificationCenter.default.post(name: heartAttackNotificationName, object: nil)
                
                
                
                print(self?.featuredEvents.count as Any)
                }
            )
        }
    }
}

