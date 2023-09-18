//
//  TabBarViewController.swift
//  Tracker
//
//  Created by Алия Давлетова on 14.09.2023.
//

import Foundation
import UIKit

final class TabBarViewController: UITabBarController {
    override func viewDidLoad() {
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: self.tabBar.frame.size.width, height: 1))
        lineView.backgroundColor = UIColor.getAppColors(.tabBarBorder)
        
        self.tabBar.addSubview(lineView)
        
        let navigationController = UINavigationController(rootViewController: TrackerCollectionView())
        navigationController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("trackers", comment: "кнопка перехода на список трекеров"),
            image: UIImage(named: "record.circle.fill"),
            tag: 0
        )
        
        let statisticsViewModel = StatisticsViewModel(
            recordStore: TrackerRecordStore(),
            scheduleStore: TrackerScheduleStore(),
            trackerStore: TrackerStore()
        )
        let statisticsViewController = StatisticsViewController(viewModel: statisticsViewModel)
        statisticsViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("statistic", comment: "кнопка перехода на статистику"),
            image: UIImage(named: "hare.fill"),
            tag: 1
        )
        
        self.setViewControllers([navigationController, statisticsViewController], animated: true)
    }
}
