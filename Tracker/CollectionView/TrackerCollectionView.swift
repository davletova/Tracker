//
//  ViewController.swift
//  Tracker
//
//  Created by Алия Давлетова on 27.07.2023.
//

import UIKit

let cellIdentifier = "cell"
let headerIdentifier = "header"

struct GeometricParams {
    let cellCount: Int
    let leftInset: CGFloat
    let rightInset: CGFloat
    let cellSpacing: CGFloat
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
    static let EventSavedNotification = Notification.Name(rawValue: "CreateEvent")
    
    private var trackerService: TrackerServiceProtocol?
    
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var visibleEventsByCategory = [Section]()
    private var completedEvents = Set<UUID>()
    private var datePicker: UIDatePicker = {
        var datePicker = UIDatePicker()
        var datePickerCalendar = Calendar(identifier: .gregorian)
        datePickerCalendar.firstWeekday = 2
        datePicker.calendar = datePickerCalendar
        return datePicker
    }()
    private let searchController = UISearchController(searchResultsController: nil)
    private var currentTask: DispatchWorkItem?
    
    private let params = GeometricParams(cellCount: 2, leftInset: 10, rightInset: 10, cellSpacing: 10)
    
    lazy var emptyCollectionView: UIView = {
        let view = UIView()
        let imageView = UIImageView(image: UIImage(named: "star"))
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textAlignment = .center
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            forName: TrackerCollectionView.EventSavedNotification,
            object: nil,
            queue: OperationQueue.main
        ) { [weak self] _ in
            guard let self = self else {
                print("TrackerCollectionView, CreateEventNotification: self is empty")
                return
            }
            
            guard let trackerService = self.trackerService else {
                print("CreateEventNotification: trackerService is empty")
                return
            }
            
            self.visibleEventsByCategory = trackerService.getEvents(by: datePicker.date)
            
            self.collectionView.reloadData()
        }
        
        trackerService = TrackerService(trackerRecordService: TrackerRecordService())
        visibleEventsByCategory = trackerService!.getEvents(by: datePicker.date)
        completedEvents = trackerService!.getCompletedEvents(by: datePicker.date)
        
        searchController.searchResultsUpdater = self
        
        view.backgroundColor = UIColor(named: "WhiteDay")

        createNavigationBar()
        showCollectionView()
    }

    func showEmptyCollection() {
        collectionView.addSubview(emptyCollectionView)
        
        NSLayoutConstraint.activate([
            emptyCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyCollectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func hideEmptyView() {
        emptyCollectionView.removeFromSuperview()
    }
    
    func createNavigationBar() {
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.backgroundColor = UIColor(named: "WhiteDay")
            navigationBar.tintColor = .black
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "add"), style: .plain, target: self, action: #selector(clickButtonCreateEvent))
            
            datePicker.preferredDatePickerStyle = .compact
            datePicker.datePickerMode = UIDatePicker.Mode.date
            datePicker.addTarget(self, action: #selector(changeDateOnDatePicker(_:)), for: .valueChanged)
           
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
    
    func showCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(SupplementaryView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: headerIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc func clickButtonCreateEvent() {
        let typeSelectionViewController = TypeSelectionViewController()
        typeSelectionViewController.trackerService = trackerService
        typeSelectionViewController.modalPresentationStyle = .popover
        self.present(typeSelectionViewController, animated: true)
    }
    
    @objc func changeDateOnDatePicker(_ datePicker: UIDatePicker) {
        guard let trackerService = trackerService else {
            print("changeDateOnDatePicker: trackerService is empty")
            return
        }
        visibleEventsByCategory = trackerService.getEvents(by: datePicker.date)
        completedEvents = trackerService.getCompletedEvents(by: datePicker.date)
        print(completedEvents)
        collectionView.reloadData()
        presentedViewController?.dismiss(animated: true)
    }
}

extension TrackerCollectionView: TrackEventProtocol {
    func untrackedEvent(event: Event) {
        NotificationCenter.default.post(
            name: TrackerRecordService.DeleteTrackerRecordNotification,
            object: self,
            userInfo: ["record": TrackerRecord(eventID: event.id, date: Calendar.current.startOfDay(for: datePicker.date))]
        )
        
        guard let trackerService = trackerService else {
            print("changeDate: trackerService is empty")
            return
        }
        
        trackerService.untrackEvent(eventId: event.id)
    }
    
    func trackEvent(event: Event) {
        NotificationCenter.default.post(
            name: TrackerRecordService.AddTrackerRecordNotification,
            object: self,
            userInfo: ["record": TrackerRecord(eventID: event.id, date: Calendar.current.startOfDay(for: datePicker.date))]
        )
        
        guard let trackerService = trackerService else {
            print("changeDate: trackerService is empty")
            return
        }
        
        trackerService.trackEvent(eventId: event.id)
    }
}

extension TrackerCollectionView: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        currentTask?.cancel()
        
        let newTask = DispatchWorkItem { [weak self] in
            self?.performSearch(with: searchController.searchBar.text)
        }
        
        currentTask = newTask
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: newTask)
    }
    
    func performSearch(with query: String?) {
        guard let query = query else {
            return
        }
        
        guard let trackerService = trackerService else {
            print("performSearch: trackerService is empty")
            return
        }
        
        var filteredEvents = [Section]()
        
        if query.isEmpty {
            filteredEvents = trackerService.getEvents(by: datePicker.date)
            if filteredEvents.count == visibleEventsByCategory.count {
                return
            }
        } else {
            filteredEvents = trackerService.filterEvents(by: query, date: datePicker.date)
        }
        
        visibleEventsByCategory = filteredEvents
        
        collectionView.reloadData()
    }
}

extension TrackerCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if visibleEventsByCategory.count == 0 {
            showEmptyCollection()
        } else {
            hideEmptyView()
        }
        
        return visibleEventsByCategory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = visibleEventsByCategory.safetyAccessElement(at: section) else {
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
        
        guard let section = visibleEventsByCategory.safetyAccessElement(at: indexPath.section) else {
            print("failed to get section from collection by index \(indexPath.section)")
            return UICollectionViewCell()
        }
        
        guard let event = section.events.safetyAccessElement(at: indexPath.row) else {
            print("failed to get element from section: \(section.categoryName) by index \(indexPath.row)")
            return UICollectionViewCell()
        }
        
        let cellEvent = CellEvent(event: event, tracked: completedEvents.contains(event.id))
        
        cell.cellEvent = cellEvent
        cell.delegate = self
        cell.contentView.layer.cornerRadius = 16
        
        if Calendar.current.startOfDay(for: datePicker.date) > Date() {
            cell.disableTrackButton()
        } else {
            cell.enableTrackButton()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = headerIdentifier
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

