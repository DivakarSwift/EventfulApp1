//
//  ContactUsVC.swift
//  Eventful
//
//  Created by Shawn Miller on 6/29/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit


class ContactUsVC: UIViewController {
    
    lazy var contactUsPromptLabel : UILabel = {
        let label = UILabel()
        let customFont = UIFont.systemFont(ofSize: 18)
        label.font = UIFontMetrics.default.scaledFont(for: customFont)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textAlignment = .justified
        label.text = "At Haipe we love to hear from our users, so take the time out to contact us. Tell us what you like about the app. Tell us what you don't like about the app, so we can continously improve how you discover and conect with events.To report anything to us at all just shake your phone and select from the menu of options\n\n -Thanks Haipe "
        return label
    }()
    
    
    
  
    
    @objc func sendEmail(){
        print("attempting to send email")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        // Do any additional setup after loading the view.
    }
    @objc func setupViews(){
        navigationItem.title = "Contant Us"
        view.addSubview(contactUsPromptLabel)
        contactUsPromptLabel.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
        updateWithSpacing(lineSpacing: 5)
        
         let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(self.GoBack))
        self.navigationItem.leftBarButtonItem = backButton

    }
    
    @objc func GoBack(){
        self.navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: - Update Line Spacing
    func updateWithSpacing(lineSpacing: Float) {
        // The attributed string to which the
        // paragraph line spacing style will be applied.
        let attributedString = NSMutableAttributedString(string: contactUsPromptLabel.text!)
        let mutableParagraphStyle = NSMutableParagraphStyle()
        // Customize the line spacing for paragraph.
        mutableParagraphStyle.lineSpacing = CGFloat(lineSpacing)
        mutableParagraphStyle.alignment = .justified
        if let stringLength = contactUsPromptLabel.text?.count {
            attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: mutableParagraphStyle, range: NSMakeRange(0, stringLength))
        }
        // textLabel is the UILabel subclass
        // which shows the custom text on the screen
        contactUsPromptLabel.attributedText = attributedString
        
    }

}
