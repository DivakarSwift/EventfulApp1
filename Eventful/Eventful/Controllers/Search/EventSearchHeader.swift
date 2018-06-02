//
//  EventSearchHeader.swift
//  Eventful
//
//  Created by Shawn Miller on 8/23/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit

class SearchHeader: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        addSubview(searchBar)
        searchBar.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    

    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search"
        sb.searchBarStyle = .minimal
        sb.showsScopeBar = true
        sb.sizeToFit()
        sb.setScopeBarButtonTitleTextAttributes([ NSAttributedStringKey.foregroundColor.rawValue : UIColor.black], for: .normal)
        let textFieldInsideUISearchBar = sb.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.font = UIFont.systemFont(ofSize: 14)
        sb.layer.borderColor = UIColor.lightGray.cgColor
        sb.layer.borderWidth = 0.3
        sb.layer.cornerRadius = 5
        sb.layer.masksToBounds = true
        sb.barTintColor = UIColor.white
        sb.tintColor = UIColor.rgb(red: 24, green: 136, blue: 211)
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        //  sb.delegate = self
        return sb
    }()
    
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width:  1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

