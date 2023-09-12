//
//  ListCategoriesViewController.swift
//  Tracker
//
//  Created by Алия Давлетова on 08.08.2023.
//

import Foundation
import UIKit

protocol ListCategoriesViewControllerDelegate: AnyObject {
    func selectCategory(_ category: TrackerCategory) -> Void
}

final class ListCategoriesViewController: UIViewController {
    private let viewModel: ListCategoriesViewModel
    weak var delegate: ListCategoriesViewControllerDelegate?
    
    private let cellIdentifier = "cell"
    
    private let titleLabel: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = NSLocalizedString("category", comment: "заголовок страницы со списком категорий")
        title.textAlignment = .center
        
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        title.textColor = UIColor.getAppColors(.blackDay)
        
        return title
    }()
    
    private let table: UITableView = {
        let table = UITableView()
        table.rowHeight = rowHeight
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorStyle = .none
        
        return table
    }()
    
    private let createButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.getAppColors(.blackDay)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.setTitle(
            NSLocalizedString("add.category", comment: "текст кнопки с созданием категории"),
            for: .normal
        )
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = UIColor.getAppColors(.whiteDay)
        button.titleLabel?.textAlignment = .center
        
        return button
    }()
    
    private lazy var emptyCollectionView: UIView = {
        let view = UIView()
        let imageView = UIImageView(image: UIImage(named: "star"))
        let label = UILabel()
        label.text = NSLocalizedString("empty.list.of.categories", comment: "текст для пустого списка категорий") 
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        return view
    }()
    
    var selectedCategory: TrackerCategory?
    
    init(_ viewModel: ListCategoriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.getAppColors(.whiteDay)
        
        setupTitle()
        setupTable()
        setupButton()
        
        if viewModel.listOfCategories.count == 0 {
            showEmptyView()
        }
        
        viewModel.$listOfCategories.bind { [weak self] _ in
            guard let self = self else { return }
            self.table.reloadData()
        }
        
        viewModel.$selectedCategory.bind { [weak self] category in
            guard let self = self else {
                assertionFailure("self is empty")
                return
            }

            guard let category = category else {
                assertionFailure("selected category is empty")
                return
            }
            
            guard let delegate = delegate else {
                assertionFailure("select category: delegate is empty")
                return
            }
            
            delegate.selectCategory(category)
        }
    }

    private func setupTitle() {
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }
    
    private func setupTable() {
        table.dataSource = self
        table.delegate = self
        
        table.register(ListCategoriesViewControllerCell.self, forCellReuseIdentifier: cellIdentifier)
       
        view.addSubview(table)
        
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -buttonHeight - CGFloat(44))
        ])
    }
    
    private func setupButton() {
        view.addSubview(createButton)
      
        createButton.addTarget(self, action: #selector(didTapCreationButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            createButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            createButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -39),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
    
    @objc func didTapCreationButton() {
        let createCategoryVC = CreateCategoryViewController()
        createCategoryVC.delegate = self
        createCategoryVC.modalPresentationStyle = .popover
        self.present(createCategoryVC, animated: true)
    }
    
    private func showEmptyView() {
        view.addSubview(emptyCollectionView)
        
        NSLayoutConstraint.activate([
            emptyCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyCollectionView.centerYAnchor.constraint(equalTo: table.centerYAnchor)
        ])
    }
}

extension ListCategoriesViewController: CreateCategoryViewControllerDelegate {
    func createCategory(_ category: TrackerCategory) {
        viewModel.addTrackerCategory(category: category)
    }
}

extension ListCategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.listOfCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ListCategoriesViewControllerCell
        
        guard let category = viewModel.listOfCategories[at: indexPath.row] else {
            assertionFailure("failed to get category from viewModel.listOfCategories by index \(indexPath)")
            return UITableViewCell()
        }
        
        cell.configure(title: category.name)

        if let selectedCategory = selectedCategory,
           category.id == selectedCategory.id
        {
            cell.selectRow()
        }
        
        var cornerMasks = CACornerMask()
        // Для первой (верхней) ячейки скругляем верхние углы
        if indexPath.row == 0 {
            cornerMasks.insert(.layerMinXMinYCorner)
            cornerMasks.insert(.layerMaxXMinYCorner)
        }
        // для последней (нижней) ячейки скругляем нижние ячейки
        if indexPath.row == viewModel.listOfCategories.count - 1 {
            cornerMasks.insert(.layerMinXMaxYCorner)
            cornerMasks.insert(.layerMaxXMaxYCorner)
        }
        cell.configureCornersRadius(masks: cornerMasks)
        
        // Если количество свойств > 1, то у каждой нечетной ячейки сверху отрисовываем линию
        if viewModel.listOfCategories.count > 1 && indexPath.row >= 1 {
            cell.showSeparator()
        }
        
        return cell
    }
}

extension ListCategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectTrackerCategory(indexPath: indexPath)
        dismiss(animated: true, completion: nil)
    }
}
