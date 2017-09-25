//
//  NewHomeFeedControllerViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 9/25/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import UIKit
import Alamofire
import AlamofireNetworkActivityIndicator
import SwiftLocation
import CoreLocation
import AMScrollingNavbar

class HomeFeedController: UIViewController {
    let detailView = EventDetailViewController()
    var allEvents = [Event]()
    let customCellIdentifier1 = "customCellIdentifier1"
    var grideLayout = GridLayout(numberOfColumns: 2)
    let refreshControl = UIRefreshControl()
    var newHomeFeed: NewHomeFeedControllerViewController?
    let paginationHelper = PaginationHelper<Event>(serviceMethod: PostService.showEvent)
    lazy var dropDownLauncer : DropDownLauncher = {
        let launcer = DropDownLauncher()
        launcer.homeFeed = self
        return launcer
    }()
    
    // 1 IGListKit uses IGListCollectionView, which is a subclass of UICollectionView, which patches some functionality and prevents others.
    let collectionView: UICollectionView = {
        // 2 This starts with a zero-sized rect since the view isn’t created yet. It uses the UICollectionViewFlowLayout just as the ClassicFeedViewController did.
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        // 3 The background color is set to white
        view.backgroundColor = UIColor.white
        return view
    }()
    func handleDropDownMenu(){
        dropDownLauncer.showDropDown()
    }
    func configureCollectionView() {
        // add pull to refresh
        refreshControl.addTarget(self, action: #selector(reloadHomeFeed), for: .valueChanged)
        collectionView.addSubview(refreshControl)
    }
    func reloadHomeFeed() {
        self.paginationHelper.reloadData(completion: { [unowned self] (events) in
            self.allEvents = events
            
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        })
    }
    
    func categoryFetch(dropDown: DropDown){
        navigationItem.title = dropDown.name
        paginationHelper.category = dropDown.name
        configureCollectionView()
        reloadHomeFeed()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        collectionView.contentInset = UIEdgeInsetsMake(15, 0, 0, 0)
        navigationItem.title = "Home"
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = grideLayout
        collectionView.reloadData()
        collectionView.register(CustomCell.self, forCellWithReuseIdentifier: customCellIdentifier1)
        //  self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: self, action: #selector(handleDropDownMenu))
        self.navigationItem.leftBarButtonItem = backButton
        configureCollectionView()
        reloadHomeFeed()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.followScrollView(self.collectionView, delay: 50.0)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let navigationController = navigationController as? ScrollingNavigationController {
            navigationController.stopFollowingScrollView()
        }
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        if let navigationController = navigationController as? ScrollingNavigationController {
            navigationController.showNavbar(animated: true)
        }
        return true
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        grideLayout.invalidateLayout()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension HomeFeedController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let selectedEvent = self.imageArray[indexPath.row]
        //let eventDetailVC
        if let cell = collectionView.cellForItem(at: indexPath){
            //  print("Look here for event name")
            // print(detailView.eventName)
            detailView.eventKey = allEvents[indexPath.row].key!
            detailView.eventPromo = allEvents[indexPath.row].currentEventPromo!
            detailView.currentEvent = allEvents[indexPath.row]
            present(detailView, animated: true, completion: nil)
            //self.navigationController?.pushViewController(detailView, animated: true)
            
        }
        print("Cell \(indexPath.row) selected")
    }
}

extension HomeFeedController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allEvents.count
    }
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let customCell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier1, for: indexPath) as! CustomCell
        let imageURL = URL(string: allEvents[indexPath.item].currentEventImage)
        print(imageURL ?? "")
        customCell.sampleImage.af_setImage(withURL: imageURL!)
        return customCell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section >= allEvents.count - 1 {
            // print("paginating for post")
            paginationHelper.paginate(completion: { [unowned self] (events) in
                self.allEvents.append(contentsOf: events)
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            })
        }else{
            print("Not paginating")
        }
    }
    
}


extension HomeFeedController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0 || indexPath.item == 1 {
            return CGSize(width: view.frame.width, height: grideLayout.itemSize.height)
        }else{
            return grideLayout.itemSize
        }
    }
}
//responsible for populating each cell with content

class CustomCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    let sampleImage: UIImageView = {
        let firstImage = UIImageView()
        firstImage.clipsToBounds = true
        firstImage.translatesAutoresizingMaskIntoConstraints = false
        firstImage.contentMode = .scaleToFill
        firstImage.layer.masksToBounds = true
        return firstImage
    }()
    let nameLabel: UILabel = {
        let name = UILabel()
        name.text = "Custom Text"
        name.translatesAutoresizingMaskIntoConstraints = false
        return name
    }()
    func setupViews() {
        addSubview(sampleImage)
        backgroundColor = UIColor.white
        //addSubview(nameLabel)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": sampleImage]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": sampleImage]))
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// responsible for creating the grid layout that you see in the home view feed

class GridLayout: UICollectionViewFlowLayout {
    
    var numberOfColumns:Int = 2
    
    init(numberOfColumns: Int) {
        super.init()
        // controlls spacing inbetween them as well as spacing below them to next item
        self.numberOfColumns = numberOfColumns
        self.minimumInteritemSpacing = 3
        self.minimumLineSpacing = 5
    }
    // just needs to be here because swift tells us to
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override var itemSize: CGSize{
        get{
            if collectionView != nil {
                let collectionVieweWidth = collectionView?.frame.width
                let itemWidth = (collectionVieweWidth!/CGFloat(self.numberOfColumns)) - self.minimumInteritemSpacing
                let itemHeight: CGFloat = 200
                return CGSize(width: itemWidth, height: itemHeight)
            }
            return CGSize(width: 100, height: 100)
        }set{
            super.itemSize = newValue
        }
    }
    
    
}