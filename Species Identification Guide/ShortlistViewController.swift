//
//  ShortlistViewController.swift
//  Species Identification Guide
//
//  Created by David on 21/5/18.
//  Copyright © 2018 PACE Group24. All rights reserved.
//

import UIKit

class ShortlistViewController: UIViewController {

    var searchResultPassed : [[String]] = [[]]
    @IBOutlet weak var mainView: UIView!
    
    func generateSpeciesButtons() {
        var buttonY : CGFloat = 10
        for species in searchResultPassed {
            
            // Setting button properties (size, width, colours, etc.)
            let speciesButton = UIButton(type: .custom) as UIButton
            speciesButton.backgroundColor = UIColor.white
            speciesButton.setTitleColor(UIColor.darkText, for: .normal)
            speciesButton.setTitle(species[0], for: .normal)
            speciesButton.titleLabel?.text = species[0]
            speciesButton.titleLabel?.textAlignment = NSTextAlignment.center
            speciesButton.addTarget(self, action: #selector(speciesProfileBtn), for: .touchUpInside)
            
            self.mainView.addSubview(speciesButton)
            
            // Setting Button Constraints
            speciesButton.translatesAutoresizingMaskIntoConstraints = false
            
            //speciesButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            speciesButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            speciesButton.topAnchor.constraint(equalTo: mainView.topAnchor, constant: buttonY).isActive = true
            speciesButton.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: 10).isActive = true
            speciesButton.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 10).isActive = true
            
            
            //print(species[0])
            buttonY = buttonY + 60
        }
    }
    
    @objc func speciesProfileBtn(sender: UIButton!) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        
        var speciesEntry : [String] = []
        for entry in searchResultPassed {
            if entry.contains(sender.currentTitle!) {
                speciesEntry = entry
            }
        }
        myVC.speciesDetailsPassed = speciesEntry
        navigationController?.pushViewController(myVC, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(searchResultPassed)
        print(searchResultPassed.count)
        if searchResultPassed.count >= 1 {
            generateSpeciesButtons()
        } else {
            let speciesButton = UIButton(frame: CGRect(x:10, y: 10, width: 355, height: 50))
            
            speciesButton.backgroundColor = UIColor.white
            speciesButton.setTitle("No Matching Species", for: .normal)
            speciesButton.titleLabel?.text = "No Matching Species"
        }
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
