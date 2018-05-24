//
//  PreviewPhotoContainerView.swift
//  Eventful
//
//  Created by Shawn Miller on 3/30/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import Photos

class PreviewPhotoContainerView: UIView {
    var eventKey = ""

    let previewImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "Close"), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    let saveToAlbum: UIButton = {
        let saveToAlbum = UIButton(type: .system)
        saveToAlbum.setImage(UIImage(named: "save_shadow"), for: .normal)
        saveToAlbum.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return saveToAlbum
    }()
    
    
    @objc func handleCancel(){
        self.removeFromSuperview()
    }
    
    let shareButton: UIButton = {
        let shareButton = UIButton(type: .system)
        shareButton.setImage(#imageLiteral(resourceName: "icons8-circled-right-48").withRenderingMode(.alwaysOriginal), for: .normal)
        shareButton.addTarget(self, action: #selector(handleAdd), for: .touchUpInside)
        return shareButton
    }()
    
    @objc func handleAdd(){
        print("Attempting to add to story")
        print(self.eventKey)
        guard let currentImage = previewImageView.image else {
            return
        }
        let dateFormatter = ISO8601DateFormatter()
        let timeStamp = dateFormatter.string(from: Date())
        let uid = User.current.uid
        let storageRef = Storage.storage().reference().child("event_stories").child(self.eventKey).child(uid).child(timeStamp + ".PNG")
        StorageService.uploadImage(currentImage, at: storageRef) { (downloadUrl) in
            guard let downloadUrl = downloadUrl else {
                return
            }
            let videoUrlString = downloadUrl.absoluteString
            print(videoUrlString)
            PostService.create(for: self.eventKey, for: videoUrlString)
            
            DispatchQueue.main.async {
                let savedLabel = UILabel()
                savedLabel.text = "Added Successfully"
                savedLabel.font = UIFont.boldSystemFont(ofSize: 18)
                savedLabel.textColor = .white
                savedLabel.numberOfLines = 0
                savedLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
                savedLabel.textAlignment = .center
                
                savedLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
                savedLabel.center = self.center
                
                self.addSubview(savedLabel)
                
                savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    
                    savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
                    
                }, completion: { (completed) in
                    //completed
                    
                    UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                        
                        savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                        savedLabel.alpha = 0
                        
                    }, completion: { (_) in
                        
                        savedLabel.removeFromSuperview()
                        self.removeFromSuperview()
                    })
                    
                })
            }
        }
        
    }
    
    @objc func handleSave(){
        print("Attempting to save photo")
        guard let previewImage = previewImageView.image else {
            return
        }
        let library = PHPhotoLibrary.shared()
        library.performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
        }) { (success, err) in
            if let err = err{
                print("Failed to save image to photo library:",err)
                return
            }
            print("Successfully saved image to library")
            
            DispatchQueue.main.async {
                let savedLabel = UILabel()
                savedLabel.text = "Saved Successfully"
                savedLabel.font = UIFont.boldSystemFont(ofSize: 18)
                savedLabel.textColor = .white
                savedLabel.numberOfLines = 0
                savedLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
                savedLabel.textAlignment = .center
                
                savedLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
                savedLabel.center = self.center
                
                self.addSubview(savedLabel)
                
                savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    
                    savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
                    
                }, completion: { (completed) in
                    //completed
                    
                    UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                        
                        savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                        savedLabel.alpha = 0
                        
                    }, completion: { (_) in
                        
                        savedLabel.removeFromSuperview()
                        //self.removeFromSuperview()
                    })
                    
                })
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupViews()
    }
    
    @objc func setupViews(){
        addSubview(previewImageView)
        previewImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).inset(10)
            make.left.equalTo(self.safeAreaLayoutGuide.snp.left).inset(15)
            make.height.width.equalTo(40)
        }
        addSubview(shareButton)
        shareButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).inset(10)
            make.right.equalTo(self.safeAreaLayoutGuide.snp.right).inset(10)
            make.height.width.equalTo(35)
        }
        
        addSubview(saveToAlbum)
        saveToAlbum.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).inset(10)
            make.left.equalTo(self.safeAreaLayoutGuide.snp.left).inset(10)
            make.height.width.equalTo(40)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
