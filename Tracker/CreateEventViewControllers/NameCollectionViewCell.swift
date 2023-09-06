//
//  PropertyCollectionViewCell.swift
//  Tracker
//
//  Created by Алия Давлетова on 29.08.2023.
//

import Foundation
import UIKit

final class NameCollectionViewCell: UICollectionViewCell {
    private let trackerNameInput: UITextField = {
        let eventNameInput = UITextField()
        eventNameInput.translatesAutoresizingMaskIntoConstraints = false
        eventNameInput.backgroundColor = UIColor.getAppColors(.backgroundDay)
        eventNameInput.layer.cornerRadius = 16
        eventNameInput.leftView = UIView(frame: CGRectMake(0, 0, 16, eventNameInput.frame.height))
        eventNameInput.leftViewMode = .always
        eventNameInput.placeholder = "Введите название трекера"
        
        return eventNameInput
    }()
    
    var setTrackerNameClosure: ((_ name: String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        trackerNameInput.delegate = self
        trackerNameInput.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        contentView.addSubview(trackerNameInput)
        
        NSLayoutConstraint.activate([
            trackerNameInput.heightAnchor.constraint(equalToConstant: rowHeight),
            trackerNameInput.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerNameInput.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerNameInput.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        if let nameInputText = trackerNameInput.text {
            guard let setTrackerName = setTrackerNameClosure else {
                print("NameCollectionViewCell: setTrackerNameClosure is empty")
                return
            }
            setTrackerName(nameInputText)
        }
    }
}

extension NameCollectionViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 38
    }
}

