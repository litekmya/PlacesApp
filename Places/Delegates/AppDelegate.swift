//
//  AppDelegate.swift
//  Places
//
//  Created by Владимир Ли on 09.05.2021.
//

import UIKit
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let schemaVersion: UInt64 = 2
        let config = Realm.Configuration(
            schemaVersion: schemaVersion,
            
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < schemaVersion) {
                    migration.enumerateObjects(ofType: Place.className()) { oldObject, newObject in
                        if oldObject == nil {
                            newObject!["placeID"] = UUID().uuidString
                        }
                    }
                }
            }
        )
        
        Realm.Configuration.defaultConfiguration = config
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

