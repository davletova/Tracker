//
//  StartViewController.swift
//  Tracker
//
//  Created by Алия Давлетова on 13.09.2023.
//

import Foundation
import UIKit

final class StartViewController: UITabBarController {
    override func viewDidLoad() {
        let tabBar = UITabBarController()

        let lineView = UIView(frame: CGRect(x: 0, y: 0, width:tabBar.tabBar.frame.size.width, height: 1))
        lineView.backgroundColor = UIColor.getAppColors(.tabBarBorder)
        tabBar.tabBar.addSubview(lineView)

        let navigationController = UINavigationController(rootViewController: TrackerCollectionView())
        navigationController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("trackers", comment: "кнопка перехода на список трекеров"),
            image: UIImage(named: "record.circle.fill"),
            tag: 0
        )

        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("statistic", comment: "кнопка перехода на статистику"),
            image: UIImage(named: "hare.fill"),
            tag: 1
        )
        tabBar.setViewControllers([navigationController, statisticsViewController], animated: true)
    }
}
