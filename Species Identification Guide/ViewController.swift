//
//  ViewController.swift
//  Species Identification Guide
//
//  Created by user910210 on 4/30/18.
//  Copyright © 2018 PACE Group24. All rights reserved.
//

import UIKit
import SQLite3
import Foundation
import CSV

extension UITextField {
    func setPadding(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
        self.rightView = paddingView
        self.rightViewMode = .always    }
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
    
    var db: OpaquePointer?
    var searchQuery = "SELECT * FROM INVERTEBRATES WHERE"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        search.setPadding(10)
        
        viewConstraint.constant = -310
        
        self.hideKeyboardWhenTappedAround()
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("SIG.sqlite")
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error Opening Database!")
        }
        
        let createTableQuery = "CREATE TABLE IF NOT EXISTS INVERTEBRATES (id INTEGER PRIMARY KEY AUTOINCREMENT, COMMON_NAME VARCHAR(40), SPECIES_NAME VARCHAR(40), BODY_TYPE VARCHAR(20), BODY_SHAPE VARCHAR(20), BODY_COMPRESS VARCHAR(20), LEG_NUM VARCHAR(20), LEG_TYPE VARCHAR(20), WING_NUM VARCHAR(20), WING_TEXTURE VARCHAR(20), WINGS_RESTING VARCHAR(20), THORAX_CONSTRICT VARCHAR(20), ANTENNAE VARCHAR(20), ANTENNAE_LENGTH VARCHAR(20), MOUTH_PARTS VARCHAR(20), THORACIC_SEC VARCHAR(20), AB_APPENDAGE VARCHAR(20), SIZE INT)"
        
        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error Creating Table!")
            return
        }
        print("Database is Working!")
        
        let csvPath = Bundle.main.path(forResource: "invertebrates", ofType: "csv")!
        let stream = InputStream(fileAtPath: csvPath)!
        let csv = try! CSVReader(stream: stream, hasHeaderRow: true)

        while let row = csv.next() {
            print("\(row)")
        }
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
    
    @IBAction func menuToggle(_ sender: Any) {
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
    
    @IBOutlet var bodySubMenuItems: [UIStackView]!
    @IBAction func bodySubMenus(_ sender: Any) {
        bodySubMenuItems.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    //----------------------------------Categories---------------------------------------------//
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
    
    @IBOutlet weak var wingPositionButton: UIButton!
    @IBOutlet var wingPositions: [UIButton]!
    
    @IBAction func wingPositionChoice(_ sender: UIButton) {
        wingPositions.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    enum WingPositions: String {
        case vertical = "Vertical (above body like butterfly)"
        case horizontal = "Horizontally out from thorax"
        case tent = "Like a tent over abdomen"
        case tucked = "Tucked in close to the body / folded"
    }
    
    
    @IBAction func wingPositionTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let wingPosition = WingPositions(rawValue: title) else {
            return
        }
        switch wingPosition{
        case .vertical:
            wingPositionButton.setTitle("Vertical (above body like butterfly)", for: .normal)
            wingPositionChoice(sender)
        case .horizontal:
            wingPositionButton.setTitle("Horizontally out from thorax", for: .normal)
            wingPositionChoice(sender)
        case .tent:
            wingPositionButton.setTitle("Like a tent of abdomen", for: .normal)
            wingPositionChoice(sender)
        case .tucked:
            wingPositionButton.setTitle("Tucked in close to the body / folded", for: .normal)
            wingPositionChoice(sender)
        }
    }

    @IBOutlet weak var antennaeButton: UIButton!
    @IBOutlet var antennae: [UIButton]!
    @IBAction func antennaeChoice(_ sender: UIButton) {
        antennae.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    enum Antennae: String {
        case absent = "Antennae Absent"
        case fileform = "Fileform (looks like a thread)"
        case beadlike = "Bead-like (looks like a pearl string)"
        case longFirst = "Long first segment (Scape)"
        case other = "Other type of Antennae"
    }
    @IBAction func antannaeTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let antennae = Antennae(rawValue: title) else {
            return
        }
        switch antennae{
        case .absent:
            antennaeButton.setTitle("Antennae Absent", for: .normal)
            antennaeChoice(sender)
        case .fileform:
            antennaeButton.setTitle("Fileform (looks like a thread)", for: .normal)
            antennaeChoice(sender)
        case .beadlike:
            antennaeButton.setTitle("Bead-like (looks like a pearl string)", for: .normal)
            antennaeChoice(sender)
        case .longFirst:
            antennaeButton.setTitle("Long first segment (Scape)", for: .normal)
            antennaeChoice(sender)
        case .other:
            antennaeButton.setTitle("Other type of Antennae", for: .normal)
            antennaeChoice(sender)
        }
    }
    
    @IBOutlet var antennaLengths: [UIButton]!
    @IBOutlet weak var antennaLengthButton: UIButton!
    @IBAction func antennaLengthChoice(_ sender: UIButton) {
        antennaLengths.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    enum AntennaLengths: String {
        case none = "No antenna / may be hidden or hard to see"
        case short = "Short - about length of head or shorter"
        case long = "Long - about length of thorax (could extend over thorax but not beyond end of abdomen)"
        case extraLong = "Extra long - longer than body (could extend over thorax and abdomen)"
    }
    
    @IBAction func antennaLengthTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let antennaLength = AntennaLengths(rawValue: title) else {
            return
        }
        switch antennaLength{
        case .none:
            antennaLengthButton.setTitle("No antenna / may be hidden or hard to see", for: .normal)
            antennaLengthChoice(sender)
        case .short:
            antennaLengthButton.setTitle("Short - about length of head or shorter", for: .normal)
            antennaLengthChoice(sender)
        case .long:
            antennaLengthButton.setTitle("Long - about length of thorax (could extend over thorax but not beyond end of abdomen)", for: .normal)
            antennaLengthChoice(sender)
        case .extraLong:
            antennaLengthButton.setTitle("Extra long - longer than body (could extend over thorax and abdomen)", for: .normal)
            antennaLengthChoice(sender)
        }
    }
    
    @IBOutlet weak var mouthPartsButton: UIButton!
    @IBOutlet var mouthParts: [UIButton]!
    @IBAction func mouthPartsChoice(_ sender: UIButton) {
        mouthParts.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    enum MouthParts: String {
        case chewing = "Chewing (Mandibles)"
        case piercing = "Piercing or Sucking (Rostrum)"
        case enclosed = "Enclosed / not visible"
    }
    @IBAction func mouthPartsTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let mouthPart = MouthParts(rawValue: title) else {
            return
        }
        switch mouthPart{
        case .chewing:
            mouthPartsButton.setTitle("Chewing (Mandibles)", for: .normal)
            mouthPartsChoice(sender)
        case .piercing:
            mouthPartsButton.setTitle("Piercing or Sucking (Rostrum)", for: .normal)
            mouthPartsChoice(sender)
        case .enclosed:
            mouthPartsButton.setTitle("Enclosed / not visible", for: .normal)
            mouthPartsChoice(sender)
        }
    }
    @IBOutlet weak var thoracicSectionsButton: UIButton!
    @IBOutlet var thoracicSections: [UIButton]!
    @IBAction func thoracicSectionsChoice(_ sender: UIButton) {
        thoracicSections.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    enum ThoracicSections: String {
        case pronotom = "Pronotom (1st section)"
        case mesonotum = "Mesonotum (2nd section)"
        case metathorax = "Metathorax (3rd section)"
    }
    @IBAction func thoracicSectionsTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let thoracicSection = ThoracicSections(rawValue: title) else {
            return
        }
        switch thoracicSection{
        case .pronotom:
            thoracicSectionsButton.setTitle("Pronotom (1st section)", for: .normal)
            thoracicSectionsChoice(sender)
        case .mesonotum:
            thoracicSectionsButton.setTitle("Mesonotum (2nd section)", for: .normal)
            thoracicSectionsChoice(sender)
        case .metathorax:
            thoracicSectionsButton.setTitle("Metathorax (3rd section)", for: .normal)
            thoracicSectionsChoice(sender)
        }
    }
    
    @IBOutlet weak var abdomenAppendageButton: UIButton!
    @IBOutlet var abdomenAppendages: [UIButton]!
    @IBAction func abdomenAppendageChoice(_ sender: UIButton) {
        abdomenAppendages.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: { //doesnt seem to be working for this dropdown?
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    enum AbdomenAppendages: String {
        case furculum = "Furculum (looks like BBQ fork)"
        case piercing = "Piercing (e.g. wasp or bee stinger)"
        case saw = "Saw (folded into body like a pocket knife)"
        case cerci = "Grasping cerci (looks like claws or forcepts)"
        case tails0 = "Thread like 'tails' (cerci) x1"
        case tails1 = "Thread like 'tails' (cerci) x2"
        case tails2 = "Thread like 'tails' (cerci) x3"
        case brush = "Brush"
        case telson = "Telson"
    }
    @IBAction func abdomenAppendageTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let abdomenAppendage = AbdomenAppendages(rawValue: title) else {
            return
        }
        switch abdomenAppendage{
            case .furculum:
                abdomenAppendageButton.setTitle("Furculum (looks like BBQ fork)", for: .normal)
                abdomenAppendageChoice(sender)
            case .piercing:
                abdomenAppendageButton.setTitle("Piercing (e.g. wasp or bee stinger)", for: .normal)
                abdomenAppendageChoice(sender)
            case .saw:
                abdomenAppendageButton.setTitle("Saw (folded into body like a pocket knife)", for: .normal)
                abdomenAppendageChoice(sender)
            case .cerci:
                abdomenAppendageButton.setTitle("Grasping cerci (looks like claws or forcepts)", for: .normal)
                abdomenAppendageChoice(sender)
            case .tails0:
                abdomenAppendageButton.setTitle("Thread like 'tails' (cerci) x1", for: .normal)
                abdomenAppendageChoice(sender)
            case .tails1:
                abdomenAppendageButton.setTitle("Thread like 'tails' (cerci) x2", for: .normal)
                abdomenAppendageChoice(sender)
            case .tails2:
                abdomenAppendageButton.setTitle("Thread like 'tails' (cerci) x3", for: .normal)
                abdomenAppendageChoice(sender)
            case .brush:
                abdomenAppendageButton.setTitle("Brush", for: .normal)
                abdomenAppendageChoice(sender)
            case .telson:
                abdomenAppendageButton.setTitle("Telson", for: .normal)
                abdomenAppendageChoice(sender)
        }
    }
    @IBOutlet weak var sizeButton: UIButton!
    @IBOutlet var sizes: [UIButton]!
    @IBAction func sizeChoice(_ sender: UIButton) {
        sizes.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    enum Sizes: String {
        case verySmall = "Really small <5mm (can't really see with naked eye)"
        case small = "Small"
        case large = "Large"
    }
    @IBAction func sizeTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let size = Sizes(rawValue: title) else {
            return
        }
        switch size{
            case .verySmall:
                sizeButton.setTitle("Really small <5mm (can't really see with naked eye)", for: .normal)
                sizeChoice(sender)
            case .small:
                sizeButton.setTitle("Small", for: .normal)
                sizeChoice(sender)
            case .large:
                sizeButton.setTitle("Large", for: .normal)
                sizeChoice(sender)
        }
    }
}




