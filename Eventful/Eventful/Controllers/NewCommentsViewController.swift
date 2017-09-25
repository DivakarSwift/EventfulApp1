//
//  NewCommentsViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 9/23/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import IGListKit
import Firebase


class NewCommentsViewController: UIViewController, UITextFieldDelegate {
    //array of comments which will be loaded by a service function
    var comments = [CommentGrabbed]()
    var messagesRef: DatabaseReference?
    var bottomConstraint: NSLayoutConstraint?
    public var eventKey = ""
    //This creates a lazily-initialized variable for the IGListAdapter. The initializer requires three parameters:
    //1 updater is an object conforming to IGListUpdatingDelegate, which handles row and section updates. IGListAdapterUpdater is a default implementation that is suitable for your usage.
    //2 viewController is a UIViewController that houses the adapter. This view controller is later used for navigating to other view controllers.
    //3 workingRangeSize is the size of the working range, which allows you to prepare content for sections just outside of the visible frame.
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    
    // 1 IGListKit uses IGListCollectionView, which is a subclass of UICollectionView, which patches some functionality and prevents others.
    let collectionView: UICollectionView = {
        // 2 This starts with a zero-sized rect since the view isn’t created yet. It uses the UICollectionViewFlowLayout just as the ClassicFeedViewController did.
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        // 3 The background color is set to white
        view.backgroundColor = UIColor.white
        return view
    }()
    
    //will fetch the comments from the database and append them to an array
    fileprivate func fetchComments(){
        messagesRef = Database.database().reference().child("Comments").child(eventKey)
        print(eventKey)
        print(comments.count)
        messagesRef?.observe(.childAdded, with: { (snapshot) in
            print(snapshot)
            guard let commentDictionary = snapshot.value as? [String: Any] else{
                return
            }
            print(commentDictionary)
            guard let uid = commentDictionary["uid"] as? String else{
                return
            }
            UserService.show(forUID: uid, completion: { (user) in
                if let user = user {
                    var commentFetched = CommentGrabbed(user: user, dictionary: commentDictionary)
                    commentFetched.commentID = snapshot.key
                    let filteredArr = self.comments.filter { (comment) -> Bool in
                        return comment.commentID == commentFetched.commentID
                    }
                    if filteredArr.count == 0 {
                        self.comments.append(commentFetched)
                    }
                    print(self.comments)
                    self.adapter.performUpdates(animated: true)
                }
                self.comments.sort(by: { (comment1, comment2) -> Bool in
                    return comment1.creationDate.compare(comment2.creationDate) == .orderedAscending
                })
                self.comments.forEach({ (comments) in
                })
            })
        }, withCancel: { (error) in
            print("Failed to observe comments")
        })
        
        //first lets fetch comments for current event
    }
    
    lazy var submitButton : UIButton = {
        let submitButton = UIButton(type: .system)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(.black, for: .normal)
        submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        submitButton.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        submitButton.isEnabled = false
        return submitButton
    }()
    
    //allows you to gain access to the input accessory view that each view controller has for inputting text
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.addSubview(self.submitButton)
        self.submitButton.anchor(top: containerView.topAnchor, left: nil, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 0)
        
        containerView.addSubview(self.commentTextField)
        self.commentTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: self.submitButton.leftAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 180, width: 0, height: 0)
        self.commentTextField.delegate = self
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        containerView.addSubview(lineSeparatorView)
        lineSeparatorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        return containerView
    }()
    
    lazy var commentTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Add a comment"
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return textField
    }()
    
    func textFieldDidChange(_ textField: UITextField) {
        let isCommentValid = commentTextField.text?.characters.count ?? 0 > 0
        if isCommentValid {
            submitButton.isEnabled = true
        }else{
            submitButton.isEnabled = false
        }
    }
    
    func handleSubmit(){
        guard let comment = commentTextField.text, comment.characters.count > 0 else{
            return
        }
        let userText = Comments(content: comment, uid: User.current.uid, profilePic: User.current.profilePic!)
        sendMessage(userText)
        // will remove text after entered
        self.commentTextField.text = nil
    }
    
    func flagButtonTapped (from cell: CommentCell){
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        // 2
        let comment = comments[indexPath.item]
        _ = comment.uid
        
        // 3
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // 4
        if comment.uid != User.current.uid {
            let flagAction = UIAlertAction(title: "Report as Inappropriate", style: .default) { _ in
                ChatService.flag(comment)
                
                let okAlert = UIAlertController(title: nil, message: "The post has been flagged.", preferredStyle: .alert)
                okAlert.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(okAlert, animated: true)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            alertController.addAction(flagAction)
        }else{
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete Comment", style: .default, handler: { _ in
                ChatService.deleteComment(comment, self.eventKey)
                let okAlert = UIAlertController(title: nil, message: "Comment Has Been Deleted", preferredStyle: .alert)
                okAlert.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(okAlert, animated: true)
                self.adapter.performUpdates(animated: true)
                
            })
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            
        }
        present(alertController, animated: true, completion: nil)
        
    }
    
    func handleKeyboardNotification(notification: NSNotification){
        if let userinfo = notification.userInfo{
            
            let keyboardFrame = (userinfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            self.bottomConstraint?.constant = -(keyboardFrame.height)
            
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            self.bottomConstraint?.constant = isKeyboardShowing ? -(keyboardFrame.height) : 0
            
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (completion) in
                if self.comments.count > 0  && isKeyboardShowing {
                    let indexPath = IndexPath(item: self.comments.count-1, section: 0)
                    self.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        collectionView.addSubview(containerView)
        collectionView.alwaysBounceVertical = true
        view.addConstraintsWithFormatt("H:|[v0]|", views: containerView)
        view.addConstraintsWithFormatt("V:[v0(48)]", views: containerView)
        bottomConstraint = NSLayoutConstraint(item: containerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
        adapter.collectionView = collectionView
        adapter.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: "CommentCell")
        fetchComments()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        submitButton.isUserInteractionEnabled = true
        
    }
    //viewDidLayoutSubviews() is overridden, setting the collectionView frame to match the view bounds.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension NewCommentsViewController: ListAdapterDataSource {
    // 1 objects(for:) returns an array of data objects that should show up in the collection view. loader.entries is provided here as it contains the journal entries.
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        print("comments = \(comments)")
        return comments
    }
    
    // 2 For each data object, listAdapter(_:sectionControllerFor:) must return a new instance of a section controller. For now you’re returning a plain IGListSectionController to appease the compiler — in a moment, you’ll modify this to return a custom journal section controller.
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        //the comment section controller will be placed here but we don't have it yet so this will be a placeholder
        return CommentsSectionController()
    }
    
    // 3 emptyView(for:) returns a view that should be displayed when the list is empty. NASA is in a bit of a time crunch, so they didn’t budget for this feature.
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }
}

extension NewCommentsViewController {
    func sendMessage(_ message: Comments) {
        ChatService.sendMessage(message, eventKey: eventKey)
        
    }
}



