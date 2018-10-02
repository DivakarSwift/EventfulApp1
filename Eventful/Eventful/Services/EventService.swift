//
//  EventService.swift
//  Eventful
//
//  Created by Shawn Miller on 8/16/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase


struct EventService {
    
    static func show(isFromHomeFeed: Bool,passedDate: Date? = nil,forEventKey eventKey: String, completion: @escaping (Event?) -> Void) {
        // print(eventKey)
        let ref = Database.database().reference().child("events").child(eventKey)
       //  print(eventKey)
        //pull everything
        
        ref.observeSingleEvent(of: .value, andPreviousSiblingKeyWith: {(snapshot,eventKey) in
           print(snapshot.value ?? "")

            guard let event = Event(snapshot: snapshot) else {
                return completion(nil)
            }
            //for the default case
            if passedDate == nil{
                //will check if the events current end time is greater then the current date
                if event.endTime > Date(){
                    //if it is return it
                    completion(event)
                }else{
                    //if it isn't check if it's a request from the home feed
                    
                    if isFromHomeFeed {
                        //if it is return nothing
                        completion(nil)
//                        completion(event)
                    }else{
                        //if it isn't return an event
                        completion(event)                        
                    }
                }
            }else{
                //if there is a passed date parameter which would come from the calendar
                if let date = passedDate{
                    // check if the event being passed back is happening after current passed date for filtering purposes
                    if event.endTime > date {
                        //if so return it
                        completion(event)
                    }else{
                        //if not return nothing
                        completion(nil)
                    }
                }
            }
        })
    }
}
