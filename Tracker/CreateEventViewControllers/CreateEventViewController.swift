//
//  AddingHabit.swift
//  Tracker
//
//  Created by Алия Давлетова on 07.08.2023.
//


//6420
import Foundation
import UIKit

private let nameCellIdentifier = "nameCell"
private let propertyCellIdentifier = "propertyCell"
private let emojiCellIdentifier = "emojiCell"
private let colorCellIdentifier = "colorCell"
private let buttonsCellIdentifier = "buttonCell"

enum CollectionSectionType: Int {
    case name = 0
    case properties = 1
    case emoji = 2
    case color = 3
    case buttons = 4
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
    
    var delegate: ChangeButtonStateProtocol?
    
    var isHabit: Bool = false
    
    private var trackerName: String? { didSet { changeStateCreateButtonifNeedIt() } }
    
    private var selectSchedule: Schedule? {
        didSet {
            guard var _ = trackerProperties[.schedule] else {
                return
            }
            trackerProperties[.schedule]!.selectedValue = selectSchedule?.getRepetitionString()
            collectionView.reloadItems(at: [IndexPath(row: PropertyType.schedule.rawValue, section: CollectionSectionType.properties.rawValue)])
            changeStateCreateButtonifNeedIt()
        }
    }
    
    private var selectCategory: TrackerCategory?  {
        didSet {
            guard var _ = trackerProperties[.category] else {
                assertionFailure("failed to get property category")
                return
            }
            trackerProperties[.category]!.selectedValue = selectCategory?.name
            collectionView.reloadItems(at: [IndexPath(row: PropertyType.category.rawValue, section: CollectionSectionType.properties.rawValue)])
            changeStateCreateButtonifNeedIt()
        }
    }

    private var selectEmojiIndexPath: IndexPath? { didSet { changeStateCreateButtonifNeedIt() } }

    private var selectColorIndexPath: IndexPath? { didSet { changeStateCreateButtonifNeedIt() } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.getAppColors(.whiteDay)
        
        trackerProperties[.category] = TrackerProperty(name: "Категория", callback: openCategories)
        if isHabit {
            trackerProperties[.schedule] = TrackerProperty(name: "Расписание", callback: openSchedule)
        }
                
        setupTitle()
        setupCollectionView()
    }
    
    private func setupTitle() {
        view.addSubview(titleLabel)
        titleLabel.text = isHabit ? "Новая привычка" : "Новое нерегулярное событие"
        
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
    
    private func openCategories() {
        let categoriesViewController = ListCategoriesViewController()
        categoriesViewController.delegate = self
        categoriesViewController.modalPresentationStyle = .popover
        self.present(categoriesViewController, animated: true)
    }
    
    private func openSchedule() {
        let scheduleViewController = ScheduleViewController()
        scheduleViewController.delegate = self
        scheduleViewController.modalPresentationStyle = .popover
        self.present(scheduleViewController, animated: true)
    }
    
    func changeStateCreateButtonifNeedIt() {
        guard let delegate = delegate else {
            print("changeStateCreateButtonifNeedIt: delegate is empty")
            return
        }
        
        if
            let nameInputText = trackerName,
            !nameInputText.isEmpty,
            selectCategory != nil,
            let _ = selectEmojiIndexPath,
            let _ = selectColorIndexPath
        {
            if !isHabit || (isHabit && selectSchedule != nil) {
                delegate.enableButton()
                return
            }
        }
        
        delegate.disableButton()
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

        guard let selectedEmojiIndex = selectEmojiIndexPath else {
            print("create tracker: emoji is empty")
            return
        }

        guard let selectedColorIndex = selectColorIndexPath else {
            print("create tracker: color is empty")
            return
        }

        guard let selectCategory = self.selectCategory else {
            print("create tracker: category is empty")
            return
        }
        
        guard let color = colors[selectedColorIndex.row] else {
            assertionFailure("create tracker: color by indes \(selectedColorIndex.row) is undefined")
            return
        }
        
        let newTracker: Tracker
        if isHabit {
            guard let schedule = selectSchedule else {
                print("create habit: schedule is empty")
                return
            }

            newTracker = Habit(
                name: value,
                category: selectCategory,
                emoji: emojies[selectedEmojiIndex.row],
                color: color,
                schedule: schedule
            )
        } else {
            newTracker = Tracker(
                name: value,
                category: selectCategory,
                emoji: emojies[selectedEmojiIndex.row],
                color: color
            )
        }

        do {
            try trackerStore.addNewTracker(newTracker)
        } catch {
            print("failed to create tracker")
        }

        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}

extension CreateEventViewController: SetTrackerNameProtocol {
    func setTrackerName(name: String) {
        trackerName = name
    }
}

extension CreateEventViewController: ScheduleViewControllerDelegateProtocol {
    func saveSchedule(schedule: Schedule) {
        self.selectSchedule = schedule
    }
}

extension CreateEventViewController: ListCategoriesDelegateProtocol {
    func saveCategory(category: TrackerCategory) {
        self.selectCategory = category
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
        case .name:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nameCellIdentifier, for: indexPath) as! NameCollectionViewCell
            cell.delegate = self
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
            if trackerProperties.count > 1 && indexPath.row % 2 == 1 {
                let lineView = UIView(frame: CGRect(x: 16, y: cell.bounds.minY, width: cell.frame.size.width - 32, height: 0.5))
                lineView.backgroundColor = UIColor.getAppColors(.gray)
                cell.addSubview(lineView)
            }
            
            return cell
        case .emoji:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emojiCellIdentifier, for: indexPath) as! EmojiCollectionViewCell
            cell.titleLabel.text = emojies[indexPath.row]
            return cell
        case .color:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: colorCellIdentifier, for: indexPath) as! ColorCollectionViewCell
            cell.view.backgroundColor = colors[indexPath.row]
            cell.view.layer.cornerRadius = 8
            cell.cellColor = colors[indexPath.row]
            return cell
        case .buttons:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: buttonsCellIdentifier, for: indexPath) as! ButtonCollectionViewCell
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
            view.titleLabel.text = "Emoji"
        case 3:
            view.titleLabel.text = "Цвет"
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
            return CGSize(width: 52, height: 52)
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
        case 2, 3:
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
            
            let oldSelectedIndexPath = sectionType == .emoji ? selectEmojiIndexPath : selectColorIndexPath
            
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
                selectEmojiIndexPath = indexPath
            } else {
                selectColorIndexPath = indexPath
            }
            
            selectableCell.selectCell()
        }
    }
}
