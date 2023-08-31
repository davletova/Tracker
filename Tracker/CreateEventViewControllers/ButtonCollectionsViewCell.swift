//
//  ButtonCollectionsViewCell.swift
//  Tracker
//
//  Created by Алия Давлетова on 29.08.2023.
//

import Foundation
import UIKit

final class ButtonCollectionViewCell: UICollectionViewCell {
    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.backgroundColor = UIColor.getAppColors(.whiteDay)
        cancelButton.layer.cornerRadius = 16
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitleColor(UIColor.getAppColors(.red), for: .normal)
        cancelButton.layer.borderColor = UIColor.getAppColors(.red).cgColor
        cancelButton.layer.borderWidth = 1

        cancelButton.addTarget(self, action: #selector(cancelCreateEvent), for: .touchUpInside)

        return cancelButton
    }()

    private lazy var createEventButton: UIButton = {
        let createEventButton = UIButton()
        createEventButton.backgroundColor = UIColor.getAppColors(.blackDay)
        createEventButton.translatesAutoresizingMaskIntoConstraints = false
        createEventButton.layer.cornerRadius = 16
        createEventButton.setTitle("Создать", for: .normal)
        createEventButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createEventButton.setTitleColor(UIColor.getAppColors(.whiteDay), for: .normal)
        createEventButton.titleLabel?.textAlignment = .center

        createEventButton.addTarget(self, action: #selector(createEvent), for: .touchUpInside)

        return createEventButton
    }()
    
    weak var delegate: TrackerActionProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        contentView.addSubview(cancelButton)
        contentView.addSubview(createEventButton)
        
        contentView.backgroundColor = UIColor.getAppColors(.whiteDay)
        contentView.layer.cornerRadius = 16
        
        NSLayoutConstraint.activate([
           cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
           cancelButton.topAnchor.constraint(equalTo:contentView.topAnchor),
           cancelButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -(contentView.frame.width / 2 + 8)),
           cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 1),
            
           createEventButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
           createEventButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
           createEventButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
           createEventButton.topAnchor.constraint(equalTo: contentView.topAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func cancelCreateEvent() {
        guard let delegate = delegate else {
            assertionFailure("create event: delegate is empty")
            return
        }
        delegate.cancelCreateEvent()
    }
    
    @objc func createEvent() {
        guard let delegate = delegate else {
            assertionFailure("create event: delegate is empty")
            return
        }
        delegate.createEvent()
    }
}

extension ButtonCollectionViewCell: ChangeButtonStateProtocol {
    func enableButton() {
        createEventButton.isEnabled = true
        createEventButton.backgroundColor = UIColor.getAppColors(.blackDay)
    }
    func disableButton() {
        createEventButton.isEnabled = false
        createEventButton.backgroundColor = UIColor.getAppColors(.gray)
    }
}
