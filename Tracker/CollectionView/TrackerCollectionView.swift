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
    var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    var trackerService: TrackerService?
    private var collection = [Section]()
    private var datePicker: UIDatePicker = UIDatePicker()
    private let params = GeometricParams(cellCount: 2, leftInset: 10, rightInset: 10, cellSpacing: 10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trackerService = TrackerService(trackerRecordService: TrackerRecordService())
        collection = trackerService!.getEventsByDate(date: datePicker.date)
        
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
        
        if collection.count == 0 {
            showEmptyCollection()
        }
    }

    func showEmptyCollection() {
        let imageView = UIImageView(image: UIImage(named: "star"))
        imageView.translatesAutoresizingMaskIntoConstraints = false

        collectionView.addSubview(imageView)
        
        imageView.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor).isActive = true
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
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "add"), style: .plain, target: self, action: #selector(add))
            
            datePicker.preferredDatePickerStyle = .compact
            datePicker.datePickerMode = UIDatePicker.Mode.date
            datePicker.addTarget(self, action: #selector(changeDate(_:)), for: .valueChanged)
           
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            
            navigationBar.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor(named: "BlackDay"),
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 34, weight: UIFont.Weight.bold),
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ] as [NSAttributedString.Key : Any]
            navigationItem.title = "Трекеры"

            navigationBar.prefersLargeTitles = true
            
            navigationItem.searchController = UISearchController()
        }
    }
    
    @objc func add() {
        let popup = TypeSelectionViewController()
        popup.modalPresentationStyle = .popover
//        popup.popoverPresentationController?.passthroughViews = nil
        self.present(popup, animated: true)
    }
    
    @objc func changeDate(_ datePicker: UIDatePicker) {
        guard let trackerService = trackerService else {
            print("changeDate: trackerService is empty")
            return
        }
        collection = trackerService.getEventsByDate(date: datePicker.date)
//        datePicker.state = .
        collectionView.reloadData()
        presentedViewController?.dismiss(animated: true)
    }
}

extension TrackerCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        collection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = collection.safelyAccessElement(at: section) else {
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
        
        guard let section = collection.safelyAccessElement(at: indexPath.section) else {
            print("failed to get section from collection by index \(indexPath.section)")
            return UICollectionViewCell()
        }
        
        guard let event = section.events.safelyAccessElement(at: indexPath.row) else {
            print("failed to get element from section: \(section.categoryName) by index \(indexPath.row)")
            return UICollectionViewCell()
        }
        
        cell.event = event
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
        
        view.titleLabel.text = collection[indexPath.section].categoryName
        
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


//extension ViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//        let indexPath = IndexPath(row: 0, section: section)
//
//        let footerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionFooter, at: indexPath)
//
//        return footerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height),
//                                                  withHorizontalFittingPriority: .required,
//                                                  verticalFittingPriority: .fittingSizeLevel)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: collectionView.bounds.width / 3, height: 50)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
//}
//extension SupplementaryCollection: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let removeColor = colors[indexPath.row]
//        var indexPathes = [IndexPath]()
//
//        for i in 0..<colors.count {
//            if colors[i] == removeColor {
//                indexPathes.append(IndexPath(row: i, section: 0))
//            }
//        }
//
//        colors = colors.filter{ $0 != removeColor}
//
//        collectionView.performBatchUpdates {
//            collectionView.deleteItems(at: indexPathes)
//        }
//    }
//}


//
//final class EmojiMixesViewController: UIViewController {
//    private let emojies = [
//        "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍", "🥭", "🍎", "🍏", "🍐", "🍒",
//        "🍓", "🫐", "🥝", "🍅", "🫒", "🥥", "🥑", "🍆", "🥔", "🥕", "🌽", "🌶️",
//        "🫑", "🥒", "🥬", "🥦", "🧄", "🧅", "🍄",
//    ]
//
//    private var visibleEmojies: [String] = []
//
//    private let collectionView: UICollectionView = {
//        let collectionView = UICollectionView(
//            frame: .zero,
//            collectionViewLayout: UICollectionViewFlowLayout()
//        )
//        collectionView.register(EmojiMixCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
//        return collectionView
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        if let navBar = navigationController?.navigationBar {
//            let rightButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNextEmoji))
//            navBar.topItem?.setRightBarButton(rightButton, animated: false)
//
//            let leftButton = UIBarButtonItem(barButtonSystemItem: .undo, target: self, action: #selector(removeLastEmoji))
//            navBar.topItem?.setLeftBarButton(leftButton, animated: false)
//        }
//        setupCollectionView()
//    }
//
//    @objc
//    private func addNextEmoji() {
//        guard visibleEmojies.count < emojies.count else { return }
//
//        let nextEmojiIndex = visibleEmojies.count
//        visibleEmojies.append(emojies[nextEmojiIndex])
//        collectionView.performBatchUpdates {
//            collectionView.insertItems(at: [IndexPath(item: nextEmojiIndex, section: 0)])
//        }
//    }
//
//    @objc
//    private func removeLastEmoji() {
//        guard visibleEmojies.count > 0 else { return }
//
//        let lastEmojiIndex = visibleEmojies.count - 1
//        visibleEmojies.removeLast()
//        collectionView.performBatchUpdates {
//            collectionView.deleteItems(at: [IndexPath(item: lastEmojiIndex, section: 0)])
//        }
//    }
//
//    private func setupCollectionView() {
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(collectionView)
//        NSLayoutConstraint.activate([
//            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
//            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//        ])
//
//        collectionView.dataSource = self
//        collectionView.delegate = self
//    }
//}
//
//extension EmojiMixesViewController: UICollectionViewDataSource {
//    func collectionView(
//        _ collectionView: UICollectionView,
//        numberOfItemsInSection section: Int
//    ) -> Int {
//        return visibleEmojies.count
//    }
//
//    func collectionView(
//        _ collectionView: UICollectionView,
//        cellForItemAt indexPath: IndexPath
//    ) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! EmojiMixCollectionViewCell
//
//        cell.titleLabel.text = visibleEmojies[indexPath.row]
//        return cell
//    }
//}
//
//extension EmojiMixesViewController: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//    }
//}
//
//
//extension EmojiMixesViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(
//        _ collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        sizeForItemAt indexPath: IndexPath
//    ) -> CGSize {
//        return CGSize(width: collectionView.bounds.width / 2, height: 50)
//    }
//
//    func collectionView(
//        _ collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        minimumInteritemSpacingForSectionAt section: Int
//    ) -> CGFloat {
//        return 0
//    }
//}
