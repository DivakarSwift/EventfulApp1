//
//  MenuFeedController.swift
//  Eventful
//
//  Created by Shawn Miller on 8/29/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

protocol ContentViewControllerDelegate: class {
    func contentViewControllerDidScroll(menuFeed: MenuFeedController)
}


class MenuFeedController: UIViewController,UICollectionViewDelegateFlowLayout {
    weak var ContentViewControllerDelegate: ContentViewControllerDelegate? = nil
    weak var rootRef: MainViewController?
    let featuredSectionID = "featuredSection"
    let categoryEventsSectionID = "categoryEvents"
    var categoryEvents:[String:[Event]] = [:]

    var featuredEvents:[Event]?{
        didSet{
            print("recieved featured events")
        }
    }
    var finalCategoryEvents:[Event]? {
        didSet{
            
            guard let events = self.finalCategoryEvents else {
                return
            }
            
            for event in events {
                
                if let first = event.eventTags?.first {
                    if self.categoryEvents[first] == nil {
                        self.categoryEvents[first] = []
                    }
                    
                    if var arr = self.categoryEvents[first] {
                        arr.append(event)
                        self.categoryEvents[first] = arr
                    }
                    
                }
            }
            
            collectionView.reloadData()
        }
    }

    lazy var collectionView: UICollectionView = {
        let layout =   UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        collectionView.register(FeaturedCell.self, forCellWithReuseIdentifier: featuredSectionID)
        collectionView.register(FinalCategoryCell.self, forCellWithReuseIdentifier: categoryEventsSectionID)
        collectionView.emptyDataSetDelegate = self
        collectionView.emptyDataSetSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc func setupViews(){
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        collectionView.dataSource = self
        collectionView.delegate = self
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}


extension MenuFeedController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 5)
        }
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: view.frame.width, height: 440)
        }else {
            return CGSize(width: view.frame.width, height: 320)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        ContentViewControllerDelegate?.contentViewControllerDidScroll(menuFeed: self)
    }
}

extension MenuFeedController: UICollectionViewDataSource {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if section == 0 {
            guard let featureCount = self.featuredEvents?.count else {
                return 0
            }
            return featureCount
        }else {
         return self.categoryEvents.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: featuredSectionID, for: indexPath) as! FeaturedCell
            cell.featuredEvents = featuredEvents
         let attributedText = NSMutableAttributedString(string:  "featured".uppercased(), attributes: [NSAttributedStringKey.font: UIFont(name: "NoirPro-SemiBold", size: 25) as Any])
        let attributedText2 = NSMutableAttributedString(string:  " events".uppercased(), attributes: [NSAttributedStringKey.font: UIFont(name: "NoirPro-Light", size: 25) as Any])
            attributedText.append(attributedText2)
            cell.featured.featuredLabel.attributedText =  attributedText
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryEventsSectionID, for: indexPath) as! FinalCategoryCell
        
        cell.categoryEvents = self.categoryEvents[Array(categoryEvents.keys)[indexPath.item]]
        cell.mainVC = rootRef
        
        let nsRange = NSString(string: Array(categoryEvents.keys)[indexPath.item].uppercased()).range(of: " ", options: String.CompareOptions.caseInsensitive)
        
        if nsRange.location != NSNotFound {
            let attributedSubString = NSMutableAttributedString.init(string: NSString(string: Array(categoryEvents.keys)[indexPath.item].uppercased()).substring(from: nsRange.location), attributes: [NSAttributedStringKey.font : UIFont(name: "NoirPro-Light", size: 25) as Any ])
            let normalNameString = NSMutableAttributedString.init(string: NSString(string: Array(categoryEvents.keys)[indexPath.item].uppercased()).substring(to: nsRange.location), attributes: [NSAttributedStringKey.font : UIFont(name: "NoirPro-SemiBold", size: 25) as Any ])
            normalNameString.append(attributedSubString)
                cell.category.categoryLabel.attributedText =  normalNameString
        }else {
            let attributedText = NSMutableAttributedString(string:  Array(categoryEvents.keys)[indexPath.item].uppercased(), attributes: [NSAttributedStringKey.font: UIFont(name: "NoirPro-SemiBold", size: 25) as Any])
             cell.category.categoryLabel.attributedText =  attributedText
        }
    
        return cell
    }
    
    
}

extension MenuFeedController: DZNEmptyDataSetDelegate,DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attribute = [NSAttributedStringKey.font: UIFont(name: "NoirPro-Light", size: 20),NSAttributedStringKey.foregroundColor: UIColor.black]
        let str = "No events to show."
        return NSAttributedString(string: str, attributes: attribute as [NSAttributedStringKey : Any])
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attribute = [NSAttributedStringKey.font: UIFont(name: "NoirPro-Light", size: 15),NSAttributedStringKey.foregroundColor: UIColor.black]
        let str = "When there are events to attend they will be listed here"
        return NSAttributedString(string: str, attributes: attribute as [NSAttributedStringKey : Any])
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "icons8-face-50")
    }
}
