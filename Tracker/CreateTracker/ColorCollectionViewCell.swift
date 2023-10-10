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
    
    var cellColor: UIColor?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: contentView.bounds.width - 12),
            view.heightAnchor.constraint(equalToConstant: contentView.bounds.height - 12),
            view.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        self.layer.borderWidth = 3
        self.layer.cornerRadius = 10
        self.contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        self.unselectCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ColorCollectionViewCell:SelectableCellProtocol {
    func selectCell() {
        guard let color = cellColor else {
            assertionFailure("select cell: cell color is empty")
            return
        }
        
        self.layer.borderColor = color.withAlphaComponent(0.3).cgColor
    }
    
    func unselectCell() {
        self.layer.borderColor = UIColor.getAppColors(.whiteDay).cgColor
    }
}
