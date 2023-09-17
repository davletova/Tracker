//
//  AddingHabit.swift
//  Tracker
//
//  Created by Алия Давлетова on 07.08.2023.
//

import Foundation
import UIKit

private let daysCellIdentifier = ""
private let nameCellIdentifier = "nameCell"
private let propertyCellIdentifier = "propertyCell"
private let emojiCellIdentifier = "emojiCell"
private let colorCellIdentifier = "colorCell"
private let buttonsCellIdentifier = "buttonCell"

enum CollectionSectionType: Int {
    case days = 0
    case name = 1
    case properties = 2
    case emoji = 3
    case color = 4
    case buttons = 5
}

enum PropertyType: Int, Hashable {
    case category = 0
    case schedule = 1
}

struct TrackerProperty {
    var name: String
    var callback: () -> Void
    
    var selectedValue: String?
}

final class CreateEventViewController: UIViewController {
    private var trackerProperties = [PropertyType: TrackerProperty]()
    private let emojies = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪",
    ]
    private let colors = (1...18).map{ UIColor(named: "ColorSelection\($0)") }
    
    private let trackerStore = TrackerStore()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor.getAppColors(.blackDay)
        
        return titleLabel
    }()
    
    private let trackedDaysTitle: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = UIColor.getAppColors(.blackDay)
        titleLabel.isHidden = true
        
        return titleLabel
    }()
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = true
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        collectionView.collectionViewLayout = layout
        
        collectionView.register(NameCollectionViewCell.self, forCellWithReuseIdentifier: nameCellIdentifier)
        collectionView.register(PropertiesCollectionViewCell.self, forCellWithReuseIdentifier: propertyCellIdentifier)
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: emojiCellIdentifier)
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: colorCellIdentifier)
        collectionView.register(ButtonCollectionViewCell.self, forCellWithReuseIdentifier: buttonsCellIdentifier)
        
        collectionView.register(CreateEventSupplementaryView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "header")
        
        return collectionView
    }()
    
    weak var delegate: ChangeButtonStateProtocol?
    
    var isHabit: Bool = false
    
    private var trackerName: String? { didSet { changeStateCreateButtonifNeedIt() } }
    
    private var selectedSchedule: Schedule? {
        didSet {
            guard var _ = trackerProperties[.schedule] else {
                return
            }
            trackerProperties[.schedule]!.selectedValue = selectedSchedule?.getRepetitionString()
            UIView.performWithoutAnimation {
                collectionView.reloadItems(at: [IndexPath(row: PropertyType.schedule.rawValue, section: CollectionSectionType.properties.rawValue)])
            }
            changeStateCreateButtonifNeedIt()
        }
    }
    
    private var selectedCategory: TrackerCategory?  {
        didSet {
            guard var _ = trackerProperties[.category] else {
                assertionFailure("failed to get property category")
                return
            }
            trackerProperties[.category]!.selectedValue = selectedCategory?.name
            UIView.performWithoutAnimation {
                collectionView.reloadItems(at: [IndexPath(row: PropertyType.category.rawValue, section: CollectionSectionType.properties.rawValue)])
            }
            changeStateCreateButtonifNeedIt()
        }
    }
    
    private var selectedEmojiIndexPath: IndexPath? { didSet { changeStateCreateButtonifNeedIt() } }
    
    private var selectedColorIndexPath: IndexPath? { didSet { changeStateCreateButtonifNeedIt() } }
    
    var updateTracker: Tracker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.getAppColors(.whiteDay)
        
        trackerProperties[.category] = TrackerProperty(
            name: NSLocalizedString("category", comment: "кнопка с выбором категории на странице создания трекера"),
            callback: { [weak self] in
                guard let self = self else {
                    assertionFailure("open list of category callback: self is empty")
                    return
                }
                
                let categoriesViewModel = ListCategoriesViewModel()
                let categoriesViewController = ListCategoriesViewController(categoriesViewModel)
                categoriesViewController.delegate = self
                categoriesViewController.selectedCategory = self.selectedCategory
                categoriesViewController.modalPresentationStyle = .popover
                self.present(categoriesViewController, animated: true)
            }
        )
        if isHabit {
            trackerProperties[.schedule] = TrackerProperty(
                name: NSLocalizedString("schedule", comment: "кнопка с выбором расписания на странице создания трекера"),
                callback: { [weak self] in
                    guard let self = self else {
                        assertionFailure("open schedule callback: self is empty")
                        return
                    }
                    
                    let scheduleViewController = ScheduleViewController()
                    scheduleViewController.delegate = self
                    scheduleViewController.selectedSchedule = self.selectedSchedule
                    scheduleViewController.modalPresentationStyle = .popover
                    self.present(scheduleViewController, animated: true)
                }
            )
        }
        
        if let updateTracker = updateTracker {
            if let habit = updateTracker as? Timetable {
                selectedSchedule = habit.getSchedule()
            }
            trackerName = updateTracker.name
            selectedCategory = updateTracker.category
            
            guard let emojiIndex = emojies.firstIndex(of: updateTracker.emoji) else {
                assertionFailure("emoji not found")
                return
            }
            selectedEmojiIndexPath = IndexPath(row: emojiIndex, section: CollectionSectionType.emoji.rawValue)
            
            //TODO: убрать force unwrapp
            guard let colorIndex = colors.firstIndex(where: { color in
                UIColorMarshalling.hexString(from: color!) == UIColorMarshalling.hexString(from: updateTracker.color)
            }) else {
                assertionFailure("color not found")
                return
            }
            selectedColorIndexPath = IndexPath(row: colorIndex, section: CollectionSectionType.color.rawValue)
        }
        
        setupTitle()
        setupCollectionView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    private func setupTitle() {
        view.addSubview(titleLabel)
        
        if let _ = updateTracker {
         //TODO: локализовать заголовки
            titleLabel.text = "Редактирование"
        } else {
            let localizeTitlekey = isHabit ? "new.habit" : "new.event"
            titleLabel.text = NSLocalizedString(localizeTitlekey, comment: "заголовок страницы с созданием трекера")
        }
        
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 32),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34)
        ])
    }
    
    func changeStateCreateButtonifNeedIt() {
        guard let delegate = delegate else {
            print("changeStateCreateButtonifNeedIt: delegate is empty")
            return
        }
        
        if
            let nameInputText = trackerName,
            !nameInputText.isEmpty,
            selectedCategory != nil,
            let _ = selectedEmojiIndexPath,
            let _ = selectedColorIndexPath
        {
            if !isHabit || (isHabit && selectedSchedule != nil) {
                delegate.enableButton()
                return
            }
        }
        
        delegate.disableButton()
    }
    
    @objc private func hideKeyboard() {
        self.view.endEditing(true)
    }
}

