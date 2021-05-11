//
//  DescriptionTableViewController.swift
//  Places
//
//  Created by Владимир Ли on 09.05.2021.
//

import UIKit

class DescriptionTableViewController: UITableViewController {
    
    //MARK:- IBOutlets
    @IBOutlet weak var placeImageView: UIImageView!
    
    @IBOutlet weak var namelabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    //MARK:- Public properties
    var currentPlaces: [Place]!
    
    //MARK:- IBOutlets
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLabels()
        setupTextFields()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK:- Private properties
    private func setupLabels() {
        namelabel.setup(label: namelabel, fontsize: 23, weight: .medium)
        addressLabel.setup(label: addressLabel, fontsize: 23, weight: .medium)
        typeLabel.setup(label: typeLabel, fontsize: 23, weight: .medium)
    }
    
    private func setupTextFields() {
        nameTextField.setup(textField: nameTextField,
                            fontSize: 21,
                            weight: .regular,
                            placeHolder: "Name")
        
        addressTextField.setup(textField: addressTextField,
                               fontSize: 21,
                               weight: .regular,
                               placeHolder: "Address")
        
        typeTextField.setup(textField: typeTextField,
                            fontSize: 21,
                            weight: .regular,
                            placeHolder: "Type")
    }
}

