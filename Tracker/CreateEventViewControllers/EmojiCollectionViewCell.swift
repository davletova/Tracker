//
//  EmojiCollectionViewCell.swift
//  Tracker
//
//  Created by Алия Давлетова on 09.08.2023.
//

import Foundation
import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    var titleLabel: UILabel = {
        var titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return titleLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EmojiCollectionViewCell: SelectableCellProtocol {
    func selectCell() {
        self.contentView.backgroundColor = UIColor(named: "LightGray")
        self.contentView.layer.cornerRadius = 16
    }
    
    func unselectCell() {
        self.contentView.backgroundColor = UIColor(named: "WhiteDay")
    }
}