extension CreateEventViewController: ListCategoriesViewControllerDelegate {
    func selectCategory(_ category: TrackerCategory) {
        self.selectedCategory = category
    }
}

extension CreateEventViewController: ScheduleViewControllerDelegate {
    func selectSchedule(_ schedule: Schedule) {
        self.selectedSchedule = schedule
    }
}

extension CreateEventViewController: TrackerActionProtocol {
    func cancelCreateEvent() {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    func createEvent() {
        guard let value = trackerName else {
            print("goToCreateEventController: nameInput.text is empty")
            return
        }
        
        guard let selectedEmojiIndex = selectedEmojiIndexPath else {
            print("create tracker: emoji is empty")
            return
        }
        
        guard let selectedColorIndex = selectedColorIndexPath else {
            print("create tracker: color is empty")
            return
        }
        
        guard let selectCategory = self.selectedCategory else {
            print("create tracker: category is empty")
            return
        }
        
        guard let color = colors[selectedColorIndex.row] else {
            assertionFailure("create tracker: color by indes \(selectedColorIndex.row) is undefined")
            return
        }
        
        let newTracker: Tracker
        if isHabit {
            guard let schedule = selectedSchedule else {
                print("create habit: schedule is empty")
                return
            }
            
            newTracker = Habit(
                id: UUID(),
                name: value,
                category: selectCategory,
                emoji: emojies[selectedEmojiIndex.row],
                color: color,
                schedule: schedule
            )
        } else {
            newTracker = Tracker(
                id: UUID(),
                name: value,
                category: selectCategory,
                emoji: emojies[selectedEmojiIndex.row],
                color: color
            )
        }
        
        do {
            if let updateTracker = updateTracker {
                newTracker.id = updateTracker.id
                try trackerStore.updateTracker(newTracker)
            } else {
                try trackerStore.addNewTracker(newTracker)
            }
        } catch {
            print("failed to create tracker: \(error)")
        }
        
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}

// SetTrackerNameClosure for NameCollectionViewCell
extension CreateEventViewController {
    func setTrackerName(name: String) {
        trackerName = name
    }
}

extension CreateEventViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = CollectionSectionType(rawValue: section) else {
            assertionFailure("invalid section")
            return 0
        }
        
        switch sectionType {
        case .days:
            if updateTracker == 0 {
                return 0
            }
            return 1
        case .name:
            return 1
        case .properties:
            return trackerProperties.count
        case .emoji:
            return emojies.count
        case .color:
            return colors.count
        case .buttons:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = CollectionSectionType(rawValue: indexPath.section) else {
            assertionFailure("invalid section")
            return UICollectionViewCell()
        }
        
        switch sectionType {
        case .days:
            if updateTracker == nil {
                return UICollectionViewCell()
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: , for: <#T##IndexPath#>)
        case .name:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nameCellIdentifier, for: indexPath) as! NameCollectionViewCell
            cell.configure(name: trackerName) { [weak self] name in
                guard let self = self else {
                    assertionFailure("set setTrackerNameClosure: self is empty")
                    return
                }
                
                self.setTrackerName(name: name)
            }
            
            return cell
        case .properties:
            guard
                let propertyType = PropertyType(rawValue: indexPath.row),
                let trackerProperty = trackerProperties[propertyType]
            else {
                assertionFailure("invalid property")
                return UICollectionViewCell()
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: propertyCellIdentifier, for: indexPath) as! PropertiesCollectionViewCell
            cell.title.text = trackerProperty.name
            
            // Если категория или расписание выбраны
            // то устанавливаем subtitle
            if let property = trackerProperties[propertyType],
               let selectedProperty = property.selectedValue
            {
                cell.setSubtitle(subtitle: selectedProperty)
            }
            
            var cornerMasks = CACornerMask()
            // Для первой (верхней) ячейки скругляем верхние углы
            if indexPath.row == 0 {
                cornerMasks.insert(.layerMinXMinYCorner)
                cornerMasks.insert(.layerMaxXMinYCorner)
            }
            // для последней (нижней) ячейки скругляем нижние ячейки
            if indexPath.row == trackerProperties.count - 1 {
                cornerMasks.insert(.layerMinXMaxYCorner)
                cornerMasks.insert(.layerMaxXMaxYCorner)
            }
            cell.configureCornersRadius(masks: cornerMasks)
            
            // Если количество свойств > 1, то у каждой нечетной ячейки сверху отрисовываем линию
            if trackerProperties.count > 1 && indexPath.row >= 1 {
                cell.showSeparator()
            }
            
            return cell
        case .emoji:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emojiCellIdentifier, for: indexPath) as! EmojiCollectionViewCell
            cell.titleLabel.text = emojies[indexPath.row]
            
            if let index = selectedEmojiIndexPath, index.row == indexPath.row {
                cell.selectCell()
            }
            
            return cell
        case .color:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: colorCellIdentifier, for: indexPath) as! ColorCollectionViewCell
            cell.view.backgroundColor = colors[indexPath.row]
            cell.view.layer.cornerRadius = 8
            cell.cellColor = colors[indexPath.row]
            
            if let index = selectedColorIndexPath, index.row == indexPath.row {
                cell.selectCell()
            }
            
            return cell
        case .buttons:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: buttonsCellIdentifier, for: indexPath) as! ButtonCollectionViewCell
            let create = NSLocalizedString("to.create", comment: "текст кнопки Создать")
            //TODO: локализовать
            let save = "Save"
            let createButtonText = updateTracker != nil ? save : create
            
