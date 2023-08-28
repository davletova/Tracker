//
//  TypeSelectionViewController.swift
//  Tracker
//
//  Created by Алия Давлетова on 07.08.2023.
//

import Foundation

import UIKit

final class TypeSelectionViewController: UIViewController {
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Создание трекера"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = BlackDayColor
        
        view.addSubview(titleLabel)
        
        return titleLabel
    }()
    
    private let habitButton: UIButton = {
        let habitButton = UIButton()
        habitButton.backgroundColor = BlackDayColor
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        habitButton.layer.cornerRadius = 16
        habitButton.setTitle("Привычка", for: .normal)
        habitButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        habitButton.titleLabel?.textColor = WhiteDayColor
        habitButton.titleLabel?.textAlignment = .center
        
        return habitButton
    }()
    
    private let eventButton: UIButton = {
        let eventButton = UIButton()
        eventButton.backgroundColor = BlackDayColor
        eventButton.translatesAutoresizingMaskIntoConstraints = false
        eventButton.layer.cornerRadius = 16
        eventButton.setTitle("Нерегулярное событие", for: .normal)
        eventButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        eventButton.titleLabel?.textColor = WhiteDayColor
        eventButton.titleLabel?.textAlignment = .center
        
        return eventButton
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = WhiteDayColor
        
        habitButton.addTarget(self, action: #selector(goToCreateHabit), for: .touchUpInside)
        view.addSubview(habitButton)
        
        eventButton.addTarget(self, action: #selector(goToCreateEvent), for: .touchUpInside)
        view.addSubview(eventButton)
        
        setConstraint()
    }
    
    func setConstraint() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            habitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            eventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            eventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            eventButton.heightAnchor.constraint(equalToConstant: 60),
            eventButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            eventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 10),
        ])
    }
    
    @objc func goToCreateEvent() {
        let addingEventViewController = CreateEventViewController()
        addingEventViewController.isHabit = false
        self.present(addingEventViewController, animated: true)
    }
    
    @objc func goToCreateHabit() {
        let addingEventViewController = CreateEventViewController()
        addingEventViewController.isHabit = true
        self.present(addingEventViewController, animated: true)
    }
}
