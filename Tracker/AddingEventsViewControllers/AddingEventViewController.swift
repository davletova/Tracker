//
//  AddingHabit.swift
//  Tracker
//
//  Created by Алия Давлетова on 07.08.2023.
//

import Foundation
import UIKit

final class AddingEvent: UIViewController {
//    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var categoryButton: UIButton!
    
//    var isHabit: Bool
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "WhiteDay")
        createTitle()
        createNameInput()
        createCategory()
    }
    
    func createTitle() {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Новое нерегулярное событие"
        title.textAlignment = .center
        
        title.font = UIFont.systemFont(ofSize: 16)
        title.textColor = UIColor(named: "BlackDay")
        view.addSubview(title)
        
        title.widthAnchor.constraint(equalToConstant: 288).isActive = true
        title.heightAnchor.constraint(equalToConstant: 22).isActive = true
        title.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        title.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        titleLabel = title
    }
    
    func createNameInput() {
        let input = UITextField(frame: CGRect(x: 0, y: 0, width: 288, height: 75))
        input.translatesAutoresizingMaskIntoConstraints = false
        input.backgroundColor = UIColor(named: "BackgroundDay")
        input.layer.cornerRadius = 16
        input.placeholder = "Введите название трекера"
        view.addSubview(input)
        
        input.widthAnchor.constraint(equalToConstant: 288).isActive = true
        input.heightAnchor.constraint(equalToConstant: 75).isActive = true
        input.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        input.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        nameInput = input
    }
    
    func createCategory() {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.backgroundColor = .lightGray
        button.setTitle("Категория", for: .normal)
        
        //TODO
        button.titleLabel!.font = UIFont.systemFont(ofSize: 17)
        button.titleLabel!.textAlignment = .left
        button.titleLabel!.textColor = .red
        
        button.addTarget(self, action: #selector(openCategories), for: .touchUpInside)
        view.addSubview(button)
        categoryButton = button
        
        button.topAnchor.constraint(equalTo: nameInput.bottomAnchor, constant: 10).isActive = true
        button.heightAnchor.constraint(equalToConstant: 75).isActive = true
        button.widthAnchor.constraint(equalToConstant: 288).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    @objc func openCategories() {
        var categoriesVC = ListCategoriesViewController()
        
        categoriesVC.modalPresentationStyle = .popover
//        popup.popoverPresentationController?.passthroughViews = nil
        self.present(categoriesVC, animated: true)
    }
}
