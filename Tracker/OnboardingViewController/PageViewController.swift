//
//  BlueViewController.swift
//  Tracker
//
//  Created by Алия Давлетова on 01.09.2023.
//

import Foundation
import UIKit

class PageViewController: UIViewController {
    private let backgroundView: UIImageView
    
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
        let title = NSLocalizedString("onboarding.button", comment: "buttn title on he onboarding page")
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.getAppColors(.whiteDay), for: .normal)
        
        return button
    }()
    
    init(title: String, backgroundImage: UIImage) {
        titleLabel.text = title
        backgroundView = UIImageView(image: backgroundImage)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgroundView()
        setupTitle()
        setupButton()
    }
    
    func setupBackgroundView() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
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
        button.addTarget(self, action: #selector(goToTrackersView), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -34),
            button.heightAnchor.constraint(equalToConstant: buttonHeight),
        ])
    }
    
    @objc func goToTrackersView() {
        let tabBar = TabBarViewController()
        
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("PageViewController: failed to get UIApplication.shared.windows.first")
            return
        }
        
        window.rootViewController = tabBar
    }
}

