//
//  FriendService.swift
//  Eventful
//
//  Created by Shawn Miller on 5/26/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import Firebase

class FriendService{
    static let system = FriendService()

    // MARK: - Firebase references
    /** The base Firebase reference */
    let BASE_REF = Database.database().reference()
    /* The user Firebase reference */
    let USER_REF = Database.database().reference().child("users")
    /** The Firebase reference to the current user tree */
    var CURRENT_USER_REF: DatabaseReference {
        let id = Auth.auth().currentUser!.uid
        return USER_REF.child("\(id)")
    }
    /** The Firebase reference to the current user's friend request tree */
    var BASE_REQUESTS_REF: DatabaseReference {
        return BASE_REF.child("requests").child(CURRENT_USER_ID)
    }
    /** The Firebase reference to the request tree */
    var BASE_REQUESTS_REF2: DatabaseReference {
        return BASE_REF.child("requests")
    }
    /** The current user's id */
    var CURRENT_USER_ID: String {
        let id = Auth.auth().currentUser!.uid
        return id
    }
    /** The Firebase reference to the current user's friend tree */
    var CURRENT_USER_FRIENDS_REF: DatabaseReference {
        return BASE_REF.child("followers").child(CURRENT_USER_ID)
    }

     /** Sends a friend request to the user with the specified id */
    func sendRequestToUser(_ userID: String){
        BASE_REQUESTS_REF2.child(userID).child(CURRENT_USER_ID).setValue(true)
    }
    
    func removeFriendRequest(_ userID: String){
        if userID != CURRENT_USER_ID {
            BASE_REQUESTS_REF.child(userID).removeValue()
        }else{
            BASE_REQUESTS_REF2.child(userID).child(CURRENT_USER_ID).removeValue()
        }
    }
    
    
    func checkForRequest(_ userID: String, success: @escaping (Bool) -> Void){
        BASE_REQUESTS_REF2.child(userID).queryEqual(toValue: nil, childKey: CURRENT_USER_ID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? [String : Bool] {
                success(true)
            } else {
                success(false)
            }
        })
    }
    
    // MARK: - All friends
    /** The list of all friends of the current user. */
    var friendList = [User]()
    /** Adds a friend observer. The completion function will run every time this list changes, allowing you
     to update your UI. */
    func addFriendObserver(_ update: @escaping () -> Void) {
        CURRENT_USER_FRIENDS_REF.observe(.value, with: { (snapshot) in
            self.friendList.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let id = child.key
                UserService.show(forUID: id, completion: { (user) in
                    self.friendList.append(user!)
                    update()
                })
            }
            // If there are no children, run completion here instead
            if snapshot.childrenCount == 0 {
                update()
            }
        })
    }
    /** Removes the friend observer. This should be done when leaving the view that uses the observer. */
    func removeFriendObserver() {
        CURRENT_USER_FRIENDS_REF.removeAllObservers()
    }
    
    //will observe the request tree for users
    // MARK: - All requests
    /** The list of all friend requests the current user has. */
    var requestList = [User]()
    /** Adds a friend request observer. The completion function will run every time this list changes, allowing you
     to update your UI. */
    func addRequestObserver(_ update: @escaping () -> Void) {
        BASE_REQUESTS_REF.observe(DataEventType.value, with: { (snapshot) in
            self.requestList.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let id = child.key
                
                UserService.show(forUID: id, completion: { (user) in
                    self.requestList.append(user!)
                    update()
                })

            }
            // If there are no children, run completion here instead
            if snapshot.childrenCount == 0 {
                update()
            }
        })
    }
    /** Removes the friend request observer. This should be done when leaving the view that uses the observer. */
    func removeRequestObserver() {
        BASE_REQUESTS_REF.removeAllObservers()
    }
    
}
