//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Алия Давлетова on 19.09.2023.
//

import Foundation
import UIKit

enum TrackerFilterType: Int, CaseIterable {
    case all
    case today
    case finished
    case unfinished

    var localizedLabel: String {
        switch self {
        case .all:
            return NSLocalizedString("filters.all", comment: "")
        case .today:
            return NSLocalizedString("filters.today", comment: "")
        case .finished:
            return NSLocalizedString("filters.finished", comment: "")
        case .unfinished:
            return NSLocalizedString("filters.unfinished", comment: "")
        }
    }
}

protocol FiltersViewControllerDelegate: AnyObject {
    func selectFilter(_ filterType: TrackerFilterType) -> Void
}

final class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    weak var delegate: FiltersViewControllerDelegate?
    
    private let cellIdentifier = "FilterCell"
    
    private let titleLabel: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = NSLocalizedString("filters.title", comment: "")
        title.textAlignment = .center
        
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        title.textColor = UIColor.getAppColors(.blackDay)
        
        return title
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = rowHeight
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private var currentFilter: TrackerFilterType
    
    init(initialFilter: TrackerFilterType) {
        currentFilter = initialFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .getAppColors(.whiteDay)
        
        setupTitle()
        setupTable()
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
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(FilterTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -buttonHeight - CGFloat(44))
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TrackerFilterType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FilterTableViewCell,
            let filter = TrackerFilterType.allCases[at: indexPath.row]
        else {
            assertionFailure("should never be happen")
            return UITableViewCell()
        }
        
        cell.configure(title: NSLocalizedString(filter.localizedLabel, comment: ""))
        if filter == currentFilter {
            cell.selectRow()
        }
        
        var cornerMasks = CACornerMask()
        
        // Для первой (верхней) ячейки скругляем верхние углы
        if indexPath.row == 0 {
            cornerMasks.insert(.layerMinXMinYCorner)
            cornerMasks.insert(.layerMaxXMinYCorner)
        }
        
        // для последней (нижней) ячейки скругляем нижние ячейки
        if indexPath.row == TrackerFilterType.allCases.count - 1 {
            cornerMasks.insert(.layerMinXMaxYCorner)
            cornerMasks.insert(.layerMaxXMaxYCorner)
        }
        
        cell.configureCornersRadius(masks: cornerMasks)
        
        if indexPath.row >= 1 {
            cell.showSeparator()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedFilter = TrackerFilterType.allCases[at: indexPath.row] else {
            assertionFailure("should never be happen")
            return
        }
        
        currentFilter = selectedFilter
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
        
        delegate?.selectFilter(selectedFilter)
    }
}
