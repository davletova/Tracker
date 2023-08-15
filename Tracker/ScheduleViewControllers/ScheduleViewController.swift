//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Алия Давлетова on 10.08.2023.
//

import Foundation
import UIKit

struct DailySchedule {
    let dayOfWeek: Weekday
    var isScheduled: Bool
}

final class ScheduleViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    let rowHeight: CGFloat = 75.0
    let buttonHeight: CGFloat = 60.0
    
    var scheduleDays = Weekday.allCases.map { weekday in
        DailySchedule(dayOfWeek: weekday, isScheduled: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "WhiteDay")
        
        createTitle()
        createTable()
        createButton()
    }
    
    func createButton() {
        let button = UIButton(type: .custom)

        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.backgroundColor = UIColor(named: "BlackDay")

        button.setTitle("Готово", for: .normal)
        // button.addTarget(self, action: #selector(<#T##@objc method#>), for: .)

        // button.addTarget(self, action: #selector(openSchedules), for: .touchUpInside)
        view.addSubview(button)
        doneButton = button
        
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24).isActive = true
        button.heightAnchor.constraint(equalToConstant: 75).isActive = true
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
    }
    
    func createTitle() {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Расписание"
        title.textAlignment = .center
        
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        title.textColor = UIColor(named: "BlackDay")
        view.addSubview(title)
        
        title.widthAnchor.constraint(equalToConstant: 288).isActive = true
        title.heightAnchor.constraint(equalToConstant: 22).isActive = true
        title.topAnchor.constraint(equalTo: view.topAnchor, constant: 24).isActive = true
        title.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        titleLabel = title
     }

    func createTable() {
        let table = UITableView()
        
        view.addSubview(table)
        table.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        table.dataSource = self
        table.delegate = self
        
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = UIColor(named: "BackgroundDay")
        table.layer.cornerRadius = 16
        table.separatorColor = .gray
        table.separatorStyle = .singleLine
        
        table.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24).isActive = true
        table.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        table.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        table.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -buttonHeight-44.0).isActive = true
    }
}

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduleDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let weekdayIndex = (indexPath.row + 1) % 7
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        let switcher = UISwitch(frame: CGRect(x: 0, y: 0, width: 51, height: 31))
        switcher.setOn(scheduleDays[weekdayIndex].isScheduled, animated: true)
        switcher.tag = weekdayIndex
        switcher.addTarget(self, action: #selector(weekDaySwitcherValueChanged), for: .valueChanged)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = dateFormatter.standaloneWeekdaySymbols?[weekdayIndex].localizedCapitalized
        cell.backgroundColor = UIColor(named: "BackgroundDay")
        cell.accessoryView = switcher
        
        return cell
    }
    
    @objc func weekDaySwitcherValueChanged(_ sender: UISwitch) {
        let weekdayIndex: Int = sender.tag
        scheduleDays[weekdayIndex].isScheduled = sender.isOn
    }
}

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let numberOfRows = scheduleDays.count
        let totalTableHeight = tableView.frame.height - tableView.contentInset.top - tableView.contentInset.bottom
        let cellHeight = totalTableHeight / CGFloat(numberOfRows)
        
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true, completion: nil)
    }
}

