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
    
    @IBOutlet weak var ratingControl: RatingControl!
    
    //MARK:- Public properties
    var currentPlace: Place!
    
    //MARK:- IBOutlets
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSaveButton()
        setupLabels()
        setupTextFields()
        getData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK:- Public Methods
    func saveData() {
        let imageData = placeImageView.image?.pngData()
        
        let place = Place(name: nameTextField.text!,
                          address: addressTextField.text,
                          type: typeTextField.text,
                          imageData: imageData,
                          date: Date(),
                          rating: ratingControl.rating)
        
        if currentPlace != nil {
            StorageManager.shared.write {
                currentPlace.name = place.name
                currentPlace.address = place.address
                currentPlace.type = place.type
                currentPlace.imageData = place.imageData
                currentPlace.date = place.date
                currentPlace.rating = place.rating
            }
        } else {
            StorageManager.shared.save(place: place)
        }
    }
    
    //MARK:- Private properties
    private func setupLabels() {
        namelabel.setup(label: namelabel, fontsize: 23, weight: .medium)
        addressLabel.setup(label: addressLabel, fontsize: 23, weight: .medium)
        typeLabel.setup(label: typeLabel, fontsize: 23, weight: .medium)
    }
    
    private func setupTextFields() {
        nameTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(activateSaveButton), for: .editingChanged)
        nameTextField.setup(textField: nameTextField,
                            fontSize: 21,
                            weight: .regular,
                            placeholder: "Name")
        
        addressTextField.delegate = self
        addressTextField.setup(textField: addressTextField,
                               fontSize: 21,
                               weight: .regular,
                               placeholder: "Address")
        
        typeTextField.delegate = self
        typeTextField.setup(textField: typeTextField,
                            fontSize: 21,
                            weight: .regular,
                            placeholder: "Type")
    }
    
    private func setupSaveButton() {
        saveButton.isEnabled = false
    }
    
    private func getData() {
        if currentPlace != nil {
            nameTextField.text = currentPlace.name
            addressTextField.text = currentPlace.address
            typeTextField.text = currentPlace.type
            
            ratingControl.rating = Int(currentPlace.rating)
    
            placeImageView.getDataFor(imageView: placeImageView, from: currentPlace)
            
            saveButton.isEnabled = true
        } else {
            placeImageView.image = #imageLiteral(resourceName: "cameraPlug")
        }
    }
    
    private func getDataForImageData() {
            
    }
}

    //MARK:- UItextFieldDelegate
extension DescriptionTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    @objc func activateSaveButton() {
        if nameTextField.text?.isEmpty == true {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
}


