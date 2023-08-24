//
//  CreateCategoryViewController.swift
//  Tracker
//
//  Created by Алия Давлетова on 08.08.2023.
//

import Foundation
import UIKit

final class CreateCategoryViewController: UIViewController {
    var categoryService: CategoryServiceProtocol?
    
    private lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Новая категория"
        title.textAlignment = .center
        
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        title.textColor = UIColor(named: "BlackDay")
        view.addSubview(title)
        
        title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        title.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        title.heightAnchor.constraint(equalToConstant: 22).isActive = true
        title.topAnchor.constraint(equalTo: view.topAnchor, constant: 24).isActive = true
        title.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        return title
    }()
    
    private lazy var nameInput: UITextField = {
        let input = UITextField(frame: CGRect(x: 0, y: 0, width: 288, height: 75))
        input.translatesAutoresizingMaskIntoConstraints = false
        input.backgroundColor = UIColor(named: "BackgroundDay")
        input.layer.cornerRadius = 16
        input.placeholder = "Введите название категории"
        input.leftView = UIView(frame: CGRectMake(0, 0, 16, input.frame.height))
        input.leftViewMode = .always
        view.addSubview(input)
        
        return input
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "BlackDay")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = UIColor(named: "WhiteDay")
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(createCategory), for: .touchUpInside)
        view.addSubview(button)
        
        return button
       
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryService = CategoryService()

        view.backgroundColor = UIColor(named: "WhiteDay")

        setConstraint()

        nameInput.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        if let nameInputText = nameInput.text,
           nameInputText.isEmpty {
            createButton.isEnabled = false
            createButton.backgroundColor = UIColor(named: "Gray")
        }
    }
    
    func setConstraint() {
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 24).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        nameInput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        nameInput.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        nameInput.heightAnchor.constraint(equalToConstant: 75).isActive = true
        nameInput.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        nameInput.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        createButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        createButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -39).isActive = true
        
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        if let nameInputText = nameInput.text,
           !nameInputText.isEmpty {
            createButton.isEnabled = true
            createButton.backgroundColor = UIColor(named: "BlackDay")
            return
        }
        
        createButton.isEnabled = false
        createButton.backgroundColor = UIColor(named: "Gray")
    }
    
    @objc func createCategory() {}
}
