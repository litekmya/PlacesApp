//
//  PHPickerManager.swift
//  Places
//
//  Created by Владимир Ли on 18.07.2022.
//

import Foundation
import PhotosUI

class PHPickerManager {
    
    static let shared = PHPickerManager()
    
    private init() {}
    
    func selectImageFromPhoto(results: [PHPickerResult], completion: @escaping(NSItemProviderReading?) -> Void) {
        let itemProviders = results.map(\.itemProvider)
        
        for provider in itemProviders {
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }
            }
        }
    }
    
    func setupPHPicker(delegate: PHPickerViewControllerDelegate?) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
    
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = delegate
        
        return picker
    }
}
