//
//  PlaceModel.swift
//  Places
//
//  Created by Владимир Ли on 09.05.2021.
//

import RealmSwift

class Place: Object {
    
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
}
