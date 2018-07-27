//
//  Stories.swift
//  Eventful
//
//  Created by Shawn Miller on 8/21/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import  AVFoundation

class StoriesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    let cellID = "cellID"
    var eventKey = ""
    var allStories = [Story]()
    let player: AVPlayer? = nil
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        cv.isPagingEnabled = true
        return cv
    }()
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allStories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! StoryDisplayCell
        let desiredURL = allStories[indexPath.row].Url
        cell.startPlayingVideo(urlEntered: desiredURL)
        cell.cellStry = allStories[indexPath.row]
        cell.backgroundColor = UIColor.white
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        downSwipe.direction = .down
        view.addGestureRecognizer(downSwipe)
        view.addSubview(collectionView)
        collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        //Do any additional setup after loading the view
        collectionView.register(StoryDisplayCell.self, forCellWithReuseIdentifier: cellID)
        //        fetchStories()
        
    }
    
    
    @objc func swipeAction(_ swipe: UIGestureRecognizer){
        if let swipeGesture = swipe as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
                break
            case UISwipeGestureRecognizerDirection.down:
                dismiss(animated: true, completion: nil)
                break
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
                break
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
                break
            default:
                break
            }
        }
    }
    fileprivate func fetchStories(){
        
        StoryService.showEvent(for: self.eventKey) { (story) in
            self.allStories = story
            print(self.allStories)
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.allStories.removeAll()
        self.collectionView.reloadData()
        
        
        self.fetchStories();
    }
    
}

