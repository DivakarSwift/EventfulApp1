//
//  EVFooter.swift
//  Eventful
//
//  Created by Shawn Miller on 9/22/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import SnapKit

class EVFooter: UICollectionViewCell,UICollectionViewDelegateFlowLayout {
    let actionID = "actionID"
    weak var homeRef: NewEventDetailViewController?
    var event: Event?{
        didSet{
            print("got event")
        }
    }
    
    let actions: [String] = ["Attend Event","Share Event","View Comments","Add to Story","View Story"]
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    lazy var interact: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    fileprivate func setupViews(){
      addSubview(interact)
        interact.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
         interact.register(InteractCell.self, forCellWithReuseIdentifier: actionID)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EVFooter: UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return actions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: actionID, for: indexPath) as! InteractCell
        cell.actionLabel.text = actions[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 40, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
        guard let home = homeRef else {
            return
        }
        guard let eventKey = event?.key else {
            return
        }
        if indexPath.item == 0{
            print("attending event")
        }else if indexPath.item == 1 {
            print("sharing event")
            let share = ShareViewController()
 
            share.eventKey = eventKey
            home.navigationController?.pushViewController(share, animated: true)
        }else if indexPath.item == 2 {
            print("showing comment")
            let newCommentsController = NewCommentsViewController()
            newCommentsController.eventKey = eventKey
            newCommentsController.comments.removeAll()
            newCommentsController.adapter.reloadData { (updated) in
            }
            home.navigationController?.pushViewController(newCommentsController, animated: true)
            
        }else if indexPath.item == 3 {
            print("displaying camera")
            let transition = CATransition()
            transition.duration = 0.4
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromBottom
            home.view.window!.layer.add(transition, forKey: kCATransition)
            let camera = TempCameraViewController()
            camera.event = event
            home.present(camera, animated: false, completion: nil)
            
        }else if indexPath.item == 4{
            print("viewing story")
            let vc = StoriesViewController()
            vc.eventDetailRef = home
            vc.eventKey = eventKey
            home.present(vc, animated: false, completion: nil)
        }
    }
    
    
}

extension EVFooter: UICollectionViewDelegate{
    
}

