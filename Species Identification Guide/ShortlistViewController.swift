//
//  ShortlistViewController.swift
//  Species Identification Guide
//
//  Created by David Rosetti on 21/5/18.
//  Copyright © 2018 David Rosetti. All rights reserved.
//

import UIKit

class ShortlistViewController: UIViewController {

    var searchResultPassed : [[String]] = [[]]
    var headersTMP : [String] = []
    @IBOutlet weak var mainView: UIView!
    
    var generatedButtons : [UIButton] = []
    
    func generateSpeciesButtons() {
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
            speciesButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            if(generatedButtons.count == 0){
                speciesButton.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 10).isActive = true
            } else {
                speciesButton.topAnchor.constraint(equalTo: (generatedButtons.last!).bottomAnchor, constant: 10).isActive = true
            }
            
            speciesButton.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10).isActive = true
            speciesButton.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 10).isActive = true
            
            generatedButtons.append(speciesButton)
            //print(species[0])
        }
        generatedButtons.last?.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -10).isActive = true
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
        myVC.passedHeaders = headersTMP
        navigationController?.pushViewController(myVC, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(searchResultPassed)
        print(searchResultPassed.count)
        if searchResultPassed.count >= 1 {
            generateSpeciesButtons()
        } else {
            let noResult = UIButton(type: .custom) as UIButton
            noResult.backgroundColor = UIColor.white
            noResult.setTitleColor(UIColor.darkText, for: .normal)
            noResult.setTitle("No Matching Species", for: .normal)
            noResult.titleLabel?.text = "No Matching Species"
            noResult.titleLabel?.textAlignment = NSTextAlignment.center
            
            self.mainView.addSubview(noResult)
            
            // Setting Button Constraints
            noResult.translatesAutoresizingMaskIntoConstraints = false
            noResult.heightAnchor.constraint(equalToConstant: 50).isActive = true
            noResult.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 10).isActive = true
            noResult.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10).isActive = true
            noResult.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 10).isActive = true
        }
    }
}
