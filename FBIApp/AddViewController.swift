//
//  AddViewController.swift
//  FBIApp
//
//  Created by Pavani Baradi on 11/30/16.
//  Copyright © 2016 nempe1. All rights reserved.
//

import UIKit
import Firebase

class AddViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var ref: FIRDatabaseReference!
    var storageRef: FIRStorageReference!

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        storageRef = FIRStorage.storage().reference(forURL: "gs://fbi-fr.appspot.com/missing_person_images")
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageView)))
        imageView.isUserInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addMissingPerson(_ sender: Any) {
        let email = "pavani.j.baradi@gmail.com"
        let password = "password1"
        
        FIRAuth.auth()!.signIn(withEmail: email, password: password){auth, user in
            print("user is \(user)")
            print("auth is \(auth?.email) \(auth?.uid)")
            if auth != nil {
                let imageName = NSUUID().uuidString
                let imageRef = self.storageRef.child("\(imageName).png")
                if let uploadedData = UIImageJPEGRepresentation(self.imageView.image!, 0.1){
                    imageRef.put(uploadedData, metadata: nil, completion: { (metadata, error) in
                        if error != nil{
                            print(error!)
                            return
                        }
                        let interval = Date().timeIntervalSince1970
                        if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                            
                            let values = ["addedDate": String(format: "%f", interval), "profileImageUrl": profileImageUrl]
                            
                            self.addPersonWithUID(uid: imageName, values: values as [String : AnyObject])
                        }
                    })
                }
            }
        }
    }
    
    func handleImageView(){
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    private func addPersonWithUID(uid: String, values: [String: AnyObject]) {
        let usersReference = self.ref.child("missing_persons").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err!)
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            imageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
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
