//
//  Story.swift
//  Eventful
//
//  Created by Shawn Miller on 8/21/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import Firebase
import  UIKit


struct Story {
    
    let Url: String
    let uid: String
    
    init(url: String)
    {
        self.Url = url
        self.uid = User.current.uid
    }
    
    init?(snapshot: DataSnapshot){
        guard let dict = snapshot.value as? [String:Any],
       let uid = dict["uid"] as? String,
        let Url = dict["url"] as? String
        else {
            return nil
        }
        self.uid = uid
        self.Url = Url
    }
    
    var dictValue : [String : Any]
    {
        return ["url" : Url,"uid" : uid]
    }
    
    
}
