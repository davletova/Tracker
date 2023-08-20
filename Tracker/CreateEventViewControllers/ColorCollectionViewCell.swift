//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Алия Давлетова on 09.08.2023.
//


import Foundation
import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    let view: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: contentView.bounds.width - 12),
            view.heightAnchor.constraint(equalToConstant: contentView.bounds.height - 12),
            view.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

