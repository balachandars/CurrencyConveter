//
//  CoreDataManager.swift
//  AARP
//
//  Created by Dattu Somineni on 9/21/18.
//  Copyright © 2018 Balu. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {
    static let coreDataSharedInstance = CoreDataManager()
    /**
     * Method for Get Managed Object Context
     */
    class func getContext() -> NSManagedObjectContext{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    /**
     * Method for store currency rates into Core data
     */
    class func addNewCurrecncyRatess(responceData : Data) {
        let context = getContext()
        self.deleteEntityFromCoreData(entityName: "CurrencyRates")
        let entity  = NSEntityDescription.entity(forEntityName: "CurrencyRates", in: context)
        let managedObj = NSManagedObject(entity: entity!, insertInto: context) as! CurrencyRates
      managedObj.exchangesRates = responceData
        do{
            try context.save()
            print("saved!")
        }catch {
            print(error.localizedDescription)
        }
    }
    /**
     * Method for Fetch the currency rates from core data
     */
    class func  fetchDetails(entityName : String)->Array<Any>{
        var fetchResultsArray = Array<Any>()
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: getContext())
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        do {
            let result = try getContext().fetch(fetchRequest)
            print(result)
            for item in result {
                /*fetchResultsArray.append(item.name!)
                 fetchResultsArray.append(item.email!)
                 fetchResultsArray.append(item.phone!)*/
                fetchResultsArray.append(item)
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        return fetchResultsArray
    }
    /**
     * Method for Delete Entity
     */
    class func deleteEntityFromCoreData(entityName : String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let result = try? getContext().fetch(fetchRequest)
        for object in result! {
            getContext().delete(object as! NSManagedObject)
        }
        do {
            try getContext().save()
            print("Delete Sucessfully!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
        }
    }
}

