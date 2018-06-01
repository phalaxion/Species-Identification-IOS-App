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
    
    // Initalises the menu and sets it to not be shown
    var menuVisible = false;
    @IBOutlet weak var viewConstraint: NSLayoutConstraint!
    @IBOutlet weak var sideView: UIView!
    
    // db: Database pointer, searchResult: Prepared array for select queries
    var db: OpaquePointer?
    var searchResult : [[String]] = [[]]
    var searchBarResult : [[String]] = []
    
    // List of variables holding their corresponding drop-down menu selection
    var BodyTypeSelection = ""
    var BodyConstrictionSelection = "No"
    var LegNumSelection = ""
    var LegTypeSelection = ""
    var MoreLegSelection = ""
    var WingNumSelection = ""
    var WingTextureSelection = ""
    var AntennaeSelection = ""
    var AntennaeLengthSelection = ""
    var MouthPartsSelection = ""
    var AbdomenAppendageSelection = ""
    var AverageSizeSelection = ""
    var EyePresenceSelection = ""
    var HeadFeaturesSelection = ""
    var ElytraLengthSelection = ""
    var AntSubfamilySelection = ""
    
    @IBOutlet weak var search: UITextField!
    
    @IBAction func speciesShortlistBtn(_ sender: Any) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "ShortlistViewController") as! ShortlistViewController
        myVC.searchResultPassed = searchResult
        navigationController?.pushViewController(myVC, animated: true)
    }
    
    /*
        When the button on the search bar is pressed this
        function runs and queries the database for any species
        with a COMMON_NAME matching the input unless the input is
        empty, then the function will just return
     */
    @IBOutlet weak var searchInput: UITextField!
    @IBAction func searchBarActivate(_ sender: Any) {
        searchBarResult.removeAll()
        
        // Grab searchbar input. If its empty don't bother searching (return)
        let inputTxt: String = searchInput.text!
        
        // ToDo: Santize the input text to protect against SQL Injection
        // HERE
        
        var stmt: OpaquePointer?
        let searchQuery = "SELECT * FROM INVERTEBRATES WHERE COMMON_NAME LIKE '%\(inputTxt)%';"
        //print(searchQuery)
        
        if sqlite3_prepare_v2(db, searchQuery, -1, &stmt, nil)  != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Searchbar Query Failed!: \(errmsg)")
            return
        }
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            var tmp : [String] = []
            for i in 1...29 {
                tmp.append(String(cString: sqlite3_column_text(stmt, Int32(i))))
            }
            searchBarResult.append(tmp)
        }
        //print(searchBarResult)
        sqlite3_finalize(stmt)
        
        let myVC = storyboard?.instantiateViewController(withIdentifier: "ShortlistViewController") as! ShortlistViewController
        myVC.searchResultPassed = searchBarResult
        navigationController?.pushViewController(myVC, animated: true)
    }
    
    /*
        Find the database called "SIG.sqlite" if it does not exist
        create a new database under that name. Then drop the invertebrates
        table if it exists. Then recreate the invertebrates table.
     */
    func createTable(){
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("SIG.sqlite")
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error Opening Database!")
        }
        
        let initalDrop = "DROP TABLE IF EXISTS INVERTEBRATES;"
        
        if sqlite3_exec(db, initalDrop, nil, nil, nil) != SQLITE_OK {
            print("Error Dropping Table!")
            return
        } else {
            //print("Table Dropped Successfully")
        }
        
        let createTableQuery = """
        CREATE TABLE INVERTEBRATES (
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        COMMON_NAME VARCHAR(40),
        SPECIES_NAME VARCHAR(40),
        MORPHO_SPECIES_NAME VARCAHR(40),
        BODY_TYPE VARCHAR(30),
        BODY_CONSTRICTION VARCHAR(30),
        LEG_NUM VARCHAR(30),
        LEG_TYPE VARCHAR(30),
        GREATER_THAN_EIGHT_LEGS VARCHAR(30),
        WING_NUM VARCHAR(30),
        WING_TEXTURE VARCHAR(30),
        ANTENNAE VARCHAR(30),
        ANTENNAE_LENGTH VARCHAR(30),
        MOUTH_PARTS VARCHAR(30),
        ABDOMEN_APPENDAGE VARCHAR(30),
        SIZE VARCHAR(20),
        EYE_PRESENCE VARCHAR(30),
        HEAD_SHAPE_FEATURES VARCHAR(30),
        LENGTH_OF_ELYTRA VARCHAR(30),
        ANT_SUBFAMILY_CRITERIA VARCHAR(30),
        PHYLUM VARCHAR(30),
        SUBPHYLUM VARCHAR(30),
        CLASS VARCHAR(30),
        SUBCLASS VARCHAR(30),
        SUPERORDER VARCHAR(30),
        `ORDER` VARCHAR(30),
        SUBORDER VARCHAR(30),
        SUPERFAMILY VARCHAR(30),
        FAMILY VARCHAR(30),
        SUBFAMILY VARCHAR(30));
        """
        
        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error Creating Table!")
            return
        } else {
            //print("Database is Working!")
        }
        
    }
    
    /*
        Creates a connection to the csv file "invertebrates.csv" and
        imports all rows contained except the header row. Each row
        is then inserted into the database.
     */
    func importCSV() {
        // CSV Import Handler
        let csvPath = Bundle.main.path(forResource: "invertebrates", ofType: "csv")!
        let stream = InputStream(fileAtPath: csvPath)!
        let csv = try! CSVReader(stream: stream, hasHeaderRow: true)
        
        var insertQuery = ""
        while let row = csv.next() {
            insertQuery = """
            INSERT INTO INVERTEBRATES (
            COMMON_NAME, SPECIES_NAME, MORPHO_SPECIES_NAME, BODY_TYPE, BODY_CONSTRICTION,  LEG_NUM, LEG_TYPE, GREATER_THAN_EIGHT_LEGS, WING_NUM, WING_TEXTURE,  ANTENNAE, ANTENNAE_LENGTH, MOUTH_PARTS, ABDOMEN_APPENDAGE, SIZE, EYE_PRESENCE, HEAD_SHAPE_FEATURES, LENGTH_OF_ELYTRA, ANT_SUBFAMILY_CRITERIA, PHYLUM, SUBPHYLUM, CLASS, SUBCLASS, SUPERORDER, `ORDER`, SUBORDER, SUPERFAMILY, FAMILY, SUBFAMILY
            )
            VALUES
            (
            '\(row[0])', '\(row[1])', '\(row[2])', '\(row[3])', '\(row[4])', '\(row[5])', '\(row[6])', '\(row[7])', '\(row[8])', '\(row[9])', '\(row[10])', '\(row[11])', '\(row[12])', '\(row[13])', '\(row[14])', '\(row[15])', '\(row[16])', '\(row[17])', '\(row[18])', '\(row[19])', '\(row[20])', '\(row[21])', '\(row[22])', '\(row[23])', '\(row[24])', '\(row[25])', '\(row[26])', '\(row[27])', '\(row[28])'
            );
            """
            //print(insertQuery)
            
            if sqlite3_exec(db, insertQuery, nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Row Insert Failed!: \(errmsg)")
                return
            } else {
                //print("Row Inserted Successfully!")
            }
        }
    }
    
    /*
        The main search system for the appliation, taking input from the drop-down
        menu selections and creating a query that only returns results that
        fit the selected criteria
     */
    func autoQuery() {
        searchResult.removeAll()
        
        // A query that is updated by drop-down options being selected
        let mainQuery = """
        SELECT * FROM INVERTEBRATES
        WHERE BODY_TYPE LIKE '%\(BodyTypeSelection)%'
        AND BODY_CONSTRICTION LIKE '%\(BodyConstrictionSelection)%'
        AND LEG_NUM LIKE '%\(LegNumSelection)%'
        AND LEG_TYPE LIKE '%\(LegTypeSelection)%'
        AND GREATER_THAN_EIGHT_LEGS LIKE '%\(MoreLegSelection)%'
        AND WING_NUM LIKE '%\(WingNumSelection)%'
        AND WING_TEXTURE LIKE '%\(WingTextureSelection)%'
        AND ANTENNAE LIKE '%\(AntennaeSelection)%'
        AND ANTENNAE_LENGTH LIKE '%\(AntennaeLengthSelection)%'
        AND MOUTH_PARTS LIKE '%\(MouthPartsSelection)%'
        AND ABDOMEN_APPENDAGE LIKE '%\(AbdomenAppendageSelection)%'
        AND SIZE LIKE '%\(AverageSizeSelection)%';
        AND EYE_PRESENCE LIKE '%\(EyePresenceSelection)%'
        AND HEAD_SHAPE_FEATURES LIKE '%\(HeadFeaturesSelection)%'
        AND LENGTH_OF_ELYTRA LIKE '%\(ElytraLengthSelection)%'
        AND ANT_SUBFAMILY_CRITERIA LIKE '%\(AntSubfamilySelection)%';
        """
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, mainQuery, -1, &stmt, nil)  != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Global Query Failed!: \(errmsg)")
            return
        }
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            var tmp : [String] = []
            for i in 1...29 {
                tmp.append(String(cString: sqlite3_column_text(stmt, Int32(i))))
            }
            searchResult.append(tmp)
        }
        //print(searchResult)
        sqlite3_finalize(stmt)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        search.setPadding(10)
        viewConstraint.constant = -310
        
        self.hideKeyboardWhenTappedAround()
        
        createTable()
        importCSV()
        autoQuery()
    }
    
    /*
        A function that detects if any swipes are performed on the horizontal axis
        If so then the menu is dragged out. Once it reaches the designated x value
        it will fully emerage regardless of swipe activity
     */
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
    
    /*
        Secondary method to opening the menu through the nav button.
        Simple button toggle (open, closed)
     */
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
    
    //-----Characteristic Group Menus-----//
    @IBOutlet var bodySubMenuItems: [UIStackView]!
    @IBAction func bodySubMenus(_ sender: Any) {
        print("unhide")
        bodySubMenuItems.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBOutlet var legSubMenuItems: [UIStackView]!
    @IBAction func legSubMenus(_ sender: UIButton) {
        print("unhide")
        legSubMenuItems.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBOutlet var wingSubMenuItems: [UIStackView]!
    
    @IBAction func wingSubMenus(_ sender: UIButton) {
        print("unhide")
        wingSubMenuItems.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    @IBOutlet var antennaeSubMenuItems: [UIStackView]!
    @IBAction func antennaeSubMenus(_ sender: UIButton) {
        print("unhide")
        antennaeSubMenuItems.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    //-----Characteristic Submenus-----//
    //Cases must be exactly the same as the button in storyboard
    
    // BODY TYPE
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
    }
    @IBAction func bodyTypeTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let bodyType = BodyTypes(rawValue: title) else {
            return
        }
        BodyTypeSelection = title // Sets global variable to the current menu selection
        autoQuery() // Runs the update query for species shortlist
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
        }
    }
    
    // BODY CONSTRICTION
    @IBOutlet weak var abdomenThoraxConstriction: UIButton!
    var count = 0
    @IBAction func abdomenThoraxConstrictionButton(_ sender: Any) {
        count = count + 1
        if (count%2 == 1){
            abdomenThoraxConstriction.setTitle("Constriction Between Thorax and Abdomen", for: .normal)
            BodyConstrictionSelection = "Yes" // Sets global variable to the current menu selection
            autoQuery() // Runs the update query for species shortlist
        }
        else {
            abdomenThoraxConstriction.setTitle("No Constriction Between Thorax and Abdomen", for: .normal)
            BodyConstrictionSelection = "No" // Sets global variable to the current menu selection
            autoQuery() // Runs the update query for species shortlist
        }
    }
    
    // LEG NUMBER
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
        LegNumSelection = title // Sets global variable to the current menu selection
        autoQuery() // Runs the update query for species shortlist
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
    
    // LEG TYPE
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
        case na = "N/A"
        case jumpingHind = "Strong jumping hind legs"
        case raptorial = "Raptorial"
        case digging = "Front Legs flattened for digging"
    }
    @IBAction func legTypeTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let legType = LegTypes(rawValue: title) else {
            return
        }
        LegTypeSelection = title // Sets global variable to the current menu selection
        autoQuery() // Runs the update query for species shortlist
        switch legType{
        case .na:
            legTypeButton.setTitle("N/A", for: .normal)
            legTypeChoice(sender)
        case .jumpingHind:
            legTypeButton.setTitle("Strong jumping hind legs", for: .normal)
            legTypeChoice(sender)
        case .raptorial:
            legTypeButton.setTitle("Raptorial", for: .normal)
            legTypeChoice(sender)
        case .digging:
            legTypeButton.setTitle("Front Legs flattened for digging", for: .normal)
            legTypeChoice(sender)
        }
    }
    
    // WING NUMBER
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
        case elytra = "2 Wings (+ elytra)"
        case hemelytra = "2 Wings (+ hemelytra)"
        case halteres = "2 Wings (+ halteres)"
    }
    @IBAction func numWingsTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let numWing = NumWings(rawValue: title) else {
            return
        }
        WingNumSelection = title // Sets global variable to the current menu selection
        autoQuery() // Runs the update query for species shortlist
        switch numWing{
        case .none:
            numWingsButton.setTitle("No Wings", for: .normal)
            numWingsChoice(sender)
        case .elytra:
            numWingsButton.setTitle("2 Wings (+ elytra)", for: .normal)
            numWingsChoice(sender)
        case .hemelytra:
            numWingsButton.setTitle("2 Wings (+ hemelytra)", for: .normal)
            numWingsChoice(sender)
        case .halteres:
            numWingsButton.setTitle("2 Wings (+ halteres)", for: .normal)
            numWingsChoice(sender)
        }
    }
    
    // WING TEXTURE
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
        case hairy = "Hairy"
        case scaly = "Scaly and Patterned"
        case membranous1 = "Complex vein pattern"
        case membranous2 = "Simple vein pattern"
    }
    @IBAction func wingTextureTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let wingTexture = WingTextures(rawValue: title) else {
            return
        }
        WingTextureSelection = title // Sets global variable to the current menu selection
        autoQuery() // Runs the update query for species shortlist
        switch wingTexture{
        case .hairy:
            wingTextureButton.setTitle("Hairy", for: .normal)
            wingTextureChoice(sender)
        case .scaly:
            wingTextureButton.setTitle("Scaly and Patterned)", for: .normal)
            wingTextureChoice(sender)
        case .membranous1:
            wingTextureButton.setTitle("Complex vein pattern", for: .normal)
            wingTextureChoice(sender)
        case .membranous2:
            wingTextureButton.setTitle("Simple vein pattern", for: .normal)
            wingTextureChoice(sender)
        }
    }
    
    // ANTENNAE TYPE
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
        case fileform = "Filiform"
        case beadlike = "Bead-like"
        case longFirst = "Long first segment"
        case biramous = "Biramous"
        case clubbed = "Clubbed"
    }
    @IBAction func antannaeTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let antennae = Antennae(rawValue: title) else {
            return
        }
        AntennaeSelection = title // Sets global variable to the current menu selection
        autoQuery() // Runs the update query for species shortlist
        switch antennae{
        case .fileform:
            antennaeButton.setTitle("Filiform", for: .normal)
            antennaeChoice(sender)
        case .beadlike:
            antennaeButton.setTitle("Bead-like", for: .normal)
            antennaeChoice(sender)
        case .longFirst:
            antennaeButton.setTitle("Long first segment", for: .normal)
            antennaeChoice(sender)
        case .biramous:
            antennaeButton.setTitle("Biramous", for: .normal)
            antennaeChoice(sender)
        case .clubbed:
            antennaeButton.setTitle("Clubbed", for: .normal)
            antennaeChoice(sender)
        }
    }
    
    // ANTENNAE LENGTH
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
        case none = "No antenna"
        case short = "Short"
        case long = "Long First Segment"
    }
    @IBAction func antennaLengthTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let antennaLength = AntennaLengths(rawValue: title) else {
            return
        }
        AntennaeLengthSelection = title // Sets global variable to the current menu selection
        autoQuery() // Runs the update query for species shortlist
        switch antennaLength{
        case .none:
            antennaLengthButton.setTitle("No antenna", for: .normal)
            antennaLengthChoice(sender)
        case .short:
            antennaLengthButton.setTitle("Short", for: .normal)
            antennaLengthChoice(sender)
        case .long:
            antennaLengthButton.setTitle("Long First Segment", for: .normal)
            antennaLengthChoice(sender)
        }
    }
    
    //  MOUTH PARTS
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
        case chewing = "Chewing"
        case piercing = "Piercing or Sucking"
        case enclosed = "Enclosed / Not visible"
    }
    @IBAction func mouthPartsTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let mouthPart = MouthParts(rawValue: title) else {
            return
        }
        MouthPartsSelection = title // Sets global variable to the current menu selection
        autoQuery() // Runs the update query for species shortlist
        switch mouthPart{
        case .chewing:
            mouthPartsButton.setTitle("Chewing", for: .normal)
            mouthPartsChoice(sender)
        case .piercing:
            mouthPartsButton.setTitle("Piercing or Sucking ", for: .normal)
            mouthPartsChoice(sender)
        case .enclosed:
            mouthPartsButton.setTitle("Enclosed / Not visible", for: .normal)
            mouthPartsChoice(sender)
        }
    }
    
    // ABDOMEN APPENDAGE
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
        case furculum = "Furculum"
        case piercing = "Piercing"
        case cerci = "2 Grasping Cerci"
        case tails1 = "2 Tail-like Cerci"
        case tails2 = "3 Tail-like Cerci"
        case telson = "Telson"
    }
    @IBAction func abdomenAppendageTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let abdomenAppendage = AbdomenAppendages(rawValue: title) else {
            return
        }
        AbdomenAppendageSelection = title // Sets global variable to the current menu selection
        autoQuery() // Runs the update query for species shortlist
        switch abdomenAppendage{
            case .furculum:
                abdomenAppendageButton.setTitle("Furculum", for: .normal)
                abdomenAppendageChoice(sender)
            case .piercing:
                abdomenAppendageButton.setTitle("Piercing", for: .normal)
                abdomenAppendageChoice(sender)
            case .cerci:
                abdomenAppendageButton.setTitle("2 Grasping Cerci", for: .normal)
                abdomenAppendageChoice(sender)
            case .tails1:
                abdomenAppendageButton.setTitle("2 Tail-like Cerci", for: .normal)
                abdomenAppendageChoice(sender)
            case .tails2:
                abdomenAppendageButton.setTitle("3 Tail-like Cerci", for: .normal)
                abdomenAppendageChoice(sender)
            case .telson:
                abdomenAppendageButton.setTitle("Telson", for: .normal)
                abdomenAppendageChoice(sender)
        }
    }
    
    // SIZE
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
        case verySmall = "Really small"
        case small = "Small"
        case large = "Large"
    }
    @IBAction func sizeTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let size = Sizes(rawValue: title) else {
            return
        }
        AverageSizeSelection = title // Sets global variable to the current menu selection
        autoQuery() // Runs the update query for species shortlist
        switch size{
            case .verySmall:
                sizeButton.setTitle("Really small", for: .normal)
                sizeChoice(sender)
            case .small:
                sizeButton.setTitle("Small", for: .normal)
                sizeChoice(sender)
            case .large:
                sizeButton.setTitle("Large", for: .normal)
                sizeChoice(sender)
        }
    }
    
    // EYES
    @IBOutlet weak var hasEyes: UIButton!
    var count1 = 1
    @IBAction func eyesButton(_ sender: Any) {
        count1 = count1 + 1
        if (count1%2 == 1){
            hasEyes.setTitle("Has Eyes", for: .normal)
        }
        else {
            hasEyes.setTitle("No Eyes or Extremely Reduced", for: .normal)
        }
    }
    
    // ELYTRA LENGTH
    @IBOutlet weak var elytraLength: UIButton!
    var count2 = 1
    @IBAction func elytraButton(_ sender: Any) {
        count2 = count2 + 1
        if (count2%2 == 1){
            elytraLength.setTitle("Short Elytra", for: .normal)
        }
        else {
            elytraLength.setTitle("Long Elytra", for: .normal)
        }
    }
    
    //ANT SUBFAMILY
    @IBOutlet weak var subFamilyButton: UIButton!
    @IBOutlet var subFamilies: [UIButton]!
    @IBAction func subFamilyChoice(_ sender: UIButton){
        subFamilies.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    enum Families: String {
        case dolichoderinae = "Dolichoderinae"
        case formicinae = "Formicinae"
        case ecatomminae = "Ecatomminae"
        case ponerinae = "Ponerinae"
        case myrmeciinae = "Myrmeciinae"
        case myrmicinae = "Myrmicinae"
        case dorylinae = "Dorylinae"
    }
    
    @IBAction func subFamilyTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let fam = Families(rawValue: title) else {
            return
        }
        switch fam{
        case .dolichoderinae:
            subFamilyButton.setTitle("Dolichoderinae", for: .normal)
            subFamilyChoice(sender)
        case .formicinae:
            subFamilyButton.setTitle("Formicinae", for: .normal)
            subFamilyChoice(sender)
        case .ecatomminae:
            subFamilyButton.setTitle("Ecatomminae", for: .normal)
            subFamilyChoice(sender)
        case .ponerinae:
            subFamilyButton.setTitle("Ponerinae", for: .normal)
            subFamilyChoice(sender)
        case .myrmeciinae:
            subFamilyButton.setTitle("Myrmeciinae", for: .normal)
            subFamilyChoice(sender)
        case .myrmicinae:
            subFamilyButton.setTitle("Myrmicinae", for: .normal)
            subFamilyChoice(sender)
        case .dorylinae:
            subFamilyButton.setTitle("Dorylinae", for: .normal)
            subFamilyChoice(sender)
        }
    }
}




