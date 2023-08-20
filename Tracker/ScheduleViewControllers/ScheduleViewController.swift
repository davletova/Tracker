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
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Расписание"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(named: "BlackDay")
        
        view.addSubview(titleLabel)
        
        return titleLabel
    }()
    
    private lazy var doneButton: UIButton = {
        let doneButton = UIButton()
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.layer.cornerRadius = 16
        doneButton.backgroundColor = UIColor(named: "BlackDay")
        doneButton.setTitle("Готово", for: .normal)
        doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)
        
        view.addSubview(doneButton)
        
        return doneButton
    }()
    
    private lazy var daysTable: UITableView = {
        let daysTable = UITableView()
        daysTable.translatesAutoresizingMaskIntoConstraints = false
        daysTable.backgroundColor = UIColor(named: "BackgroundDay")
        daysTable.layer.cornerRadius = 16
        daysTable.separatorColor = .gray
        daysTable.separatorStyle = .singleLine
        
        daysTable.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        daysTable.dataSource = self
        daysTable.delegate = self
        
        view.addSubview(daysTable)
        
        return daysTable
    }()
    
    let rowHeight: CGFloat = 75.0
    let buttonHeight: CGFloat = 60.0
    
    var scheduleDays = Weekday.allCases.map { weekday in
        DailySchedule(dayOfWeek: weekday, isScheduled: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "WhiteDay")
        
        setConstraint()
    }
    
    func setConstraint() {
        NSLayoutConstraint.activate([
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -44),
            doneButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            titleLabel.widthAnchor.constraint(equalToConstant: 288),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            daysTable.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            daysTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            daysTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            daysTable.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -39)
        ])
    }
    
    @objc func done() {
        dismiss(animated: true, completion: nil)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
}

