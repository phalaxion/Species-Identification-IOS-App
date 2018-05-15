//
//  ViewController.swift
//  Species Identification Guide
//
//  Created by user910210 on 4/30/18.
//  Copyright © 2018 PACE Group24. All rights reserved.
//

import UIKit

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
        
    }
    
    func setRightPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

class ViewController: UIViewController {
    
    @IBOutlet weak var viewConstraint: NSLayoutConstraint!
    @IBOutlet weak var sideView: UIView!
    
    @IBOutlet weak var search: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        search.setLeftPaddingPoints(10)
        search.setRightPaddingPoints(10)
        
        viewConstraint.constant = -310
        
        self.hideKeyboardWhenTappedAround()
    }
    
    var menuVisible = false;
    
    @IBAction func panPerformed(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            let translation = sender.translation(in: self.view).x
            if translation > 0 {    // Swipe Right
                if viewConstraint.constant < 20 {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.viewConstraint.constant += translation
                        self.view.layoutIfNeeded()
                    })
                }
            } else {                // Swipe Left
                if viewConstraint.constant > -310 {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.viewConstraint.constant += translation
                        self.view.layoutIfNeeded()
                    })
                }
            }
        } else if sender.state == .ended {
            if viewConstraint.constant < -100 {
                UIView.animate(withDuration: 0.2, animations: {
                    self.viewConstraint.constant = -310
                    self.view.layoutIfNeeded()
                })
                menuVisible = !menuVisible
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.viewConstraint.constant = -100
                    self.view.layoutIfNeeded()
                })
                menuVisible = !menuVisible
            }
        }
    }
    
    @IBAction func menuButton(_ sender: Any) {
        if !menuVisible {
            UIView.animate(withDuration: 0.2, animations: {
                self.viewConstraint.constant = -310
                self.view.layoutIfNeeded()
            })
            menuVisible = !menuVisible
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.viewConstraint.constant = -100
                self.view.layoutIfNeeded()
            })
            menuVisible = !menuVisible
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var bodyTypeButton: UIButton!
    @IBOutlet var bodyTypes: [UIButton]!
    @IBAction func bodyTypeChoice(_ sender: UIButton) {
        bodyTypes.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    enum BodyTypes: String {        //Cases must be exactly the same as the button in storyboard
        case soft = "Soft Body"
        case shell = "Shell"
        case exo = "Tough Exoskeleton"
        case hairy = "Visibly Hairy"
    }
    @IBAction func bodyTypeTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let bodyType = BodyTypes(rawValue: title) else {
            return
        }
        switch bodyType {
        case .soft:
            bodyTypeButton.setTitle("Soft Body", for: .normal)
            bodyTypeChoice(sender)
        case .shell:
            bodyTypeButton.setTitle("Shell", for: .normal)
            bodyTypeChoice(sender)
        case .exo:
            bodyTypeButton.setTitle("Tough Exoskeleton", for: .normal)
            bodyTypeChoice(sender)
        case .hairy:
            bodyTypeButton.setTitle("Visibly Hairy", for: .normal)
            bodyTypeChoice(sender)
        }
    }
    
    @IBOutlet weak var bodyShapeButton: UIButton!
    @IBOutlet var bodyShapes: [UIButton]!
    
    @IBAction func bodyShapeChoice(_ sender: UIButton) {
        bodyShapes.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    enum BodyShapes: String {
        case long = "Long and Slim"
        case short = "Short and Wide"
        case neither = "Neither"
    }
    @IBAction func bodyShapeTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let shape = BodyShapes(rawValue: title) else {
            return
        }
        switch shape{
        case .long:
            bodyShapeButton.setTitle("Long and Slim", for: .normal)
            bodyShapeChoice(sender)
        case .short:
            bodyShapeButton.setTitle("Short and Wide", for: .normal)
            bodyShapeChoice(sender)
        case .neither:
            bodyShapeButton.setTitle("Neither", for: .normal)
            bodyShapeChoice(sender)
        }
    }
    
    @IBOutlet weak var bodyCompressionButton: UIButton!
    @IBOutlet var bodyCompressions: [UIButton]!
    
    @IBAction func bodyCompressionChoice(_ sender: UIButton) {
        bodyCompressions.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
        
    }
    
    enum BodyCompressions: String {
        case lateral = "Lateral (from side)"
        case dorsoVentral = "Dorso-ventral (from top and bottom)"
        case none = "None"
    }
    
    @IBAction func bodyCompressionTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let compression = BodyCompressions(rawValue: title) else {
            print("nooo")
            return
        }
        switch compression{
        case .lateral:
            bodyCompressionButton.setTitle("Lateral", for: .normal)
            bodyCompressionChoice(sender)
        case .dorsoVentral:
            bodyCompressionButton.setTitle("Dorso-Ventral", for: .normal)
            bodyCompressionChoice(sender)
        case .none:
            bodyCompressionButton.setTitle("None", for: .normal)
            bodyCompressionChoice(sender)
        }
    }
    
    @IBOutlet weak var abdomenThoraxConstriction: UIButton!
    var count = 0
    @IBAction func abdomenThoraxConstrictionButton(_ sender: Any) {
        count = count + 1
        print(count)
        print(count%2)
        if (count%2 == 1){
            abdomenThoraxConstriction.setTitle("Has Constriction Between Thorax and Abdomen", for: .normal)
        }
        else {
            abdomenThoraxConstriction.setTitle("Does Not Have Constriction Between Thorax and Abdomen", for: .normal)
        }
    }
}




