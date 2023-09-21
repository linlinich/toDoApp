//
//  ToDoItemsPresenter.swift
//  ToDoListProject
//
//  Created by Ангелина Решетникова on 30.06.2023.
//

import Foundation

final class ToDoItemsPresenter {
    
    weak var  view: ToDoItemsViewInput?
    weak var moduleOutput: ToDoItemsModuleOutput?
    var isDirty: Bool {
        didSet {
            DispatchQueue.main.async {
                self.view?.changeNetworkStatus()
            }
        }
    }
    
    var toDoItems = [TodoItem]()
    private let model: ToDoItemsModelInput
    init(view: ToDoItemsViewInput, model: ToDoItemsModelInput, isDirty: Bool = false) {
        self.view = view
        self.model = model
        self.isDirty = isDirty
    }
    
    func didLoadView() {
        loadToDoItems()
    }

}

private extension ToDoItemsPresenter {
    func loadToDoItems() {
        model.loadToDoItems()
    }
}

extension ToDoItemsPresenter: ToDoItemsViewOutput {
    func changeItem(item: TodoItem) {
        if let index = toDoItems.firstIndex(where: {item.id == $0.id}) {
            toDoItems[index] = item
            view?.reload()
        } else {
           return
        }
        model.editingItem(item: item)
    }
    
    func addItem(item: TodoItem) {
        view?.reload()
        toDoItems.append(item)
        self.toDoItems = toDoItems.sorted(by: {$0.dateOfCreation > $1.dateOfCreation})
        model.addingNewItem(item: item)
    }
    
    func loading() {
        view?.showLoadingView()
    }
    
    func endLoading() {
        view?.hideLoadingView()
    }
    
    func checkIsDone(type: ToDoItemsViewController.TypeOfTableView, row: Int) -> Bool {
        if row < toDoItems.count {
            var item: TodoItem
            switch type {
            case .all:
                item = toDoItems[row]
            case .undone:
                item = toDoItems.filter { $0.didDone == false }[row]
            }
            return item.didDone
        }
        return true
    }
    
    func changeIsDone(type: ToDoItemsViewController.TypeOfTableView, row: Int) {
        if row < toDoItems.count {
            var item: TodoItem
            switch type {
            case .all:
                item = toDoItems[row]
                item.didDone = !toDoItems[row].didDone
                toDoItems[row] = item
            case .undone:
                item = toDoItems.filter { $0.didDone == false }[row]
                item.didDone = true
                if let index = toDoItems.map({$0.id}).firstIndex(of: item.id) {
                    toDoItems[index] = item
                }
            }
            model.editingItem(item: item)
            self.toDoItems = toDoItems.sorted(by: {$0.dateOfCreation > $1.dateOfCreation})
            view?.reload()
        }
    }
    
    func deleteItem(type: ToDoItemsViewController.TypeOfTableView, row: Int) {
        if row < toDoItems.count {
            switch type {
            case .all:
                let id = toDoItems[row].id
                model.deleteItem(id: id)
                if let index = toDoItems.map({$0.id}).firstIndex(of: id) {
                    toDoItems.remove(at: index)
                }
                view?.reload()
            case .undone:
                let id = toDoItems.filter { $0.didDone == false }[row].id
                model.deleteItem(id: id)
                if let index = toDoItems.map({$0.id}).firstIndex(of: id) {
                    toDoItems.remove(at: index)
                }
                view?.reload()
            }
        }
    }
    
    func countOfCompleted() -> Int {
        return toDoItems.filter { $0.didDone == true }.count
    }
    
    func displayToDoItems(row: Int, type: ToDoItemsViewController.TypeOfTableView) -> TodoItem? {
        switch type {
        case .all:
            if row < toDoItems.count {
                return toDoItems[row]
            }
        case .undone:
            if row < toDoItems.filter({ $0.didDone == false }).count {
                return toDoItems.filter { $0.didDone == false }[row]
            }
        }
        return nil
    }
    
    func getCellsCount(type: ToDoItemsViewController.TypeOfTableView) -> Int {
        switch type {
        case .all:
            return toDoItems.count
        case .undone:
            return toDoItems.filter { $0.didDone == false }.count
        }
    }
    
    
}

extension ToDoItemsPresenter: ToDoItemsModelOutput {
    
    func didRecieveData(items: [TodoItem]) {
        self.toDoItems = items.sorted(by: {$0.dateOfCreation > $1.dateOfCreation})
        view?.reload()
    }
    
    func reloadToDoItems() {
        model.reloadToDoItems(items: toDoItems)
    }
}
