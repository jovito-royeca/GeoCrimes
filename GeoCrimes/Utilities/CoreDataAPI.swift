//
//  CoreDataAPI.swift
//  GeoCrimes
//
//  Created by Jovito Royeca on 28/06/2018.
//  Copyright © 2018 Jovito Royeca. All rights reserved.
//

import UIKit
import PromiseKit
import Sync

class CoreDataAPI: NSObject {
    // MARK: - Shared Instance
    static let sharedInstance = CoreDataAPI()
    
    // MARK: Variables
    
    /*
     * Uses SyncDB to simplify mapping JSON to Core Data.
     * This is the main context of Core Data and is used for saving and retrieving data.
     */
    fileprivate var _dataStack:DataStack?
    var dataStack:DataStack? {
        get {
            if _dataStack == nil {
                _dataStack = DataStack(modelName: "GeoCrimes")
            }
            return _dataStack
        }
        set {
            _dataStack = newValue
        }
    }
    
    // MARK: Custom methods
    /*
     * Listen for Core Data updates in SyncDB
     */
    @objc func changeNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        if let updatedObjects = userInfo[NSUpdatedObjectsKey] {
            if let set = updatedObjects as? NSSet {
                print("updatedObjects: \(set.count)")
            }
        }
        
        if let deletedObjects = userInfo[NSDeletedObjectsKey] {
            if let set = deletedObjects as? NSSet {
                print("deletedObjects: \(set.count)")
            }
        }
        
        if let insertedObjects = userInfo[NSInsertedObjectsKey] {
            if let set = insertedObjects as? NSSet {
                print("insertedObjects: \(set.count)")
            }
        }
    }

    /*
     * Save JSON to Core Data using background context
     */
    func saveQueryResults(json: [[String: Any]]) -> Promise<Void> {
        return Promise { seal in
            // delete previous crimes
            self.deleteCrimes()
            
            let notifName = NSNotification.Name.NSManagedObjectContextObjectsDidChange
            
            // add location.id to satisfy Sync's id requirements
            var newJson = [[String: Any]]()
            for dict in json {
                var newDict = [String: Any]()
                for (k,v) in dict {
                    if k == "location" {
                        if let locDict = v as? [String: Any] {
                            var newLocDict = [String: Any]()
                            var locId = ""
                            
                            for (k2,v2) in locDict {
                                if k2 == "latitude" {
                                    newLocDict[k2] = Double(v2 as! String)
                                    if locId.count > 0 {
                                        locId.append("_")
                                    }
                                    locId.append("\(v2)")
                                } else if k2 == "longitude" {
                                    newLocDict[k2] = Double(v2 as! String)
                                    if locId.count > 0 {
                                        locId.append("_")
                                    }
                                    locId.append("\(v2)")
                                } else {
                                    newLocDict[k2] = v2
                                }
                            }
                            newLocDict["id"] = locId
                            newDict[k] = newLocDict
                        }
                        
                    } else {
                        newDict[k] = v
                    }
                }
                newJson.append(newDict)
            }
            
            dataStack?.performInNewBackgroundContext { backgroundContext in
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(CoreDataAPI.changeNotification(_:)),
                                                       name: notifName,
                                                       object: backgroundContext)
                Sync.changes(newJson,
                             inEntityNamed: "Crime",
                             predicate: nil,
                             parent: nil,
                             parentRelationship: nil,
                             inContext: backgroundContext,
                             operations: .all,//[.insert, .update, .insertRelationships, .updateRelationships],
                             completion:  { error in
                                NotificationCenter.default.removeObserver(self, name:notifName, object: nil)
                                
                                if let error = error {
                                    seal.reject(error)
                                } else {
                                    seal.fulfill(())
                                }
                })
            }
        }
    }
    
    /*
     * Delete crimes from a previous search result
     */
    func deleteCrimes() {
        // delete existing data first
        let streetRequest = Street.streetFetchRequest()
        var deleteRequest = NSBatchDeleteRequest(fetchRequest: streetRequest as! NSFetchRequest<NSFetchRequestResult> )
        try! dataStack?.persistentStoreCoordinator.execute(deleteRequest, with: (dataStack?.mainContext)!)
        
        let locationRequest = Location.locationFetchRequest()
        deleteRequest = NSBatchDeleteRequest(fetchRequest: locationRequest as! NSFetchRequest<NSFetchRequestResult> )
        try! dataStack?.persistentStoreCoordinator.execute(deleteRequest, with: (dataStack?.mainContext)!)
        
        let crimeRequest = Crime.crimeFetchRequest()
        deleteRequest = NSBatchDeleteRequest(fetchRequest: crimeRequest as! NSFetchRequest<NSFetchRequestResult> )
        try! dataStack?.persistentStoreCoordinator.execute(deleteRequest, with: (dataStack?.mainContext)!)
    }
    
    /*
     * Fetch crimes using main context
     */
    func fetchCrimes() -> [Crime]? {
        let request = Crime.crimeFetchRequest()

        guard let crimes = try! dataStack?.mainContext.fetch(request) else {
            return nil
        }
        return crimes
    }
    
    /*
     * Save pending updates, if there is any.
     */
    func saveContext() {
        guard let dataStack = dataStack else {
            return
        }
        
        if dataStack.mainContext.hasChanges {
            do {
                try dataStack.mainContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
