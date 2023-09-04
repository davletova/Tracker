//
//  ListCategoriesViewControllerCell.swift
//  Tracker
//
//  Created by Алия Давлетова on 03.09.2023.
//

import Foundation
import UIKit

final class ListCategoriesViewControllerCell: UITableViewCell {
    var titleLabel: UILabel = {
        let title = UILabel()
        title.font = .systemFont(ofSize: 17, weight: .regular)
        title.textColor = .getAppColors(.blackDay)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textAlignment = .left
        
        return title
    }()
    
    private let lineView: UIView = {
        let uiView = UIView(frame: .zero)
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.backgroundColor = UIColor.getAppColors(.gray)
        uiView.isHidden = true
        
        return uiView
    }()
    
    func configure(title: String) {
        titleLabel.text = title
        contentView.backgroundColor = UIColor.getAppColors(.backgroundDay)
        contentView.addSubview(titleLabel)
        contentView.addSubview(lineView)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            lineView.topAnchor.constraint(equalTo: contentView.topAnchor),
            lineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            lineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            lineView.heightAnchor.constraint(equalToConstant: 0.5),
        ])

    }
    
   func configureCornersRadius(masks: CACornerMask) {
        contentView.layer.cornerRadius = 16
        contentView.layer.maskedCorners = masks
    }
        
    func showSeparator() {
        lineView.isHidden = false
    }
        
    override func prepareForReuse() {
        super.prepareForReuse()
        lineView.isHidden = true
    }
}
