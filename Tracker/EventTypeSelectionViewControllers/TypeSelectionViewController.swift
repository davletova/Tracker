//
//  TypeSelectionViewController.swift
//  Tracker
//
//  Created by Алия Давлетова on 07.08.2023.
//

import Foundation

import UIKit

final class TypeSelectionViewController: UIViewController {
    let habitButton = UIButton()
    let eventButton = UIButton()
    
    var trackerService: TrackerServiceProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "WhiteDay")
        createButtons()
    }
    
    func createButtons() {
        view.addSubview(habitButton)
        habitButton.backgroundColor = UIColor(named: "BlackDay")
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        habitButton.layer.cornerRadius = 16
        habitButton.setTitle("Привычка", for: .normal)
        habitButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        habitButton.titleLabel?.textColor = UIColor(named: "WhiteDay")
        habitButton.titleLabel?.textAlignment = .center
        habitButton.addTarget(self, action: #selector(goToCreateHabit), for: .touchUpInside)
        
        view.addSubview(eventButton)
        eventButton.backgroundColor = UIColor(named: "BlackDay")
        eventButton.translatesAutoresizingMaskIntoConstraints = false
        eventButton.layer.cornerRadius = 16
        eventButton.setTitle("Нерегулярное событие", for: .normal)
        eventButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        eventButton.titleLabel?.textColor = UIColor(named: "WhiteDay")
        eventButton.titleLabel?.textAlignment = .center
        eventButton.addTarget(self, action: #selector(goToCreateEvent), for: .touchUpInside)
        
        habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        habitButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        habitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        eventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        eventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        eventButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        eventButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        eventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 10).isActive = true
    }
    
    @objc func goToCreateEvent() {
        let addingEventViewController = AddingEventViewController()
        addingEventViewController.trackerService = trackerService
        addingEventViewController.isHabit = false
        self.present(addingEventViewController, animated: true)
    }
    
    @objc func goToCreateHabit() {
        let addingEventViewController = AddingEventViewController()
        addingEventViewController.trackerService = trackerService
        addingEventViewController.isHabit = true
        self.present(addingEventViewController, animated: true)
    }
}
