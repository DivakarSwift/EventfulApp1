//
//  FeaturedCell.swift
//  Eventful
//
//  Created by Shawn Miller on 8/29/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit

class FeaturedCell: UICollectionViewCell, UICollectionViewDelegateFlowLayout {
    let featuredCellID = "featuredCell"
    var featured = FeaturedHeader()
    var featuredEvents:[Event]?{
        didSet{
            print("recieved featured event")
            homeFeedCollectionView.reloadData()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    
    
    let homeFeedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        return cv
    }()
    
    
    
    @objc func setupViews(){
        addSubview(featured)
        addSubview(homeFeedCollectionView)
        homeFeedCollectionView.delegate = self
        homeFeedCollectionView.dataSource = self
        homeFeedCollectionView.showsHorizontalScrollIndicator = false
        homeFeedCollectionView.register(FeaturedEventCell.self, forCellWithReuseIdentifier: featuredCellID)
        featured.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top).offset(5)
            make.height.equalTo(30)
            make.left.right.equalTo(self)
        }
        homeFeedCollectionView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.top.equalTo(self.featured.snp.bottom).offset(10)
            make.bottom.equalTo(self.snp.bottom).inset(15)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



extension FeaturedCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = featuredEvents?.count else {
            return 0
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: featuredCellID, for: indexPath) as! FeaturedEventCell
        cell.event = featuredEvents?[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 304.46, height: 370)    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 5, bottom: 20, right: 5)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("cell selected")
    }
    
}


