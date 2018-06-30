//
//  ContactUsVC.swift
//  Eventful
//
//  Created by Shawn Miller on 6/29/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import SwiftSMTP


class ContactUsVC: UIViewController {
    
    lazy var contactUsPromptLabel : UILabel = {
        let label = UILabel()
        let customFont = UIFont.systemFont(ofSize: 18)
        label.font = UIFontMetrics.default.scaledFont(for: customFont)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textAlignment = .justified
        label.text = "At Haipe we love to hear from our users, so take the time out to contact us. Tell us what you like about the app. Tell us what you don't like about the app, so we can continously improve how you discover and conect with events."
        return label
    }()
    
    //The text view that will correspond to the quote
    lazy var emailText: UITextView = {
        let emailText = UITextView()
        emailText.autocorrectionType = UITextAutocorrectionType.yes
        emailText.returnKeyType = UIReturnKeyType.done
        emailText.layer.borderColor = UIColor.lightGray.cgColor
        emailText.layer.borderWidth = 1
        emailText.isEditable = true
        emailText.textContainer.maximumNumberOfLines = 0
        return emailText
    }()
    
    lazy var sendButton: UIButton  = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setCellShadow()
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont(name: "ProximaNovaSoft-Regular", size: 14)
        button.addTarget(self, action: #selector(sendEmail), for: .touchUpInside)
        button.backgroundColor = UIColor.rgb(red: 44, green: 152, blue: 229)
        return button
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
        view.addSubview(emailText)
        emailText.snp.makeConstraints { (make) in
            make.top.equalTo(contactUsPromptLabel.snp.bottom).offset(20)
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(15)
            make.height.equalTo(300)
        }
        
        view.addSubview(sendButton)
        sendButton.snp.makeConstraints { (make) in
            make.top.equalTo(emailText.snp.bottom).offset(55)
            make.centerX.equalTo(view.safeAreaLayoutGuide.snp.centerX)
            make.height.equalTo(40)
            make.width.equalTo(90)
        }
        
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
    



}
