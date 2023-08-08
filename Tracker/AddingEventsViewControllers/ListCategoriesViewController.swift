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
//    @IBOutlet weak var tableView: UITableView!
    
    let categories = mockCategories
    let cellIdentifier = "cell"
    let rowHeight: CGFloat = 75
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "WhiteDay")
        
        createTitle()
        
//        var table = UITableView()
        
        let table = UITableView()
        
        view.addSubview(table)
        table.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        table.dataSource = self
        table.delegate = self
        
        table.rowHeight = rowHeight
        
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = UIColor(named: "BackgroundDay")
        table.layer.cornerRadius = 16
        table.separatorColor = .gray
        table.separatorStyle = .singleLine
        
        table.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        table.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -90).isActive = true
        table.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        table.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 10).isActive = true
        table.heightAnchor.constraint(equalToConstant: rowHeight * categories.count)
        
//        tableView = table
        
        createButton()
    }
    
    func createTitle() {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Категория"
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
    
    func createButton() {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "BlackDay")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.titleLabel?.textColor = UIColor(named: "WhiteDay")
        button.titleLabel?.textAlignment = .center
//        button.addTarget(self, action: #selector(goToCreateEvent), for: .touchUpInside)

        view.addSubview(button)
        
        addCategory = button
        
        button.widthAnchor.constraint(equalToConstant: 280).isActive = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
    }
}

extension ListCategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(categories)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        cell.backgroundColor = UIColor(named: "BackgroundDay")
        return cell
//
//        let cell: UITableViewCell
//
//        if let reusedCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
//            cell = reusedCell
//        } else {
//            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
//        }
//
//        cell.textLabel?.text = categories[indexPath.row].name

        return cell
    }
}

extension ListCategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true, completion: nil)
    }
}



//
//class ViewController: UIViewController {
//    let words = [
//        ["Apple", "Pear", "Watermelon"],
//        ["Carrot", "Pickle", "Potato", "Tomato"],
//        ["Strawberry", "Rasberry", "Blackberry", "Blueberry"]
//    ]
//
//    let headers = ["Fruits", "Vegetables", "Berries"]
//
//    @IBOutlet weak var tableView: UITableView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        tableView.sectionHeaderHeight = 32
//
//        // Do any additional setup after loading the view.
//    }
//}
//
//extension ViewController: UITableViewDataSource {
//

