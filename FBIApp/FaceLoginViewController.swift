//
//  FaceLoginViewController.swift
//  FBIApp
//
//  Created by Pavani Baradi on 12/1/16.
//  Copyright © 2016 nempe1. All rights reserved.
//

import UIKit
import CoreImage
import Firebase

class FaceLoginViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(loadPicker(_:)))
        imageTap.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(imageTap)
        
//        imagePicker.delegate = self
//        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
//            return
//        }
//        imagePicker.allowsEditing = false
//        imagePicker.sourceType = .camera
//        present(imagePicker, animated: true, completion: nil)
    }
    
    func loadPicker(_ gesture: UITapGestureRecognizer) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func detect() {
        let imageOptions =  NSDictionary(object: NSNumber(value: 5) as NSNumber, forKey: CIDetectorImageOrientation as NSString)
        let personciImage = CIImage(cgImage: imageView.image!.cgImage!)
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        let faces = faceDetector?.features(in: personciImage, options: imageOptions as? [String : AnyObject])
        
        if let face = faces?.first as? CIFaceFeature {
            print("found bounds are \(face.bounds)")
            print(face.leftEyePosition)
            print(face.rightEyePosition)
            let x1: CGFloat = face.leftEyePosition.x
            let y1: CGFloat =  face.leftEyePosition.y
            let x2: CGFloat = face.rightEyePosition.x
            let y2: CGFloat = face.rightEyePosition.y
            let distance = sqrt(pow((x2 - x1), 2) + pow((y2 - y1), 2))
            print(distance)
            
//            let userRef = self.ref.child("app_users")
//            let query = userRef.queryEqual(toValue: "\(face.bounds)", childKey: "faceBounds")
//            print(query)
//            query.observeSingleEvent(of: .value, with: {(snapshot) in
//                print(snapshot.value!)
//            })
            
            
        } else {
            let alert = UIAlertController(title: "No Face!", message: "No face was detected", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
        self.detect()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
