//
//  DescriptionTableViewController.swift
//  Places
//
//  Created by Владимир Ли on 09.05.2021.
//

import UIKit
import PhotosUI

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
    
    //MARK:- TableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            showAlert()
        }
    }
    
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
    
            placeImageView.getDataFor(imageView: placeImageView,
                                      from: currentPlace,
                                      with: CGSize(width: placeImageView.frame.width, height: placeImageView.frame.height))
            
            saveButton.isEnabled = true
        } else {
            placeImageView.image = #imageLiteral(resourceName: "cameraPlug")
        }
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

    //MARK:- Alert Controller
extension DescriptionTableViewController {
    
    private func showAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { [unowned self]_ in
            self.chooseImagePicker(sourceType: .camera)
        }
        let photoAction = UIAlertAction(title: "Photo", style: .default) { [unowned self] _ in
            self.choosePHPicker()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(cameraAction)
        alert.addAction(photoAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

    //MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension DescriptionTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        placeImageView.image = image
        
        dismiss(animated: true)
    }
    
    private func chooseImagePicker(sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.sourceType = sourceType
            imagePicker.delegate = self
            
            present(imagePicker, animated: true)
        }
    }
}

    //MARK:-PHPickerViewControllerDelegate
extension DescriptionTableViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        let itemProviders = results.map(\.itemProvider)
        
        for provider in itemProviders {
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    
                    DispatchQueue.main.async {
                        if let image = image as? UIImage {
                            self.placeImageView.image = nil
                            
                            var imageData = Data(image.jpegData(compressionQuality: 1)!)
                            let imageSize = imageData.count
                            
                            if imageSize > 4000 {
                                imageData = Data(image.jpegData(compressionQuality: 0.1)!)
                            }
                            
                            self.placeImageView.image = UIImage(data: imageData)
                        }
                    }
                }
            }
        }
    }
    
    private func choosePHPicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
    
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        present(picker, animated: true)
    }
}


