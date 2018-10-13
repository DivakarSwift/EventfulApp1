//
//  FinalCategoryCell.swift
//  Eventful
//
//  Created by Shawn Miller on 8/30/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

class FinalCategoryCell: UICollectionViewCell, UICollectionViewDelegateFlowLayout {
    let categoryCellID = "categoryCell"
    let category = CategoryHeader()
    var categoryEvents:[Event]?{
        didSet{
            print("recieved featured event")
            categroyFeedCollectionView.reloadData()
//            categroyFeedCollectionView.performBatchUpdates(nil, completion: {
//                (result) in
//                // ready
//                print("loading finished")
//            })
        }
    }
     weak var mainVC: MainViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    
    let categroyFeedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        return cv
    }()
    
    
    @objc func setupViews(){
        addSubview(categroyFeedCollectionView)
        addSubview(category)
        categroyFeedCollectionView.delegate = self
        categroyFeedCollectionView.dataSource = self
        categroyFeedCollectionView.showsHorizontalScrollIndicator = false
        categroyFeedCollectionView.decelerationRate = UIScrollViewDecelerationRateFast
        categroyFeedCollectionView.register(FinalCategoryEventCell.self, forCellWithReuseIdentifier: categoryCellID)
        category.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top).offset(5)
            make.height.equalTo(30)
            make.left.right.equalTo(self)
        }
        categroyFeedCollectionView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.top.equalTo(self.category.snp.bottom)
            make.bottom.equalTo(self.snp.bottom).inset(25)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension FinalCategoryCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = categoryEvents?.count else {
            return 0
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCellID, for: indexPath) as! FinalCategoryEventCell
        cell.event = categoryEvents?[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 142.88, height: 230.17)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let eventDetails = NewEventDetailViewController(collectionViewLayout: UICollectionViewFlowLayout())
         eventDetails.currentEvent = categoryEvents?[indexPath.item]
        mainVC?.navigationController?.pushViewController(eventDetails, animated: true)
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.categroyFeedCollectionView.scrollToNearestVisibleCollectionViewCell()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.categroyFeedCollectionView.scrollToNearestVisibleCollectionViewCell()
        }
    }
}

extension FinalCategoryCell: UICollectionViewDelegate {
    
}


