//
//  AddingViewController.swift
//  ToDoListProject
//
//  Created by Ангелина Решетникова on 23.06.2023.
//

import Foundation
import UIKit

protocol SingleTaskViewControllerOutput: AnyObject {
    func reloadData()
    func changeItem(item: TodoItem)
    func addItem(item: TodoItem)
}


final class SingleTaskViewController: UIViewController {
    
    var output: SingleTaskViewControllerOutput?
    var informationOutput: InInformationTaskViewOutput? = InformationTaskView()
    private let model = ToDoItemsModel()
    
    var todoItem: TodoItem?
    
    func configure(item: TodoItem?) {
        if let item {
            listItem.text = item.text
            listItem.textColor = UIColor(asset: Asset.Colors.labelPrimary)

            informationTaskView.setImportance(importanceCheck: item.importance)
            informationTaskView.setDate(newDate: item.deadline ?? .now)
            
            if let deadline = item.deadline {
                informationTaskView.switchControl.isOn = true
                calendarView.date = deadline
                informationTaskView.switchControlChangedValue()
            }
            
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    var stackView = UIStackView()
    let scrollView = UIScrollView()
    var stackViewWithInformation = UIStackView()
    var informationTaskView = InformationTaskView()
    
    lazy var listItem: UITextView = {
        let item = UITextView()
        item.heightAnchor.constraint(greaterThanOrEqualToConstant: 120).isActive = true
        item.layer.cornerRadius = 16
        item.text = "Что надо сделать?"
        item.textColor = UIColor(asset: Asset.Colors.labelTertiary)
        item.font = .systemFont(ofSize: 17)
        item.textContainerInset = UIEdgeInsets(top: 17, left: 16, bottom: 12, right: 16)
        item.isScrollEnabled = false
        
        item.delegate = self
        item.backgroundColor = UIColor(asset: Asset.Colors.backSecondary)
        return item
    }()
    
    lazy var calendarView: UIDatePicker = {
        let calendar = UIDatePicker()
        calendar.datePickerMode = .date
        calendar.preferredDatePickerStyle = .inline
        let tommorowDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? .now
        calendar.date = todoItem?.deadline ?? tommorowDate
        calendar.addTarget(self, action: #selector(didChangeDate), for: .valueChanged)
        calendar.translatesAutoresizingMaskIntoConstraints = false
        if let localeID = Locale.preferredLanguages.first {
            calendar.locale = Locale(identifier: localeID)
        }
        calendar.minimumDate = .now
        return calendar
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(asset: Asset.Colors.backSecondary)
        button.layer.cornerRadius = 16
        button.setTitle("Удалить", for: .normal)
        if todoItem != nil {
            button.setTitleColor(UIColor(asset: Asset.Colors.red), for: .normal)
        } else {
            button.setTitleColor(UIColor(asset: Asset.Colors.labelTertiary), for: .normal)
        }
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        button.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let separator: UIView = {
        let separator = UIView()
        separator.backgroundColor = UIColor(asset: Asset.Colors.separator)
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }()
    
    
    private func setapStackAndScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        informationTaskView.configure(delegate: self)
        stackViewWithInformation = UIStackView(arrangedSubviews: [informationTaskView, separator, calendarView])
        separator.isHidden = true
        calendarView.isHidden = true
        stackViewWithInformation.backgroundColor = UIColor(asset: Asset.Colors.backSecondary)
        stackViewWithInformation.spacing = 0
        stackViewWithInformation.axis = .vertical
        stackViewWithInformation.layer.cornerRadius = 16
        stackView = UIStackView(arrangedSubviews: [listItem, stackViewWithInformation, deleteButton])
        scrollView.addSubview(stackView)
        stackView.spacing = 16
        stackView.axis = .vertical
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(asset: Asset.Colors.backPrimary)
        setupNavBar()
        setapStackAndScrollView()
        configure(item: todoItem)
        makeConstraints()
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        setupKeyboardSettings()
    }
    override func viewWillDisappear(_ animated: Bool) {
        removeKeyboardSettings()
    }
    
    private func setupKeyboardSettings() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: self.view.window)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: self.view.window)
    }
    
