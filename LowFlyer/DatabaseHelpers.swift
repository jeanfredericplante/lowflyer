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
    var error : NSError?
    if let dbobject = managedObjectContext {
        if (dbobject.save(&error) ) {
            if ((error?.localizedDescription) != nil) {
                println(error?.localizedDescription)
            }
        }
    }
}

func getManagedObjectContext() -> NSManagedObjectContext? {
    if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate, let managedObjectContext = appDelegate.managedObjectContext {
        return managedObjectContext
    }
    else {
        return nil
    }
}

func saveMagnitude(value: Double) -> Void {
    // Get Core Data managed context
    if let managedContext = getManagedObjectContext() {
        
        let entity =  NSEntityDescription.entityForName("Magneto", inManagedObjectContext: managedContext)
        let magneto = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext:managedContext)
        magneto.setValue(value, forKey: "amplitude")
        saveToDisk(managedContext)
    }
}
