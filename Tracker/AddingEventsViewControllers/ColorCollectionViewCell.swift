//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Алия Давлетова on 09.08.2023.
//


import Foundation
import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    let view = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.widthAnchor.constraint(equalToConstant: contentView.bounds.width - 12).isActive = true
        view.heightAnchor.constraint(equalToConstant: contentView.bounds.height - 12).isActive = true
        view.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

