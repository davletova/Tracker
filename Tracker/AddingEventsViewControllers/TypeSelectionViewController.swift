//
//  TypeSelectionViewController.swift
//  Tracker
//
//  Created by Алия Давлетова on 07.08.2023.
//

import Foundation

import UIKit

final class TypeSelectionViewController: UIViewController {
    
    @IBOutlet weak var habitButton: UIButton!
    @IBOutlet weak var eventButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "WhiteDay")
        createButtons()
    }
    
    func createButtons() {
//        let buttonsView = UIView()
//        buttonsView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(buttonsView)
//        
        let habit = UIButton()
        habit.backgroundColor = UIColor(named: "BlackDay")
        habit.translatesAutoresizingMaskIntoConstraints = false
        habit.layer.cornerRadius = 16
        habit.setTitle("Привычка", for: .normal)
        habit.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        habit.titleLabel?.textColor = UIColor(named: "WhiteDay")
        habit.titleLabel?.textAlignment = .center
        habit.addTarget(self, action: #selector(goToCreateHabit), for: .touchUpInside)
        view.addSubview(habit)
        habitButton = habit
        
        
        let event = UIButton()
        event.backgroundColor = UIColor(named: "BlackDay")
        event.translatesAutoresizingMaskIntoConstraints = false
        event.layer.cornerRadius = 16
        event.setTitle("Нерегулярное событие", for: .normal)
        event.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        event.titleLabel?.textColor = UIColor(named: "WhiteDay")
        event.titleLabel?.textAlignment = .center
        
//        buttonsView.addSubview(event)
        view.addSubview(event)
        
        eventButton = event
        eventButton.addTarget(self, action: #selector(goToCreateEvent), for: .touchUpInside)
        
        
//        buttonsView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        habit.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        habit.widthAnchor.constraint(equalToConstant: 280).isActive = true
        habit.heightAnchor.constraint(equalToConstant: 60).isActive = true
        habit.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        event.widthAnchor.constraint(equalToConstant: 280).isActive = true
        event.heightAnchor.constraint(equalToConstant: 60).isActive = true
        event.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        event.topAnchor.constraint(equalTo: habit.bottomAnchor, constant: 10).isActive = true
    }
    
    
    @objc func goToCreateEvent() {
        print("-------- goToCreateEvent ----------")
        let popup = AddingEvent()
        popup.modalPresentationStyle = .popover
//        popup.popoverPresentationController?.passthroughViews = nil
        self.present(popup, animated: true)
    }
    
    @objc func goToCreateHabit() {
        print("-------------- go to create habit --------------")
    }
}
