//
//  ICloudManager.swift
//  Places
//
//  Created by Владимир Ли on 20.12.2021.
//

import UIKit
import CloudKit
import RealmSwift
import CoreMedia

class ICloudManager {
    
    private static let privateCloudDatabase = CKContainer.default().privateCloudDatabase
    private static var records: [CKRecord] = []
    
    static func saveDataToCloud(place: Place, image: UIImage, closure: @escaping (String) -> ()) {
        let (image, url) = prepareImageToSaveToCloud(place: place, image: image)
        guard let imageAsset = image, let imageURL = url else { return }
        
        let record = CKRecord(recordType: "Place")
        record.setValue(place.placeID, forKey: "placeID")
        record.setValue(place.name, forKey: "name")
        record.setValue(place.address, forKey: "address")
        record.setValue(place.type, forKey: "type")
        record.setValue(place.rating, forKey: "rating")
        record.setValue(imageAsset, forKey: "imageData")
        
        privateCloudDatabase.save(record) { newRecord, error in
            if let error = error {
                print("We cant save data in cloud: \(error)")
                return
            }
            
            if let newRecord = newRecord {
                closure(newRecord.recordID.recordName)
            }

            deleteTempImage(imageURL: imageURL)
        }
    }
    
    static func fetchDataFromCloud(places: Results<Place>, closure: @escaping (Place) -> ()) {
        let query = CKQuery(recordType: "Place", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        // Настройка параметров при загрузке данных. Данный метод позволяпет нам выбирать какие именно данные мы загружаем в первую очередь.
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["recordID", "placeID", "name", "address", "type", "rating"]
        queryOperation.queuePriority = .veryHigh
        queryOperation.resultsLimit = 5
        
        queryOperation.recordFetchedBlock = { record in
            records.append(record)
            
            let newPlace = Place(record: record)
            
            DispatchQueue.main.async {
                if newCloudRecordIsAvailable(places: places, placeID: newPlace.placeID) {
                    closure(newPlace)
                }
            }
        }
        
        queryOperation.queryCompletionBlock = { cursor, error in
            if let error = error {
                print("We have an error in ICloudManager/queryOperation.queryCompletionBlock: \(error.localizedDescription)")
                return
            }
            
            guard let cursor = cursor else { return }
            
            let secondQueryOperation = CKQueryOperation(cursor: cursor)
            
            secondQueryOperation.recordFetchedBlock = { record in
                records.append(record)
                
                let newPlace = Place(record: record)
                
                DispatchQueue.main.async {
                    if newCloudRecordIsAvailable(places: places, placeID: newPlace.placeID) {
                        closure(newPlace)
                    }
                }
            }
            
            secondQueryOperation.queryCompletionBlock = queryOperation.queryCompletionBlock
        }
        
        privateCloudDatabase.add(queryOperation)
    }
    
    static func getImageFromCloud(place: Place, closure: @escaping (Data?) -> Void) {
        records.forEach { record in
            if place.recordID == record.recordID.recordName {
                let fetchRecordsOperation = CKFetchRecordsOperation(recordIDs: [record.recordID])
                fetchRecordsOperation.desiredKeys = ["imageData"]
                fetchRecordsOperation.queuePriority = .veryHigh
                
                fetchRecordsOperation.perRecordCompletionBlock = { record, _, error in
                    guard error == nil else { return }
                    guard let record = record else { return }
                    guard let possibleImage = record.value(forKey: "imageData") as? CKAsset else { return }
                    guard let imageData = try? Data(contentsOf: possibleImage.fileURL!) else { return }
                    
                    DispatchQueue.main.async {
                        StorageManager.shared.write {
                            place.imageData = imageData
                        }
                        
                        closure(imageData)
                    }
                }
                
                privateCloudDatabase.add(fetchRecordsOperation)
            }
            
        }
    }
    
    static func updateDataToCloud(place: Place, with image: UIImage) {
        let recordID = CKRecord.ID(recordName: place.recordID)
        let (image, url) = prepareImageToSaveToCloud(place: place, image: image)
        
        guard let imageAsset = image, let imageURL = url else { return }
        
        privateCloudDatabase.fetch(withRecordID: recordID) { record, error in
            if let record = record, error == nil {
                DispatchQueue.main.async {
                    record.setValue(place.name, forKey: "name")
                    record.setValue(place.address, forKey: "address")
                    record.setValue(place.type, forKey: "type")
                    record.setValue(place.rating, forKey: "rating")
                    record.setValue(imageAsset, forKey: "imageData")
                    
                    privateCloudDatabase.save(record) { _, error in
                        if let error = error {
                            print("We have an error in method 'updateDataToCloud/ICloudManager': \(error.localizedDescription)")
                            return
                        }
                        
                        deleteTempImage(imageURL: imageURL)
                    }
                }
            }
        }
    }
    
    static func deleteDataFromCloud(recordID: String) {
        let query = CKQuery(recordType: "Place", predicate: NSPredicate(value: true))
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["recordID"]
        queryOperation.queuePriority = .veryHigh
        
        queryOperation.recordFetchedBlock = { record in
            if record.recordID.recordName == recordID {
                privateCloudDatabase.delete(withRecordID: record.recordID) { _, error in
                    if let error = error {
                        print("We have an error in ICloudManager/deleteDataFromCloud/recordFetchedBlock: \(error.localizedDescription)")
                        return
                    }
                }
            }
        }
        
        queryOperation.queryCompletionBlock = { _, error in
            if let error = error {
                print("We have an error in ICloudManager/deleteDataFromCloud/queryComplitionBlock: \(error.localizedDescription)")
                return
            }
        }
        
        privateCloudDatabase.add(queryOperation)
    }
    
    //MARK: - Private methods
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
    
    static private func newCloudRecordIsAvailable(places: Results<Place>, placeID: String) -> Bool {
        for place in places {
            if place.placeID == placeID {
                return false
            }
        }
        
        return true
    }
}
