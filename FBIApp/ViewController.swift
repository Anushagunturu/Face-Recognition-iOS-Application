//
//  ViewController.swift
//  FBIApp
//
//  Created by nempe on 11/27/16.
//  Copyright © 2016 nempe1. All rights reserved.
//

import UIKit
import ProjectOxfordFace
import Firebase


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    
    var selectedPerson: Person?
    var hasSelected: Bool = false
    
    var confidenceValue: Double?
    var identicalValue: Bool?
    var successMatch: Bool = false
    var successConfValue: Double!
    
    var ref: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    var storage: FIRStorage!
    
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let baseURL = ""
    
    var missingPeople: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        imagePicker.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(loadPicker(_:)))
        tap.numberOfTapsRequired = 1
        selectedImage.addGestureRecognizer(tap)
        
    }
    
    func getMissingPersons() {
        ref = FIRDatabase.database().reference()
        storage = FIRStorage.storage()
        storageRef = FIRStorage.storage().reference(forURL: "gs://fbi-fr.appspot.com/missing_person_images")
        
        let personsRef = self.ref.child("missing_persons")
        
        personsRef.observe(.childAdded, with: {(snapshot) in
            let person = MissingPerson(snapshot: snapshot)
            let imageRef = self.storage.reference(forURL: person.profileImageUrl)
            imageRef.data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) in
                self.missingPeople.append(UIImage(data: data!)!)
                self.collectionView.reloadData()
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.missingPeople = []
        super.viewDidAppear(animated)
        self.getMissingPersons()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return missingPeople.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PersonCell", for: indexPath) as! PersonCell
        let person = missingPeople[indexPath.row]
        cell.configureViewCell(image: person)
        return cell
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectingImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            selectedImage.image = selectingImage
            hasSelected = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    func loadPicker(_ gesture: UITapGestureRecognizer) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedPerson = Person(image: missingPeople[indexPath.row])
        let cell = collectionView.cellForItem(at: indexPath) as! PersonCell
        selectedPerson?.downloadFaceId(image: missingPeople[indexPath.row])
        cell.configureViewCell(image: missingPeople[indexPath.row])
        cell.setSelected()
    }
    
    func showErrorAlert() {
        let alert = UIAlertController(title: "Select Person & Image", message: "Please select a missing person to check and an image from your photo library", preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func findMatch(_ sender: Any) {
       self.findForMatch()
    }
    
    func findForMatch() {
        var identical:Bool = false
        var i = 0
        successMatch = false
        successConfValue = 0
        
        if let theImg = selectedImage.image, let imgData = UIImageJPEGRepresentation(theImg, 0.8) {
            FaceService.instance.client?.detect(with: imgData, returnFaceId: true, returnFaceLandmarks: false, returnFaceAttributes: nil, completionBlock: { (faces: [MPOFace]?, err: Error?) in
                
                if err != nil {
                    return
                }
                var faceId: String?
                faceId = faces?.first?.faceId
                if faceId == nil {
                    return
                }
                print(self.missingPeople.count)
                for image in self.missingPeople {
                    
                    //faceLoop: while !identical && i < self.missingPeople.count {
                    //let missingPeopleImage = self.missingPeople[i]
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
                            
                            // self.performSegue(withIdentifier: "findMatchSegue", sender: self)
                            self.confidenceValue = result?.confidence! as Double?
                            self.identicalValue = result?.isIdentical
                            print("confidenceValue : ",self.confidenceValue!)
                            print("identicalValue : ",self.identicalValue!)
                            identical = self.identicalValue!
                            if(identical){
                                self.successMatch = self.identicalValue!
                                self.successConfValue = self.confidenceValue
                                self.performSegue(withIdentifier: "display", sender: self)
                                return
                            }
                            if (i == self.missingPeople.count && !self.successMatch ) {
                                print("false")
                                self.performSegue(withIdentifier: "display", sender: self)
                                return
                            }
                        })
                    })
                }
            })
        }
    }
    
    func signOut(){
        try! FIRAuth.auth()!.signOut();
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "logout"){
            if segue.destination is LoginViewController {
                self.signOut()
            }
        }
        if (segue.identifier == "display"){
            if let destViewController : displayView = segue.destination as? displayView {
                destViewController.matchValue = identicalValue
                destViewController.confidenceVal = confidenceValue!
                destViewController.successMatch = self.successMatch
                destViewController.successConfValue = self.successConfValue
            }
        }
    }
    
}

