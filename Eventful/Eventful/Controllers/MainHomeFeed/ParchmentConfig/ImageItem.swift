//
//  ImageItem.swift
//  Eventful
//
//  Created by Shawn Miller on 8/29/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import Parchment

struct ImageItem: PagingItem, Hashable, Comparable {
    let index: Int
    let title: String
    let headerImage: UIImage
    
    var hashValue: Int {
        return index.hashValue &+ title.hashValue
    }
    
    static func ==(lhs: ImageItem, rhs: ImageItem) -> Bool {
        return lhs.index == rhs.index && lhs.title == rhs.title
    }
    
    static func <(lhs: ImageItem, rhs: ImageItem) -> Bool {
        return lhs.index < rhs.index
    }
}
