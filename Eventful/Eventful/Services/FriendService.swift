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

     /** Sends a friend request to the user with the specified id */
    func sendRequestToUser(_ userID: String){
        BASE_REQUESTS_REF2.child(userID).child(CURRENT_USER_ID).setValue(true)
    }
    /** Accepts a friend request from the user with the specified id */
    func acceptFriendRequest(_ userID: String) {
        //remove the friend request from the current users list
        BASE_REQUESTS_REF.child(userID).removeValue()
        
        //make the current user follow the other user
        CURRENT_USER_REF.child("friends").child(userID).setValue(true)
        
        //make the other user friends with you as well
        USER_REF.child(userID).child("friends").child(CURRENT_USER_ID).setValue(true)
        //remove the request from the other users list
        USER_REF.child(userID).child("requests").child(CURRENT_USER_ID).removeValue()
    }
    
}
