//
//  FinalCategoryEventCell.swift
//  Eventful
//
//  Created by Shawn Miller on 8/30/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

class FinalCategoryEventCell: UICollectionViewCell {

    var event: Event? {
        didSet{
            guard let currentEvent = event else {
                return
            }
            guard URL(string: currentEvent.currentEventImage) != nil else { return }
            backgroundImageView.loadImage(urlString: currentEvent.currentEventImage)
            eventNameLabel.text = currentEvent.currentEventName.capitalized
            let dateComponets = getDayAndMonthFromEvent(currentEvent)
            eventDateLabel.text = dateComponets.0 + " "+dateComponets.1 + " "+dateComponets.2
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    let eventNameLabel : UILabel =  {
        let eventNameLabel = UILabel()
        eventNameLabel.font = UIFont(name:"NoirPro-Medium", size: 15.0)
        eventNameLabel.textAlignment = .left
        eventNameLabel.lineBreakMode = .byTruncatingTail
        eventNameLabel.text = eventNameLabel.text?.uppercased()
        return eventNameLabel
    }()
    
    let eventDateLabel : UILabel =  {
        let eventDateLabel = UILabel()
        eventDateLabel.textColor = UIColor.rgb(red: 132, green: 132, blue: 132)
        eventDateLabel.font = UIFont(name:"NoirPro-Regular", size: 13.0)
        eventDateLabel.textAlignment = .left
        eventDateLabel.adjustsFontSizeToFitWidth = true
        eventDateLabel.text = eventDateLabel.text?.uppercased()
        return eventDateLabel
    }()
    
    public var backgroundImageView: CustomImageView = {
        let firstImage = CustomImageView()
        firstImage.setupShadow2()
        firstImage.contentMode = .scaleToFill
        return firstImage
    }()
    
    @objc func setupViews(){
        addSubview(backgroundImageView)
        addSubview(eventDateLabel)
        addSubview(eventNameLabel)
        backgroundImageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top)
            make.left.right.equalTo(self)
            make.height.equalTo(180)
        }
        eventDateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(backgroundImageView.snp.bottom).offset(5)
            make.left.right.equalTo(self)
            make.height.equalTo(20)
        }
        eventNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(eventDateLabel.snp.bottom).offset(5)
            make.left.right.equalTo(self)
            make.height.equalTo(20)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    fileprivate func getDayAndMonthFromEvent(_ event:Event) -> (String, String, String) {
        let apiDateFormat = "MM/dd/yyyy"
        let df = DateFormatter()
        df.dateFormat = apiDateFormat
        let eventDate = df.date(from: event.currentEventDate!)!
        df.dateFormat = "dd"
        let dayElement = df.string(from: eventDate)
        df.dateFormat = "MMM"
        let monthElement = df.string(from: eventDate)
        df.dateFormat = "yyyy"
        let yearElement = df.string(from: eventDate)
        return (dayElement, monthElement, yearElement)
    }
}
