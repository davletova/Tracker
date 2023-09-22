//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Алия Давлетова on 10.08.2023.
//

import Foundation
import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func selectSchedule(_ schedule: Schedule) -> Void
}

final class ScheduleViewController: UIViewController {
    weak var delegate: ScheduleViewControllerDelegate?
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = NSLocalizedString("schedule.title", comment: "заголовок страницы с расписанием")
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor.getAppColors(.blackDay)
        
        view.addSubview(titleLabel)
        
        return titleLabel
    }()
    
    private lazy var doneButton: UIButton = {
        let doneButton = UIButton()
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        doneButton.layer.cornerRadius = 16
        doneButton.backgroundColor = UIColor.getAppColors(.blackDay)
        doneButton.setTitle(
            NSLocalizedString("schedule.button.done", comment: "текст кнопки Готово"),
            for: .normal
        )
        doneButton.setTitleColor(UIColor.getAppColors(.whiteDay), for: .normal)
        
        doneButton.addTarget(self, action: #selector(selectSchedule), for: .touchUpInside)
        
        view.addSubview(doneButton)
        
        return doneButton
    }()
    
    private lazy var daysTable: UITableView = {
        let daysTable = UITableView()
        daysTable.translatesAutoresizingMaskIntoConstraints = false
        daysTable.backgroundColor = UIColor.getAppColors(.backgroundDay)
        daysTable.layer.cornerRadius = 16
        daysTable.separatorColor = .gray
        daysTable.separatorStyle = .singleLine
        
        daysTable.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        daysTable.dataSource = self
        daysTable.delegate = self
        
        view.addSubview(daysTable)
        
        return daysTable
    }()
    
    private var scheduleDays: [DailySchedule]
        
    var selectedSchedule: Schedule?
    
    init() {
        scheduleDays = Weekday.allCases.map { weekday in
            DailySchedule(dayOfWeek: weekday, isScheduled: false)
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.getAppColors(.whiteDay)
        
        if let selectedSchedule = selectedSchedule {
            scheduleDays = Weekday.allCases.map { weekday in
                DailySchedule(dayOfWeek: weekday, isScheduled: selectedSchedule.repetition.contains(weekday))
            }
        }
        
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
    
    @objc func selectSchedule() {
        guard let delegate = delegate else {
            assertionFailure("select schedule: delegate is empty")
            return
        }
        delegate.selectSchedule(convertScheduleDaysToSchedule(scheduleDays: scheduleDays))
        
        dismiss(animated: true, completion: nil)
    }
    
    func convertScheduleDaysToSchedule(scheduleDays: [DailySchedule]) -> Schedule {
        var repetition = Set<Weekday>()
        
        scheduleDays.forEach({
            if $0.isScheduled {
                repetition.insert($0.dayOfWeek)
            }
        })
        
        return Schedule(startDate: Calendar.current.startOfDay(for: Date()), repetition: repetition)
    }
}

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduleDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dateFormatter = DateFormatter()
        
        let switcher = UISwitch(frame: CGRect(x: 0, y: 0, width: 51, height: 31))
        switcher.onTintColor = UIColor.getAppColors(.blue)
        switcher.tintColor = UIColor.getAppColors(.backgroundDay)
        switcher.setOn(scheduleDays[indexPath.row].isScheduled, animated: true)
        switcher.tag = indexPath.row
        switcher.addTarget(self, action: #selector(weekDaySwitcherValueChanged), for: .valueChanged)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        // смещаем индекс дня недели на 1, так как по умолчанию нулевой день недели - воскресенье
        // а мы хотим отобразить неделю с понедельника
        let weekdayIndex = (indexPath.row + 1) % 7
        cell.textLabel?.text = dateFormatter.standaloneWeekdaySymbols?[weekdayIndex].localizedCapitalized
        cell.backgroundColor = UIColor.getAppColors(.backgroundDay)
        cell.accessoryView = switcher
        cell.selectionStyle = .none
        
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}

