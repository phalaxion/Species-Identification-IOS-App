//
//  ProfileViewController.swift
//  Species Identification Guide
//
//  Created by David Rosetti on 21/5/18.
//  Copyright © 2018 David Rosetti. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    var passedHeaders : [String] = []
    var speciesDetailsPassed : [String] = []
    var generatedLabels : [UILabel] = []
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var image: UIImageView!
    
    func setupProfile() {
        //print(passedHeaders)
        for i in 0...(speciesDetailsPassed.count - 1) {
            //if speciesDetailsPassed[i] != "" {
                let label: UILabel = UILabel()
                label.backgroundColor = #colorLiteral(red: 0.8324873096, green: 0.8324873096, blue: 0.8324873096, alpha: 1)
                label.textColor = UIColor.darkText
                label.text = "\(passedHeaders[i]): \(speciesDetailsPassed[i])"
                label.lineBreakMode = .byWordWrapping
                label.numberOfLines = 0
            
                self.mainView.addSubview(label)
                
                label.translatesAutoresizingMaskIntoConstraints = false
                
                if(generatedLabels.count == 0){
                    label.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 10).isActive = true
                } else {
                    label.topAnchor.constraint(equalTo: (generatedLabels.last!).bottomAnchor, constant: 15).isActive = true
                }
                
                label.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10).isActive = true
                label.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 10).isActive = true
                
                generatedLabels.append(label)
            //}
        }
        generatedLabels.last?.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -10).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupProfile()
    }
}
