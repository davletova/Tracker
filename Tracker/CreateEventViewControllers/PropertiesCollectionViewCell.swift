//
//  PropertiesCollectionViewCell.swift
//  Tracker
//
//  Created by Алия Давлетова on 29.08.2023.
//

import Foundation
import UIKit

final class PropertiesCollectionViewCell: UICollectionViewCell {
    let title: UILabel = {
        let title = UILabel()
        title.font = .systemFont(ofSize: 17, weight: .regular)
        title.textColor = .getAppColors(.blackDay)
        title.translatesAutoresizingMaskIntoConstraints = false
        
        return title
    }()
    
    let subTitle: UILabel = {
        let title = UILabel()
        title.font = .systemFont(ofSize: 17, weight: .regular)
        title.textColor = .getAppColors(.gray)
        title.translatesAutoresizingMaskIntoConstraints = false
        
        return title
    }()
    
    lazy var titleCenterYConstraint: NSLayoutConstraint = {
        return title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    }()

    lazy var titleYConstraint: NSLayoutConstraint = {
        return title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15)
    }()
    
//    var subTitleText: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = UIColor.getAppColors(.backgroundDay)
        contentView.addSubview(title)
        contentView.addSubview(subTitle)
        
        let chevronImageView = UIImageView(image: UIImage(named: "chevron"))
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(chevronImageView)
       
        
        titleCenterYConstraint.isActive = true
        titleYConstraint.isActive = false
    
        
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            subTitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 2),
            subTitle.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            chevronImageView.widthAnchor.constraint(equalToConstant: 24),
            chevronImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configureCornersRadius(masks: CACornerMask) {
        contentView.layer.cornerRadius = 16
        contentView.layer.maskedCorners = masks
    }
    
    func setSubtitle(subtitle: String) {
        subTitle.text = subtitle
        titleCenterYConstraint.isActive = false
        titleYConstraint.isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
