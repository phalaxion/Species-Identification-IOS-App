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
    
    @IBOutlet weak var numLegsButton: UIButton!
    @IBOutlet var numLegs: [UIButton]!
    @IBAction func numLegChoice(_ sender: UIButton) {
        numLegs.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    enum NumLegs: String {
        case zero = "0 Legs"
        case six = "6 Legs"
        case eight = "8 Legs"
        case eightPlus = "More than 8 Legs"
    }
    @IBAction func numLegsTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let shape = NumLegs(rawValue: title) else {
            return
        }
        switch shape{
        case .zero:
            numLegsButton.setTitle("0 Legs", for: .normal)
            numLegChoice(sender)
        case .six:
            numLegsButton.setTitle("6 Legs", for: .normal)
            numLegChoice(sender)
        case .eight:
            numLegsButton.setTitle("8 Legs", for: .normal)
            numLegChoice(sender)
        case .eightPlus:
            numLegsButton.setTitle("More than 8 Legs", for: .normal)
            numLegChoice(sender)
        }
    }
    
    @IBOutlet weak var legTypeButton: UIButton!
    @IBOutlet var legTypes: [UIButton]!
    
    @IBAction func legTypeChoice(_ sender: UIButton) {
        legTypes.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    enum LegTypes: String {
        case similar = "All look very similar (and similar length)"
        case different = "Legs different lengths"
        case jumpingHind = "Strong jumping hind legs"
        case raptorial = "Raptorial (like a T-rex)"
        case popeye = "Looks a bit like Popeye's arms"
    }
    @IBAction func legTypeTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let legType = LegTypes(rawValue: title) else {
            return
        }
        switch legType{
        case .similar:
            legTypeButton.setTitle("All look very similar (and similar length)", for: .normal)
            legTypeChoice(sender)
        case .different:
            legTypeButton.setTitle("Legs different lengths", for: .normal)
            legTypeChoice(sender)
        case .jumpingHind:
            legTypeButton.setTitle("Strong jumping hind legs", for: .normal)
            legTypeChoice(sender)
        case .raptorial:
            legTypeButton.setTitle("Raptorial (like a T-rex)", for: .normal)
            legTypeChoice(sender)
        case .popeye:
            legTypeButton.setTitle("Looks a bit like Popeye's arms", for: .normal)
            legTypeChoice(sender)
        }
    }
    
    @IBOutlet weak var numWingsButton: UIButton!
    @IBOutlet var numWings: [UIButton]!
    @IBAction func numWingsChoice(_ sender: UIButton) {
        numWings.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    enum NumWings: String {
        case none = "No Wings"
        case two = "2 Wings (+a pair of halteres or elytra)"
        case four = "4 Wings"
    }
    @IBAction func numWingsTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let numWing = NumWings(rawValue: title) else {
            return
        }
        switch numWing{
        case .none:
            numWingsButton.setTitle("No Wings", for: .normal)
            numWingsChoice(sender)
        case .two:
            numWingsButton.setTitle("2 Wings (+a pair of halteres or elytra)", for: .normal)
            numWingsChoice(sender)
        case .four:
            numWingsButton.setTitle("4 Wings", for: .normal)
            numWingsChoice(sender)
        }
    }
    
    @IBOutlet weak var wingTextureButton: UIButton!
    @IBOutlet var wingTextures: [UIButton]!
    
    @IBAction func wingTextureChoice(_ sender: UIButton) {
        wingTextures.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    enum WingTextures: String {
        case hairy = "Hairy (all over or on edges / margins)"
        case scaly = "Scaly and Patterned (like a Butterfly)"
        case membranous0 = "Membranous"
        case membranous1 = "Membranous (highly complex vein pattern)"
        case membranous2 = "Membranous (simple vein pattern)"
    }
    @IBAction func wingTextureTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let wingTexture = WingTextures(rawValue: title) else {
            return
        }
        switch wingTexture{
        case .hairy:
            wingTextureButton.setTitle("Hairy (all over or on edges / margins", for: .normal)
            wingTextureChoice(sender)
        case .scaly:
            wingTextureButton.setTitle("Scaly and Patterned (like a Butterfly)", for: .normal)
            wingTextureChoice(sender)
        case .membranous0:
            wingTextureButton.setTitle("Membranous", for: .normal)
            wingTextureChoice(sender)
        case .membranous1:
            wingTextureButton.setTitle("Membranous (highly complex vein pattern)", for: .normal)
            wingTextureChoice(sender)
        case .membranous2:
            wingTextureButton.setTitle("Membranous (simple vein pattern)", for: .normal)
            wingTextureChoice(sender)
        }
    }
}




