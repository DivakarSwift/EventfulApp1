//
//  FeaturedHeader.swift
//  UIPractice
//
//  Created by Shawn Miller on 8/20/18.
//  Copyright © 2018 Haipe. All rights reserved.
//

import UIKit

class FeaturedHeader: UIView {
    let featuredLabel : UILabel =  {
        let featuredLabel = UILabel()
        featuredLabel.text = "featured"
        featuredLabel.text = featuredLabel.text?.uppercased()
        featuredLabel.textAlignment = .center
        featuredLabel.font = UIFont(name:"NoirPro-SemiBold", size: 25)
        featuredLabel.adjustsFontForContentSizeCategory = true
        return featuredLabel
    }()
    
    let eventsLabel : UILabel =  {
        let eventsLabel = UILabel()
        eventsLabel.text = "events"
        eventsLabel.textAlignment = .center
        eventsLabel.text = eventsLabel.text?.uppercased()
        eventsLabel.font = UIFont(name:"NoirPro-Light", size: 25)
        eventsLabel.adjustsFontForContentSizeCategory = true
        return eventsLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func setupViews(){
        addSubview(featuredLabel)
        addSubview(eventsLabel)
        featuredLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(5)
            make.top.equalTo(self.snp.top).offset(7)
        }

        
    }
}
