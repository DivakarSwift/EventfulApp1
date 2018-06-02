//
//  CommentsSectionController.swift
//  Eventful
//
//  Created by Shawn Miller on 9/23/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import IGListKit
import Foundation
import Firebase

protocol CommentsSectionDelegate: class {
    func CommentSectionUpdared(sectionController: CommentsSectionController, comment: CommentGrabbed)
}
class CommentsSectionController: ListSectionController,CommentCellDelegate {
    weak var delegate: CommentsSectionDelegate? = nil
    weak var comment: CommentGrabbed?
    var currentViewController: NewCommentsViewController!
    var eventKey: String?
    override init() {
        super.init()
        // supplementaryViewSource = self
        //sets the spacing between items in a specfic section controller
        inset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
    }
    // MARK: IGListSectionController Overrides
    override func numberOfItems() -> Int {
        return 1
    }
    override func sizeForItem(at index: Int) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: collectionContext!.containerSize.width, height: 50)
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comment
        dummyCell.layoutIfNeeded()
        let targetSize =  CGSize(width: collectionContext!.containerSize.width, height: 55)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        let height = max(40+8+8, (estimatedSize.height))
        return  CGSize(width: collectionContext!.containerSize.width, height: height)
        
    }
    
    override var minimumLineSpacing: CGFloat {
        get {
            return 0.0
        }
        set {
            self.minimumLineSpacing = 0.0
        }
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: CommentCell.self, for: self, at: index) as? CommentCell else {
            fatalError()
        }
        //  print(comment)
        cell.comment = comment
        cell.delegate = self
        return cell
    }
    override func didUpdate(to object: Any) {
        comment = object as? CommentGrabbed
    }
    override func didSelectItem(at index: Int){
    }
    
    func optionsButtonTapped(cell: CommentCell){
        print("like")
   
        let comment = self.comment
        _ = comment?.sender.uid
        
        // 3
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // 4
        if comment?.sender.uid != User.current.uid {
            let flagAction = UIAlertAction(title: "Report as Inappropriate", style: .default) {[weak self] _ in
                ChatService.flag(comment!)
                
                let okAlert = UIAlertController(title: nil, message: "The post has been flagged.", preferredStyle: .alert)
                okAlert.addAction(UIAlertAction(title: "Ok", style: .default))
                self?.viewController?.present(okAlert, animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let replyAction = UIAlertAction(title: "Reply to Comment", style: .default, handler: { [weak self](_) in
                //do something here later to facilitate reply comment functionality
                // print("Attempting to reply to user \(comment?.sender.userna ?? <#default value#>me) comment")
                //begin comment reply functionality
                self?.handleReply()
            })
            alertController.addAction(replyAction)
            alertController.addAction(cancelAction)
            alertController.addAction(flagAction)
        }else{
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete Comment", style: .default, handler: {[weak self] _ in
                ChatService.deleteComment(comment!, (comment?.eventKey)!)
                let okAlert = UIAlertController(title: nil, message: "Comment Has Been Deleted", preferredStyle: .alert)
                okAlert.addAction(UIAlertAction(title: "Ok", style: .default))
                self?.viewController?.present(okAlert, animated: true, completion: nil)
                self?.onItemDeleted()

            })
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            
        }
        self.viewController?.present(alertController, animated: true, completion: nil)
        
    }
    func onItemDeleted() {
        print(comment?.content as Any)
        delegate?.CommentSectionUpdared(sectionController: self, comment: comment!)
    }
    func handleProfileTransition(tapGesture: UITapGestureRecognizer){
        let userProfileController = ProfileeViewController(collectionViewLayout: UICollectionViewFlowLayout())

        userProfileController.user = comment?.sender
        userProfileController.navigationItem.title = comment?.sender.username
        userProfileController.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(GoBack))
        userProfileController.navigationItem.leftBarButtonItem = backButton
        let navController = UINavigationController(rootViewController: userProfileController)
        if Auth.auth().currentUser?.uid != comment?.sender.uid{
                    self.viewController?.present(navController, animated: true, completion: nil)
        }else{
            //do nothing
            
        }
    }
    
    private func handleReply(){
       //will eliminate the placeholderText in the textView
        self.currentViewController.containerView.commentTextView.hidePlaceholderLabel()
        //will add the user's username and @symbol into the textView to get ready for reply
        self.currentViewController.containerView.commentTextView.text = "@" + (comment?.sender.username)! + " "
        //assures that the textView becomes the first respnder so the keyboard pops up and props you to tyoe
        self.currentViewController.containerView.commentTextView.becomeFirstResponder()
        //sets the isReplyingVariable to know if I am replying to someones comment or not
        self.currentViewController.isReplying = true
        UserService.show(forUID: (comment?.sender.uid)!) { (reciever) in
            self.currentViewController.notificationData = Notifications.init(eventKey: (self.comment?.eventKey)!, reciever: reciever!, content: User.current.username! + " has replied to your comment", type: notiType.comment, commentId: (self.comment?.commentID)!)
        }
    }
    
    @objc func GoBack(){
        self.viewController?.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("CommentSectionController class removed from memory")
    }
    
    
}
