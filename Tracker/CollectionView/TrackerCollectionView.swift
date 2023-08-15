//
//  ViewController.swift
//  Tracker
//
//  Created by Алия Давлетова on 27.07.2023.
//

import UIKit

let cellIdentifier = "cell"

struct GeometricParams {
    let cellCount: Int
    let leftInset: CGFloat
    let rightInset: CGFloat
    let cellSpacing: CGFloat
    // Параметр вычисляется уже при создании, что экономит время на вычислениях при отрисовке коллекции.
    let paddingWidth: CGFloat
    
    init(cellCount: Int, leftInset: CGFloat, rightInset: CGFloat, cellSpacing: CGFloat) {
        self.cellCount = cellCount
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.cellSpacing = cellSpacing
        self.paddingWidth = leftInset + rightInset + CGFloat(cellCount - 1) * cellSpacing
    }
}

final class TrackerCollectionView: UIViewController {
    static let CreateEventNotification = Notification.Name(rawValue: "CreateEvent")
    
    var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private var trackerService: TrackerServiceProtocol?
    private var visibleEventsByCategory = [Section]()
    private var completedEvents = Set<UUID>()
    private var datePicker: UIDatePicker = UIDatePicker()
    private let params = GeometricParams(cellCount: 2, leftInset: 10, rightInset: 10, cellSpacing: 10)
    
    private let emptyCollectionImageView = UIImageView(image: UIImage(named: "star"))
    private let searchController = UISearchController(searchResultsController: nil)
    private var currentTask: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            forName: TrackerCollectionView.CreateEventNotification,
            object: nil,
            queue: OperationQueue.main
        ) { notification in
            guard let event = notification.userInfo?["event"] as? Event else {
                print("failed to convert event: \(String(describing: notification.userInfo?["event"]))")
                return
            }
            
            var sectionIndex = self.visibleEventsByCategory.firstIndex(where: { $0.categoryName == event.category.name })
            
            if sectionIndex == nil {
                sectionIndex = self.visibleEventsByCategory.count
                self.visibleEventsByCategory.append(Section(categoryName: event.category.name, events: [event]))
            } else {
                var section = self.visibleEventsByCategory[sectionIndex!]
                section.events.append(event)
                self.visibleEventsByCategory[sectionIndex!] = section
            }
        
            let indexPath = IndexPath(row: self.visibleEventsByCategory[sectionIndex!].events.count-1, section: sectionIndex!)
            
            self.collectionView.performBatchUpdates {
                self.collectionView.insertItems(at: [indexPath])
            }
        }
        
        trackerService = TrackerService(trackerRecordService: TrackerRecordService())
        visibleEventsByCategory = trackerService!.getEvents(by: datePicker.date)
        completedEvents = trackerService!.getCompletedEvents(by: datePicker.date)
        
        searchController.searchResultsUpdater = self
        
        view.backgroundColor = UIColor(named: "WhiteDay")
        createNavigationBar()
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        setConstraint()
        
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(SupplementaryView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "header")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if visibleEventsByCategory.count == 0 {
            showEmptyCollection()
        }
    }

    func showEmptyCollection() {
        emptyCollectionImageView.translatesAutoresizingMaskIntoConstraints = false

        collectionView.addSubview(emptyCollectionImageView)
        
        emptyCollectionImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emptyCollectionImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func setConstraint() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func createNavigationBar() {
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.backgroundColor = UIColor(named: "WhiteDay")
            navigationBar.tintColor = .black
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "add"), style: .plain, target: self, action: #selector(createEvent))
            
            datePicker.preferredDatePickerStyle = .compact
            datePicker.datePickerMode = UIDatePicker.Mode.date
            datePicker.addTarget(self, action: #selector(changeDate(_:)), for: .valueChanged)
           
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            
            navigationBar.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor(named: "BlackDay") as Any,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 34, weight: UIFont.Weight.bold),
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ] as [NSAttributedString.Key : Any]
            navigationItem.title = "Трекеры"

            navigationBar.prefersLargeTitles = true
            
            navigationItem.searchController = searchController
        }
    }
    
    @objc func createEvent() {
        let typeSelectionViewController = TypeSelectionViewController()
        typeSelectionViewController.trackerService = trackerService
        typeSelectionViewController.modalPresentationStyle = .popover
        self.present(typeSelectionViewController, animated: true)
    }
    
    @objc func changeDate(_ datePicker: UIDatePicker) {
        guard let trackerService = trackerService else {
            print("changeDate: trackerService is empty")
            return
        }
        visibleEventsByCategory = trackerService.getEvents(by: datePicker.date)
        completedEvents = trackerService.getCompletedEvents(by: datePicker.date)
        print(completedEvents)
        collectionView.reloadData()
        presentedViewController?.dismiss(animated: true)
    }
}

