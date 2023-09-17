//
//  gradientView.swift
//  Tracker
//
//  Created by Алия Давлетова on 17.09.2023.
//

import Foundation
import UIKit

final class GradientView: UIView {
    private lazy var subview: UIView = {
        let subview = UIView(frame: CGRect(x: 1, y: 1, width: self.bounds.width - 2, height: self.bounds.height - 2))
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.backgroundColor = UIColor.getAppColors(.whiteDay)
        subview.layer.cornerRadius = 15
        subview.layer.masksToBounds = true

        return subview
    }()
    
    lazy var numberTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor.getAppColors(.blackDay)
        label.textAlignment = .left
        
        return label
    }()
    
    lazy var descTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor.getAppColors(.blackDay)
        label.textAlignment = .left
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildLayout()
    }
    
    func buildLayout() {
        self.layer.cornerRadius = 16
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        
        gradientLayer.colors = [
            UIColor.getAppColors(.gradient1).cgColor,
            UIColor.getAppColors(.gradient2).cgColor,
            UIColor.getAppColors(.gradient3).cgColor
        ]

        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 16
        gradientLayer.masksToBounds = true
        
        self.layer.addSublayer(gradientLayer)
        self.addSubview(subview)
        subview.addSubview(numberTitle)
        subview.addSubview(descTitle)
        
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: self.topAnchor, constant: 1),
            subview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1),
            subview.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 1),
            subview.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -1),

            numberTitle.leadingAnchor.constraint(equalTo: subview.leadingAnchor, constant: 12),
            numberTitle.topAnchor.constraint(equalTo: subview.topAnchor, constant: 12),

            descTitle.topAnchor.constraint(equalTo: numberTitle.bottomAnchor, constant: 7),
            descTitle.leadingAnchor.constraint(equalTo: subview.leadingAnchor, constant: 12),
        ])
    }
    
    func configure(numberTitleText: String, descTitleText: String) {
        numberTitle.text = numberTitleText
        descTitle.text = descTitleText
    }
}
