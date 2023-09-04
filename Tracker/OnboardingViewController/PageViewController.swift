//
//  BlueViewController.swift
//  Tracker
//
//  Created by Алия Давлетова on 01.09.2023.
//

import Foundation
import UIKit

class PageViewController: UIViewController {
    private let titleLabel: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textColor = UIColor.getAppColors(.blackDay)
        title.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        title.textAlignment = .center
        title.numberOfLines = 2
        
        return title
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.backgroundColor = UIColor.getAppColors(.blackDay)
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(UIColor.getAppColors(.whiteDay), for: .normal)
        button.addTarget(self, action: #selector(goToTrackersView), for: .touchUpInside)
        
        return button
    }()
    
    private let backgroundImage: UIImage
    
    init(title: String, backgroundImage: UIImage) {
        titleLabel.text = title
        self.backgroundImage = backgroundImage
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(patternImage: backgroundImage)
        
        setupTitle()
        setupButton()
    }
    
    func setupTitle() {
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 2 * view.frame.height / 3),
        ])
    }
    
    func setupButton() {
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -34),
            button.heightAnchor.constraint(equalToConstant: buttonHeight),
        ])
    }
    
    @objc func goToTrackersView() {
        let tabBar = UITabBarController()

        let lineView = UIView(frame: CGRect(x: 0, y: 0, width:tabBar.tabBar.frame.size.width, height: 1))
        lineView.backgroundColor = UIColor.getAppColors(.tabBarBorder)
        tabBar.tabBar.addSubview(lineView)

        let navigationController = UINavigationController(rootViewController: TrackerCollectionView())
        navigationController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "record.circle.fill"),
            tag: 0
        )

        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "hare.fill"),
            tag: 1
        )
        tabBar.setViewControllers([navigationController, statisticsViewController], animated: true)
        
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("PageViewController: failed to get UIApplication.shared.windows.first")
            return
        }
        
        window.rootViewController = tabBar
    }
}

