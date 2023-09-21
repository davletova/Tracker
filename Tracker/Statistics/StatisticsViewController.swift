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
    private let viewModel: StatisticsViewModelProtocol
    
    private lazy var statisticTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor.getAppColors(.blackDay)
        label.textAlignment = .left
        label.text = NSLocalizedString("statistic.title", comment: "заголовок страницы со статистикой")
        
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
    
    private lazy var emptyCollectionView: UIView = {
        let view = UIView()
        let imageView = UIImageView(image: UIImage(named: "empty"))
        let label = UILabel()
        label.text = NSLocalizedString("statistic.empty.view", comment: "текст для пустого списка категорий")
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        return view
    }()
    
    init(viewModel: StatisticsViewModelProtocol) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var trackresCount = 0
        do {
            trackresCount = try viewModel.getTrackersCount()
        } catch {
            print("failed to getTrackersCount with error \(error)")
            statisticStack.isHidden = true
            showEmptyView()
        }
        
        if trackresCount == 0 {
            showEmptyView()
            statisticStack.isHidden = true
            return
        } else {
            hideEmptyView()
            statisticStack.isHidden = false
        }
        
        var bestPeriodDays = 0
        var idealDayCount = 0
        var totalPerformedHabits = 0
        var average = 0
        do {
            bestPeriodDays = try viewModel.getBestPeriod()
        } catch {
            print("failed to get best period days with erro: \(error)")
        }
        
        do {
            idealDayCount = try viewModel.getCountOfIdealDays()
        } catch {
            print("failed to getCountOfIdealDays with erro: \(error)")
        }
        
        do {
            totalPerformedHabits = try viewModel.getTotalPerformedHabits()
        } catch {
            print("failed to getTotalPerformedHabits with erro: \(error)")
        }
        
        do {
            average = try viewModel.getAverrage()
        } catch {
            print("failed to getAverrage with erro: \(error)")
        }
        
        bestPeriodView.configure(
            numberTitleText: bestPeriodDays.description,
            descTitleText: NSLocalizedString("statistic.best.period", comment: "показатель лучший период")
        )
        perfectDays.configure(
            numberTitleText: idealDayCount.description,
            descTitleText: NSLocalizedString("statistic.ideal.days", comment: "показатель идеальный дни")
        )
        completedTrackers.configure(
            numberTitleText: totalPerformedHabits.description,
            descTitleText: NSLocalizedString("statistic.completed.trackers", comment: "показатель завершенные трекеры")
        )
        averageValue.configure(
            numberTitleText: average.description,
            descTitleText: NSLocalizedString("statistic.average.value", comment: "показатель среднее значение")
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.getAppColors(.whiteDay)

        view.addSubview(statisticTitle)
        view.addSubview(statisticStack)
        
        NSLayoutConstraint.activate([
            statisticTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statisticTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            
            statisticStack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            statisticStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            bestPeriodView.heightAnchor.constraint(equalToConstant: statisticCellHeight),
            perfectDays.heightAnchor.constraint(equalToConstant: statisticCellHeight),
            completedTrackers.heightAnchor.constraint(equalToConstant: statisticCellHeight),
            averageValue.heightAnchor.constraint(equalToConstant: statisticCellHeight),
        ])
    }
    
    private func showEmptyView() {
        view.addSubview(emptyCollectionView)
        
        NSLayoutConstraint.activate([
            emptyCollectionView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyCollectionView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    func hideEmptyView() {
        emptyCollectionView.removeFromSuperview()
    }
}
