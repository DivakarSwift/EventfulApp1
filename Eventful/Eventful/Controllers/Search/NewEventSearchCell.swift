//
//  NewEventSearchCell.swift
//  Eventful
//
//  Created by Shawn Miller on 6/26/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

class NewEventSearchCell: BaseCell {
    var searchVc: NewSearchVC?
    var filteredEvents : [Event]? {
        didSet{
            guard let currentEvents = filteredEvents else {
                return
            }
            if currentEvents.count > 0 {
                searchResultsLabel.isHidden = false
            }
            eventSearchCollectionView.reloadData()
        }
    }
    private let cellId = "cellId"
    let eventSearchCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        return cv
    }()
    
    let searchResultsLabel : UILabel = {
        let label = UILabel()
        label.text = "Search Results"
        guard let customFont = UIFont(name: "ProximaNovaSoft-Regular", size: 22) else {
            fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        label.font = UIFontMetrics.default.scaledFont(for: customFont)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    override func setupViews() {
        backgroundColor = .clear
        addSubview(searchResultsLabel)
        addSubview(eventSearchCollectionView)
        searchResultsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top).offset(10)
            make.left.equalTo(self.snp.left).offset(5)
        }
        searchResultsLabel.isHidden = true
        eventSearchCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(searchResultsLabel.snp.bottom)
            make.left.right.equalTo(self)
            make.bottom.equalTo(self).inset(5)
        }
        eventSearchCollectionView.delegate = self
        eventSearchCollectionView.dataSource = self
        eventSearchCollectionView.register(SearchCell.self, forCellWithReuseIdentifier: cellId)

    }
}

extension NewEventSearchCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let currentCount = filteredEvents?.count else{
            return 0
        }
        return currentCount
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width - 40, height: 215)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let event = filteredEvents![indexPath.item]
        let currentEventDetailController = EventDetailViewController()
        currentEventDetailController.currentEvent = event
        searchVc?.navigationController?.pushViewController(currentEventDetailController, animated: true)

    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SearchCell
        cell.event = filteredEvents?[indexPath.item]
        return cell
    }
    
    
}
