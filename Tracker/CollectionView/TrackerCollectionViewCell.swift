//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Алия Давлетова on 31.07.2023.
//

import Foundation
import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    var eventNameView = UIView()
    var trackView = UIView()
    var emogiLabel = UILabel()
    var nameLabel = UILabel()
    var trackedDaysLabel = UILabel()
    var trackButton = UIButton()
    
    var event: EventProtocol? {
        didSet {
            guard let event = event else {
                print("didSet: event is empty")
                return
            }
            emogiLabel.text = event.getEmoji()
            nameLabel.text = event.getName()
//            trackedDaysLabel.text = formatTrackedDays(days: event.getTrackedDays())
            trackedDaysLabel.text = "5 days"
            eventNameView.backgroundColor = event.getColor()
            emogiLabel.backgroundColor = .white.withAlphaComponent(0.3)
            trackButton.backgroundColor = event.getColor()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        eventNameView.translatesAutoresizingMaskIntoConstraints = false
        eventNameView.layer.cornerRadius = 16
        
        emogiLabel.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        emogiLabel.translatesAutoresizingMaskIntoConstraints = false
        emogiLabel.layer.masksToBounds = true
        emogiLabel.layer.cornerRadius = emogiLabel.frame.height / 2
        emogiLabel.textAlignment = .center
        emogiLabel.font = UIFont.systemFont(ofSize: 16)
        eventNameView.addSubview(emogiLabel)
        
        nameLabel.frame = CGRect(x: 12, y: 44, width: frame.width - 24, height: 34)
        nameLabel.font = UIFont(name: "SF Pro", size: 12)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        eventNameView.addSubview(nameLabel)
        contentView.addSubview(eventNameView)
        
        trackView.translatesAutoresizingMaskIntoConstraints = false
        
        trackButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        trackButton.layer.masksToBounds = true
        trackButton.translatesAutoresizingMaskIntoConstraints = false
        trackButton.layer.cornerRadius = trackButton.frame.height / 2
        trackButton.setImage(UIImage(systemName: "plus"), for: .normal)
        trackButton.tintColor = .white
        trackButton.addTarget(self, action: #selector(track), for: .touchUpInside)

        trackedDaysLabel.textColor = .black
        trackedDaysLabel.translatesAutoresizingMaskIntoConstraints = false
        trackedDaysLabel.textAlignment = .center

        trackView.addSubview(trackedDaysLabel)
        trackView.addSubview(trackButton)
        
        contentView.addSubview(trackView)
        
        NSLayoutConstraint.activate([
            eventNameView.topAnchor.constraint(equalTo: contentView.topAnchor),
            eventNameView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            eventNameView.widthAnchor.constraint(equalToConstant: frame.width),
            eventNameView.heightAnchor.constraint(equalToConstant: 90),
            trackView.topAnchor.constraint(equalTo: eventNameView.bottomAnchor),
            trackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackView.widthAnchor.constraint(equalToConstant: frame.width),
            trackView.heightAnchor.constraint(equalToConstant: 58),
            emogiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            emogiLabel.topAnchor.constraint(equalTo: eventNameView.topAnchor, constant: 10),
            emogiLabel.widthAnchor.constraint(equalToConstant: 30),
            emogiLabel.heightAnchor.constraint(equalToConstant: 30),
            nameLabel.bottomAnchor.constraint(equalTo: eventNameView.bottomAnchor, constant: -10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            trackedDaysLabel.centerYAnchor.constraint(equalTo: trackView.centerYAnchor),
            trackedDaysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            trackButton.centerYAnchor.constraint(equalTo: trackView.centerYAnchor),
            trackButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            trackButton.widthAnchor.constraint(equalToConstant: 40),
            trackButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func track() {
        print("track")
        
        guard let event = event else {
            print("Event track failed: event is empty")
            return
        }
        
        NotificationCenter.default.post(
                name: TrackerRecordService.AddEventNotification,
                object: self,
                userInfo: ["record": TrackerRecord(eventID: event.getID(), date: Date())]
            )
        
        trackButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        trackButton.backgroundColor = trackButton.backgroundColor?.withAlphaComponent(0.3)
    }
    
    @objc private func deleteTrack() {
        print("delete track")
        
        guard let event = event else {
            print("Event track failed: event is empty")
            return
        }
        
        NotificationCenter.default.post(
                name: TrackerRecordService.DeleteEventNotification,
                object: self,
                userInfo: ["record": TrackerRecord(eventID: event.getID(), date: Date())]
            )
        
    }
    
    private func formatTrackedDays(days: Int) -> String {
        if days >= 11 || days <= 14 {
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


//class LetterCollectionViewCell: UICollectionViewCell {
//    let label = UILabel()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        contentView.addSubview(label)
//        label.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
//        ])
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
