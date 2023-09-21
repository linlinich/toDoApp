//
//  CoreDataManager.swift
//  ToDoListProject
//
//  Created by Ангелина Решетникова on 14.07.2023.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
    
    // swiftlint:disable all

    private var appDelegate: AppDelegate {
         UIApplication.shared.delegate as! AppDelegate
     }
    // swiftlint:enable all

     private var context: NSManagedObjectContext {
         appDelegate.persistentContainer.viewContext
     }
    
    func replace(item: TodoItem) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        fetchRequest.predicate = NSPredicate(format: "id == %@", item.id)
        do {
            guard let itemsCoreData = try? context.fetch(fetchRequest) as? [Item],
                  let itemCoreData = itemsCoreData.first else { return }
            itemCoreData.id = item.id
            itemCoreData.importance = item.importance.rawValue
            itemCoreData.changed_at = item.dateOfChange
            itemCoreData.created_at = item.dateOfCreation
            itemCoreData.deadline = item.deadline
            itemCoreData.done = item.didDone
            itemCoreData.last_updated_by = item.lastUpdated
            itemCoreData.text = item.text
        }
        
        saveContext()
    }
    
    func insert(item: TodoItem) {
        guard let photoEntityDescription = NSEntityDescription.entity(forEntityName: "Item", in: context) else {
            return
        }
        let itemCoreData = Item(entity: photoEntityDescription, insertInto: context)
        itemCoreData.id = item.id
        itemCoreData.importance = item.importance.rawValue
        itemCoreData.changed_at = item.dateOfChange
        itemCoreData.created_at = item.dateOfCreation
        itemCoreData.deadline = item.deadline
        itemCoreData.done = item.didDone
        itemCoreData.last_updated_by = item.lastUpdated
        itemCoreData.text = item.text

        saveContext()
    }
    
        
    
    func save(items: [TodoItem]) {
        for item in items {
            insert(item: item)
        }
    }
    
    func delete(id: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do {
            guard let items = try? context.fetch(fetchRequest) as? [Item],
                  let item = items.first else { return}
            context.delete(item)
        }
        
        saveContext()
    }
    
    func dropTable() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        do {
            let photos = try? context.fetch(fetchRequest) as? [Item]
            photos?.forEach { context.delete($0) }
        }
        
        saveContext()
    }
    
    func load() -> [TodoItem] {
        var collectionsOfToDoItems = [TodoItem]()
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        do {
            var itemsCoreData = try context.fetch(request)
            for item in itemsCoreData {
                if let convertedItem = TodoItem.makeTodoItemFromCoreData(item: item) {
                    collectionsOfToDoItems.append(convertedItem)
                }
            }
        } catch {
            print("Error loading context \(error)")
        }
        return collectionsOfToDoItems
    }
        
    private func saveContext() {
        do {
                try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
}
