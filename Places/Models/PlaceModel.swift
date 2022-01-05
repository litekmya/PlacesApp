//
//  PlaceModel.swift
//  Places
//
//  Created by Владимир Ли on 09.05.2021.
//

import RealmSwift
import CloudKit
import UIKit

class Place: Object {
    
    @objc dynamic var recordID = ""
    @objc dynamic var placeID = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var address: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData: Data?
    @objc dynamic var date = Date()
    @objc dynamic var rating = 0 
    
    convenience init(name: String,
                     address: String?,
                     type: String?,
                     imageData: Data?,
                     date: Date,
                     rating: Int) {
        self.init()
        self.name = name
        self.address = address
        self.type = type
        self.imageData = imageData
        self.rating = rating
    }
    
    convenience init(record: CKRecord) { // Необязателная инициализация
        self.init()
        
//        guard let possibleImage = record.value(forKey: "imageData") else { return } // Делаем проверку
//        let imageAsset = possibleImage as! CKAsset // Кастим
//        guard let imageData = try? Data(contentsOf: imageAsset.fileURL!) else { return } // Достаем данные из базы с помощью URL
        
        let image = UIImage(named: "cameraPlug")
        let imageData = image?.pngData()
        
        self.recordID = record.recordID.recordName
        self.placeID = record.value(forKey: "placeID") as! String
        self.name = record.value(forKey: "name") as! String
        self.address = record.value(forKey: "address") as? String
        self.type = record.value(forKey: "type") as? String
        self.imageData = imageData
        self.date = Date()
        self.rating = record.value(forKey: "rating") as! Int
    }
    
    override static func primaryKey() -> String? {
        return "placeID"
    }
}
