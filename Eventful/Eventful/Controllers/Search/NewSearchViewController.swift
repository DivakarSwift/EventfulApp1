//
//  NewSearchViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 6/2/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import DTPagerController

class NewSearchViewController: DTPagerController, UISearchBarDelegate {
    let dividerView = UIView()

    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search"
        sb.searchBarStyle = .minimal
        sb.sizeToFit()
        sb.setScopeBarButtonTitleTextAttributes([ NSAttributedStringKey.foregroundColor.rawValue : UIColor.black], for: .normal)
        let textFieldInsideUISearchBar = sb.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.font = UIFont.systemFont(ofSize: 14)
        sb.layer.borderColor = UIColor.lightGray.cgColor
        sb.layer.borderWidth = 0.3
        sb.layer.cornerRadius = 5
        sb.layer.masksToBounds = true
        sb.showsCancelButton = true
        sb.barTintColor = UIColor.white
        sb.tintColor = UIColor.rgb(red: 24, green: 136, blue: 211)
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        sb.delegate = self
        return sb
    }()
    
    init() {
        super.init(viewControllers: [])
        title = "View Controller"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //addVC()
        setupVC()
    }
    @objc func addVC(){
        let viewController1 = EventSearchCollectionView(collectionViewLayout:  UICollectionViewFlowLayout())
        let viewController2 = UserSearchCollectionView(collectionViewLayout:  UICollectionViewFlowLayout())
                viewController1.title = "Events"
                viewController2.title = "Users"
                selectedFont =  UIFont(name: "Avenir-Medium", size: 14)!
                selectedTextColor = UIColor.black
                preferredSegmentedControlHeight = 40
                perferredScrollIndicatorHeight = 1.8
                scrollIndicator.backgroundColor = UIColor.black
                viewControllers = [viewController1, viewController2]
    }

    @objc func setupVC(){
        view.addSubview(searchBar)
        view.addSubview(dividerView)
        searchBar.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalTo(view)
        }
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.lightGray], for: .normal)

        dividerView.backgroundColor = .lightGray
        dividerView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.height.equalTo(0.5)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
