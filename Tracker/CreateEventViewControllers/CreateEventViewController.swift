//
//  AddingHabit.swift
//  Tracker
//
//  Created by Алия Давлетова on 07.08.2023.
//

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
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Создание события"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(named: "BlackDay")
        
        view.addSubview(titleLabel)
        
        return titleLabel
    }()
    
    private lazy var eventNameInput: UITextField = {
        let eventNameInput = UITextField()
        eventNameInput.translatesAutoresizingMaskIntoConstraints = false
        eventNameInput.backgroundColor = UIColor(named: "BackgroundDay")
        eventNameInput.layer.cornerRadius = 16
        eventNameInput.leftView = UIView(frame: CGRectMake(0, 0, 16, eventNameInput.frame.height))
        eventNameInput.leftViewMode = .always
        eventNameInput.placeholder = "Введите название трекера"
        eventNameInput.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        view.addSubview(eventNameInput)
        
        return eventNameInput
    }()
    
    private lazy var buttonsTableView: UITableView = {
        let buttonsTableView = UITableView()
        buttonsTableView.translatesAutoresizingMaskIntoConstraints = false
        buttonsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        buttonsTableView.rowHeight = 75
        buttonsTableView.backgroundColor = UIColor(named: "BackgroundDay")
        buttonsTableView.layer.cornerRadius = 16
        buttonsTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: buttonsTableView.frame.size.width, height: 1))
        
        buttonsTableView.dataSource = self
        buttonsTableView.delegate = self
        
        view.addSubview(buttonsTableView)
        
        return buttonsTableView
    }()
        
    private lazy var emojiCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: emojiCellIdentifier)
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: colorCellIdentifier)
        collectionView.register(CreateEventSupplementaryView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "header")
        
        view.addSubview(collectionView)
        
        return collectionView
    }()
    
    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.backgroundColor = UIColor(named: "WhiteDay")
        cancelButton.layer.cornerRadius = 16
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitleColor(UIColor(named: "Red"), for: .normal)
        cancelButton.layer.borderColor = UIColor(named: "Red")?.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.addTarget(self, action: #selector(cancelCreateEvent), for: .touchUpInside)
        
        view.addSubview(cancelButton)
        
        return cancelButton
    }()
    
    private lazy var createEventButton: UIButton = {
        let createEventButton = UIButton()
        createEventButton.backgroundColor = UIColor(named: "BlackDay")
        createEventButton.translatesAutoresizingMaskIntoConstraints = false
        createEventButton.layer.cornerRadius = 16
        createEventButton.setTitle("Создать", for: .normal)
        createEventButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createEventButton.setTitleColor(UIColor(named: "WhiteDay"), for: .normal)
        createEventButton.titleLabel?.textAlignment = .center
        createEventButton.addTarget(self, action: #selector(goToCreateEventController), for: .touchUpInside)
        
        if let inputText = eventNameInput.text,
           inputText.isEmpty {
            createEventButton.isEnabled = false
            createEventButton.backgroundColor = UIColor(named: "Gray")
        }
        
        view.addSubview(createEventButton)
        
        return createEventButton
    }()
    
    var trackerService: TrackerServiceProtocol?
    var isHabit: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "WhiteDay")
        
        categoryAndScheduleButtons.append(TableButton(name: "Категория", callback: openCategories))
        if let isHabit = isHabit, isHabit {
            categoryAndScheduleButtons.append(TableButton(name: "Расписание", callback: openSchedule))
        }
        
        setConstraint()
    }
    
    private func setConstraint() {
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            eventNameInput.heightAnchor.constraint(equalToConstant: 75),
            eventNameInput.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            eventNameInput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            eventNameInput.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            buttonsTableView.topAnchor.constraint(equalTo: eventNameInput.bottomAnchor, constant: 24),
            buttonsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonsTableView.heightAnchor.constraint(equalToConstant: 75 * CGFloat(categoryAndScheduleButtons.count)),
            
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 450),
            emojiCollectionView.topAnchor.constraint(equalTo: buttonsTableView.bottomAnchor, constant: 16),
            emojiCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            emojiCollectionView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -buttonHeight - CGFloat(44)),
            
            cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
            cancelButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(view.frame.width / 2 + 3)),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            createEventButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 6),
            createEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createEventButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            createEventButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34)
        ])
    }
    
    private func openCategories() {
        let categoriesViewController = ListCategoriesViewController()
        categoriesViewController.modalPresentationStyle = .popover
        self.present(categoriesViewController, animated: true)
    }
    
    private func openSchedule() {
        let scheduleViewController = ScheduleViewController()
        scheduleViewController.modalPresentationStyle = .popover
        self.present(scheduleViewController, animated: true)
    }
    
    @objc func cancelCreateEvent() {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func goToCreateEventController() {
        guard let value = eventNameInput.text else {
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
        
        let newEvent: Tracker
        if isHabit {
            newEvent = Habit(
                id: UUID(),
                name: value,
                category: category2,
                emoji: "🏓",
                color: UIColor(named: "ColorSelection3")!,
                schedule: Schedule(startDate: Calendar.current.startOfDay(for: Date()), repetition: [Weekday.friday])
            )
        } else {
            newEvent = Tracker(
                id: UUID(),
                name: value,
                category: category2,
                emoji: "🏓",
                color: UIColor(named: "ColorSelection3")!
            )
        }
        
        trackerService.createTracker(tracker: newEvent)
        
        NotificationCenter.default.post(
            name: TrackerService.CreateTrackerNotification,
            object: self,
            userInfo: ["event": newEvent]
        )
        
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        if let nameInputText = eventNameInput.text,
           !nameInputText.isEmpty {
            createEventButton.isEnabled = true
            createEventButton.backgroundColor = UIColor(named: "BlackDay")
            return
        }
        
        createEventButton.isEnabled = false
        createEventButton.backgroundColor = UIColor(named: "Gray")
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
        return CGSize(width: collectionView.bounds.width / 6, height: collectionView.bounds.width / 6)
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
}


