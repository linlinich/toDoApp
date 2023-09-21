//
//  Coordinator.swift
//  ToDoListProject
//
//  Created by Ангелина Решетникова on 23.06.2023.
//

import Foundation
import UIKit

protocol CoordinatorProtocol: AnyObject {
    func start(navigationController: UINavigationController)
    func finish()
}

final class Coordinator: NSObject, CoordinatorProtocol {
    
    func start(navigationController: UINavigationController) {
        let builder = ToDoItemsBuilder()
        let viewController = builder.build(moduleOutput: self)
        navigationController.pushViewController(viewController, animated: false)
    }
    
    func finish() {
    }
}

extension Coordinator: ToDoItemsModuleOutput {
    
}
