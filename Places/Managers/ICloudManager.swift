//
//  ICloudManager.swift
//  Places
//
//  Created by Владимир Ли on 20.12.2021.
//

import UIKit
import CloudKit
import RealmSwift

class ICloudManager {
    
    private static let privateCloudDatabase = CKContainer.default().privateCloudDatabase
    
    static func saveDataToCloud(place: Place, image: UIImage) {
        let (image, url) = prepareImageToSaveToCloud(place: place, image: image)
        guard let imageAsset = image, let imageURL = url else { return }
        
        let record = CKRecord(recordType: "Place")
        record.setValue(place.placeID, forKey: "placeID")
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
    
    static func fetchDataFromCloud(places: Results<Place>, closure: @escaping (Place) -> ()) { // метод для загрузки данных из облака
        let query = CKQuery(recordType: "Place", predicate: NSPredicate(value: true)) // Создаем запрос по типу записи. С помощью predicate мы можем отфильтровать по параметрам, какие данные нам нужны. В данном коде мы будем получать все данные
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)] // Создаем дескриптор сортировкм, который будет сортировать данные по заданному ключу
        
        // вызываем метод, который выберет записи, которые подходят нам по запросу. Во втором параметре мы указываем из какой зоны делать выборку. Мы ставим nil, так как у нас только одна дефолтная зона
        privateCloudDatabase.perform(query, inZoneWith: nil) { records, error in
            guard error == nil else {
                print("We have an error in method 'fetchDataFromCloud from ICloudManager: \(error?.localizedDescription ?? "")")
                return
            }
            
            guard let records = records else { return }
            records.forEach { record in // Делаем перебор по каждому объекту
                
                let newPlace = Place(record: record)
                
                DispatchQueue.main.async {
                    if newCloudRecordIsAvailable(places: places, placeID: newPlace.placeID) { // Если такой же записи нет, то сохраняем
                        closure(newPlace)
                    }
                }
            }
        }
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
    
    static private func newCloudRecordIsAvailable(places: Results<Place>, placeID: String) -> Bool { // Создаем метод, который будет отслеживать, если мы создаем новую запись в локальной базе данных, то она будет сохраняться в облаке. Если же у нас уже есть эта запись в локальной базе, то нам не нужно сохранять эту запись в облаке, так как она уже там есть
        for place in places {
            if place.placeID == placeID {
                return false
            }
        }
        
        return true
    }
}
