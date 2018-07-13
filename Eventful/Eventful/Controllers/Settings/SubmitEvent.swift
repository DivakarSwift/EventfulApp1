//
//  SubmitEvent.swift
//  Eventful
//
//  Created by Shawn Miller on 7/11/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit
import Eureka
import ViewRow
import ImageRow

class submitEvent: FormViewController {
    lazy var submitEventPromptLabel : UILabel = {
        let label = UILabel()
        let customFont = UIFont.systemFont(ofSize: 18)
        label.font = UIFontMetrics.default.scaledFont(for: customFont)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textAlignment = .justified
        label.text = "We are always looking to add to our growing collection of events. Fill out the form below with all the necessary info and submit your own event for review. If every thing checks out during the review process your event will be added to the appropriate section on the main page.\n\n -Thanks Haipe "
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    @objc func setupViews(){
        navigationItem.title = "Submit an Event"
        self.tableView.backgroundColor = .white
//        view.addSubview(submitEventPromptLabel)
//        submitEventPromptLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
//            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(10)
//        }
//        updateWithSpacing(lineSpacing: 5)
        
        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(self.GoBack))
        self.navigationItem.leftBarButtonItem = backButton
        
        form +++ Section("General Info")
            <<< NameRow(){ row in
                row.title = "Event Name"
                row.placeholder = "Name"
                row.add(rule: RuleRequired())
            }
            
            <<< TextRow(){ row in
                row.title = "Event Street Address"
                row.placeholder = "Street Address"
                row.add(rule: RuleRequired())
            }
            
            <<< TextRow(){ row in
                row.title = "Event City"
                row.placeholder = "City"
                row.add(rule: RuleRequired())
            }
            
            <<< TextRow(){ row in
                row.title = "Event State"
                row.placeholder = "State"
                row.add(rule: RuleRequired())
            }
            
            <<< ZipCodeRow(){ row in
                row.title = "Event Zip Code"
                row.placeholder = "Zip Code"
                row.add(rule: RuleRequired())
            }
        
            <<< DateTimeRow(){
                $0.title = "Event Start Date"
                $0.value = Date(timeIntervalSinceReferenceDate: 0)
                $0.add(rule: RuleRequired())

        }
            <<< DateTimeRow(){
                $0.title = "Event End Date"
                $0.value = Date(timeIntervalSinceReferenceDate: 0)
                $0.add(rule: RuleRequired())
            }
            
            <<< IntRow(){
                $0.title = "Event Cost"
                $0.placeholder = "Price"
                $0.add(rule: RuleRequired())
            }
            
            +++ Section("Event Description")
            <<< TextAreaRow(){
                $0.placeholder = "Enter event description here"
                $0.add(rule: RuleRequired())
            }
            +++ Section("Event Flyer and Promo Video Attachments")
            <<< ImageRow() {
                $0.title = "Event Flyer"
                $0.sourceTypes = [.PhotoLibrary, .SavedPhotosAlbum]
                $0.clearAction = .yes(style: UIAlertActionStyle.destructive)
                $0.allowEditor = true
                $0.useEditedImage = true
                $0.add(rule: RuleRequired())
                }
                .cellUpdate { cell, row in
                    cell.accessoryView?.layer.cornerRadius = 17
                    cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
                    print(row.value as Any)
        }
            
//            +++ Section("ViewRow Demo")
//            <<< ViewRow<UIView>("view") { (row) in
//                row.title = "Enter a description for your event"
//                }
//                .cellSetup { (cell, row) in
//                    //  Construct the view for the cell
//                    cell.view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
//                    cell.view?.backgroundColor = UIColor.orange
//        }
        
    }
    
    @objc func GoBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - Update Line Spacing
    func updateWithSpacing(lineSpacing: Float) {
        // The attributed string to which the
        // paragraph line spacing style will be applied.
        let attributedString = NSMutableAttributedString(string: submitEventPromptLabel.text!)
        let mutableParagraphStyle = NSMutableParagraphStyle()
        // Customize the line spacing for paragraph.
        mutableParagraphStyle.lineSpacing = CGFloat(lineSpacing)
        mutableParagraphStyle.alignment = .justified
        if let stringLength = submitEventPromptLabel.text?.count {
            attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: mutableParagraphStyle, range: NSMakeRange(0, stringLength))
        }
        // textLabel is the UILabel subclass
        // which shows the custom text on the screen
        submitEventPromptLabel.attributedText = attributedString
        
    }
}
