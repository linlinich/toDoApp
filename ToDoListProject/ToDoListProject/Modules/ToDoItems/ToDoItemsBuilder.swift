//
//  ToDoItemsBuilder.swift
//  ToDoListProject
//
//  Created by Ангелина Решетникова on 30.06.2023.
//

import UIKit

// MARK: - AccountModuleBuilder

final class ToDoItemsBuilder {
    func build(moduleOutput: ToDoItemsModuleOutput) -> UIViewController {
        let viewController = ToDoItemsViewController()
        let model = ToDoItemsModel()
        let presenter = ToDoItemsPresenter(view: viewController, model: model)
        
        presenter.moduleOutput = moduleOutput
        model.output = presenter
        viewController.output = presenter
        
        return viewController
    }
}
