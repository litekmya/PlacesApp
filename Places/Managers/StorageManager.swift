//
//  StorageManager.swift
//  Places
//
//  Created by Владимир Ли on 12.05.2021.
//

import RealmSwift

class StorageManager {
    
    static let shared = StorageManager()
    
//    lazy var realm: Realm = {
//        return try! Realm()
//    }()
    
    let realm = try! Realm()
    
    private init() {}
    
    func write(_ completion: () -> Void) {
        do {
            try realm.write {
                completion()
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func save(place: Place) {
        write {
            realm.add(place)
        }
    }
    
    func change(currentPlace: Place, newPlace: Place) {
        write {
            currentPlace.name = newPlace.name
            currentPlace.address = newPlace.address
            currentPlace.type = newPlace.type
            currentPlace.imageData = newPlace.imageData
            currentPlace.date = newPlace.date
            currentPlace.rating = newPlace.rating
            currentPlace.recordID = newPlace.recordID
        }
    }
    
    func delete(place: Place) {
        write {
            realm.delete(place)
        }
    }
    
    private func initRealm() -> Realm {
        let realm = try! Realm()
        
        return realm
    }
    
}
