//
//  MissingPerson.swift
//  FBIApp
//
//  Created by Pavani Baradi on 11/30/16.
//  Copyright © 2016 nempe1. All rights reserved.
//

import Foundation
import Firebase

struct MissingPerson {
    let addedDate: String!
    let profileImageUrl: String!
    
    init(addedDate: String, profileImageUrl: String) {
        self.addedDate = addedDate
        self.profileImageUrl = profileImageUrl
    }
    
    init(snapshot: FIRDataSnapshot) {
        var value = snapshot.value as! [String: AnyObject]
        addedDate = value["addedDate"] as! String!
        profileImageUrl = value["profileImageUrl"] as! String
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "addedDate": addedDate,
            "profileImageUrl": profileImageUrl
            ] as AnyObject
    }
}
