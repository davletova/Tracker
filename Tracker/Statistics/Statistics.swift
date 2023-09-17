//
//  Statistics.swift
//  Tracker
//
//  Created by Алия Давлетова on 15.08.2023.
//

import Foundation
import UIKit

let statisticCellHeight = CGFloat(90)

class StatisticsViewController: UIViewController {
    private lazy var statisticTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor.getAppColors(.blackDay)
        label.textAlignment = .left
        label.text = "Статистика"
        
        return label
    }()
    
    private lazy var statisticStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [bestPeriodView, perfectDays, completedTrackers, averageValue])
        
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    
    private lazy var bestPeriodView = GradientView(frame: CGRect(x: 0, y: 0, width: view.frame.width - 32, height: 90))
    
    private lazy var perfectDays = GradientView(frame: CGRect(x: 0, y: 0, width: view.frame.width - 32, height: 90))
    
    private lazy var completedTrackers = GradientView(frame: CGRect(x: 0, y: 0, width: view.frame.width - 32, height: 90))
    
    private lazy var averageValue = GradientView(frame: CGRect(x: 0, y: 0, width: view.frame.width - 32, height: 90))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.getAppColors(.whiteDay)

        //TODO: сделать локализацию
        bestPeriodView.configure(numberTitleText: "4", descTitleText: "Лучший период")
        perfectDays.configure(numberTitleText: "123", descTitleText: "Иделаьные дни")
        completedTrackers.configure(numberTitleText: "34567788", descTitleText: "Завершенные трекеры")
        averageValue.configure(numberTitleText: "34", descTitleText: "Среднее значение")
        
        view.addSubview(statisticTitle)
        view.addSubview(statisticStack)
        
        NSLayoutConstraint.activate([
            statisticTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statisticTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            
            statisticStack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            statisticStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
//            bestPeriodView.topAnchor.constraint(equalTo: statisticTitle.bottomAnchor, constant: 77),
//            bestPeriodView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            bestPeriodView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bestPeriodView.heightAnchor.constraint(equalToConstant: statisticCellHeight),
//
//            perfectDays.topAnchor.constraint(equalTo: bestPeriodView.bottomAnchor, constant: 12),
            perfectDays.heightAnchor.constraint(equalToConstant: statisticCellHeight),
//            perfectDays.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            perfectDays.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//
//            completedTrackers.topAnchor.constraint(equalTo: perfectDays.bottomAnchor, constant: 12),
            completedTrackers.heightAnchor.constraint(equalToConstant: statisticCellHeight),
//            completedTrackers.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            completedTrackers.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//
//            averageValue.topAnchor.constraint(equalTo: completedTrackers.bottomAnchor, constant: 12),
            averageValue.heightAnchor.constraint(equalToConstant: statisticCellHeight),
//            averageValue.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            averageValue.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
}
