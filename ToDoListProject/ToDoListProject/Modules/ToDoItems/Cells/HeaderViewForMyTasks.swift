//
//  headerViewForMyTasks.swift
//  ToDoListProject
//
//  Created by Ангелина Решетникова on 27.06.2023.
//

import Foundation
import UIKit

@objc
protocol HeaderViewForMyTasksDelegate: AnyObject {
    func didTapShowOrHideButton()
}

class HeaderViewForMyTasks: UIView {
    
    private weak var delegate: HeaderViewForMyTasksDelegate?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(asset: Asset.Colors.labelTertiary)
        label.font = .systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let buttonShowOrHide: UIButton = {
        let button = UIButton()
        button.setTitle("Показать", for: .normal)
        button.setTitleColor(UIColor(asset: Asset.Colors.blue), for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(nil, action: #selector(didTapShowOrHideButton), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(buttonShowOrHide)
        makeConstraints()
    }
    
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
        
        NSLayoutConstraint.activate([
            buttonShowOrHide.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            buttonShowOrHide.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            buttonShowOrHide.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
        
        
    }
    
    func configure(countOfCompleted: Int, delegate: HeaderViewForMyTasksDelegate) {
        self.delegate = delegate
        let labelText = "Выполнено — " + String(countOfCompleted)
        titleLabel.text = labelText
    }
    
    func configureButtonShowOrHide() {
        if buttonShowOrHide.titleLabel?.text == "Показать" {
            buttonShowOrHide.setTitle("Cкрыть", for: .normal)
        } else {
            buttonShowOrHide.setTitle("Показать", for: .normal)
        }
    }
    
    @objc
    func didTapShowOrHideButton() {
        configureButtonShowOrHide()
        delegate?.didTapShowOrHideButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
