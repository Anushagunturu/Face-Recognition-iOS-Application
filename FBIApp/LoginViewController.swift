//
//  LoginViewController.swift
//  FBI-FR
//
//  Created by Bharath chadarajupalli on 11/27/16.
//  Copyright © 2016 Sesh Harika. All rights reserved.
//

import UIKit
import Firebase
import CoreImage
import ProjectOxfordFace

class LoginViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    let imagePicker = UIImagePickerController()
    var imageView: UIImageView!
    
    var ref: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    var storage: FIRStorage!
    
    var users: [UIImage] = []
    var successMatch: Bool!
    
    
    func signIn() {
        if email.text == "" || password.text == ""
        {
            let alertController = UIAlertController(title: "Oops!", message: "Please enter an email and password.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK!", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else
        {
            FIRAuth.auth()?.signIn(withEmail: self.email.text!, password: self.password.text!, completion: { (user, error) in
                if(error == nil && user != nil)
                {
                    self.email.text = ""
                    self.password.text = ""
                }
                else
                {
                    let alertController = UIAlertController(title: "Oops!", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK!", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }
        
        
    }
    
    @IBAction func faceLogin(_ sender: Any) {
        //self.getMissingPersons()
        imagePicker.delegate = self
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    func getMissingPersons() {
        ref = FIRDatabase.database().reference()
        storageRef = FIRStorage.storage().reference(forURL: "gs://fbi-fr.appspot.com/app_users_images")
        
        let personsRef = self.ref.child("users_persons")
        
        personsRef.observe(.childAdded, with: {(snapshot) in
            let person = Users(snapshot: snapshot)
            let imageRef = self.storage.reference(forURL: person.profileImageUrl)
            imageRef.data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) in
                self.users.append(UIImage(data: data!)!)
            })
        })
    }
    
    func findForMatch() {
        var identical:Bool = false
        var i = 0
        successMatch = false
        //        successConfValue = 0
        
        if let theImg = imageView.image, let imgData = UIImageJPEGRepresentation(theImg, 0.8) {
            FaceService.instance.client?.detect(with: imgData, returnFaceId: true, returnFaceLandmarks: false, returnFaceAttributes: nil, completionBlock: { (faces: [MPOFace]?, err: Error?) in
                
                if err != nil {
                    return
                }
                var faceId: String?
                faceId = faces?.first?.faceId
                if faceId == nil {
                    return
                }
                print(self.users.count)
                for image in self.users {
                    
                    let missingPeopleImage = image
                    let imgDataFromDb = UIImageJPEGRepresentation(missingPeopleImage, 0.8)
                    
                    
                    FaceService.instance.client?.detect(with: imgDataFromDb, returnFaceId: true, returnFaceLandmarks: false, returnFaceAttributes: nil, completionBlock: { (facesFromDb: [MPOFace]?, err: Error?) in
                        
                        if err != nil {
                            return
                        }
                        
                        var faceIdFromDb: String?
                        faceIdFromDb = facesFromDb?.first?.faceId
                        
                        FaceService.instance.client?.verify(withFirstFaceId: faceIdFromDb, faceId2: faceId, completionBlock: { (result: MPOVerifyResult?, err: Error?) in
                            i = i + 1
                            if err != nil {
                                print(err.debugDescription)
                                return
                            }
                            
                            identical = (result?.isIdentical)!
                            if identical {
                                self.successMatch = identical
                                self.performSegue(withIdentifier: "faceLogin", sender: self)
                                let alertController = UIAlertController(title: "Successful!", message: "Face Login", preferredStyle: .alert)
                                let defaultAction = UIAlertAction(title: "OK!", style: .cancel, handler: nil)
                                alertController.addAction(defaultAction)
                                self.present(alertController, animated: true, completion: nil)
                                print("success")
                                
                                return
                            }
                            if (i == self.users.count && !self.successMatch ) {
                                let alertController = UIAlertController(title: "Oops!", message: "No User found!", preferredStyle: .alert)
                                let defaultAction = UIAlertAction(title: "OK!", style: .cancel, handler: nil)
                                alertController.addAction(defaultAction)
                                self.present(alertController, animated: true, completion: nil)
                                return
                            }
                        })
                    })
                }
            })
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
            self.findForMatch()
        }
        
        dismiss(animated: true, completion: nil)
        //        self.detect()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegisterViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        ref = FIRDatabase.database().reference()
        storage = FIRStorage.storage()
        storageRef = FIRStorage.storage().reference(forURL: "gs://fbi-fr.appspot.com/app_users_images")
        
        self.imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 600, height: 600))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.users = []
        self.getMissingPersons()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "home") {
            if let nextViewController = segue.destination as? ViewController{
                self.signIn()
            }
        }
    }
    
}
