//
//  AddingHabit.swift
//  Tracker
//
//  Created by Алия Давлетова on 07.08.2023.
//


//6420
import Foundation
import UIKit

private let emojiCellIdentifier = "emojiCell"
private let colorCellIdentifier = "colorCell"

struct TableButton {
    var name: String
    var callback: () -> Void
}

final class CreateEventViewController: UIViewController {
    private let buttonHeight = CGFloat(60)
    private var categoryAndScheduleButtons = [TableButton]()
    private let emojies = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪",
    ]
    private let colors = (1...18).map{ UIColor(named: "ColorSelection\($0)") }
    
    private var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(named: "BlackDay")
        
        return titleLabel
    }()
    
    private var trackerNameInput: UITextField = {
        let eventNameInput = UITextField()
        eventNameInput.translatesAutoresizingMaskIntoConstraints = false
        eventNameInput.backgroundColor = UIColor(named: "BackgroundDay")
        eventNameInput.layer.cornerRadius = 16
        eventNameInput.leftView = UIView(frame: CGRectMake(0, 0, 16, eventNameInput.frame.height))
        eventNameInput.leftViewMode = .always
        eventNameInput.placeholder = "Введите название трекера"
        
        return eventNameInput
    }()
    
    private var buttonsTableView: UITableView = {
        let buttonsTableView = UITableView()
        buttonsTableView.translatesAutoresizingMaskIntoConstraints = false
        buttonsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        buttonsTableView.rowHeight = 75
        buttonsTableView.backgroundColor = UIColor(named: "BackgroundDay")
        buttonsTableView.layer.cornerRadius = 16
        
        return buttonsTableView
    }()
    
    private var emojiAndColorCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = true
        collectionView.allowsSelection = true
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout
        
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: emojiCellIdentifier)
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: colorCellIdentifier)
        collectionView.register(CreateEventSupplementaryView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "header")
        
        return collectionView
    }()
    
    private var cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.backgroundColor = UIColor(named: "WhiteDay")
        cancelButton.layer.cornerRadius = 16
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitleColor(UIColor(named: "Red"), for: .normal)
        cancelButton.layer.borderColor = UIColor(named: "Red")?.cgColor
        cancelButton.layer.borderWidth = 1
        
        return cancelButton
    }()
    
    private var createEventButton: UIButton = {
        let createEventButton = UIButton()
        createEventButton.backgroundColor = UIColor(named: "BlackDay")
        createEventButton.translatesAutoresizingMaskIntoConstraints = false
        createEventButton.layer.cornerRadius = 16
        createEventButton.setTitle("Создать", for: .normal)
        createEventButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createEventButton.setTitleColor(UIColor(named: "WhiteDay"), for: .normal)
        createEventButton.titleLabel?.textAlignment = .center
       
        return createEventButton
    }()
    
    var trackerService: TrackerServiceProtocol?
    var isHabit: Bool?
    
    private var selectSchedule: Schedule?
    private var selectCategory: String?
    private var selectedEmoji: String?
    private var selectedColor: UIColor?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "WhiteDay")
        
        categoryAndScheduleButtons.append(TableButton(name: "Категория", callback: openCategories))
        if let isHabit = isHabit, isHabit {
            categoryAndScheduleButtons.append(TableButton(name: "Расписание", callback: openSchedule))
        }
        
        setupTitle()
        setupTrackerNameInput()
        setupButtonsTableView()
        setupEmojiAndColorCollectionView()
        setupCancelButton()
        setupCreateTracker()
    }
    
    private func setupTitle() {
        view.addSubview(titleLabel)
        
        guard let isHabit = isHabit else {
            print("create titleLabel: isHabit is empty")
            return
        }
        
        if isHabit {
            titleLabel.text = "Новая привычка"
        } else {
            titleLabel.text = "Новое нерегулярное событие"
        }
        
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupTrackerNameInput() {
        trackerNameInput.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        view.addSubview(trackerNameInput)
        
        NSLayoutConstraint.activate([
            trackerNameInput.heightAnchor.constraint(equalToConstant: 75),
            trackerNameInput.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            trackerNameInput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerNameInput.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupButtonsTableView() {
        buttonsTableView.dataSource = self
        buttonsTableView.delegate = self
        
        view.addSubview(buttonsTableView)
        
        NSLayoutConstraint.activate([
            buttonsTableView.topAnchor.constraint(equalTo: trackerNameInput.bottomAnchor, constant: 24),
            buttonsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonsTableView.heightAnchor.constraint(equalToConstant: 75 * CGFloat(categoryAndScheduleButtons.count))
        ])
    }
    
    private func setupEmojiAndColorCollectionView() {
        emojiAndColorCollectionView.dataSource = self
        emojiAndColorCollectionView.delegate = self
        
        view.addSubview(emojiAndColorCollectionView)
        
        NSLayoutConstraint.activate([
            emojiAndColorCollectionView.heightAnchor.constraint(equalToConstant: 450),
            emojiAndColorCollectionView.topAnchor.constraint(equalTo: buttonsTableView.bottomAnchor, constant: 16),
            emojiAndColorCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emojiAndColorCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            emojiAndColorCollectionView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -buttonHeight - CGFloat(44))
         ])
    }
    
    private func setupCancelButton() {
        cancelButton.addTarget(self, action: #selector(cancelCreateEvent), for: .touchUpInside)
        
        view.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
            cancelButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(view.frame.width / 2 + 3)),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }

    private func setupCreateTracker() {
        createEventButton.addTarget(self, action: #selector(goToCreateEventController), for: .touchUpInside)
        
        if let inputText = trackerNameInput.text,
           inputText.isEmpty {
            createEventButton.isEnabled = false
            createEventButton.backgroundColor = UIColor(named: "Gray")
        }
        
        view.addSubview(createEventButton)
 
        NSLayoutConstraint.activate([
            createEventButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 6),
            createEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createEventButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            createEventButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34)
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
    
    @objc func cancelCreateEvent() {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func goToCreateEventController() {
        guard let value = trackerNameInput.text else {
            print("goToCreateEventController: nameInput.text is empty")
            return
        }
        
        guard let trackerService = trackerService else {
            print("goToCreateEventController: trackerService is empty")
            return
        }
        
        guard let isHabit = isHabit else {
            print("goToCreateEventController: isHabit is empty")
            return
        }
        
        guard let selectedEmoji = self.selectedEmoji else {
            print("create tracker: emoji is empty")
            return
        }
        
        guard let selectedColor = self.selectedColor else {
            print("create tracker: color is empty")
            return
        }
        
        guard let selectCategory = self.selectCategory else {
            print("create tracker: category is empty")
            return
        }
        
        let newEvent: Tracker
        if isHabit {
            guard let schedule = selectSchedule else {
                print("create habit: schedule is empty")
                return
            }
            
            newEvent = Habit(
                id: UUID(),
                name: value,
                category: selectCategory,
                emoji: selectedEmoji,
                color: selectedColor,
                schedule: schedule
            )
        } else {
            newEvent = Tracker(
                id: UUID(),
                name: value,
                category: selectCategory,
                emoji: selectedEmoji,
                color: selectedColor
            )
        }
        
        trackerService.createTracker(tracker: newEvent)
        
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        if let nameInputText = trackerNameInput.text,
           !nameInputText.isEmpty {
            createEventButton.isEnabled = true
            createEventButton.backgroundColor = UIColor(named: "BlackDay")
            return
        }
        
        createEventButton.isEnabled = false
        createEventButton.backgroundColor = UIColor(named: "Gray")
    }
}

extension CreateEventViewController: ScheduleViewControllerDelegateProtocol {
    func saveSchedule(schedule: Schedule) {
        self.selectSchedule = schedule
    }
}

extension CreateEventViewController: ListCategoriesDelegateProtocol {
    func saveCategory(category: String) {
        self.selectCategory = category
    }
}

extension CreateEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryAndScheduleButtons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = categoryAndScheduleButtons[indexPath.row].name
        cell.backgroundColor = UIColor(named: "BackgroundDay")
        
        let chevronImageView = UIImageView(image: UIImage(named: "chevron"))
        cell.addSubview(chevronImageView)
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            chevronImageView.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -15),
            chevronImageView.widthAnchor.constraint(equalToConstant: 24),
            chevronImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        cell.selectionStyle = .none
        return cell
    }
}

extension CreateEventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        categoryAndScheduleButtons[indexPath.row].callback()
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}

extension CreateEventViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return emojies.count
        } else {
            return colors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emojiCellIdentifier, for: indexPath) as! EmojiCollectionViewCell
            
            cell.titleLabel.text = emojies[indexPath.row]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: colorCellIdentifier, for: indexPath) as! ColorCollectionViewCell
            
            cell.view.backgroundColor = colors[indexPath.row]
            cell.view.layer.cornerRadius = 8
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
            id = ""
        }
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? CreateEventSupplementaryView else {
            print("fialed to convert SupplementaryView")
            return UICollectionReusableView()
        }
        
        if indexPath.section == 0 {
            view.titleLabel.text = "Emoji"
        } else {
            view.titleLabel.text = "Цвет"
        }
        
        return view
    }
}

