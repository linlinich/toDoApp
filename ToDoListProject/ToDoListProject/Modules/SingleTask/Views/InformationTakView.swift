//
//  InformationTakView.swift
//  ToDoListProject
//
//  Created by Ангелина Решетникова on 23.06.2023.
//

import Foundation
import UIKit


@objc
protocol InInformationTaskViewDelegate: AnyObject {
    func didTapDate()
    func switchControlChangedValue()
    func closeCalendar()
}

protocol InInformationTaskViewOutput: AnyObject {
    func didSwitchIsOn() -> Bool
}

class InformationTaskView: UIView {
    private var toDoItem: TodoItem?
    private weak var delegate: InInformationTaskViewDelegate?
    var didOpen = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.heightAnchor.constraint(greaterThanOrEqualToConstant: 112.5).isActive = true
        self.addSubview(importance)
        self.addSubview(separator)
        self.addSubview(deadline)
        self.addSubview(deadlineNewPosition)
        deadlineNewPosition.isHidden = true
        self.addSubview(date)
        date.isHidden = true
        self.addSubview(importanceSegmentControl)
        self.addSubview(switchControl)
        switchControl.addTarget(nil, action: #selector(delegate?.switchControlChangedValue), for: .valueChanged)
        date.addTarget(nil, action: #selector(delegate?.didTapDate), for: .touchUpInside)
        makeConstraints()
        ifConfigure()
    }
    
     func ifConfigure() {
        let formatter = DateFormatter()
         if let localeID = Locale.preferredLanguages.first {
             formatter.locale = Locale(identifier: localeID)
         }
        formatter.dateFormat = "d MMMM yyyy"

        if let dateFormat = toDoItem?.deadline {
            date.setTitle(formatter.string(from: dateFormat), for: .normal)
        } else {
            let tommorowDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? .now

            date.setTitle(formatter.string(from: tommorowDate), for: .normal)
        }
    }
    
    let importance: UILabel = {
        let label = UILabel()
        label.text = "Важность"
        label.font = .systemFont(ofSize: 17)
        label.textColor = UIColor(asset: Asset.Colors.labelPrimary)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let separator: UIView = {
        let separator = UIView()
        separator.backgroundColor = UIColor(asset: Asset.Colors.separator)
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }()
    
    let deadline: UILabel = {
        let label = UILabel()
        label.text = "Сделать до"
        label.font = .systemFont(ofSize: 17)
        label.textColor = UIColor(asset: Asset.Colors.labelPrimary)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let deadlineNewPosition: UILabel = {
        let label = UILabel()
        label.text = "Сделать до"
        label.font = .systemFont(ofSize: 17)
        label.textColor = UIColor(asset: Asset.Colors.labelPrimary)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let date: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 16
        button.setTitleColor(UIColor(asset: Asset.Colors.blue), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let importanceSegmentControl: UISegmentedControl = {
        let control = UISegmentedControl()
        
        let arrorDown = UIImage(systemName: "arrow.down",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))?
                                .withTintColor(UIColor(asset: Asset.Colors.gray) ?? .gray,
                                renderingMode: .alwaysOriginal)
        
        let exclamationMarks = UIImage(systemName: "exclamationmark.2",
                                       withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .bold))?
                                        .withTintColor(UIColor(asset: Asset.Colors.red) ?? .red,
                                        renderingMode: .alwaysOriginal)
        
        control.insertSegment(with: arrorDown, at: 0, animated: false)
        control.insertSegment(withTitle: "нет", at: 1, animated: false)
        control.insertSegment(with: exclamationMarks, at: 2, animated: false)
        control.layer.cornerRadius = 8.91
        control.backgroundColor = UIColor(asset: Asset.Colors.overlay)
        control.heightAnchor.constraint(equalToConstant: 36).isActive = true
        control.widthAnchor.constraint(equalToConstant: 150).isActive = true
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    let switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.heightAnchor.constraint(equalToConstant: 31).isActive = true
        switchControl.widthAnchor.constraint(equalToConstant: 51).isActive = true
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
    
    
    func makeConstraints() {
        NSLayoutConstraint.activate([
            importance.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            importance.topAnchor.constraint(equalTo: self.topAnchor, constant: 17)
        ])
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            separator.topAnchor.constraint(equalTo: importance.bottomAnchor, constant: 17)
        ])
        
        NSLayoutConstraint.activate([
            deadline.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            deadline.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 17)
        ])
        
        NSLayoutConstraint.activate([
            importanceSegmentControl.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            importanceSegmentControl.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12)
        ])
        
        NSLayoutConstraint.activate([
            switchControl.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            switchControl.topAnchor.constraint(equalTo: self.topAnchor, constant: 71)
        ])
        
        NSLayoutConstraint.activate([
            deadlineNewPosition.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            deadlineNewPosition.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 9)
        ])
        
        NSLayoutConstraint.activate([
            date.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            date.topAnchor.constraint(equalTo: deadlineNewPosition.bottomAnchor, constant: -4)
        ])
        
    }
    
    func configure(delegate: InInformationTaskViewDelegate) {
        self.delegate = delegate
    }

    func switchControlChangedValue() {
        if switchControl.isOn {
            deadline.isHidden = true
            deadlineNewPosition.isHidden = false
            date.isHidden = false
        } else {
            deadlineNewPosition.isHidden = true
            deadline.isHidden = false
            date.isHidden = true
            delegate?.closeCalendar()
            didOpen = false
        }
    }
    
    func returnImportance() -> ImportanceOfTask {
        if importanceSegmentControl.selectedSegmentIndex == 0 {
            return .unimportant
        } else if importanceSegmentControl.selectedSegmentIndex == 1 {
            return .usual
        } else if importanceSegmentControl.selectedSegmentIndex == 2 {
            return .important
        } else {
            return .usual
        }
    }
    
    func setImportance(importanceCheck: ImportanceOfTask) {
        switch importanceCheck {
        case ImportanceOfTask.unimportant:
            importanceSegmentControl.selectedSegmentIndex = 0
        case ImportanceOfTask.usual:
            importanceSegmentControl.selectedSegmentIndex = 1
        case ImportanceOfTask.important:
            importanceSegmentControl.selectedSegmentIndex = 2
        }
    }
    
    func setDate(newDate: Date) {
        let formatter = DateFormatter()
        if let localeID = Locale.preferredLanguages.first {
            formatter.locale = Locale(identifier: localeID)
        }
        formatter.dateFormat = "d MMMM yyyy"
        date.setTitle(formatter.string(from: newDate), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension InformationTaskView: InInformationTaskViewOutput {
    func didSwitchIsOn() -> Bool {
        switchControl.isOn
    }
}
