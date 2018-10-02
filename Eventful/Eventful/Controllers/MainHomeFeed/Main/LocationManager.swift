//
//  LocationManager.swift
//  Eventful
//
//  Created by Shawn Miller on 8/29/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit

class LocationManager: UIBarButtonItem {
    var viewController: MainViewController?
    
    lazy var labelImage : UIImageView = {
       let labelImage = UIImageView()
        labelImage.image = UIImage(named: "DOWNaRROW")
        return labelImage
    }()
    
    lazy var cityText: UILabel = {
        let cityText = UILabel()
        guard let customFont = UIFont(name: "NoirPro-SemiBold", size: 20) else {
            fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        cityText.font = customFont
        cityText.textColor = UIColor.black
        return cityText
    }()
    
    
    
    
    
    override init() {
        super.init()
        setupViews()
    }
    
    @objc func setupViews(){
        let tempView = UIView()
        tempView.addSubview(cityText)
        tempView.addSubview(labelImage)
        cityText.snp.makeConstraints { (make) in
            make.left.equalTo(tempView.snp.left)
            make.top.bottom.equalTo(tempView)
        }
        
        labelImage.snp.makeConstraints { (make) in
            make.left.equalTo(cityText.snp.right)
            make.right.equalTo(tempView.snp.right)
            make.top.bottom.equalTo(tempView)
        }
        customView = tempView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