extension CreateEventViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
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

    #if false
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false {
            // Элемент уже выбран, снимите его выделение
            collectionView.deselectItem(at: indexPath, animated: true)
        } else {
            // Элемент не выбран, выделите его
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .none)
        }
    }
    #endif
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell: UICollectionViewCell = collectionView.cellForItem(at: indexPath)!
        
        if indexPath.section == 0 {
            
            // отменияем выбор предыдущего эмодзи
//            if let oldSelectedEmoji = selectedEmoji, !oldSelectedEmoji.isEmpty {
//                guard let rowOfOldSelection = emojies.firstIndex(of: oldSelectedEmoji) else {
//                    print("deselectItemAt: search firstIndex of old selection failed")
//                    return
//                }
//
//                collectionView.deselectItem(at: IndexPath(row: rowOfOldSelection, section: 0), animated: true)
//            }

//            emojiAndColorCollectionView.deselectItem(at: IndexPath(row: indexPath.row-1, section: 0), animated: true)
            if emojiAndColorCollectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false {
                emojiAndColorCollectionView.deselectItem(at: indexPath, animated: true)
            } else {
                emojiAndColorCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
            }
            
            
            
            
            selectedCell.contentView.backgroundColor = UIColor(named: "LightGray")?.withAlphaComponent(0.3)
            selectedCell.contentView.layer.cornerRadius = 16
            selectedEmoji = emojies.safetyAccessElement(at: indexPath.row)
            return
        }
        
        if indexPath.section == 1 {
            // отменяем выбор предыдущего цвета
            if let oldSelectedColor = selectedColor {
                guard let rowOldSelection = colors.firstIndex(of: selectedColor) else {
                    print("deselectItemAt: search firstIndex of old selection failed")
                    return
                }
                
                collectionView.deselectItem(at: IndexPath(row: rowOldSelection, section: 1), animated: true)
            }
            
            var color = colors.safetyAccessElement(at: indexPath.row) ?? .lightGray
            
            selectedCell.layer.borderWidth = 3
            selectedCell.layer.borderColor = color?.withAlphaComponent(0.3).cgColor
            selectedCell.layer.cornerRadius = 8

            let borderLayer = CALayer()
            borderLayer.frame = selectedCell.bounds
            borderLayer.borderColor = UIColor.white.cgColor
            borderLayer.borderWidth = 6
            borderLayer.cornerRadius = 8
            selectedCell.layer.insertSublayer(borderLayer, above: selectedCell.layer)
            
            guard let color = colors.safetyAccessElement(at: indexPath.row) else {
                print("select color: safetyAccessElement for index \(indexPath.row) failed")
                return
            }
            selectedColor = color
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        print("deselect \(indexPath)")
//        guard let cell = collectionView.cellForItem(at: indexPath) else {
//            print("failed to get cell by index \(indexPath)")
//            return
//        }
//
//        if indexPath.section == 0 {
//            cell.contentView.backgroundColor = UIColor(named: "WhiteDay")?.withAlphaComponent(0.3)
//            return
//        }
//
//        if indexPath.section == 1 {
//            cell.layer.borderColor = UIColor(named: "WhiteDay")?.cgColor
//        }
//    }
}


