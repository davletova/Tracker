//
//  CreateCategoryViewController.swift
//  Tracker
//
//  Created by Алия Давлетова on 08.08.2023.
//

import Foundation
import UIKit

final class CreateCategoryViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var done: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "WhiteDay")
        createTitle()
        createNameInput()
        createButton()
    }
    
    func createTitle() {
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
        
        titleLabel = title
    }
    
    func createNameInput() {
        let input = UITextField(frame: CGRect(x: 0, y: 0, width: 288, height: 75))
        input.translatesAutoresizingMaskIntoConstraints = false
        input.backgroundColor = UIColor(named: "BackgroundDay")
        input.layer.cornerRadius = 16
        input.placeholder = "Введите название категории"
        input.leftView = UIView(frame: CGRectMake(0, 0, 16, input.frame.height))
        input.leftViewMode = .always
        view.addSubview(input)
        
        input.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        input.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        input.heightAnchor.constraint(equalToConstant: 75).isActive = true
        input.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        input.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        input.addTarget(self, action: #selector(textFieldDidChange(_:)), for: <#T##UIControl.Event#>)
        
        nameInput = input
    }
    
    func createButton() {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "BlackDay")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.titleLabel?.textColor = UIColor(named: "WhiteDay")
        button.titleLabel?.textAlignment = .center
//        button.addTarget(self, action: #selector(createCategory), for: .touchUpInside)

        view.addSubview(button)
        
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24).isActive = true
        done = button
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        //do something here
    }
}
