//
//  ViewController.swift
//  Species Identification Guide
//
//  Created by David Rosetti on 4/30/18.
//  Copyright © 2018 David Rosetti. All rights reserved.
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
    var menuVisible = true;
    @IBOutlet weak var viewConstraint: NSLayoutConstraint!
    @IBOutlet weak var sideView: UIView!
    
    // db: Database pointer, searchResult: Prepared array for select queries
    var db: OpaquePointer?
    var searchResult : [[String]] = [[]]
    var searchBarResult : [[String]] = []
    var headers : [String] = []
    
    // List of variables holding their corresponding drop-down menu selection
    var BodyTypeSelection = ""
    var BodyConstrictionSelection = ""
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
    @IBOutlet weak var speciesShortlistLabel: UIButton!
    
    @IBAction func speciesShortlistBtn(_ sender: Any) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "ShortlistViewController") as! ShortlistViewController
        myVC.searchResultPassed = searchResult
        myVC.headersTMP = headers
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
        
        // Grab searchbar input.
        let inputTxt: String = searchInput.text!
        
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
        sqlite3_finalize(stmt)
        //print(searchBarResult)
        
        
        let myVC = storyboard?.instantiateViewController(withIdentifier: "ShortlistViewController") as! ShortlistViewController
        myVC.searchResultPassed = searchBarResult
        myVC.headersTMP = headers
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
        }
        
        let createTableQuery = """
        CREATE TABLE INVERTEBRATES (
        `ID` INTEGER PRIMARY KEY AUTOINCREMENT,
        `COMMON_NAME` VARCHAR(40),
        `SPECIES_NAME` VARCHAR(40),
        `MORPHO_SPECIES_NAME` VARCAHR(40),
        `BODY_TYPE` VARCHAR(30),
        `BODY_CONSTRICTION` VARCHAR(30),
        `LEG_NUM` VARCHAR(30),
        `LEG_TYPE` VARCHAR(30),
        `GREATER_THAN_EIGHT_LEGS` VARCHAR(30),
        `WING_NUM` VARCHAR(30),
        `WING_TEXTURE` VARCHAR(30),
        `ANTENNAE` VARCHAR(30),
        `ANTENNAE_LENGTH` VARCHAR(30),
        `MOUTH_PARTS` VARCHAR(30),
        `ABDOMEN_APPENDAGE` VARCHAR(30),
        `SIZE` VARCHAR(20),
        `EYE_PRESENCE` VARCHAR(30),
        `HEAD_SHAPE_FEATURES` VARCHAR(30),
        `LENGTH_OF_ELYTRA` VARCHAR(30),
        `ANT_SUBFAMILY_CRITERIA` VARCHAR(30),
        `PHYLUM` VARCHAR(30),
        `SUBPHYLUM` VARCHAR(30),
        `CLASS` VARCHAR(30),
        `SUBCLASS` VARCHAR(30),
        `SUPERORDER` VARCHAR(30),
        `ORDER` VARCHAR(30),
        `SUBORDER` VARCHAR(30),
        `SUPERFAMILY` VARCHAR(30),
        `FAMILY` VARCHAR(30),
        `SUBFAMILY` VARCHAR(30));
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
        
        headers = csv.headerRow!
        
        var insertQuery = ""
        while let row = csv.next() {
            insertQuery = """
            INSERT INTO INVERTEBRATES (
            `COMMON_NAME`, `SPECIES_NAME`, `MORPHO_SPECIES_NAME`, `BODY_TYPE`, `BODY_CONSTRICTION`,  `LEG_NUM`, `LEG_TYPE`, `GREATER_THAN_EIGHT_LEGS`, `WING_NUM`, `WING_TEXTURE`,  `ANTENNAE`, `ANTENNAE_LENGTH`, `MOUTH_PARTS`, `ABDOMEN_APPENDAGE`, `SIZE`, `EYE_PRESENCE`, `HEAD_SHAPE_FEATURES`, `LENGTH_OF_ELYTRA`, `ANT_SUBFAMILY_CRITERIA`, `PHYLUM`, `SUBPHYLUM`, `CLASS`, `SUBCLASS`, `SUPERORDER`, `ORDER`, `SUBORDER`, `SUPERFAMILY`, `FAMILY`, `SUBFAMILY`
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
        AND SIZE LIKE '%\(AverageSizeSelection)%'
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
        
        speciesShortlistLabel.setTitle("Species Shortlist (\(searchResult.count))", for: .normal)
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
    //-----Characteristic Menu Groupings-----//
    //Body
    @IBOutlet var Bodys: [UIStackView]!
    @IBAction func BodySelection(_ sender: UIButton) { // Dropdown header selected
        Bodys.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    //Head
    @IBOutlet var Heads: [UIStackView]!
    @IBAction func HeadSelection(_ sender: UIButton) { // Dropdown header selected
        Heads.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    //Legs
    @IBOutlet var Legs: [UIStackView]!
    @IBAction func LegSelection(_ sender: UIButton) { // Dropdown header selected
        Legs.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    //Wings
    @IBOutlet var Wings: [UIStackView]!
    @IBAction func WingSelection(_ sender: UIButton) { // Dropdown header selected
        Wings.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    //AntennaeGroup
    @IBOutlet var AntennaeGroups: [UIStackView]!
    @IBAction func AntennaeGroupSelection(_ sender: UIButton) { // Dropdown header selected
        AntennaeGroups.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    
    //-----Characteristic Submenus-----//
    //Cases must be exactly the same as the button in storyboard
    
    //Body Type
    @IBOutlet weak var BodyTypeButton: UIButton! //The Title of the Dropdown
    @IBOutlet var BodyTypes: [UIButton]! //All of the Dropdown Options
    @IBAction func BodyTypeSelection(_ sender: UIButton) { // Dropdown header selected
        BodyTypes.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    enum BodyTypeOptions: String { //Dropdown Option Names
        case soft = "Soft Body"
        case shell = "Shell"
        case exo = "Tough Exoskeleton"
    }
    @IBAction func BodyTypeTapped(_ sender: UIButton) { //all dropdown options
        guard let title = sender.currentTitle, let bodyType = BodyTypeOptions(rawValue: title) else {
            return
        }
        BodyTypeSelection = title
        autoQuery()
        switch bodyType { //cases for each option
        case .soft:
            BodyTypeButton.setTitle("Soft Body", for: .normal)
            BodyTypeSelection(sender)
        case .shell:
            BodyTypeButton.setTitle("Shell", for: .normal)
            BodyTypeSelection(sender)
        case .exo:
            BodyTypeButton.setTitle("Tough Exoskeleton", for: .normal)
            BodyTypeSelection(sender)
        }
    }
    
    //Body Constriction
    @IBOutlet weak var BodyConstrictionButton: UIButton! //The Title of the Dropdown
    @IBOutlet var BodyConstrictions: [UIButton]! //All of the Dropdown Options
    @IBAction func BodyConstrictionSelection(_ sender: UIButton) { // Dropdown header selected
        BodyConstrictions.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    enum BodyConstrictionOptions: String { //Dropdown Option Names
        case no = "No"
        case yes = "Yes"
    }
    @IBAction func BodyConstrictionTapped(_ sender: UIButton) { //all dropdown options
        guard let title = sender.currentTitle, let BodyConstriction = BodyConstrictionOptions(rawValue: title) else { //Make enum list
            return
        }
        BodyConstrictionSelection = title
        autoQuery()
        switch BodyConstriction { //cases for each option
        case .no:
            BodyConstrictionButton.setTitle("No", for: .normal)
            BodyConstrictionSelection(sender)
        case .yes:
            BodyConstrictionButton.setTitle("Yes", for: .normal)
            BodyConstrictionSelection(sender)
        }
    }
    
    //Leg Number
    @IBOutlet weak var LegNumberButton: UIButton! //The Title of the Dropdown
    @IBOutlet var LegNumbers: [UIButton]! //All of the Dropdown Options
    @IBAction func LegNumberSelection(_ sender: UIButton) { // Dropdown header selected
        LegNumbers.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    enum LegNumberOptions: String { //Dropdown Option Names
        case zero = "0"
        case six = "6"
        case eight = "8"
        case morethaneight = ">8"
    }
    @IBAction func LegNumberTapped(_ sender: UIButton) { //all dropdown options
        guard let title = sender.currentTitle, let LegNumber = LegNumberOptions(rawValue: title) else { //Make enum list
            return
        }
        LegNumSelection = title
        autoQuery()
        switch LegNumber { //cases for each option
        case .zero:
            LegNumberButton.setTitle("0", for: .normal)
            LegNumberSelection(sender)
        case .six:
            LegNumberButton.setTitle("6", for: .normal)
            LegNumberSelection(sender)
        case .eight:
            LegNumberButton.setTitle("8", for: .normal)
            LegNumberSelection(sender)
        case .morethaneight:
            LegNumberButton.setTitle(">8", for: .normal)
            LegNumberSelection(sender)
        }
    }
    
    //Leg Type
    @IBOutlet weak var LegTypeButton: UIButton! //The Title of the Dropdown
    @IBOutlet var LegTypes: [UIButton]! //All of the Dropdown Options
    @IBAction func LegTypeSelection(_ sender: UIButton) { // Dropdown header selected
        LegTypes.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    enum LegTypeOptions: String { //Dropdown Option Names
        case none = "No special features or no legs"
        case jump = "Strong jumping hind legs"
        case raptor = "Raptorial"
        case digging = "Front legs flattened for digging"
    }
    @IBAction func LegTypeTapped(_ sender: UIButton) { //all dropdown options
        guard let title = sender.currentTitle, let LegType = LegTypeOptions(rawValue: title) else { //Make enum list
            return
        }
        LegTypeSelection = title
        autoQuery()
        switch LegType { //cases for each option
        case .none:
            LegTypeButton.setTitle("No special features or no legs", for: .normal)
            LegTypeSelection(sender)
        case .jump:
            LegTypeButton.setTitle("Strong jumping hind legs", for: .normal)
            LegTypeSelection(sender)
        case .raptor:
            LegTypeButton.setTitle("Raptorial", for: .normal)
            LegTypeSelection(sender)
        case .digging:
            LegTypeButton.setTitle("Front legs flattened for digging", for: .normal)
            LegTypeSelection(sender)
        }
    }
    
    //More than 8 Legs
    @IBOutlet weak var MoreLegButton: UIButton! //The Title of the Dropdown
    @IBOutlet var MoreLegs: [UIButton]! //All of the Dropdown Options
    @IBAction func MoreLegSelection(_ sender: UIButton) { // Dropdown header selected
        MoreLegs.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    enum MoreLegOptions: String { //Dropdown Option Names
        case one = "1 pair per segment"
        case two = "2 pairs per segment"
    }
    @IBAction func MoreLegTapped(_ sender: UIButton) { //all dropdown options
        guard let title = sender.currentTitle, let MoreLeg = MoreLegOptions(rawValue: title) else { //Make enum list
            return
        }
        MoreLegSelection = title
        autoQuery()
        switch MoreLeg { //cases for each option
        case .one:
            MoreLegButton.setTitle("1 pair per segment", for: .normal)
            MoreLegSelection(sender)
        case .two:
            MoreLegButton.setTitle("2 pairs per segment", for: .normal)
            MoreLegSelection(sender)
        }
    }
    
    //Wing Number
    @IBOutlet weak var WingNumButton: UIButton! //The Title of the Dropdown
    @IBOutlet var WingNums: [UIButton]! //All of the Dropdown Options
    @IBAction func WingNumSelection(_ sender: UIButton) { // Dropdown header selected
        WingNums.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    enum WingNumOptions: String { //Dropdown Option Names
        case none = "0"
        case four = "4"
        case elytra = "2 + elytra"
        case hemelytra = "2 + hemelytra"
        case halteres = "2 + halteres"
    }
    @IBAction func WingNumTapped(_ sender: UIButton) { //all dropdown options
        guard let title = sender.currentTitle, let WingNum = WingNumOptions(rawValue: title) else { //Make enum list
            return
        }
        WingNumSelection = title
        autoQuery()
        switch WingNum { //cases for each option
        case .none:
            WingNumButton.setTitle("0", for: .normal)
            WingNumSelection(sender)
        case .four:
            WingNumButton.setTitle("4", for: .normal)
            WingNumSelection(sender)
        case .elytra:
            WingNumButton.setTitle("2 + elytra", for: .normal)
            WingNumSelection(sender)
        case .hemelytra:
            WingNumButton.setTitle("2 + hemelytra", for: .normal)
            WingNumSelection(sender)
        case .halteres:
            WingNumButton.setTitle("2 + halteres", for: .normal)
            WingNumSelection(sender)
        }
    }
    
    //Wing Texture
    @IBOutlet weak var WingTextureButton: UIButton! //The Title of the Dropdown
    @IBOutlet var WingTextures: [UIButton]! //All of the Dropdown Options
    @IBAction func WingTextureSelection(_ sender: UIButton) { // Dropdown header selected
        WingTextures.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    enum WingTextureOptions: String { //Dropdown Option Names
        case none = "No wings"
        case scaly = "Scaly and patterned"
        case complex = "Membraneous, complex"
        case simple = "Membraneous, simple"
        case hairy = "Hairy"
    }
    @IBAction func WingTextureTapped(_ sender: UIButton) { //all dropdown options
        guard let title = sender.currentTitle, let WingTexture = WingTextureOptions(rawValue: title) else { //Make enum list
            return
        }
        WingTextureSelection = title
        autoQuery()
        switch WingTexture { //cases for each option
        case .none:
            WingTextureButton.setTitle("No wings", for: .normal)
            WingTextureSelection(sender)
        case .scaly:
            WingTextureButton.setTitle("Scaly and patterned", for: .normal)
            WingTextureSelection(sender)
        case .simple:
            WingTextureButton.setTitle("Membraneous, complex", for: .normal)
            WingTextureSelection(sender)
        case .complex:
            WingTextureButton.setTitle("Membraneous, simple", for: .normal)
            WingTextureSelection(sender)
        case .hairy:
            WingTextureButton.setTitle("Hairy", for: .normal)
            WingTextureSelection(sender)
        }
    }
    
    //Antennae
    @IBOutlet weak var AntennaeButton: UIButton! //The Title of the Dropdown
    @IBOutlet var Antennaes: [UIButton]! //All of the Dropdown Options
    @IBAction func AntennaeSelection(_ sender: UIButton) { // Dropdown header selected
        Antennaes.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    enum AntennaeOptions: String { //Dropdown Option Names
        case absent = "Absent"
        case filiform = "Filiform"
        case bead = "Bead-like"
        case long = "Long first segment"
        case club = "Club at the end"
        case biramous = "Biramous"
    }
    @IBAction func AntennaeTapped(_ sender: UIButton) { //all dropdown options
        guard let title = sender.currentTitle, let Antennae = AntennaeOptions(rawValue: title) else { //Make enum list
            return
        }
        AntennaeSelection = title
        autoQuery()
        switch Antennae { //cases for each option
        case .absent:
            AntennaeButton.setTitle("Absent", for: .normal)
            AntennaeSelection(sender)
        case .filiform:
            AntennaeButton.setTitle("Filiform", for: .normal)
            AntennaeSelection(sender)
        case .bead:
            AntennaeButton.setTitle("Bead-like", for: .normal)
            AntennaeSelection(sender)
        case .long:
            AntennaeButton.setTitle("Long first segment", for: .normal)
            AntennaeSelection(sender)
        case .club:
            AntennaeButton.setTitle("Club at the end", for: .normal)
            AntennaeSelection(sender)
        case .biramous:
            AntennaeButton.setTitle("Biramous", for: .normal)
            AntennaeSelection(sender)
        }
    }
    
    //Antennae Length
    @IBOutlet weak var AntennaeLengthButton: UIButton! //The Title of the Dropdown
    @IBOutlet var AntennaeLengths: [UIButton]! //All of the Dropdown Options
    @IBAction func AntennaeLengthSelection(_ sender: UIButton) { // Dropdown header selected
        AntennaeLengths.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    enum AntennaeLengthOptions: String { //Dropdown Option Names
        case none = "No antennae"
        case short = "Short"
        case medium = "Medium"
        case long = "Long"
    }
    @IBAction func AntennaeLengthTapped(_ sender: UIButton) { //all dropdown options
        guard let title = sender.currentTitle, let AntennaeLength = AntennaeLengthOptions(rawValue: title) else { //Make enum list
            return
        }
        AntennaeLengthSelection = title
        autoQuery()
        switch AntennaeLength { //cases for each option
        case .none:
            AntennaeLengthButton.setTitle("No antennae", for: .normal)
            AntennaeLengthSelection(sender)
        case .short:
            AntennaeLengthButton.setTitle("Short", for: .normal)
            AntennaeLengthSelection(sender)
        case .medium:
            AntennaeLengthButton.setTitle("Medium", for: .normal)
            AntennaeLengthSelection(sender)
        case .long:
            AntennaeLengthButton.setTitle("Long", for: .normal)
            AntennaeLengthSelection(sender)
        }
    }
    
    //Mouth Parts
    @IBOutlet weak var MouthPartButton: UIButton! //The Title of the Dropdown
    @IBOutlet var MouthParts: [UIButton]! //All of the Dropdown Options
    @IBAction func MouthPartSelection(_ sender: UIButton) { // Dropdown header selected
        MouthParts.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    enum MouthPartOptions: String { //Dropdown Option Names
        case chewing = "Chewing"
        case suck = "Piercing or sucking"
        case enclosed = "Enclosed/not visible"
    }
    @IBAction func MouthPartTapped(_ sender: UIButton) { //all dropdown options
        guard let title = sender.currentTitle, let MouthPart = MouthPartOptions(rawValue: title) else { //Make enum list
            return
        }
        MouthPartsSelection = title
        autoQuery()
        switch MouthPart { //cases for each option
        case .chewing:
            MouthPartButton.setTitle("Chewing", for: .normal)
            MouthPartSelection(sender)
        case .suck:
            MouthPartButton.setTitle("Piercing or sucking", for: .normal)
            MouthPartSelection(sender)
        case .enclosed:
            MouthPartButton.setTitle("Enclosed/not visible", for: .normal)
            MouthPartSelection(sender)
        }
    }
    
    //Abdomen Appendage
    @IBOutlet weak var AbdomenAppendageButton: UIButton! //The Title of the Dropdown
    @IBOutlet var AbdomenAppendages: [UIButton]! //All of the Dropdown Options
    @IBAction func AbdomenAppendageSelection(_ sender: UIButton) { // Dropdown header selected
        AbdomenAppendages.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    enum AbdomenAppendageOptions: String { //Dropdown Option Names
        case none = "Absent"
        case furculum = "Raptorial Furculum"
        case piercing = "Raptorial Piercing"
        case grasping = "2 Grasping cerci"
        case twotailcerci = "2 Tail-like cerci"
        case threetailcerci = "3 Tail-like cerci"
        case telson = "Raptorial Telson"
    }
    @IBAction func AbdomenAppendageTapped(_ sender: UIButton) { //all dropdown options
        guard let title = sender.currentTitle, let AbdomenAppendage = AbdomenAppendageOptions(rawValue: title) else { //Make enum list
            return
        }
        AbdomenAppendageSelection = title
        autoQuery()
        switch AbdomenAppendage { //cases for each option
        case .none:
            AbdomenAppendageButton.setTitle("Absent", for: .normal)
            AbdomenAppendageSelection(sender)
        case .furculum:
            AbdomenAppendageButton.setTitle("Raptorial Furculum", for: .normal)
            AbdomenAppendageSelection(sender)
        case .piercing:
            AbdomenAppendageButton.setTitle("Raptorial Piercing", for: .normal)
            AbdomenAppendageSelection(sender)
        case .grasping:
            AbdomenAppendageButton.setTitle("2 Grasping cerci", for: .normal)
            AbdomenAppendageSelection(sender)
        case .twotailcerci:
            AbdomenAppendageButton.setTitle("2 Tail-like cerci", for: .normal)
            AbdomenAppendageSelection(sender)
        case .threetailcerci:
            AbdomenAppendageButton.setTitle("3 Tail-like cerci", for: .normal)
            AbdomenAppendageSelection(sender)
        case .telson:
            AbdomenAppendageButton.setTitle("Raptorial Telson", for: .normal)
            AbdomenAppendageSelection(sender)
        }
    }
    
    //Size
    @IBOutlet weak var SizeButton: UIButton! //The Title of the Dropdown
    @IBOutlet var Sizes: [UIButton]! //All of the Dropdown Options
    @IBAction func SizeSelection(_ sender: UIButton) { // Dropdown header selected
        Sizes.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    enum SizeOptions: String { //Dropdown Option Names
        case realsmall = "Really small"
        case small = "Small 5-10mm"
        case large = "Large > 10mm"
    }
    @IBAction func SizeTapped(_ sender: UIButton) { //all dropdown options
        guard let title = sender.currentTitle, let Size = SizeOptions(rawValue: title) else { //Make enum list
            return
        }
        AverageSizeSelection = title
        autoQuery()
        switch Size { //cases for each option
        case .realsmall:
            SizeButton.setTitle("Really small", for: .normal)
            SizeSelection(sender)
        case .small:
            SizeButton.setTitle("Small 5-10mm", for: .normal)
            SizeSelection(sender)
        case .large:
            SizeButton.setTitle("Large > 10mm", for: .normal)
            SizeSelection(sender)
        }
    }
    
    //Presence of Eyes
    @IBOutlet weak var EyePresenceButton: UIButton! //The Title of the Dropdown
    @IBOutlet var EyePresences: [UIButton]! //All of the Dropdown Options
    @IBAction func EyePresenceSelection(_ sender: UIButton) { // Dropdown header selected
        EyePresences.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    enum EyePresenceOptions: String { //Dropdown Option Names
        case yes = "Yes"
        case no = "No or extremely reduced"
    }
    @IBAction func EyePresenceTapped(_ sender: UIButton) { //all dropdown options
        guard let title = sender.currentTitle, let EyePresence = EyePresenceOptions(rawValue: title) else { //Make enum list
            return
        }
        EyePresenceSelection = title
        autoQuery()
        switch EyePresence { //cases for each option
        case .yes:
            EyePresenceButton.setTitle("Yes", for: .normal)
            EyePresenceSelection(sender)
        case .no:
            EyePresenceButton.setTitle("No or extremely reduced", for: .normal)
            EyePresenceSelection(sender)
        }
    }
    
    //Head Features
    @IBOutlet weak var HeadFeatureButton: UIButton! //The Title of the Dropdown
    @IBOutlet var HeadFeatures: [UIButton]! //All of the Dropdown Options
    @IBAction func HeadFeatureSelection(_ sender: UIButton) { // Dropdown header selected
        HeadFeatures.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    enum HeadFeatureOptions: String { //Dropdown Option Names
        case noRostrum = "Elongated but no rostrum"
        case rostrum = "Elongated with rostrum"
        case sharp = "Sharp angle when viewed from side"
        case pronotum = "Pronotum"
    }
    @IBAction func HeadFeatureTapped(_ sender: UIButton) { //all dropdown options
        guard let title = sender.currentTitle, let HeadFeature = HeadFeatureOptions(rawValue: title) else { //Make enum list
            return
        }
        HeadFeaturesSelection = title
        autoQuery()
        switch HeadFeature { //cases for each option
        case .noRostrum:
            HeadFeatureButton.setTitle("Elongated but no rostrum", for: .normal)
            HeadFeatureSelection(sender)
        case .rostrum:
            HeadFeatureButton.setTitle("Elongated with rostrum", for: .normal)
            HeadFeatureSelection(sender)
        case .sharp:
            HeadFeatureButton.setTitle("Sharp angle when viewed from side", for: .normal)
            HeadFeatureSelection(sender)
        case .pronotum:
            HeadFeatureButton.setTitle("Pronotum", for: .normal)
            HeadFeatureSelection(sender)
        }
    }
    
    //Lenght of Elytra
    @IBOutlet weak var ElytraLengthButton: UIButton! //The Title of the Dropdown
    @IBOutlet var ElytraLengths: [UIButton]! //All of the Dropdown Options
    @IBAction func ElytraLengthSelection(_ sender: UIButton) { // Dropdown header selected
        ElytraLengths.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    enum ElytraLengthOptions: String { //Dropdown Option Names
        case short = "Short"
        case long = "Long"
    }
    @IBAction func ElytraLengthTapped(_ sender: UIButton) { //all dropdown options
        guard let title = sender.currentTitle, let ElytraLength = ElytraLengthOptions(rawValue: title) else { //Make enum list
            return
        }
        ElytraLengthSelection = title
        autoQuery()
        switch ElytraLength { //cases for each option
        case .short:
            ElytraLengthButton.setTitle("Short", for: .normal)
            ElytraLengthSelection(sender)
        case .long:
            ElytraLengthButton.setTitle("Long", for: .normal)
            ElytraLengthSelection(sender)
        }
    }
    
    //Ant Subfamily Criteria
    @IBOutlet weak var AntCriteriaButton: UIButton! //The Title of the Dropdown
    @IBOutlet var AntCriterias: [UIButton]! //All of the Dropdown Options
    @IBAction func AntCriteriaSelection(_ sender: UIButton) { // Dropdown header selected
        AntCriterias.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    enum AntCriteriaOptions: String { //Dropdown Option Names
        case dolic = "Dolichoderinae"
        case formi = "Formicinae"
        case ectat = "Ectatomminae"
        case poner = "Ponerinae"
        case myrmec = "Myrmeciinae"
        case myrmic = "Myrmicinae"
        case doryli = "Dorylinae"
    }
    @IBAction func AntCriteriaTapped(_ sender: UIButton) { //all dropdown options
        guard let title = sender.currentTitle, let AntCriteria = AntCriteriaOptions(rawValue: title) else { //Make enum list
            return
        }
        AntSubfamilySelection = title
        autoQuery()
        switch AntCriteria { //cases for each option
        case .dolic:
            AntCriteriaButton.setTitle("Dolichoderinae", for: .normal)
            AntCriteriaSelection(sender)
        case .formi:
            AntCriteriaButton.setTitle("Formicinae", for: .normal)
            AntCriteriaSelection(sender)
        case .ectat:
            AntCriteriaButton.setTitle("Ectatomminae", for: .normal)
            AntCriteriaSelection(sender)
        case .poner:
            AntCriteriaButton.setTitle("Ponerinae", for: .normal)
            AntCriteriaSelection(sender)
        case .myrmec:
            AntCriteriaButton.setTitle("Myrmeciinae", for: .normal)
            AntCriteriaSelection(sender)
        case .myrmic:
            AntCriteriaButton.setTitle("Myrmicinae", for: .normal)
            AntCriteriaSelection(sender)
        case .doryli:
            AntCriteriaButton.setTitle("Dorylinae", for: .normal)
            AntCriteriaSelection(sender)
        }
    }
}




