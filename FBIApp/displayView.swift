//
//  displayView.swift
//  FBIApp
//
//  Created by nempe on 11/28/16.
//  Copyright © 2016 nempe1. All rights reserved.
//

import UIKit

class displayView: UIViewController{
    
    @IBOutlet weak var matchLabel: UILabel!
    @IBOutlet weak var matchImageView: UIImageView!
    @IBOutlet weak var confidenceLabel: UILabel!
    
    var matchValue: Bool?
    var confidenceVal: Double?
    var successMatch: Bool?
    var successConfValue: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if successMatch == true {
            matchLabel.text = "Found Match !!"
            matchImageView.image = UIImage(named: "right_icon")
            confidenceLabel.text = String(describing: successConfValue!)
        }else{
            matchLabel.text = "Not a Match !!"
            matchImageView.image = UIImage(named: "RedX")
            confidenceLabel.text = String(describing: confidenceVal!)
        }
    }
    
}
