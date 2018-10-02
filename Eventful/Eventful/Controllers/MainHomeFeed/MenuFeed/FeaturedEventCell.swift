//
//  FeaturedEventCell.swift
//  Eventful
//
//  Created by Shawn Miller on 8/29/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit

class FeaturedEventCell: UICollectionViewCell {
    var event: Event? {
        didSet{
            guard let currentEvent = event else {
                return
            }
            guard URL(string: currentEvent.currentEventImage) != nil else { return }
            backgroundImageView.loadImage(urlString: currentEvent.currentEventImage)
//            eventNameLabel.text = currentEvent.currentEventName.capitalized
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    public var backgroundImageView: CustomImageView = {
        let firstImage = CustomImageView()
        firstImage.clipsToBounds = true
        firstImage.translatesAutoresizingMaskIntoConstraints = false
        firstImage.contentMode = .scaleToFill
        firstImage.layer.cornerRadius = 8
        return firstImage
    }()
    
    @objc func setupViews(){
        
        
//        let infoNameLabel = UILabel()
//        infoNameLabel.text = "Astro World Tour"
//        infoNameLabel.textAlignment = .center
//        infoNameLabel.backgroundColor = UIColor.black.withAlphaComponent(0.1)
//        infoNameLabel.textColor = UIColor.white
//        infoNameLabel.font = UIFont(name: "NoirPro-SemiBold", size: 28)
//        infoNameLabel.adjustsFontSizeToFitWidth = true
        
        setCellShadow()
        addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
//        backgroundImageView.addSubview(infoNameLabel)
//        infoNameLabel.snp.makeConstraints { (make) in
//            make.bottom.equalTo(backgroundImageView.snp.bottom)
//            make.left.right.equalTo(backgroundImageView)
//        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
