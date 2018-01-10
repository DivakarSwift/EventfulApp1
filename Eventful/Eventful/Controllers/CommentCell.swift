//
//  CommentCell.swift
//  Eventful
//
//  Created by Shawn Miller on 8/10/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit

protocol CommentCellDelegate: class {
    func optionsButtonTapped(cell: CommentCell)
}
class CommentCell: UICollectionViewCell {
    weak var delegate: CommentCellDelegate? = nil
    
    override var reuseIdentifier : String {
        get {
            return "cellID"
        }
        set {
            // nothing, because only red is allowed
        }
    }
    var didTapOptionsButtonForCell: ((CommentCell) -> Void)?
    
    var comment: CommentGrabbed?{
        didSet{
            guard let comment = comment else{
                return
            }
            
            // textLabel.text = comment.content
            //shawn was also here
            profileImageView.loadImage(urlString: comment.user.profilePic!)
            //  print(comment.user.username)
            let attributedText = NSMutableAttributedString(string: comment.user.username!, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
            
            attributedText.append(NSAttributedString(string: " " + (comment.content), attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
            textView.attributedText = attributedText
            
            
        }
    }
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.isScrollEnabled = false
        textView.isEditable = false
        return textView
    }()
    
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    lazy var flagButton: UIButton = {
        let flagButton = UIButton(type: .system)
        flagButton.setImage(#imageLiteral(resourceName: "icons8-Info-64"), for: .normal)
        flagButton.addTarget(self, action: #selector(optionsButtonTapped), for: .touchUpInside)
        return flagButton
    }()
    
    @objc func optionsButtonTapped (){
        didTapOptionsButtonForCell?(self)
    }
    
    @objc func onOptionsTapped() {
        delegate?.optionsButtonTapped(cell: self)
    }
    
    
    
    override init(frame: CGRect){
        super.init(frame: frame)
        addSubview(textView)
        addSubview(profileImageView)
        addSubview(flagButton)
        textView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width: 0, height: 0)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40/2
        flagButton.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 4, width: 40, height: 40)
        flagButton.addTarget(self, action: #selector(CommentCell.onOptionsTapped), for: .touchUpInside)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}
