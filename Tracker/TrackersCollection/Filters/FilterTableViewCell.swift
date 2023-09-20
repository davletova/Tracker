//
//  FilterTableViewCell.swift
//  Tracker
//
//  Created by Алия Давлетова on 19.09.2023.
//

import Foundation
import UIKit

class FilterTableViewCell: UITableViewCell {
    let titleLabel: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .systemFont(ofSize: 17, weight: .regular)
        title.textColor = .getAppColors(.blackDay)
        
        return title
    }()
    
    private let lineView: UIView = {
        let lineView = UIView(frame: .zero)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = .getAppColors(.gray)
        lineView.isHidden = true
        
        return lineView
    }()
    
    let selectedIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = .getAppColors(.blue)
        imageView.isHidden = true
        
        return imageView
    }()
    
    func configure(title: String) {
        titleLabel.text = title
        contentView.backgroundColor = .getAppColors(.backgroundDay)
        contentView.addSubview(titleLabel)
        contentView.addSubview(lineView)
        contentView.addSubview(selectedIcon)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            lineView.topAnchor.constraint(equalTo: contentView.topAnchor),
            lineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            lineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            lineView.heightAnchor.constraint(equalToConstant: 0.5),
            selectedIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            selectedIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configureCornersRadius(masks: CACornerMask) {
         contentView.layer.cornerRadius = 16
         contentView.layer.maskedCorners = masks
     }
         
     func showSeparator() {
         lineView.isHidden = false
     }
         
     func selectRow() {
         selectedIcon.isHidden = false
     }
     
     override func prepareForReuse() {
         super.prepareForReuse()
         lineView.isHidden = true
         selectedIcon.isHidden = true
     }
}

