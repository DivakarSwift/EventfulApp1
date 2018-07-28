//
//  Notification.swift
//  Eventful
//
//  Created by Shawn Miller on 2/24/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot
import  IGListKit


class Notifications: NSObject {
    
    var content : String
    var creationDate : Double = 0
    var timeStamp : Date?
    var eventKey : String?
    var key : String?
    var commentId : String?
    var notiType: notiType.RawValue?
    let sender: String
    let receiver: String?

    //init for comment notif
    init(eventKey: String,reciever: String, content: String, type: notiType.RawValue,commentId:String){
        self.content = content
        self.creationDate = Date().timeIntervalSince1970
        self.eventKey = eventKey
        self.commentId = commentId
        self.sender = User.current.uid
        self.notiType = type
        self.receiver = reciever

    }
    
    //init for follow notif
    init(reciever: String, content: String, type: notiType.RawValue){
        self.content = content
        self.notiType = type
        self.receiver = reciever
        self.sender = User.current.uid
        self.creationDate = Date().timeIntervalSince1970
    }
    
    //int for share notif
    
    init(reciever: String, content: String,type: notiType.RawValue,eventKey: String) {
        self.content = content
        self.receiver = reciever
        self.content = content
        self.notiType = type
        self.sender = User.current.uid
        self.eventKey = eventKey
        self.creationDate = Date().timeIntervalSince1970
    }

    
    //snapshot for comment notif
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let content = dict["content"] as? String,
            let timestamp = dict["creationDate"] as? TimeInterval,
            let eventKey = dict["eventKey"] as? String,
            let commentId = dict["commentId"] as? String,
            let receiverUid = dict["receiver"] as? String,
            let uid = dict["sender"] as? String,
            let notiType = dict["notiType"] as? notiType.RawValue
            else { return nil }
        
        self.key = snapshot.key
        self.content = content
        self.timeStamp = Date(timeIntervalSince1970: timestamp)
        self.eventKey = eventKey
        self.commentId = commentId
        self.notiType = notiType
        self.sender = uid
        self.receiver = receiverUid
    }
    
    //snapshot for follow notif
    init?(followSnapshot: DataSnapshot) {
        guard let dict = followSnapshot.value as? [String : Any],
            let content = dict["content"] as? String,
            let timestamp = dict["creationDate"] as? TimeInterval,
            let uid = dict["sender"] as? String,
            let receiverUid = dict["receiver"] as? String,
            let notiType = dict["notiType"] as? notiType.RawValue
            else { return nil }
        
        self.key = followSnapshot.key
        self.content = content
        self.timeStamp = Date(timeIntervalSince1970: timestamp)
        self.notiType = notiType
        self.sender = uid
        self.receiver = receiverUid
    }
    
    //snapshot for share notif
    init?(shareSnapShot: DataSnapshot) {
        guard let dict = shareSnapShot.value as? [String : Any],
            let content = dict["content"] as? String,
            let eventKey = dict["eventKey"] as? String,
            let timestamp = dict["creationDate"] as? TimeInterval,
            let uid = dict["sender"] as? String,
            let receiverUid = dict["receiver"] as? String,
            let notiType = dict["notiType"] as? notiType.RawValue
            else { return nil }
        
        self.key = shareSnapShot.key
        self.content = content
        self.timeStamp = Date(timeIntervalSince1970: timestamp)
        self.notiType = notiType
        self.sender = uid
        self.receiver = receiverUid
        self.eventKey = eventKey
    }
    
    //dictvalue for comment
    var dictValue: [String : Any] {
        
        
        return ["eventKey" : eventKey  as Any,
                "content": content,
                "creationDate": creationDate,
                "commentId" : commentId as Any,
                "sender" : sender,
                "receiver" : receiver ?? "",
                "notiType" : notiType as Any]
    }
    // dict value for follow notif
    var followDictValue: [String : Any] {
        
        return [
            "content": content,
            "creationDate": creationDate,
            "sender" : sender,
            "receiver" : receiver ?? "",
            "notiType" : notiType as Any]
    }
    //dict value for share notif
    var shareDictValue: [String : Any] {
        
        
        return ["eventKey" : eventKey  as Any,
                "content": content,
                "creationDate": creationDate,
                "sender" : sender,
                "receiver" : receiver ?? "",
                "notiType" : notiType as Any]
    }
    
}
extension Notifications{
    static public func  ==(rhs: Notifications, lhs: Notifications) ->Bool{
        return (rhs.commentId == lhs.commentId || rhs.receiver == lhs.receiver)
    }
}
extension Notifications: ListDiffable{
    public func diffIdentifier() -> NSObjectProtocol {
        if let currentCommentID = key {
            return currentCommentID as NSObjectProtocol
        }else {
            guard let currentFollowee = receiver else {
                return receiver as! NSObjectProtocol
            }
            return currentFollowee as NSObjectProtocol
        }
    }
    public func isEqual(toDiffableObject object: ListDiffable?) ->Bool{
        guard let object = object as? Notifications else {
            return false
        }
        return  self.key==object.key || self.receiver == object.receiver
    }
}

enum notiType: String {
    case follow = "follow"
    case comment = "comment"
    case friendRequest = "friendRequest"
    case share = "share"

}

