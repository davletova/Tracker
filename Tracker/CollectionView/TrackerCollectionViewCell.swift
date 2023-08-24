//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Алия Давлетова on 31.07.2023.
//

import Foundation
import UIKit

struct TrackerCell {
    let id: UUID
    let name: String
    let emoji: String
    let color: UIColor
    var tracked: Bool
    var trackedDaysCount: Int
    
    init(event: Tracker,
         trackedDaysCount: Int,
         tracked: Bool
    ) {
        self.id = event.id
        self.name = event.name
        self.emoji = event.emoji
        self.color = event.color
        
        self.trackedDaysCount = trackedDaysCount
        self.tracked = tracked
    }
}

protocol TrackEventProtocol {
    func trackEvent(eventId: UUID, indexPath: IndexPath)
    func untrackEvent(eventId: UUID, indexPath: IndexPath)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    private var emogiLabel: UILabel = {
        var emogiLabel = UILabel()
        emogiLabel.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        emogiLabel.translatesAutoresizingMaskIntoConstraints = false
        emogiLabel.layer.masksToBounds = true
        emogiLabel.layer.cornerRadius = emogiLabel.frame.height / 2
        emogiLabel.textAlignment = .center
        emogiLabel.font = UIFont.systemFont(ofSize: 16)
        
        return emogiLabel
    }()
    
    private var nameLabel: UILabel = {
        var nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        nameLabel.textColor = .white
        
        return nameLabel
    }()
    
    private var eventNameView: UIView = {
        let eventNameView = UIView()
        eventNameView.translatesAutoresizingMaskIntoConstraints = false
        eventNameView.layer.cornerRadius = 16
        
        return eventNameView
    }()
    
    private var trackedDaysLabel: UILabel = {
        let trackedDaysLabel = UILabel()
        trackedDaysLabel.textColor = .black
        trackedDaysLabel.translatesAutoresizingMaskIntoConstraints = false
        trackedDaysLabel.textAlignment = .center
        trackedDaysLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        return trackedDaysLabel
    }()
    
    private var trackButton: UIButton = {
        var trackButton = UIButton()
        trackButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        trackButton.layer.masksToBounds = true
        trackButton.translatesAutoresizingMaskIntoConstraints = false
        trackButton.layer.cornerRadius = trackButton.frame.height / 2
        trackButton.tintColor = .white
        
        return trackButton
    }()
    
    private var trackView: UIView = {
        var trackView = UIView()
        trackView.translatesAutoresizingMaskIntoConstraints = false
        
        return trackView
    }()
    
    var cellEvent: TrackerCell? {
        didSet {
            guard let cellEvent = cellEvent else {
                print("event didSet: event is empty")
                return
            }
            emogiLabel.text = cellEvent.emoji
            nameLabel.text = cellEvent.name
            nameLabel.lineBreakMode = .byWordWrapping
            nameLabel.numberOfLines = 0
            trackedDaysLabel.text = formatTrackedDays(days: cellEvent.trackedDaysCount)
            eventNameView.backgroundColor = cellEvent.color
            emogiLabel.backgroundColor = .white.withAlphaComponent(0.3)
            trackButton.backgroundColor = cellEvent.color
            
            if cellEvent.tracked {
                trackButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
                trackButton.backgroundColor = trackButton.backgroundColor?.withAlphaComponent(0.3)
            } else {
                trackButton.setImage(UIImage(systemName: "plus"), for: .normal)
                trackButton.backgroundColor = trackButton.backgroundColor?.withAlphaComponent(1)
                trackButton.tintColor = .white
            }
        }
    }
    
    var indexPath: IndexPath?
    
    var delegate: TrackEventProtocol?
    
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
        
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConstraint() {
        NSLayoutConstraint.activate([
            eventNameView.topAnchor.constraint(equalTo: contentView.topAnchor),
            eventNameView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            eventNameView.widthAnchor.constraint(equalToConstant: frame.width),
            eventNameView.heightAnchor.constraint(equalToConstant: 90),
            nameLabel.widthAnchor.constraint(equalTo: eventNameView.widthAnchor),
            emogiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            emogiLabel.topAnchor.constraint(equalTo: eventNameView.topAnchor, constant: 10),
            emogiLabel.widthAnchor.constraint(equalToConstant: 30),
            emogiLabel.heightAnchor.constraint(equalToConstant: 30),
            nameLabel.bottomAnchor.constraint(equalTo: eventNameView.bottomAnchor, constant: -10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
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
    
    @objc private func trackEvent() {
        guard var cellEvent = cellEvent else {
            print("Event track failed: event is empty")
            return
        }
        
        guard let indexPath = indexPath else {
            print("TrackerCollectionViewCell: indexPath is empty")
            return
        }
        
        guard let delegate = delegate else {
            print("TrackerCollectionViewCell: delegate is empty")
            return
        }
        
        if cellEvent.tracked {
            delegate.untrackEvent(eventId: cellEvent.id, indexPath: indexPath)
        } else {
            delegate.trackEvent(eventId: cellEvent.id, indexPath: indexPath)
        }
        self.cellEvent = cellEvent
        trackedDaysLabel.text = formatTrackedDays(days: cellEvent.trackedDaysCount)
    }
    
    func disableTrackButton() { trackButton.isEnabled = false }
    
    func enableTrackButton() { trackButton.isEnabled = true }
    
    private func formatTrackedDays(days: Int) -> String {
        if days >= 11 && days <= 14 {
            return "\(days) дней"
        }
        
        switch Double(days).remainder(dividingBy: 10) {
        case 0, 5, 6, 7, 8, 9:
            return "\(days) дней"
        case 1:
            return "\(days) день"
        case 2, 3, 4:
            return "\(days) дня"
        default:
            return "\(days) дней"
        }
    }
}
