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
    
    private var trackerStore: TrackerStoreProtocol
    private var trackerRecordStore: TrackerRecordStoreProtocol
    
    private var visibleCategories = [TrackersByCategory]()
    
    private let datePicker: UIDatePicker = {
        var datePicker = UIDatePicker()
        var datePickerCalendar = Calendar(identifier: .gregorian)
        datePickerCalendar.firstWeekday = 2
        datePicker.calendar = datePickerCalendar
        
        return datePicker
    }()
    
    private var trackerFilter: TrackerFilterType = .all
    
    private let params = GeometricParams(cellCount: 2, leftInset: 10, rightInset: 10, cellSpacing: 10)
    
    private let searchTextField: UISearchTextField = {
        let textField = UISearchTextField()
        textField.backgroundColor = UIColor.getAppColors(.backgroundDay)
        textField.textColor = UIColor.getAppColors(.blackDay)
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
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor.getAppColors(.whiteDay)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(SupplementaryView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: headerIdentifier)
        
        return collectionView
    }()
    
    private let filterButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle(
            NSLocalizedString("Filters", comment: ""),
            for: .normal
        )
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor  = .getAppColors(.blue)
        button.layer.cornerRadius = 16
        button.isHidden = true
        
        return button
    }()
    
    @objc private func showFilter() {
        let filterController = FiltersViewController(initialFilter: trackerFilter)
        filterController.delegate = self
        filterController.modalPresentationStyle = .popover
        self.present(filterController, animated: true)
    }
    
    private lazy var emptyCollectionView: UIView = {
        let view = UIView()
        let imageView = UIImageView(image: UIImage(named: "star"))
        let label = UILabel()
        label.text = NSLocalizedString("empty.list.of.trackers", comment: "текст на месте пустого списока трекеров")
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
    
    private lazy var errorCollectionView: UIView = {
        let view = UIView()
        let imageView = UIImageView(image: UIImage(named: "error"))
        let label = UILabel()
        label.text = NSLocalizedString("no.trackers.found", comment: "Empty list of filtered trackers")
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
    
    init() {
        trackerStore = TrackerStore()
        trackerRecordStore = TrackerRecordStore()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateVisibleCategories),
            name: TrackerCollectionView.TrackerSavedNotification,
            object: nil
        )
                
        visibleCategories = trackerStore.getTrackers(by: datePicker.date, withName:  nil)
        
        setupSearchTextField()
        setupCollection()
        setupFilterButton()
        
        view.backgroundColor = UIColor.getAppColors(.whiteDay)
        
        createNavigationBar()
        
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
        AnalyticsService.sendEvent(event: "open", screen: "Main")
    }
    
    deinit {
        AnalyticsService.sendEvent(event: "close", screen: "Main")
    }
    
    @objc func updateVisibleCategories() {
        self.visibleCategories = trackerStore.getTrackers(by: datePicker.date, withName: nil)
        self.collectionView.reloadData()
    }
    
    @objc private func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func showEmptyView() {
        hideEmptyView()
        
        filterButton.isHidden = true
        
        if let search = searchTextField.text,
           !search.isEmpty
        {
            collectionView.addSubview(errorCollectionView)
            NSLayoutConstraint.activate([
                errorCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                errorCollectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
            return
        }
        collectionView.addSubview(emptyCollectionView)
        
        NSLayoutConstraint.activate([
            emptyCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyCollectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func hideEmptyView() {
        emptyCollectionView.removeFromSuperview()
        errorCollectionView.removeFromSuperview()
        
        filterButton.isHidden = false
    }
    
    private func createNavigationBar() {
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.backgroundColor = UIColor.getAppColors(.whiteDay)
            navigationBar.tintColor = UIColor.getAppColors(.blackDay)
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "add"), style: .plain, target: self, action: #selector(clickButtonCreateEvent))
            navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
            
            datePicker.preferredDatePickerStyle = .compact
            datePicker.datePickerMode = UIDatePicker.Mode.date
            datePicker.addTarget(self, action: #selector(changeDateOnDatePicker(_:)), for: .valueChanged)
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            
            navigationBar.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.getAppColors(.blackDay) as Any,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 34, weight: UIFont.Weight.bold),
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ] as [NSAttributedString.Key : Any]
            navigationItem.title =  NSLocalizedString("trackers", comment: "заголовок списка трекеров")
            
            navigationBar.prefersLargeTitles = true
        }
    }
    
    private func setupSearchTextField() {
        searchTextField.delegate = self
        
        view.addSubview(searchTextField)
        
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupCollection() {
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
    
    private func setupFilterButton() {
        filterButton.addTarget(self, action: #selector(showFilter), for: .touchUpInside)
        view.addSubview(filterButton)
        
        NSLayoutConstraint.activate([
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    @objc func clickButtonCreateEvent() {
        AnalyticsService.sendEvent(event: "click", screen: "Main", item: "add_track")
        
        let typeSelectionViewController = TypeSelectionViewController()
        typeSelectionViewController.modalPresentationStyle = .popover
        self.present(typeSelectionViewController, animated: true)
    }
    
    @objc func changeDateOnDatePicker(_ datePicker: UIDatePicker) {
        visibleCategories = trackerStore.getTrackers(by: datePicker.date, withName: nil)
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
            visibleCategories = trackerStore.getTrackers(by: datePicker.date, withName: nil)
        } else {
            visibleCategories = trackerStore.getTrackers(by: datePicker.date, withName: searchText)
        }
        
        collectionView.reloadData()
        
        return true
    }
}

extension TrackerCollectionView: TrackEventProtocol {
    func pinTracker(indexPath: IndexPath, pinned: Bool) {
        guard
            let category = visibleCategories[at: indexPath.section],
            let trackerVM = category.trackers[at: indexPath.row]
        else {
            assertionFailure("pinTracker failed")
            return
        }
        
        do {
            let tracker = trackerVM.tracker
            tracker.pinned = pinned
            
            try trackerStore.updateTracker(trackerVM.tracker)
        } catch {
            print("failed to pin tracker \(error)")
        }
    }
    
    func editTracker(indexPath: IndexPath) {
        guard
            let category = visibleCategories[at: indexPath.section],
            let trackerVM = category.trackers[at: indexPath.row]
        else {
            assertionFailure("editTracker failed")
            return
        }
        
        let editTrackerVC = CreateEventViewController()
        editTrackerVC.updateTrackerVM = trackerVM
        if let _ = trackerVM.tracker as? Timetable {
            editTrackerVC.isHabit = true
        } else {
            editTrackerVC.isHabit = false
        }
            
        self.present(editTrackerVC, animated: true)
    }
    
    func deleteTracker(indexPath: IndexPath) {
        let destroyAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] (action) in
            guard
                let category = self!.visibleCategories[at: indexPath.section],
                let trackerVM = category.trackers[at: indexPath.row]
            else {
                return
            }
            
            try! self!.trackerStore.deleteTracker(trackerVM.tracker)
           }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let alert = UIAlertController(title: "Delete the image?",
                       message: "",
                       preferredStyle: .actionSheet)
        alert.addAction(destroyAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
    
    func trackEvent(indexPath: IndexPath) {
        guard
            let category = visibleCategories[at: indexPath.section],
            let cellTracker = category.trackers[at: indexPath.row]
        else {
            return
        }
        
        if cellTracker.tracked {
            do {
                try trackerRecordStore.deleteRecord(TrackerRecord(eventID: cellTracker.tracker.id, date: Calendar.current.startOfDay(for: datePicker.date)))
            } catch {
                print("failed to delete record with error: \(error)")
            }
        } else {
            do {
                try trackerRecordStore.addNewRecord(TrackerRecord(eventID: cellTracker.tracker.id, date: Calendar.current.startOfDay(for: datePicker.date)))
            } catch {
                print("failed to create new record with error \(error)")
            }
        }
        
        visibleCategories = trackerStore.getTrackers(by: datePicker.date, withName:  nil)
    }
}

extension TrackerCollectionView: FiltersViewControllerDelegate {
    func selectFilter(_ trackerFilter: TrackerFilterType) {
        self.trackerFilter = trackerFilter
        dismiss(animated: true)
    }
}

extension TrackerCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if visibleCategories.count == 0 {
            showEmptyView()
        } else {
            hideEmptyView()
        }
        
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = visibleCategories[at: section] else {
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
        
        guard let section = visibleCategories[at: indexPath.section] else {
            print("failed to get section from collection by index \(indexPath.section)")
            return UICollectionViewCell()
        }
        
        guard let trackerCell = section.trackers[at: indexPath.row] else {
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
