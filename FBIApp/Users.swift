//
//  Users.swift
//  FBIApp
//
//  Created by Pavani Baradi on 12/1/16.
//  Copyright © 2016 nempe1. All rights reserved.
//

import Foundation
import Firebase

struct Users {
    let email: String!
    let addedDate: String!
    let profileImageUrl: String!
    
    
    init(email: String, addedDate: String, profileImageUrl: String) {
        self.email = email
        self.addedDate = addedDate
        self.profileImageUrl = profileImageUrl
        
    }
    
    init(snapshot: FIRDataSnapshot) {
        var value = snapshot.value as! [String: AnyObject]
        self.addedDate = value["addedDate"] as! String!
        self.profileImageUrl = value["profileImageUrl"] as! String
        self.email = value["email"] as! String
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "email": email,
            "addedDate": addedDate,
            "profileImageUrl": profileImageUrl
            ] as AnyObject
    }
    
}
