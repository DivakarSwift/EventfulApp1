//
//  CustomPagingViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 8/29/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit
import Parchment

class CustomPagingViewController: PagingViewController<ImageItem> {
    
    override func loadView() {
        view = CustomPagingView(
            options: options,
            collectionView: collectionView,
            pageView: pageViewController.view
        )
    }
    
}
