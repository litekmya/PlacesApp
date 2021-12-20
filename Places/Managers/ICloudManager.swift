//
//  ICloudManager.swift
//  Places
//
//  Created by Владимир Ли on 20.12.2021.
//

import UIKit
import CloudKit

class ICloudManager {
    
    private static let privateCloudDatabase = CKContainer.default().privateCloudDatabase
    
    static func saveDataToCloud(place: Place, image: UIImage) {
        let (image, url) = prepareImageToSaveToCloud(place: place, image: image)
        guard let imageAsset = image, let imageURL = url else { return }
        
        let record = CKRecord(recordType: "Place")
        record.setValue(place.name, forKey: "name")
        record.setValue(place.address, forKey: "address")
        record.setValue(place.type, forKey: "type")
        record.setValue(place.rating, forKey: "rating")
        record.setValue(imageAsset, forKey: "imageData")
        
        privateCloudDatabase.save(record) { _, error in
            if let error = error {
                print("We cant save data in cloud: \(error)")
                return
            }
            
            deleteTempImage(imageURL: imageURL)
        }
    }
    
    private static func prepareImageToSaveToCloud(place: Place, image: UIImage) -> (CKAsset?, URL?) {
        var scale: CGFloat = 0
        
        if image.size.width > 1080 {
            scale = 1080 / image.size.width
        } else {
            scale = 1
        }
        
        let scaleImage = UIImage(data: image.pngData()!, scale: scale)
        guard let dataToPath = scaleImage?.jpegData(compressionQuality: 1) else { return (nil, nil) }
                
        let imageFilePath = NSTemporaryDirectory() + place.name
        let imageURL = URL(fileURLWithPath: imageFilePath)
        
        do {
            try dataToPath.write(to: imageURL, options: .atomic)
        } catch {
            print(" We have an error in the ICloudManager:\(error.localizedDescription)")
        }
        
        let imageAsset = CKAsset(fileURL: imageURL)
        
        return (imageAsset, imageURL)
    }
    
    static private func deleteTempImage(imageURL: URL) { 
        do {
            try FileManager.default.removeItem(at: imageURL)
        } catch {
            print("We cant delete data in FileManager: \(error.localizedDescription)")
        }
    }
}
