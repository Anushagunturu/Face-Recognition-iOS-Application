//
//  RegisterViewController.swift
//  FBI-FR
//
//  Created by Bharath chadarajupalli on 11/27/16.
//  Copyright © 2016 Sesh Harika. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import CoreImage

class RegisterViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    
    let imagePicker = UIImagePickerController()
    var faceBounds: String!
    var ref: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    
    var e: String!
    
    func register() {
        if email.text == "" || password.text == "" || confirmPassword.text == ""
        {
            let alertController = UIAlertController(title: "Oops!", message: "Please enter an email and password.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK!", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else
        {
            FIRAuth.auth()?.createUser(withEmail: self.email.text!, password: self.password.text!, completion: {(user, error) in
                if(error == nil)
                {
                    self.email.text = ""
                    self.password.text = ""
                    self.confirmPassword.text = ""
                    self.e = self.email.text!
                    self.createUser()
                }
            })
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegisterViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        ref = FIRDatabase.database().reference()
        storageRef = FIRStorage.storage().reference(forURL: "gs://fbi-fr.appspot.com/app_users_images")
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(loadPicker(_:)))
        imageTap.numberOfTapsRequired = 1
        userImage.addGestureRecognizer(imageTap)
        
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
    func createUser(){
        let imageName = NSUUID().uuidString
        let imageRef = self.storageRef.child("\(imageName).png")
        if let uploadedData = UIImageJPEGRepresentation(self.userImage.image!, 0.1){
            imageRef.put(uploadedData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error!)
                    return
                }
                let interval = Date().timeIntervalSince1970
                if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                    
                    let values = ["addedDate": String(format: "%f", interval), "email": self.e, "profileImageUrl": profileImageUrl]
                    
                    self.addPersonWithUID(uid: imageName, values: values as [String : AnyObject])
                }
            })
        }
    }
    
    private func addPersonWithUID(uid: String, values: [String: AnyObject]) {
        let usersReference = self.ref.child("users_persons").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                let alertController = UIAlertController(title: "Oops!", message: err?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK!", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
            let alertController = UIAlertController(title: "Successful!", message: "Registration successful", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK!", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            
            //self.dismiss(animated: true, completion: nil)
        })
    }
    
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            userImage.contentMode = .scaleAspectFit
            userImage.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "register") {
            if let nextViewController = segue.destination as? ViewController{
                self.register()
            }
        }
    }
    
}
