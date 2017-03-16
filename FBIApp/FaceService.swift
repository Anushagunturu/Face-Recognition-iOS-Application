//
//  FaceService.swift
//  FBIApp
//
//  Created by nempe on 11/27/16.
//  Copyright © 2016 nempe1. All rights reserved.
//

import Foundation
import ProjectOxfordFace

class FaceService{
    static let instance = FaceService()
    
    let client = MPOFaceServiceClient(subscriptionKey: "3675404674344b1391465256e0c77aa6")
}
