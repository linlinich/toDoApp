import Foundation
import SQLite

enum ImportanceOfTask: String {
    case unimportant = "low"
    case usual = "basic"
    case important = "important"
}

struct TodoItem {
    let id: String
    let text: String
    let importance: ImportanceOfTask
    let deadline: Date?
    var didDone: Bool
    let dateOfCreation: Date
    let dateOfChange: Date
    let lastUpdated: String
    
    //private var context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    init(id: String = UUID().uuidString, text: String, importance: ImportanceOfTask, deadline: Date? = nil, didDone: Bool = false, dateOfCreation: Date = Date(), dateOfChange: Date = Date(), lastUpdated: String) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.didDone = didDone
        self.dateOfCreation = dateOfCreation
        self.dateOfChange = dateOfCreation
        self.lastUpdated = lastUpdated
    }
}

enum CodingKeys: String {
    case id
    case text
    case importance
    case deadline
    case didDone = "done"
    case dateOfCreation = "created_at"
    case dateOfChange = "changed_at"
    case lastUpdated = "last_updated_by"
}

extension TodoItem {
    static func parse(json: Any) -> TodoItem? {
        guard
            let json = json as? [String: Any],
            let id = json[CodingKeys.id.rawValue] as? String,
            let text = json[CodingKeys.text.rawValue] as? String,
            let didDone = json[CodingKeys.didDone.rawValue] as? Bool,
            let lastUpdated = json[CodingKeys.lastUpdated.rawValue] as? String,
            let dateOfCreationJson = json[CodingKeys.dateOfCreation.rawValue] as? Int,
            let dateOfChangedJson = json[CodingKeys.dateOfChange.rawValue] as? Int
        else {
            return nil
        }
        
        let importance: ImportanceOfTask
        if let importanceJson = json[CodingKeys.importance.rawValue] as? String {
            if let importanceTry = ImportanceOfTask(rawValue: importanceJson) {
                importance = importanceTry
            } else {
                return nil
            }
        } else {
            return nil
        }
        
        let dateOfCreation = Date(timeIntervalSince1970: TimeInterval(dateOfCreationJson))
        
        let deadline: Date?
        if let deadlineJson = json[CodingKeys.deadline.rawValue] as? Double {
            deadline = Date(timeIntervalSince1970: deadlineJson)
        } else {
            deadline = nil
        }
        
        let dateOfChange = Date(timeIntervalSince1970: TimeInterval(dateOfChangedJson))
        
        return TodoItem(id: id,
                        text: text,
                        importance: importance,
                        deadline: deadline,
                        didDone: didDone,
                        dateOfCreation: dateOfCreation,
                        dateOfChange: dateOfChange,
                        lastUpdated: lastUpdated)
    }
    
    static func makeTodoItemFromSQL(itemSQL: Row) -> TodoItem? {
        let id = itemSQL[TodoItemSQL.id]
        let text = itemSQL[TodoItemSQL.text]
        let didDone = itemSQL[TodoItemSQL.didDone]
        let lastUpdated = itemSQL[TodoItemSQL.lastUpdated]
        let dateOfCreationSql = itemSQL[TodoItemSQL.dateOfCreation]
        let dateOfChangedSql = itemSQL[TodoItemSQL.dateOfChange]
        let importanceSQL = itemSQL[TodoItemSQL.importance]
        
        let importance: ImportanceOfTask
        if let importanceTry = ImportanceOfTask(rawValue: importanceSQL) {
            importance = importanceTry
        } else {
            return nil
        }
        
        let dateOfCreation = Date(timeIntervalSince1970: TimeInterval(dateOfCreationSql))
        
        let deadline: Date?
        if let deadlineSql = itemSQL[TodoItemSQL.deadline] {
            deadline = Date(timeIntervalSince1970: deadlineSql)
        } else {
            deadline = nil
        }
        
        let dateOfChange = Date(timeIntervalSince1970: TimeInterval(dateOfChangedSql))
        
        return TodoItem(id: id,
                        text: text,
                        importance: importance,
                        deadline: deadline,
                        didDone: didDone,
                        dateOfCreation: dateOfCreation,
                        dateOfChange: dateOfChange,
                        lastUpdated: lastUpdated)
    }
    
    static func makeTodoItemFromCoreData(item: Item) -> TodoItem? {
        let importance: ImportanceOfTask
        guard
            let id = item.id,
            let text = item.text,
            let lastUpdated = item.last_updated_by,
            let dateOfCreation = item.created_at,
            let dateOfChanged = item.changed_at,
            let importanceCoreData = item.importance
        else {
            return nil
        }
        if let importanceTry = ImportanceOfTask(rawValue: importanceCoreData) {
            importance = importanceTry
        } else {
            return nil
        }
        
        let deadline: Date?
        if let deadlineCoreData = item.deadline {
            deadline = deadlineCoreData
        } else {
            deadline = nil
        }
        
        return TodoItem(id: id,
                        text: text,
                        importance: importance,
                        deadline: deadline,
                        didDone: item.done,
                        dateOfCreation: dateOfCreation,
                        dateOfChange: dateOfChanged,
                        lastUpdated: lastUpdated
        )
        
    }
    
    var json: Any {
        
        var json: [String: Any] = [
            CodingKeys.id.rawValue: id,
            CodingKeys.text.rawValue: text,
            CodingKeys.didDone.rawValue: didDone,
            CodingKeys.dateOfCreation.rawValue: Int(dateOfCreation.timeIntervalSince1970),
            CodingKeys.lastUpdated.rawValue: lastUpdated,
            CodingKeys.importance.rawValue: importance.rawValue,
            CodingKeys.dateOfChange.rawValue: Int(dateOfChange.timeIntervalSince1970)
        ]
        
        if let deadline = deadline {
            json[CodingKeys.deadline.rawValue] = Int(deadline.timeIntervalSince1970)
        }
        
        
        return json
    }
}
