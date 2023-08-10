//
//  EmojiCollectionViewCell.swift
//  Tracker
//
//  Created by Алия Давлетова on 09.08.2023.
//

import Foundation
import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    var titleLabel = UILabel()
    var color = UIColor()
    var isEmoji = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        
            contentView.addSubview(titleLabel)
            titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
            
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
