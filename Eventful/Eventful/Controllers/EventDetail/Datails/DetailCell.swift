//
//  DetailCell.swift
//  Eventful
//
//  Created by Shawn Miller on 9/23/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

class DetailCell: UICollectionViewCell {
    
    var eventDescription: String? {
        didSet{

            guard let eventDescription = eventDescription else {
                return
            }
            eventDetails.text = eventDescription
            updateWithSpacing(lineSpacing: 10.0)
            textViewDidChange(eventDetails)
        
        }
    }
    
    
    lazy var detailsLabel: UILabel = {
        let detailsLabel = UILabel()
        detailsLabel.text = "About Event"
        guard let customFont = UIFont(name: "NoirPro-SemiBold", size: 15) else {
            fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        detailsLabel.textColor = .black
        detailsLabel.textAlignment = .left
        detailsLabel.font = customFont
        detailsLabel.numberOfLines = 0
        return detailsLabel
    }()
    
    lazy var eventDetails: UITextView = {
        let textView = UITextView()
        guard let customFont = UIFont(name: "NoirPro-SemiBold", size: 15) else {
            fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        textView.font = customFont
        textView.textColor = UIColor.rgb(red: 32, green: 32, blue: 32)
        textView.textContainer.maximumNumberOfLines = 0
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.textAlignment = .natural
        return textView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    fileprivate func setupViews(){
        addSubview(detailsLabel)
        addSubview(eventDetails)
        eventDetails.delegate = self
        detailsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top)
            make.left.equalTo(self.snp.left).offset(5)
        }
        
        eventDetails.snp.makeConstraints {
            make in
            make.top.equalTo(detailsLabel.snp.bottom).offset(15)
            make.left.right.equalTo(self).inset(5)
            make.height.equalTo(50)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Update Line Spacing
    func updateWithSpacing(lineSpacing: Float) {
        // The attributed string to which the
        // paragraph line spacing style will be applied.
        let attributedString = NSMutableAttributedString(string: eventDetails.text!)
        let mutableParagraphStyle = NSMutableParagraphStyle()
        // Customize the line spacing for paragraph.
        mutableParagraphStyle.lineSpacing = CGFloat(lineSpacing)
        mutableParagraphStyle.alignment = .justified
        if let stringLength = eventDetails.text?.count {
            attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: mutableParagraphStyle, range: NSMakeRange(0, stringLength))
        }
        // textLabel is the UILabel subclass
        // which shows the custom text on the screen
        eventDetails.attributedText = attributedString
        
    }
    
}

extension DetailCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        print(textView.text)
        let size = CGSize(width: self.frame.width - 5, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
    }
    
}
