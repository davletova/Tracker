//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Алия Давлетова on 31.07.2023.
//

import Foundation
import UIKit

protocol TrackEventProtocol: AnyObject {
    func trackEvent(indexPath: IndexPath)
    func pinTracker(indexPath: IndexPath, pinned: Bool)
    func editTracker(indexPath: IndexPath)
    func deleteTracker(indexPath: IndexPath)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    static let TrackerRecordSavedNotification = Notification.Name(rawValue: "CreateRecord")
    
    private let emogiLabel: UILabel = {
        var emojiLabel = UILabel()
        emojiLabel.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.layer.masksToBounds = true
        emojiLabel.layer.cornerRadius = emojiLabel.frame.height / 2
        emojiLabel.textAlignment = .center
        emojiLabel.font = UIFont.systemFont(ofSize: 16)
        
        return emojiLabel
    }()
    
    private let nameLabel: UILabel = {
        var nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        nameLabel.textColor = .white
        
        return nameLabel
    }()
    
    private let eventNameView: UIView = {
        let eventNameView = UIView()
        eventNameView.translatesAutoresizingMaskIntoConstraints = false
        eventNameView.layer.cornerRadius = 16
        
        return eventNameView
    }()
    
    private let trackedDaysLabel: UILabel = {
        let trackedDaysLabel = UILabel()
        trackedDaysLabel.textColor = .getAppColors(.blackDay)
        trackedDaysLabel.translatesAutoresizingMaskIntoConstraints = false
        trackedDaysLabel.textAlignment = .center
        trackedDaysLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        return trackedDaysLabel
    }()
    
    private let trackButton: UIButton = {
        var trackButton = UIButton()
        trackButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        trackButton.layer.masksToBounds = true
        trackButton.translatesAutoresizingMaskIntoConstraints = false
        trackButton.layer.cornerRadius = trackButton.frame.height / 2
        trackButton.tintColor = .white
        
        return trackButton
    }()
    
    private let trackView: UIView = {
        var trackView = UIView()
        trackView.translatesAutoresizingMaskIntoConstraints = false
        
        return trackView
    }()
    
    var indexPath: IndexPath?
    var pinned = false
    
    weak var delegate: TrackEventProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        nameLabel.frame = CGRect(x: 12, y: 44, width: frame.width - 24, height: 34)
        
        eventNameView.addSubview(emogiLabel)
        eventNameView.addSubview(nameLabel)
        contentView.addSubview(eventNameView)
        
        trackButton.addTarget(self, action: #selector(trackEvent), for: .touchUpInside)
        
        trackView.addSubview(trackedDaysLabel)
        trackView.addSubview(trackButton)
        contentView.addSubview(trackView)
        
        let interaction = UIContextMenuInteraction(delegate: self)
        eventNameView.addInteraction(interaction)
        
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConstraint() {
        NSLayoutConstraint.activate([
            eventNameView.topAnchor.constraint(equalTo: contentView.topAnchor),
            eventNameView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            eventNameView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            eventNameView.heightAnchor.constraint(equalToConstant: 90),
            
            nameLabel.bottomAnchor.constraint(equalTo: eventNameView.bottomAnchor, constant: -10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            emogiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            emogiLabel.topAnchor.constraint(equalTo: eventNameView.topAnchor, constant: 10),
            emogiLabel.widthAnchor.constraint(equalToConstant: 30),
            emogiLabel.heightAnchor.constraint(equalToConstant: 30),
            
            trackView.topAnchor.constraint(equalTo: eventNameView.bottomAnchor),
            trackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackView.widthAnchor.constraint(equalToConstant: frame.width),
            trackView.heightAnchor.constraint(equalToConstant: 58),
            
            trackedDaysLabel.centerYAnchor.constraint(equalTo: trackView.centerYAnchor),
            trackedDaysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            
            trackButton.centerYAnchor.constraint(equalTo: trackView.centerYAnchor),
            trackButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            trackButton.widthAnchor.constraint(equalToConstant: 40),
            trackButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    func configureCell(cellTracker: TrackerViewModel) {
        pinned = cellTracker.tracker.pinned
        emogiLabel.text = cellTracker.tracker.emoji
        
        nameLabel.text = cellTracker.tracker.name
        
        nameLabel.lineBreakMode = .byWordWrapping
        nameLabel.numberOfLines = 0
        trackedDaysLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("trackedDays", comment: "Число затреканных дней"),
            cellTracker.trackedDaysCount
        )
        eventNameView.backgroundColor = cellTracker.tracker.color
        emogiLabel.backgroundColor = .white.withAlphaComponent(0.3)
        trackButton.backgroundColor = cellTracker.tracker.color
        
        if cellTracker.tracked {
            trackButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            trackButton.backgroundColor = trackButton.backgroundColor?.withAlphaComponent(0.3)
        } else {
            trackButton.setImage(UIImage(systemName: "plus"), for: .normal)
            trackButton.backgroundColor = trackButton.backgroundColor?.withAlphaComponent(1)
            trackButton.tintColor = .white
        }
    }
    
    @objc private func trackEvent() {
        AnalyticsService.sendEvent(event: "click", screen: "Main", item: "track")
        
        guard let indexPath = indexPath else {
            print("TrackerCollectionViewCell: indexPath is empty")
            return
        }
        
        guard let delegate = delegate else {
            assertionFailure("TrackerCollectionViewCell: delegate is empty")
            return
        }
        delegate.trackEvent(indexPath: indexPath)
    }
    
    func disableTrackButton() { trackButton.isEnabled = false }
    
    func enableTrackButton() { trackButton.isEnabled = true }
}

extension TrackerCollectionViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        //TODO: убрать иконки на действиях
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil,
                                          actionProvider: { [weak self] suggestedActions in
            guard let self = self else {
                assertionFailure("this should be never happen!")
                return UIMenu()
            }
            let pinAction =
            UIAction(title: NSLocalizedString(self.pinned ? "Открепить" : "Закрепить", comment: ""),
                         image: UIImage(systemName: "arrow.up.square")) { action in
                
                self.delegate?.pinTracker(indexPath: self.indexPath!, pinned: !self.pinned)
                }
                
            let editAction =
                UIAction(title: NSLocalizedString("Редактировать", comment: ""),
                         image: UIImage(systemName: "plus.square.on.square")) { action in
                    AnalyticsService.sendEvent(event: "click", screen: "Main", item: "edit")
                                        
                    self.delegate?.editTracker(indexPath: self.indexPath!)
                }
                
            let deleteAction =
                UIAction(title: NSLocalizedString("Удалить", comment: ""),
                         image: UIImage(systemName: "trash"),
                         attributes: .destructive) { action in
                    AnalyticsService.sendEvent(event: "click", screen: "Main", item: "delete")
                    
                    self.delegate?.deleteTracker(indexPath: self.indexPath!)
                }
                                            
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        })
    }
}
