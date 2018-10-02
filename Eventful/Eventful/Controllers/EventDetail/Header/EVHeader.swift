//
//  EVHeader.swift
//  Eventful
//
//  Created by Shawn Miller on 9/22/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import SnapKit
import SimpleImageViewer

class EVHeader: UICollectionViewCell {
    weak var homeRef: NewEventDetailViewController?
    var eventPromo: String? {
        didSet{
        }
    }
    var imageURL: URL?{
        didSet{
            DispatchQueue.main.async {
                self.currentEventImage.af_setImage(withURL: self.imageURL!, placeholderImage: nil, filter: nil, progress: nil, progressQueue: .main, imageTransition: .crossDissolve(0.5), runImageTransitionIfCached: false, completion: { (response) in
                    _ = response.result.value // UIImage Object
                })
            }
        }
    }

    lazy var currentEventImage : UIImageView = {
        let currentEvent = UIImageView()
        currentEvent.setupShadow2()
        currentEvent.contentMode = .scaleToFill
//        currentEvent.layer.masksToBounds = true
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handlePromoVid))
        singleTap.numberOfTapsRequired = 1

        currentEvent.isUserInteractionEnabled = true
        currentEvent.addGestureRecognizer(singleTap)
        let doubleTap =  UITapGestureRecognizer(target: self, action: #selector(handleImageZoom))
        doubleTap.numberOfTapsRequired = 2
        currentEvent.addGestureRecognizer(doubleTap)
        singleTap.require(toFail: doubleTap)
        return currentEvent
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    fileprivate func setupViews(){
        addSubview(currentEventImage)
        currentEventImage.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(10)
        }
    }
    
    
    @objc func handleImageZoom(){
        print("double tap recognized")
        let configuration = ImageViewerConfiguration { config in
            config.imageView = currentEventImage
        }
        let imageViewerController = ImageViewerController(configuration: configuration)
        guard let home = homeRef else {
            return
        }
        home.present(imageViewerController, animated: true)
    }
    
    @objc func handlePromoVid(){
        guard let promo = eventPromo else {
            return
        }
        let url = URL(string: promo)
        let videoLauncher = extractedFunc(url)
        guard let home = homeRef else {
            return
        }
        home.present(videoLauncher, animated: true, completion: nil)
    }
    
    fileprivate func extractedFunc(_ url: URL?) -> EventPromoVideoPlayer {
        return EventPromoVideoPlayer(videoURL: url!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
