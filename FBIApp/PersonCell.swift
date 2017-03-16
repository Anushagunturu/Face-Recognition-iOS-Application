//
//  PersonCell.swift
//  FBIApp
//
//  Created by nempe on 11/27/16.
//  Copyright © 2016 nempe1. All rights reserved.
//

import UIKit

class PersonCell: UICollectionViewCell {
    
    @IBOutlet weak var personImage: UIImageView!
    
    func configureCell(imgUrl: String){
        
        if let url = NSURL(string: imgUrl){
        
        downloadImage(url: url)
            
        }
        
    }
    
    func configureViewCell(image: UIImage){
        
        self.personImage.image = image
        
    }

    func setSelected(){
        personImage.clipsToBounds = false
        personImage.layer.borderWidth = 2.0
        personImage.layer.borderColor = UIColor.yellow.cgColor
    }
    
    func downloadImage(url: NSURL){
        
        getDataFromUrl(url as URL) { (data, response, error) in
            DispatchQueue.main.async { () -> Void in
                guard let data = data, error == nil else { return }
                self.personImage.image = UIImage(data: data)
                
            }
        }
        
    }
    
    func getDataFromUrl(_ url: URL, completion: @escaping ((_ data: Data?, _ response: URLResponse?, _ error: NSError?) -> Void)) {
        
       /* URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            completion(data, response, error)
        }) .resume()*/
    }
}
