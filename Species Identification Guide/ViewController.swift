//
//  ViewController.swift
//  Species Identification Guide
//
//  Created by user910210 on 4/30/18.
//  Copyright © 2018 PACE Group24. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var characteristicList: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func handleSelection(_ sender: UIButton) {
        characteristicList.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
        
    }
    
    enum Characteristics: String {
        case leg = "Leg"
        case arm = "Arm"
        case head = "Head"
    }
    
    @IBAction func characterisitcTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let characteristic = Characteristics(rawValue: title) else {
            return
        }
        
        switch characteristic {
        case .leg:
            print("Leg")
        case .arm:
            print("Arm")
        default:
            print("Default")
        }
    }
}
