//
//  ProfileViewController.swift
//  Species Identification Guide
//
//  Created by David on 21/5/18.
//  Copyright © 2018 PACE Group24. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    var speciesDetailsPassed : [String] = []
    
    @IBOutlet weak var textView: UITextView!
    func setupProfile() {
        textView.text = speciesDetailsPassed[0]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupProfile()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
