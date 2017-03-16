//
//  Person.swift
//  FBIApp
//
//  Created by nempe on 11/27/16.
//  Copyright © 2016 nempe1. All rights reserved.
//

import UIKit
import ProjectOxfordFace

class Person{
    var faceId: String?
    var personImage: UIImage?
    var personImageUrl: String?
    
    init(personImageUrl: String){
        self.personImageUrl = personImageUrl
    }
    
    init(image: UIImage){
    self.personImage = image
    }
    
    func downloadFaceId(image: UIImage?) {
        if let img = image, let imgData = UIImageJPEGRepresentation(img, 0.8) {
            FaceService.instance.client?.detect(with: imgData, returnFaceId: true, returnFaceLandmarks: false, returnFaceAttributes: nil, completionBlock: { (faces: [MPOFace]?, err: Error?) in
                
                if err == nil {
                    var faceId: String?
                    for face in faces! {
                        faceId = face.faceId
                        print("Face Id: \(faceId)")
                        break
                    }
                    
                    self.faceId = faceId
                }
            })
        }
    }
    
 /*   func downloadFaceId(){
        if let img = personImage, let imgData = UIImagePNGRepresentation(img){
            FaceService.instance.client?.detect(with: imgData, returnFaceId: true, returnFaceLandmarks: false, returnFaceAttributes: nil, completionBlock: { (faces: [MPOFace]?, err: Error?) in
                
                if(err == nil){
                    var faceId: String?
                    for face in faces! {
                        faceId = face.faceId
                        break;
                    }
                    
                    self.faceId = faceId
                }
            })
        }
    }*/
    
    func setSelected(){
       
    }

}
