//
//  ToDoItemsModelIO.swift
//  ToDoListProject
//
//  Created by Ангелина Решетникова on 30.06.2023.
//

import Foundation
import UIKit

final class ToDoItemsModel {
    var output: ToDoItemsModelOutput?
    let dataBase = CoreDataManager() //let dataBase = SQLiteManager.shared
    
    /* Чтобы проверить sqlite поменяйте данную строку за закомментированную и то же самое сделайте в двух случаях ниже
     */
}

extension ToDoItemsModel: ToDoItemsModelInput {
    
    func reloadToDoItems(items: [TodoItem]) {
        guard let url = try? RequestProcessor.makeUrl() else {
            print("wrong url")
            return
        }
        var array: [Any] = []
        
        for item in items {
            array.append(item.json)
        }
        let dict: [String: Any] = ["list": array]
        let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted])
        Task {
            do {
                output?.isDirty = false
                
                let (data, responseStatusCode) = try await RequestProcessor.requestToTheServer(url: url, method: .patch, body: data)
             
                if responseStatusCode == 400 {
                    output?.loading()
                    getCurrentRevision()
                    DispatchQueue.main.async {
                        self.reloadToDoItems(items: items)
                    }
                    getCurrentRevision()
                    output?.endLoading()
                }
                guard let (revision, _) = parseSingleItem(data: data) else { return }
                RequestProcessor.revision = revision

            } catch {
                output?.isDirty = true
            }
            
        }
    }
    
    func editingItem(item: TodoItem) {
        if output?.isDirty == true {
            output?.reloadToDoItems()
        }
        dataBase.replace(item: item) // dataBase.incertOrReplace(item: item)
        let url = try? RequestProcessor.makeUrl(id: item.id)
        let dict: [String: Any] = ["element": item.json]

        let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted])
        Task {
            do {
                output?.isDirty = false
                let (data, responseStatusCode) = try await RequestProcessor.requestToTheServer(url: url!, method: .put, body: data)
                
                if responseStatusCode == 400 {
                    output?.loading()
                    getCurrentRevision()
                    DispatchQueue.main.async {
                        self.editingItem(item: item)
                    }
                    getCurrentRevision()
                    output?.endLoading()
                }
                guard let (revision, _) = parseSingleItem(data: data) else { return }
                RequestProcessor.revision = revision
                

            } catch {
                output?.isDirty = true
            }
            
        }
    }
    
    func addingNewItem(item: TodoItem) {
        if output?.isDirty == true {
            output?.reloadToDoItems()
        }
        dataBase.insert(item: item) // dataBase.incertOrReplace(item: item)
        print(item)
        let url = try? RequestProcessor.makeUrl()
        let dict: [String: Any] = ["element": item.json]
        let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted])
        Task {
            do {
                output?.isDirty = false
                let (data, responseStatusCode) = try await RequestProcessor.requestToTheServer(url: url!, method: .post, body: data)
                
                if responseStatusCode == 400 {
                    print("400")
                    output?.loading()
                    getCurrentRevision()
                    DispatchQueue.main.async {
                        self.addingNewItem(item: item)
                    }
                    output?.endLoading()
                }
                guard let (revision, _) = parseSingleItem(data: data) else { return }
                RequestProcessor.revision = revision

            } catch {
                output?.isDirty = true
            }
        }
    }
    
    func deleteItem(id: String) {
        if output?.isDirty == true {
            output?.reloadToDoItems()
        }
        dataBase.delete(id: id)
        let url = try? RequestProcessor.makeUrl(id: id)
        Task {
            do {
                output?.isDirty = false
                let (data, responseStatusCode) = try await RequestProcessor.requestToTheServer(url: url!, method: .delete)
                
                if responseStatusCode == 400 {
                    output?.loading()
                    getCurrentRevision()
                    DispatchQueue.main.async {
                        self.deleteItem(id: id)
                    }
                    output?.endLoading()
                }
                guard let (revision, _) = parseSingleItem(data: data) else { return }
                RequestProcessor.revision = revision

            } catch {
                output?.isDirty = true
            }
        }
    }
    
    func getCurrentRevision() {
        let url = try? RequestProcessor.makeUrl()
        Task {
            do {
                output?.isDirty = false
                let (data, _) = try await RequestProcessor.requestToTheServer(url: url!, method: .get)
                guard let (revision, items) = parseToDoItems(data: data) else { return }
                output?.didRecieveData(items: items)
                RequestProcessor.revision = revision
            } catch {
                output?.isDirty = true
            }
        }
    }
    
    func loadToDoItems() {
        if output?.isDirty == true {
            output?.reloadToDoItems()
        }
        let url = try? RequestProcessor.makeUrl()

        Task {
            do {
                output?.isDirty = false
                let (data, _) = try await RequestProcessor.requestToTheServer(url: url!, method: .get)
                guard let (revision, items) = parseToDoItems(data: data) else { return }
                RequestProcessor.revision = revision
                output?.didRecieveData(items: items)
                output?.endLoading()
                
                DispatchQueue.main.async {
                    self.dataBase.dropTable()
                    self.dataBase.save(items: items)
                }
            } catch {
                
                output?.didRecieveData(items: dataBase.load())
                output?.endLoading()
                output?.isDirty = true
            }
        }
    }
    
    private func parseToDoItems(data: Data) -> (Int32, [TodoItem])? {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            print("Ошибка при парсинге")
            return nil
        }
        guard let collectionOfToDoItemsJson = json["list"] as? [[String: Any]],
              let revisionJson = json["revision"] as? Int32
        else {
            print("Ошибка! в файле нет ToDoItem")
            return nil
        }

        var collectionToDoitem = [TodoItem]()
        for item in collectionOfToDoItemsJson {
            let optionalToDoItem = TodoItem.parse(json: item)
            if let toDoItem = optionalToDoItem {
                collectionToDoitem.append(toDoItem)
            }
        }
        return (revisionJson, collectionToDoitem)
    }
    
    private func parseSingleItem(data: Data) -> (Int32, TodoItem)? {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return nil }
        
        guard
            let itemjson = json["element"] as? [String: Any],
            let revisionJson = json["revision"] as? Int32,
            let item = TodoItem.parse(json: itemjson)
        else { return nil }
         return (revisionJson, item)
    }
}
