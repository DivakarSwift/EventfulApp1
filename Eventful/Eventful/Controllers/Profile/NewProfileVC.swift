//
//  NewProfileVC.swift
//  Eventful
//
//  Created by Shawn Miller on 6/14/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit
import SimpleImageViewer

class NewProfileVC: UIViewController,UIScrollViewDelegate {
    let cellID = "cellID"
    let headerID = "headerID"

    lazy var myCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .white
        return cv
    }()
    
    lazy var currentImage : UIImageView = {
        let currentImage = UIImageView()
        currentImage.clipsToBounds = true
        currentImage.translatesAutoresizingMaskIntoConstraints = false
        currentImage.contentMode = .scaleToFill
        currentImage.isUserInteractionEnabled = true
        currentImage.layer.masksToBounds = true
        currentImage.image = UIImage(named: "lbj")
        let singleTap =  UITapGestureRecognizer(target: self, action: #selector(handleImageZoom))
        singleTap.numberOfTapsRequired = 1
        currentImage.addGestureRecognizer(singleTap)
        return currentImage
    }()
    let titleView = UILabel()
    
    

    
    @objc func handleImageZoom(){
        print("double tap recognized")
        let configuration = ImageViewerConfiguration { config in
            config.imageView = currentImage
        }
        let imageViewerController = ImageViewerController(configuration: configuration)
        present(imageViewerController, animated: true)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        myCollectionView.register(NewUserHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerID)
        myCollectionView.register(NewUserEventAttendingCell.self, forCellWithReuseIdentifier: cellID)
        setupVC()
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        
        if parent != nil && self.navigationItem.titleView == nil {
            initNavigationItemTitleView()
        }
    }
    
    private func initNavigationItemTitleView() {
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 500))
        titleView.textAlignment = .center;
        titleView.text = "Lebron James"
        self.navigationItem.titleView = titleView
        self.titleView.font = UIFont(name: "Futura-CondensedMedium", size: 18)
        self.titleView.adjustsFontSizeToFitWidth = true
        
    }
    
    @objc func setupVC(){
    //will be responsible for setting up vc
        self.navigationController?.navigationBar.isTranslucent = false
        view.addSubview(currentImage)
        currentImage.snp.makeConstraints { (make) in
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(view.bounds.height / 3)
        }
        view.addSubview(myCollectionView)
        myCollectionView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(currentImage.snp.bottom)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
    }
    
}

extension NewProfileVC: UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! NewUserEventAttendingCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 1.0, bottom: 1.0, right: 1.0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let kWhateverHeightYouWant = 149
        return CGSize(width: collectionView.bounds.size.width - 60, height: CGFloat(kWhateverHeightYouWant))
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: view.frame.width/6, height: 100)
//    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerID, for: indexPath) as! NewUserHeader
        return header
    }
    
    
}
