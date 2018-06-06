//
//  ProfileViewController.swift
//  Species Identification Guide
//
//  Created by David Rosetti on 21/5/18.
//  Copyright © 2018 David Rosetti. All rights reserved.
//

import UIKit
import ImageSlideshow

class ProfileViewController: UIViewController {
    
    var passedHeaders : [String] = []
    var speciesDetailsPassed : [String] = []
    var generatedLabels : [UILabel] = []
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var slideshow: ImageSlideshow!
    var imageList : [ImageSource] = []
    
    func setupProfile() {
        //print(passedHeaders)
        for i in 0...(speciesDetailsPassed.count - 1) {
            //if speciesDetailsPassed[i] != "" {
                let label: UILabel = UILabel()
                label.backgroundColor = UIColor(red:0/255,green:0/255,blue:0/255,alpha: 0)
                label.textColor = UIColor.darkText
                label.text = "\(passedHeaders[i]): \(speciesDetailsPassed[i])"
                label.lineBreakMode = .byWordWrapping
                label.numberOfLines = 0
            
                self.mainView.addSubview(label)
                
                label.translatesAutoresizingMaskIntoConstraints = false
                
                if(generatedLabels.count == 0){
                    label.topAnchor.constraint(equalTo: slideshow.bottomAnchor, constant: 10).isActive = true
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
    
    func setupImages(morphoSpecies: String) {
        let fileManager = FileManager.default
        let bundleURL = Bundle.main.bundleURL
        let assetURL = bundleURL.appendingPathComponent("Resources.bundle")
        let contents = try! fileManager.contentsOfDirectory(at: assetURL, includingPropertiesForKeys: [URLResourceKey.nameKey, URLResourceKey.isDirectoryKey], options: .skipsHiddenFiles)
        
        for item in contents {
            if item.lastPathComponent.lowercased().contains(morphoSpecies.lowercased()){
                let img = ImageSource(image: UIImage(named: "Resources.bundle/" + item.lastPathComponent)!)
                imageList.append(img)
            }
        }
    }
    
    @objc func didTap() {
        slideshow.presentFullScreenController(from: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupProfile()
        setupImages(morphoSpecies: speciesDetailsPassed[2])
        
        slideshow.setImageInputs(imageList)
        
        let pageIndicator = UIPageControl()
        pageIndicator.currentPageIndicatorTintColor = UIColor(red:0/255,green:0/255,blue:0/255,alpha: 0)
        pageIndicator.pageIndicatorTintColor = UIColor.black
        slideshow.pageIndicator = pageIndicator
        slideshow.zoomEnabled = true
        slideshow.pageIndicatorPosition = PageIndicatorPosition(horizontal: .center, vertical: .bottom)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        slideshow.addGestureRecognizer(gestureRecognizer)
    }
}