    private func removeKeyboardSettings() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            view.frame.size.height -= keyboardSize.height
        }
    }
    @objc func keyboardWillHide(sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            view.frame.size.height += keyboardSize.height
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            if UIDevice.current.orientation.isLandscape {
                self.deleteButton.isHidden = true
                self.stackViewWithInformation.isHidden = true
                self.listItem.heightAnchor.constraint(greaterThanOrEqualToConstant: 330).isActive = true
                self.listItem.heightAnchor.constraint(equalToConstant: 330).isActive = false
            } else {
                self.deleteButton.isHidden = false
                self.stackViewWithInformation.isHidden = false
                self.listItem.heightAnchor.constraint(equalToConstant: 120).isActive = true
                self.listItem.heightAnchor.constraint(equalToConstant: 120).isActive = false
            }

        }, completion: nil)
    }

    
    private func setupNavBar() {
        navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 56)
        let saveButtonItem = UIBarButtonItem(title: "Сохранить",
                                             style: .done,
                                             target: self,
                                             action: #selector(didTapSaveButton))

        let canselButtonItem = UIBarButtonItem(title: "Отменить",
                                             style: .plain,
                                             target: self,
                                             action: #selector(didTapCanselButton))
        if todoItem == nil {
            saveButtonItem.isEnabled = false
        }
        navigationItem.leftBarButtonItem = canselButtonItem
        navigationItem.rightBarButtonItem = saveButtonItem
        title = "Дело"
    }
    
    private func makeConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            calendarView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            calendarView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            separator.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16)
        ])
    }
    
    @objc
    func switchControlChangedValue() {
        informationTaskView.switchControlChangedValue()
    }
    
    @objc
    func didTapCanselButton() {
        self.dismiss(animated: true)
    }
    
    @objc
    func didTapSaveButton() {
        let importance = informationTaskView.returnImportance()
        if let text = listItem.text {
            var deadline: Date?
            if informationTaskView.switchControl.isOn == true {
                deadline = calendarView.date
            }
            let item: TodoItem
            if let inputTodoItem = todoItem {
                item = TodoItem(id: inputTodoItem.id,
                                text: text,
                                importance: importance,
                                deadline: deadline,
                                dateOfCreation: inputTodoItem.dateOfCreation,
                                dateOfChange: .now,
                                lastUpdated: "kkd")
                output?.changeItem(item: item)
            } else {
                item = TodoItem(text: text,
                                importance: importance,
                                deadline: deadline,
                                dateOfChange: .now,
                                lastUpdated: "kdkd")
                output?.addItem(item: item)
            }
            self.dismiss(animated: true)
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        if listItem.text.count < 1 {
            listItem.text = "Что надо сделать?"
            listItem.textColor = UIColor(asset: Asset.Colors.labelTertiary)
        }
    }
    
    @objc
    func didChangeDate() {
        informationTaskView.setDate(newDate: calendarView.date)
    }
    
    @objc
    func didTapDeleteButton() {
        if let id = todoItem?.id {
            model.deleteItem(id: id)
            output?.reloadData()
        }
        self.dismiss(animated: true)
    }
}

extension SingleTaskViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor(asset: Asset.Colors.labelTertiary) {
            textView.text = nil
            textView.textColor = UIColor(asset: Asset.Colors.labelPrimary)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.textColor == UIColor(asset: Asset.Colors.labelPrimary) && textView.text.count > 0 {
            navigationItem.rightBarButtonItem?.isEnabled = true
            deleteButton.setTitleColor(UIColor(asset: Asset.Colors.red), for: .normal)
        }
    }
}

extension SingleTaskViewController: InInformationTaskViewDelegate {
    
    func closeCalendar() {
        self.calendarView.alpha = 1
        separator.isHidden = true
        UIView.animate(withDuration: 0.5) {
            self.calendarView.alpha = 0
            self.calendarView.isHidden = true
        }
    }
    
    
    func didTapDate() {
        separator.isHidden.toggle()
        var alpha: CGFloat = 0
        if calendarView.isHidden {
            calendarView.alpha = 0
            alpha = 1
        } else {
            calendarView.alpha = 1
            alpha = 0
        }
        UIView.animate(withDuration: 0.5) {
            self.calendarView.alpha = alpha
            self.calendarView.isHidden.toggle()
        }
    }
}
