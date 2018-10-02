//
//  ImagePagingCell.swift
//  Eventful
//
//  Created by Shawn Miller on 8/29/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit
import Parchment

class ImagePagingCell: PagingCell {
    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor.rgb(red: 207, green: 207, blue: 207)
        label.backgroundColor = UIColor(white: 0, alpha: 0.6)
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate lazy var paragraphStyle: NSParagraphStyle = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.hyphenationFactor = 1
        paragraphStyle.alignment = .center
        return paragraphStyle
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 6
        contentView.clipsToBounds = true
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.constrainToEdges(imageView)
        contentView.constrainToEdges(titleLabel)
    }
    
    
    override func setPagingItem(_ pagingItem: PagingItem, selected: Bool, options: PagingOptions) {
        let item = pagingItem as! ImageItem
        imageView.image = item.headerImage
        titleLabel.attributedText = NSAttributedString(
            string: item.title,
            attributes: [NSAttributedStringKey.paragraphStyle: paragraphStyle])
        
        if selected {
            imageView.transform = CGAffineTransform(scaleX: 2, y: 2)
        } else {
            imageView.transform = CGAffineTransform.identity
        }
    }
    
    
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        if let attributes = layoutAttributes as? PagingCellLayoutAttributes {
            let scale = 1 + attributes.progress
            imageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