            cell.setTitle(text: createButtonText)
            
            self.delegate = cell
            cell.delegate = self
            changeStateCreateButtonifNeedIt()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
        default:
            assertionFailure("kind of supplementary element invalid")
            return UICollectionReusableView()
        }
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? CreateEventSupplementaryView else {
            print("fialed to convert SupplementaryView")
            return UICollectionReusableView()
        }
        
        switch indexPath.section {
        case 2:
            view.titleLabel.text = NSLocalizedString("emoji", comment: "заголовок раздела с выбором emoji")
        case 3:
            view.titleLabel.text = NSLocalizedString("color", comment: "заголовок раздела с выбором цвета")
        default:
            return view
        }
        
        return view
    }
}

extension CreateEventViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            return CGSize(width: view.bounds.width - 32, height: rowHeight)
        case 1:
            return CGSize(width: view.bounds.width - 32, height: rowHeight)
        case 2, 3:
            return CGSize(width: collectionView.bounds.width / 6 - 2, height: collectionView.bounds.width / 6 - 2)
        case 4:
            return CGSize(width: view.bounds.width - 32 , height: buttonHeight)
        default:
            assertionFailure("invalid section")
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch section {
        case 2, 3:
            let indexPath = IndexPath(row: 0, section: section)
            
            let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
            
            return headerView.systemLayoutSizeFitting(
                CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel)
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch section {
        case 0:
            return UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 10)
        case 1:
            return UIEdgeInsets(top: 24, left: 0, bottom: 32, right: 10)
        case 2:
            return UIEdgeInsets(top: 24, left: 0, bottom: 40, right: 10)
        case 3:
            return UIEdgeInsets(top: 24, left: 0, bottom: 16, right: 10)
        default:
            return UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 10)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sectionType = CollectionSectionType(rawValue: indexPath.section) else {
            assertionFailure("didSelectItemAt: unknown section type")
            return
        }
        
        switch sectionType {
        case .buttons, .name:
            return
        case .properties:
            guard
                let propertyType = PropertyType(rawValue: indexPath.row),
                let trackerProperty = trackerProperties[propertyType]
            else {
                assertionFailure("didSelectItemAt: unknown row type for properties")
                return
            }
            
            trackerProperty.callback()
        case .emoji, .color:
            let oldSelectedIndexPath = sectionType == .emoji ? selectedEmojiIndexPath : selectedColorIndexPath
            
            // если ранее уже было выбрано эмодзи или цвет
            if let oldSelectedIndexPath = oldSelectedIndexPath {
                // берем ранее выбранную ячейку
                // проверяем, что она реализует протокол SelectableCellProtocol
                guard let oldSelectableCell = collectionView.cellForItem(at: oldSelectedIndexPath),
                      let oldSelectableCell = oldSelectableCell as? SelectableCellProtocol else {
                    assertionFailure("didSelectItemAt: old selection cell is invalid")
                    return
                }
                // отменяем предыдущий выбор эмодзи или цвета
                oldSelectableCell.unselectCell()
            }
            
            // берем текущую выбранную ячейку
            // проверяем, что она реализует протокол SelectableCellProtocol
            guard let selectedCell = collectionView.cellForItem(at: indexPath),
                  let selectableCell = selectedCell as? SelectableCellProtocol else {
                assertionFailure("didSelectItemAt: invalid cell")
                return
            }
            
            if sectionType == .emoji {
                selectedEmojiIndexPath = indexPath
            } else {
                selectedColorIndexPath = indexPath
            }
            
            selectableCell.selectCell()
        }
    }
}
