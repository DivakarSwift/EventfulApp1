//
//  DateAndTimeCell.swift
//  Eventful
//
//  Created by Shawn Miller on 9/23/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

class DateAndTimeCell: UICollectionViewCell {
    var startDate:String? {
        didSet{
            guard let beginDate = startDate else {
                return
            }
            let dateComponets = getDayAndMonthFromEvent(beginDate)
            let startTimeattributedText = NSMutableAttributedString(string:  "start time\n".capitalized, attributes: [NSAttributedStringKey.font: UIFont(name: "NoirPro-Regular", size: 13) as Any, NSAttributedStringKey.foregroundColor: UIColor.rgb(red: 185, green: 185, blue: 185)])
            guard let startTime = startTime else {
                return
            }
            let startTimeAttributedText2 = NSMutableAttributedString(string: "\(dateComponets.0) \(dateComponets.1) \(dateComponets.2) \(startTime)", attributes: [NSAttributedStringKey.font: UIFont(name: "NoirPro-Light", size: 13) as Any, NSAttributedStringKey.foregroundColor: UIColor.rgb(red: 32, green: 32, blue: 32)])
            
            startTimeattributedText.append(startTimeAttributedText2)
            startDateText.attributedText = startTimeattributedText
        }
    }
    
    var startTime:String? {
        didSet{
            
        }
    }
    
    var endDate:String? {
        didSet{
            guard let endDate = endDate else {
                return
            }
            guard let endTime = endTime else {
                return
            }
            let dateComponets = getDayAndMonthFromEvent(endDate)
            let endTimeattributedText = NSMutableAttributedString(string:  "end time\n".capitalized, attributes: [NSAttributedStringKey.font: UIFont(name: "NoirPro-Regular", size: 13) as Any, NSAttributedStringKey.foregroundColor: UIColor.rgb(red: 185, green: 185, blue: 185)])
            
            let endTimeAttributedText2 = NSMutableAttributedString(string: "\(dateComponets.0) \(dateComponets.1) \(dateComponets.2) \(endTime)", attributes: [NSAttributedStringKey.font: UIFont(name: "NoirPro-Light", size: 13) as Any, NSAttributedStringKey.foregroundColor: UIColor.rgb(red: 32, green: 32, blue: 32)])
            
            endTimeattributedText.append(endTimeAttributedText2)
            endDateText.attributedText = endTimeattributedText

        }
    }
    
    var endTime:String? {
        didSet{
            
        }
    }
    
    
    lazy var dateAndTimeLabel: UILabel = {
        let dateAndTimeLabel = UILabel()
        dateAndTimeLabel.text = "Date & Time"
        guard let customFont = UIFont(name: "NoirPro-Medium", size: 15) else {
            fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        dateAndTimeLabel.textColor = UIColor.rgb(red: 32, green: 32, blue: 32)
        dateAndTimeLabel.textAlignment = .left
        dateAndTimeLabel.font = customFont
        dateAndTimeLabel.numberOfLines = 0
        return dateAndTimeLabel
    }()
    
    lazy var startDateText: UILabel = {
        let startDateText = UILabel()
        startDateText.textAlignment = .left
        startDateText.numberOfLines = 0
        return startDateText
    }()
    
    lazy var endDateText: UILabel = {
        let endDateText = UILabel()
        endDateText.textAlignment = .left
        endDateText.numberOfLines = 0
        return endDateText
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    
    fileprivate func setupViews(){
        addSubview(dateAndTimeLabel)
        addSubview(startDateText)
        addSubview(endDateText)
        dateAndTimeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top)
            make.left.equalTo(self.snp.left).inset(5)
        }
        startDateText.snp.makeConstraints { (make) in
            make.top.equalTo(dateAndTimeLabel.snp.bottom).offset(15)
            make.left.equalTo(self.snp.left).inset(5)
        }
        endDateText.snp.makeConstraints { (make) in
            make.top.equalTo(startDateText.snp.bottom).offset(8)
            make.left.equalTo(self.snp.left).inset(5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    fileprivate func getDayAndMonthFromEvent(_ date:String?) -> (String, String, String) {
        guard let eventdateParam = date else {
            return ("","","")
        }
        let apiDateFormat = "MM/dd/yyyy"
        let df = DateFormatter()
        df.dateFormat = apiDateFormat
        guard let eventDate = df.date(from: eventdateParam) else {
            return ("","","")
        }
        df.dateFormat = "dd"
        let dayElement = df.string(from: eventDate)
        df.dateFormat = "MMM"
        let monthElement = df.string(from: eventDate)
        df.dateFormat = "yyyy"
        let yearElement = df.string(from: eventDate)
        return (dayElement, monthElement, yearElement)
    }
}