extension TrackerCollectionView: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // Отменяем предыдущую задачу
        currentTask?.cancel()
        
        // Создаем новую задачу для выполнения поискового запроса
        let newTask = DispatchWorkItem { [weak self] in
            // Выполняем поисковый запрос
            self?.performSearch(with: searchController.searchBar.text)
        }
        
        // Сохраняем новую задачу для последующей отмены
        currentTask = newTask
        
        // Запускаем новую задачу с небольшой задержкой
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: newTask)
    }
    
    func performSearch(with query: String?) {
        guard let query = query else {
            return
        }
        
        // Выполняем поиск на основе запроса
        print("Searching for: \(query)")
        
        guard let trackerService = trackerService else {
            print("performSearch: trackerService is empty")
            return
        }
    
        var events = trackerService.getEvents(by: datePicker.date)
        
        if query.isEmpty {
            if events.count == visibleEventsByCategory.count {
                return
            }
            visibleEventsByCategory = events
            collectionView.reloadData()
            return
        }
        
        for i in (0..<events.count).reversed() {
            events[i].events = events[i].events.filter({ $0.name.lowercased().contains(query.lowercased()) })
            
            if events[i].events.isEmpty {
                events.remove(at: i)
            }
        }
        
        reloadCollection(events: events)
    }
    
    func reloadCollection(events: [Section]) {
        visibleEventsByCategory = events
        collectionView.reloadData()
    }
}

extension TrackerCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleEventsByCategory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = visibleEventsByCategory.safelyAccessElement(at: section) else {
            print("failed to get section from collection by index \(section)")
            return 0
        }
        
        return section.events.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? TrackerCollectionViewCell else {
            print("failed to convert cell to TrackerCollectionViewCell")
            return UICollectionViewCell()
        }
        
        guard let section = visibleEventsByCategory.safelyAccessElement(at: indexPath.section) else {
            print("failed to get section from collection by index \(indexPath.section)")
            return UICollectionViewCell()
        }
        
        guard let event = section.events.safelyAccessElement(at: indexPath.row) else {
            print("failed to get element from section: \(section.categoryName) by index \(indexPath.row)")
            return UICollectionViewCell()
        }
        
        cell.event = event
        cell.isCompletedEvent = completedEvents.contains(event.id)
        cell.contentView.layer.cornerRadius = 16
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
        default:
            id = ""
        }

        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? SupplementaryView else {
            print("fialed to convert SupplementaryView")
            return UICollectionReusableView()
        }
        
        view.titleLabel.text = visibleEventsByCategory[indexPath.section].categoryName
        
        return view
    }
}

extension TrackerCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Доступная ширина после вычета отступов
        let availableWidth = collectionView.frame.width - self.params.paddingWidth
        // Ширина ячейки
        let cellWidth =  availableWidth / CGFloat(self.params.cellCount)
        
        return CGSize(width: cellWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)

        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)

        return headerView.systemLayoutSizeFitting(
            CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel)
    }
}

class MyViewController: UIViewController, UISearchResultsUpdating {
    let searchController = UISearchController(searchResultsController: nil)
    var currentTask: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        // Отменяем предыдущую задачу
        currentTask?.cancel()
        
        // Создаем новую задачу для выполнения поискового запроса
        let newTask = DispatchWorkItem { [weak self] in
            // Выполняем поисковый запрос
            self?.performSearch(with: searchController.searchBar.text)
        }
        
        // Сохраняем новую задачу для последующей отмены
        currentTask = newTask
        
        // Запускаем новую задачу с небольшой задержкой
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: newTask)
    }
    
    func performSearch(with query: String?) {
        guard let query = query else {
            return
        }
        
        // Выполняем поиск на основе запроса
        print("Searching for: \(query)")
    }
}

