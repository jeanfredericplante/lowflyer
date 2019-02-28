//
//  DatabaseHelpers.swift
//  LowFlyer
//
//  Created by Jean Frederic Plante on 3/31/15.
//  Copyright (c) 2015 Jean Frederic Plante. All rights reserved.
//


import UIKit
import CoreData

func saveToDisk(managedObjectContext: NSManagedObjectContext?) {
    if let dbobject = managedObjectContext {
        do {
            try dbobject.save()
        } catch {
            print("error when saving \(error)")
        }
    }
}

func getManagedObjectContext() -> NSManagedObjectContext? {
    if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let managedObjectContext = appDelegate.managedObjectContext {
        return managedObjectContext
    }
    else {
        return nil
    }
}

func saveMagnitude(value: Double) -> Void {
    // Get Core Data managed context
    if let managedContext = getManagedObjectContext() {
        
        let entity =  NSEntityDescription.entity(forEntityName: "Magneto", in: managedContext)
        let magneto = NSManagedObject(entity: entity!,
                                      insertInto:managedContext)
        magneto.setValue(value, forKey: "amplitude")
        saveToDisk(managedObjectContext: managedContext)
    }
}
