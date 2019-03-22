//
//  AppDelegate.swift
//  AtomicApp
//
//  Created by Omar Gomez on 5/23/18.
//  Copyright © 2018 Omar Gómez. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    static var configuration: Configuration?

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AtomicApp")
        container.loadPersistentStores(completionHandler: {
            (storeDescription, error) in
            print(storeDescription)
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        MovieDBConfig.shared.refresh()
        MovieDBGenres.shared.refresh()
        
        dummy()
        
        return true
    }
    
    func dummy() {
        let toJSON: (String) -> Any? = { str in
            guard let data = str.data(using: .utf8) else { return nil }
            return try? JSONSerialization.jsonObject(with: data)
        }
        
        let json1 =
"""
{
  "firstName": "John",
  "lastName": "Smith",
  "isAlive": true,
  "age": 27,
  "address": {
    "streetAddress": "21 2nd Street",
    "city": "New York",
    "state": "NY",
    "postalCode": "10021-3100"
  },
  "phoneNumbers": [
    {
      "type": "home",
      "number": "212 555-1234"
    },
    {
      "type": "office",
      "number": "646 555-4567"
    },
    {
      "type": "mobile",
      "number": "123 456-7890"
    }
  ],
  "children": [],
  "pi": 3.1516,
  "spouse": null
}
"""
        let raw = toJSON(json1)
        print("JSON VVV")
        
        let root = JSONRoot(raw)!
        
        let first = JSONRoot(raw)?["firstName"]?.asString
        let alive = JSONRoot(raw)?["isAlive"]?.asBool
        let age = JSONRoot(raw)?["age"]?.asInt
        let state = JSONRoot(raw)?["address"]?["state"]?.asString
        let phone1 = JSONRoot(raw)?["phoneNumbers"]?[1]?["number"]?.asString
        let pi = root["pi"]?.asDouble
        let piI = root["pi"]?.asInt
        let piS = root["pi"]?.asString
        let ageD = root["age"]?.asDouble
        let spouse = root["spouse"]?.isNull
        
        
        
        debugPrint(raw)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

