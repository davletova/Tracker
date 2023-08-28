//
//  ListCategoriesViewController.swift
//  Tracker
//
//  Created by Алия Давлетова on 08.08.2023.
//

import Foundation
import UIKit

final class ListCategoriesViewController: UIViewController {
    private let trackerCategoriesStore = TrackerCategoryStore()
    
    private var listOfCategories = [TrackerCategory]()
    private let cellIdentifier = "cell"
    private let buttonHeight: CGFloat = 60
    
    private var titleLabel: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Категория"
        title.textAlignment = .center
        
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        title.textColor = BlackDayColor
        
        return title
    }()
    
    private var table: UITableView = {
        let table = UITableView()
        table.rowHeight = RowHeight
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = BackgroundDayColor
        table.layer.cornerRadius = 16
        table.separatorStyle = .singleLine
        
        return table
    }()
    
    private var createButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = BlackDayColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.titleLabel?.textColor = WhiteDayColor
        button.titleLabel?.textAlignment = .center
        
        return button
    }()
    
    var delegate: ListCategoriesDelegateProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = WhiteDayColor
        
        listOfCategories = try! trackerCategoriesStore.getCategories()
        
        setupTitle()
        setupTable()
        setupButton()
        
        if listOfCategories.count == 0 {
            showEmptyCollection()
        }
    }
    
    func setupTitle() {
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }
    
    func setupTable() {
        table.dataSource = self
        table.delegate = self
        
        table.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
       
        view.addSubview(table)
        
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            table.heightAnchor.constraint(equalToConstant: RowHeight * CGFloat(listOfCategories.count)),
            table.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -buttonHeight - CGFloat(44))
        ])
    }
    
    func setupButton() {
        view.addSubview(createButton)
      
        createButton.addTarget(self, action: #selector(createCategory), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            createButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            createButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -39),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
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
        return listOfCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = listOfCategories[indexPath.row].name
        cell.backgroundColor = BackgroundDayColor
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        return cell
    }
}

extension ListCategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let delegate = delegate else {
            assertionFailure("save category: delegate is empty")
            return
        }
        guard let category = listOfCategories.safetyAccessElement(at: indexPath.row) else  {
            assertionFailure("failed to get categoty from listOfCategories")
            return
        }
        
        delegate.saveCategory(category: category)
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}
