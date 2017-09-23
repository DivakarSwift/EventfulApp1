//
//  ImageCollectionViewCell.swift
//  Eventful
//
//  Created by Devanshu Saini on 23/09/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    public var imageView:UIImageView!
    public var bottomBar:UIView!
    
    func setupViews() {
        self.bottomBar = UIView()
        self.bottomBar.backgroundColor = .clear
        self.bottomBar.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.bottomBar)
        NSLayoutConstraint.activateViewConstraints(self.bottomBar, inSuperView: self, withLeading: nil, trailing: nil, top: nil, bottom: 0.0, width: 40.0, height: 1.5)
        _ = NSLayoutConstraint.activateCentreXConstraint(withView: self.bottomBar, superView: self)
        
        self.imageView = UIImageView()
        self.imageView.clipsToBounds = true
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.contentMode = .scaleAspectFit
        self.addSubview(self.imageView)
        NSLayoutConstraint.activateViewConstraints(self.imageView, inSuperView: self, withLeading: nil, trailing: nil, top: 0, bottom: nil, width: 36.0, height: nil)
        _ = NSLayoutConstraint.activateCentreXConstraint(withView: self.imageView, superView: self)
        _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.imageView, secondView: self.bottomBar, andSeparation: 0.0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
}
