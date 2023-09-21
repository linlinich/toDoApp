//
//  SqLiteDataBase.swift
//  ToDoListProject
//
//  Created by Ангелина Решетникова on 13.07.2023.
//

import SQLite

struct TodoItemSQL {
    static let id = Expression<String>(CodingKeys.id.rawValue)
    static let text = Expression<String>(CodingKeys.text.rawValue)
    static let importance = Expression<String>(CodingKeys.importance.rawValue)
    static let deadline = Expression<Double?>(CodingKeys.deadline.rawValue)
    static let didDone = Expression<Bool>(CodingKeys.didDone.rawValue)
    static let dateOfCreation = Expression<Double>(CodingKeys.dateOfCreation.rawValue)
    static let dateOfChange = Expression<Double>(CodingKeys.dateOfChange.rawValue)
    static let lastUpdated = Expression<String>(CodingKeys.lastUpdated.rawValue)
}

class SQLiteManager {
    static let shared = SQLiteManager()
    public var connection: Connection?
    public var todoitems: Table?
    private init() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            connection = try Connection("\(documentsDirectory)/sqliteDB.db")
            todoitems = Table("todo_items")
        } catch {
            connection = nil
            todoitems = nil
            print("hh")
        }
        createTable()
    }
    
    func dropTable() {
        guard let connection = connection,
              let todoitems = todoitems
        else { return }
        do {
            try connection.run(todoitems.delete())
        } catch {
            print("Can't drop table :(")
        }
    }
    
    func save(items: [TodoItem]) {
        for item in items {
            incertOrReplace(item: item)
        }
    }
    
    func incertOrReplace(item: TodoItem) {
        guard let connection = connection,
              let todoitems = todoitems
        else { return }
        do {
            try connection.run(todoitems.insert(or: .replace,
                                              TodoItemSQL.id <- item.id,
                                              TodoItemSQL.text <- item.text,
                                              TodoItemSQL.importance <- item.importance.rawValue,
                                              TodoItemSQL.deadline <- item.deadline?.timeIntervalSince1970,
                                              TodoItemSQL.didDone <- item.didDone,
                                              TodoItemSQL.dateOfCreation <- item.dateOfCreation.timeIntervalSince1970,
                                              TodoItemSQL.dateOfChange <- item.dateOfCreation.timeIntervalSince1970,
                                              TodoItemSQL.lastUpdated <- item.lastUpdated
                                             ))
        } catch {
            print("Can't save this item :(")
        }
    }
    
    func delete(id: String) {
        guard let connection = connection,
              let todoitems = todoitems
        else { return }
        let item = todoitems.filter(TodoItemSQL.id == id)
        do {
            try connection.run(item.delete())
        } catch {
            print("cant delete")
        }
    }
    
    func load() -> [TodoItem] {
        var collectionsOfToDoItems = [TodoItem]()
        guard let connection = connection,
              let todoitems = todoitems
        else { return collectionsOfToDoItems }
        do {
            for itemSQL in try connection.prepare(todoitems) {
                if let item = TodoItem.makeTodoItemFromSQL(itemSQL: itemSQL) {
                    collectionsOfToDoItems.append(item)
                }
            }
        } catch {
            print("can't load todoitems")
        }
        return collectionsOfToDoItems
    }
    
    private func createTable() {
        guard let connection = connection,
              let users = todoitems
        else { return }
        do {
            try connection.run(users.create { row in
                row.column(TodoItemSQL.id, unique: true)
                row.column(TodoItemSQL.text)
                row.column(TodoItemSQL.importance)
                row.column(TodoItemSQL.deadline)
                row.column(TodoItemSQL.didDone)
                row.column(TodoItemSQL.dateOfCreation)
                row.column(TodoItemSQL.dateOfChange)
                row.column(TodoItemSQL.lastUpdated)
            })
        } catch {
            print("Can't create table, \(error.localizedDescription)")
        }
        
    }
}
