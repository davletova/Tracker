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

final class AddingEventViewController: UIViewController {
    private let buttonHeight = CGFloat(60)
    private var tableButtons = [TableButton]()
    private let emojies = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪",
    ]
    private let colors = (1...18).map{ UIColor(named: "ColorSelection\($0)") }

    private let titleLabel = UILabel()
    private let nameInput = UITextField()
    private let tableView = UITableView()
    private let titleEmojiList = UILabel()
    private let titleColorsList = UILabel()
    private let cancelButton = UIButton()
    private let createButton = UIButton()

    private let emojiCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: emojiCellIdentifier)
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: colorCellIdentifier)
        collectionView.register(AddingEventSupplementaryView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "header")
        return collectionView
    }()

    var isHabit: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "WhiteDay")
    
        if let isHabit = isHabit, isHabit {
            tableButtons.append(TableButton(name: "Категория", callback: openCategories))
        }
        tableButtons.append(TableButton(name: "Расписание", callback:  openSchedule))
        
        createTitle()
        createNameInput()
        createTableWithButtons()
        createEmojiList()
        createButtons()
    }
    
    private func createTitle() {
        view.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Новое нерегулярное событие"
        titleLabel.textAlignment = .center
        
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(named: "BlackDay")
        
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    private func createNameInput() {
        view.addSubview(nameInput)
        
        nameInput.translatesAutoresizingMaskIntoConstraints = false
        nameInput.backgroundColor = UIColor(named: "BackgroundDay")
        nameInput.layer.cornerRadius = 16
        nameInput.leftView = UIView(frame: CGRectMake(0, 0, 16, nameInput.frame.height))
        nameInput.leftViewMode = .always
        nameInput.placeholder = "Введите название трекера"
        nameInput.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        NSLayoutConstraint.activate([
            nameInput.heightAnchor.constraint(equalToConstant: 75),
            nameInput.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            nameInput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameInput.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func createTableWithButtons() {
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 75
        tableView.backgroundColor = UIColor(named: "BackgroundDay")
        tableView.layer.cornerRadius = 16
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))

        tableView.dataSource = self
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: nameInput.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 75 * CGFloat(tableButtons.count))
        ])
    }
    
    private func createEmojiList() {
        view.addSubview(emojiCollectionView)
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 450),
            emojiCollectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            emojiCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            emojiCollectionView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -buttonHeight - CGFloat(44))
        ])
        
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
    }
    
    private func createButtons() {
        view.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.backgroundColor = UIColor(named: "WhiteDay")
        cancelButton.layer.cornerRadius = 16
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitleColor(UIColor(named: "Red"), for: .normal)
        cancelButton.layer.borderColor = UIColor(named: "Red")?.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.addTarget(self, action: #selector(cancelCreateEvent), for: .touchUpInside)
        
        view.addSubview(createButton)
        createButton.backgroundColor = UIColor(named: "BlackDay")
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.layer.cornerRadius = 16
        createButton.setTitle("Создать", for: .normal)
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createButton.setTitleColor(UIColor(named: "WhiteDay"), for: .normal)
        createButton.titleLabel?.textAlignment = .center
        createButton.addTarget(self, action: #selector(createEvent), for: .touchUpInside)
        
        if let inputText = nameInput.text,
           inputText.isEmpty {
            print("--------- want disable button ------------")
            
            createButton.isEnabled = false
            createButton.backgroundColor = UIColor(named: "Gray")
        }
        
        NSLayoutConstraint.activate([
            cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
            cancelButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(view.frame.width / 2 + 3)),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 6),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            createButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34)
        ])
    }
    
    func openCategories() {
        let categoriesViewController = ListCategoriesViewController()
        categoriesViewController.modalPresentationStyle = .popover
        self.present(categoriesViewController, animated: true)
    }
    
    func openSchedule() {
        let scheduleViewController = ScheduleViewController()
        scheduleViewController.modalPresentationStyle = .popover
        self.present(scheduleViewController, animated: true)
    }
    
    @objc func cancelCreateEvent() {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
//        dismiss(animated: true)
    }
    
    @objc func  createEvent() {
        guard let value = nameInput.text else {
            print("createEvent: nameInput.text is empty")
            return
        }
        
        // Здесь будет создание ивэнта
        
        dismiss(animated: true)
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        if let nameInputText = nameInput.text,
           !nameInputText.isEmpty {
            createButton.isEnabled = true
            createButton.backgroundColor = UIColor(named: "BlackDay")
            return
        }
        
        createButton.isEnabled = false
        createButton.backgroundColor = UIColor(named: "Gray")
    }
}
extension AddingEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableButtons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = tableButtons[indexPath.row].name
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

extension AddingEventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableButtons[indexPath.row].callback()
    }
}

extension AddingEventViewController: UICollectionViewDataSource {
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

        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? AddingEventSupplementaryView else {
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

extension AddingEventViewController: UICollectionViewDelegateFlowLayout {
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


