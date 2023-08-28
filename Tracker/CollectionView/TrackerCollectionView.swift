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
    static let TrackerSavedNotification = Notification.Name(rawValue: "CreateEvent")
    
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    
    private var visibleCategories = [TrackersByCategory]()
    
    private var datePicker: UIDatePicker = {
        var datePicker = UIDatePicker()
        var datePickerCalendar = Calendar(identifier: .gregorian)
        datePickerCalendar.firstWeekday = 2
        datePicker.calendar = datePickerCalendar
        return datePicker
    }()
    
    private let params = GeometricParams(cellCount: 2, leftInset: 10, rightInset: 10, cellSpacing: 10)
    
    private var searchTextField: UISearchTextField = {
        let textField = UISearchTextField()
        textField.backgroundColor = BackgroundDayColor
        textField.textColor = BlackDayColor
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.cornerRadius = 16
        textField.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor(named: "Gray")
        ]
        let attributedPlaceholder = NSAttributedString(
            string: "Поиск",
            attributes: attributes
        )
        textField.attributedPlaceholder = attributedPlaceholder
        
        return textField
    }()
    
    private var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(SupplementaryView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: headerIdentifier)
        
        return collectionView
    }()
    
    private lazy var emptyCollectionView: UIView = {
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
            forName: TrackerCollectionView.TrackerSavedNotification,
            object: nil,
            queue: OperationQueue.main
        ) { [weak self] _ in
            guard let self = self else {
                assertionFailure("TrackerCollectionView, CreateEventNotification: self is empty")
                return
            }
            
            self.visibleCategories = trackerStore.getTrackers(by: datePicker.date)
            self.collectionView.reloadData()
        }
        
        visibleCategories = trackerStore.getTrackers(by: datePicker.date)
        
        setupSearchTextField()
        setupCollection()
        
        view.backgroundColor = WhiteDayColor
        
        createNavigationBar()
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
            navigationBar.backgroundColor = WhiteDayColor
            navigationBar.tintColor = .black
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "add"), style: .plain, target: self, action: #selector(clickButtonCreateEvent))
            
            datePicker.preferredDatePickerStyle = .compact
            datePicker.datePickerMode = UIDatePicker.Mode.date
            datePicker.addTarget(self, action: #selector(changeDateOnDatePicker(_:)), for: .valueChanged)
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            
            navigationBar.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: BlackDayColor as Any,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 34, weight: UIFont.Weight.bold),
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ] as [NSAttributedString.Key : Any]
            navigationItem.title = "Трекеры"
            
            navigationBar.prefersLargeTitles = true
        }
    }
    
    func setupSearchTextField() {
        searchTextField.delegate = self
        
        view.addSubview(searchTextField)
        
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    func setupCollection() {
        view.addSubview(collectionView)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 24),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc func clickButtonCreateEvent() {
        let typeSelectionViewController = TypeSelectionViewController()
        typeSelectionViewController.modalPresentationStyle = .popover
        self.present(typeSelectionViewController, animated: true)
    }
    
    @objc func changeDateOnDatePicker(_ datePicker: UIDatePicker) {
        visibleCategories = trackerStore.getTrackers(by: datePicker.date)
        collectionView.reloadData()
        presentedViewController?.dismiss(animated: true)
    }
}

extension TrackerCollectionView: UISearchTextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        guard let searchText = searchTextField.text else {
            return false
        }
        
        if searchText.isEmpty {
            visibleCategories = trackerStore.getTrackers(by: datePicker.date)
        } else {
            visibleCategories = trackerStore.getTrackers(by: datePicker.date, withName: searchText)
        }
        
        collectionView.reloadData()
        
        return true
    }
}

extension TrackerCollectionView: TrackEventProtocol {
    func trackEvent(indexPath: IndexPath) {
        visibleCategories = trackerStore.getTrackers(by: datePicker.date)
        guard
            let category = visibleCategories.safetyAccessElement(at: indexPath.section),
            let cellTracker = category.trackers.safetyAccessElement(at: indexPath.row)
        else {
            return
        }

        if cellTracker.tracked {
            do {
                try trackerRecordStore.deleteRecord(TrackerRecord(eventID: cellTracker.tracker.id!, date: Calendar.current.startOfDay(for: datePicker.date)))
            } catch {
                print("failed to create new record")
            }
        } else {
            do {
                try trackerRecordStore.addNewRecord(TrackerRecord(eventID: cellTracker.tracker.id!, date: Calendar.current.startOfDay(for: datePicker.date)))
            } catch {
                print("failed to create new record")
            }
        }
        
        
        visibleCategories = trackerStore.getTrackers(by: datePicker.date)
    }
}

extension TrackerCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if visibleCategories.count == 0 {
            showEmptyCollection()
        } else {
            hideEmptyView()
        }
        
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = visibleCategories.safetyAccessElement(at: section) else {
            print("failed to get section from collection by index \(section)")
            return 0
        }
        
        return section.trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? TrackerCollectionViewCell else {
            print("failed to convert cell to TrackerCollectionViewCell")
            return UICollectionViewCell()
        }
        
        guard let section = visibleCategories.safetyAccessElement(at: indexPath.section) else {
            print("failed to get section from collection by index \(indexPath.section)")
            return UICollectionViewCell()
        }
        
        guard let trackerCell = section.trackers.safetyAccessElement(at: indexPath.row) else {
            print("failed to get element from section: \(section.categoryName) by index \(indexPath.row)")
            return UICollectionViewCell()
        }
                
        cell.indexPath = indexPath
        cell.delegate = self
        cell.contentView.layer.cornerRadius = 16
        
        cell.configureCell(cellTracker: trackerCell)
       
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
        
        view.titleLabel.text = visibleCategories[indexPath.section].categoryName
        
        return view
    }
}

extension TrackerCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - self.params.paddingWidth
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

