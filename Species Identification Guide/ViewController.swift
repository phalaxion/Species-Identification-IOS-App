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
    enum BodyTypes: String {
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
    
}




