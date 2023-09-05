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
    
    private let selectesRow: UIImageView = {
        let image = UIImageView(image: UIImage(named: "row.done"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.isHidden = true
        
        return image
    }()
    
    func configure(title: String) {
        titleLabel.text = title
        contentView.backgroundColor = UIColor.getAppColors(.backgroundDay)
        contentView.addSubview(titleLabel)
        contentView.addSubview(lineView)
        contentView.addSubview(selectesRow)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            lineView.topAnchor.constraint(equalTo: contentView.topAnchor),
            lineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            lineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            lineView.heightAnchor.constraint(equalToConstant: 0.5),
            selectesRow.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectesRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            selectesRow.widthAnchor.constraint(equalToConstant: 24),
            selectesRow.heightAnchor.constraint(equalToConstant: 24),
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
        selectesRow.isHidden = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        lineView.isHidden = true
    }
}
