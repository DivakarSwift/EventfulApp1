//
//  NewSearchVC.swift
//  Eventful
//
//  Created by Shawn Miller on 6/25/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import Foundation
import ScrollableSegmentedControl

class NewSearchVC: UIViewController, UITextFieldDelegate {
    
    lazy var segmentedControl: ScrollableSegmentedControl = {
        let segmentedControl = ScrollableSegmentedControl()
        segmentedControl.segmentStyle = .textOnly
        segmentedControl.setupShadow2()
        segmentedControl.tintColor = UIColor.rgb(red: 45, green: 162, blue: 232)
        segmentedControl.underlineSelected = true
        segmentedControl.backgroundColor = UIColor.white
        segmentedControl.addTarget(self, action: #selector(NewSearchVC.segmentSelected(sender:)), for: .valueChanged)
        return segmentedControl
    }()
    
    lazy var searchTextField: LeftPaddedTextField = {
       let searchTextField = LeftPaddedTextField()
        searchTextField.backgroundColor = UIColor.white
        searchTextField.placeholder = "Search"
        searchTextField.layer.borderWidth = 0.2
        searchTextField.returnKeyType = .search
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.delegate = self
        return searchTextField
    }()
    
    lazy var searchPromptLabel : UILabel = {
        let label = UILabel()
        label.font =  UIFont(name:"HelveticaNeue-Medium", size: 34)
        label.numberOfLines = 0
        label.text = "Hi \(String(describing: User.current.username!))!\nSearch For Users\nand Events Near You"
        return label
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupVC()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func setupVC(){
//        view.backgroundColor = UIColor.white
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "homePageBG")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
        view.addSubview(searchTextField)
        searchTextField.setupShadow2()
        searchTextField.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.left.right.equalTo(view).inset(11)
            make.height.equalTo(40)
        }
        view.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { (make) in
            make.top.equalTo(searchTextField.snp.bottom).offset(10)
            make.left.right.equalTo(view).inset(11)
            make.height.equalTo(40)
        }
        setupSegment()
        
        view.addSubview(searchPromptLabel)
        searchPromptLabel.snp.makeConstraints { (make) in
            make.top.equalTo(segmentedControl.snp.bottom).offset(10)
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left).inset(11)
        }

    }
    
    @objc func setupSegment(){
        self.segmentedControl.insertSegment(withTitle: "Events", at: 0)
        self.segmentedControl.insertSegment(withTitle: "Users", at: 1)
//        self.segmentedControl.insertSegment(withTitle: "Venues", at: 2)
//        self.segmentedControl.insertSegment(withTitle: "DJs/Promoters", at: 3)

    }
    
    @objc func segmentSelected(sender:ScrollableSegmentedControl) {
        print("Segment at index \(sender.selectedSegmentIndex)  selected")
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
        searchTextField.text = ""
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if searchTextField.text?.count != 0 {
            //do search
            print(searchTextField.text as Any)
        }
        //else do nothing
        return true
    }

}

