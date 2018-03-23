//
//  HomeFeedCell.swift
//  Eventful
//
//  Created by Devanshu Saini on 22/09/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

class HomeFeedCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private let cellId = "cellId"
    var featuredEvents: [Event]?{
        didSet {
            homeFeedCollectionView.reloadData()

        }
    }
    
    var titles: String? {
        didSet {
            guard let titles = titles else {
            return
            }
//            let attributedText = NSMutableAttributedString(string: titles, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 100)])
            sectionNameLabel.text = titles
//            sectionNameLabel.attributedText = attributedText
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let sectionNameLabel : UILabel =  {
        let sectionNameLabel = UILabel()
        sectionNameLabel.font = UIFont(name:"HelveticaNeue-CondensedBlack", size: 36.0)
        return sectionNameLabel
    }()
    
    let homeFeedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        return cv
    }()
    
    @objc func setupViews(){
        backgroundColor = .clear
        addSubview(homeFeedCollectionView)
        addSubview(sectionNameLabel)
        sectionNameLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 2, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        homeFeedCollectionView.anchor(top: sectionNameLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        homeFeedCollectionView.delegate = self
        homeFeedCollectionView.dataSource = self
        homeFeedCollectionView.showsHorizontalScrollIndicator = false
        homeFeedCollectionView.register(HomeFeedEventCell.self, forCellWithReuseIdentifier: cellId)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let currentEventCount = featuredEvents?.count else{
            return 0
        }
        return currentEventCount
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         return CGSize(width: frame.width, height: frame.height - 40)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomeFeedEventCell
        cell.event = featuredEvents?[indexPath.item]
        return cell
    }
}
