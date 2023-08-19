//
//  ListCategoriesViewController.swift
//  Tracker
//
//  Created by Алия Давлетова on 08.08.2023.
//

import Foundation
import UIKit

final class ListCategoriesViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addCategory: UIButton!
    
    let categories = mockCategories
    let cellIdentifier = "cell"
    let rowHeight: CGFloat = 75
    let buttonHeight: CGFloat = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "WhiteDay")
        
        createTitle()
        createTable()
        createButton()
        
        if categories.count == 0 {
            showEmptyCollection()
        }
    }
    
    func createTitle() {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Категория"
        title.textAlignment = .center
        
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        title.textColor = UIColor(named: "BlackDay")
        view.addSubview(title)
        
        title.widthAnchor.constraint(equalToConstant: 288).isActive = true
        title.heightAnchor.constraint(equalToConstant: 22).isActive = true
        title.topAnchor.constraint(equalTo: view.topAnchor, constant: 24).isActive = true
        title.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        titleLabel = title
    }
    
    func createTable() {
        let table = UITableView()
        
        view.addSubview(table)
        table.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        table.dataSource = self
        table.delegate = self
        
        table.rowHeight = rowHeight
        
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = UIColor(named: "BackgroundDay")
        table.layer.cornerRadius = 16
        table.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: table.frame.size.width, height: 1))
        
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            table.heightAnchor.constraint(equalToConstant: rowHeight * CGFloat(categories.count)),
            table.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -buttonHeight - CGFloat(44))
        ])
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
        button.addTarget(self, action: #selector(createCategory), for: .touchUpInside)

        view.addSubview(button)
        
        addCategory = button
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 288),
            button.heightAnchor.constraint(equalToConstant: buttonHeight),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24)
        ])
    }
    
    func showEmptyCollection() {
        let imageView = UIImageView(image: UIImage(named: "star"))
        imageView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(imageView)
        
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    @objc func createCategory() {
        let createCategoryVC = CreateCategoryViewController()
        
        createCategoryVC.modalPresentationStyle = .popover
        self.present(createCategoryVC, animated: true)
    }
}

extension ListCategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        cell.backgroundColor = UIColor(named: "BackgroundDay")
        return cell
    }
}

extension ListCategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
}
