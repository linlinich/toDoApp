//
//  ToDoItemsViewIO.swift
//  ToDoListProject
//
//  Created by Ангелина Решетникова on 30.06.2023.
//

import Foundation

// MARK: - ToDoItems ViewInput
protocol ToDoItemsViewInput: AnyObject {
    func reload()
    func changeNetworkStatus()
    func showLoadingView()
    func hideLoadingView()
}

// MARK: - ToDoItems ViewOutput
protocol ToDoItemsViewOutput: AnyObject {
    func didLoadView()
    func displayToDoItems(row: Int, type: ToDoItemsViewController.TypeOfTableView) -> TodoItem?
    func getCellsCount(type: ToDoItemsViewController.TypeOfTableView) -> Int
    func countOfCompleted() -> Int
    func deleteItem(type: ToDoItemsViewController.TypeOfTableView, row: Int)
    func changeIsDone(type: ToDoItemsViewController.TypeOfTableView, row: Int)
    func checkIsDone(type: ToDoItemsViewController.TypeOfTableView, row: Int) -> Bool
    func changeItem(item: TodoItem)
    func addItem(item: TodoItem)
    var isDirty: Bool { get }
}
