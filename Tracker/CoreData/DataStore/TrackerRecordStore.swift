////
////  TrackerRecordStore.swift
////  Tracker
////
////  Created by Алия Давлетова on 25.08.2023.
////
//
//import Foundation
//import CoreData
//
//final class TrackerRecordStore {
//
//}
//
//import UIKit
//import CoreData
//
//enum EmojiMixStoreError: Error {
//    case decodingErrorInvalidEmojies
//    case decodingErrorInvalidColorHex
//}
//
//struct EmojiMixStoreUpdate {
//    struct Move: Hashable {
//        let oldIndex: Int
//        let newIndex: Int
//    }
//    let insertedIndexes: IndexSet
//    let deletedIndexes: IndexSet
//    let updatedIndexes: IndexSet
//    let movedIndexes: Set<Move>
//}
//
//protocol EmojiMixStoreDelegate: AnyObject {
//    func store(
//        _ store: EmojiMixStore,
//        didUpdate update: EmojiMixStoreUpdate
//    )
//}
//
//final class EmojiMixStore: NSObject {
//    private let uiColorMarshalling = UIColorMarshalling()
//    private let context: NSManagedObjectContext
//    private var fetchedResultsController: NSFetchedResultsController<EmojiMixCoreData>!
//
//    weak var delegate: EmojiMixStoreDelegate?
//    private var insertedIndexes: IndexSet?
//    private var deletedIndexes: IndexSet?
//    private var updatedIndexes: IndexSet?
//    private var movedIndexes: Set<EmojiMixStoreUpdate.Move>?
//
//    convenience override init() {
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//        try! self.init(context: context)
//    }
//
//    init(context: NSManagedObjectContext) throws {
//        self.context = context
//        super.init()
//
//        let fetchRequest = EmojiMixCoreData.fetchRequest()
//        fetchRequest.sortDescriptors = [
//            NSSortDescriptor(keyPath: \EmojiMixCoreData.emojies, ascending: true)
//        ]
//        let controller = NSFetchedResultsController(
//            fetchRequest: fetchRequest,
//            managedObjectContext: context,
//            sectionNameKeyPath: nil,
//            cacheName: nil
//        )
//        controller.delegate = self
//        self.fetchedResultsController = controller
//        try controller.performFetch()
//    }
//
//    var emojiMixes: [EmojiMix] {
//        guard
//            let objects = self.fetchedResultsController.fetchedObjects,
//            let emojiMixes = try? objects.map({ try self.emojiMix(from: $0) })
//        else { return [] }
//        return emojiMixes
//    }
//
//    func addNewEmojiMix(_ emojiMix: EmojiMix) throws {
//        let emojiMixCoreData = EmojiMixCoreData(context: context)
//        updateExistingEmojiMix(emojiMixCoreData, with: emojiMix)
//        try context.save()
//    }
//
//    func updateExistingEmojiMix(_ emojiMixCorData: EmojiMixCoreData, with mix: EmojiMix) {
//        emojiMixCorData.emojies = mix.emojies
//        emojiMixCorData.colorHex = uiColorMarshalling.hexString(from: mix.backgroundColor)
//    }
//
//    func emojiMix(from emojiMixCorData: EmojiMixCoreData) throws -> EmojiMix {
//        guard let emojies = emojiMixCorData.emojies else {
//            throw EmojiMixStoreError.decodingErrorInvalidEmojies
//        }
//        guard let colorHex = emojiMixCorData.colorHex else {
//            throw EmojiMixStoreError.decodingErrorInvalidEmojies
//        }
//        return EmojiMix(
//            emojies: emojies,
//            backgroundColor: uiColorMarshalling.color(from: colorHex)
//        )
//    }
//}
//
//extension EmojiMixStore: NSFetchedResultsControllerDelegate {
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        insertedIndexes = IndexSet()
//        deletedIndexes = IndexSet()
//        updatedIndexes = IndexSet()
//        movedIndexes = Set<EmojiMixStoreUpdate.Move>()
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        delegate?.store(
//            self,
//            didUpdate: EmojiMixStoreUpdate(
//                insertedIndexes: insertedIndexes!,
//                deletedIndexes: deletedIndexes!,
//                updatedIndexes: updatedIndexes!,
//                movedIndexes: movedIndexes!
//            )
//        )
//        insertedIndexes = nil
//        deletedIndexes = nil
//        updatedIndexes = nil
//        movedIndexes = nil
//    }
//
//    func controller(
//        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
//        didChange anObject: Any,
//        at indexPath: IndexPath?,
//        for type: NSFetchedResultsChangeType,
//        newIndexPath: IndexPath?
//    ) {
//        switch type {
//        case .insert:
//            guard let indexPath = newIndexPath else { fatalError() }
//            insertedIndexes?.insert(indexPath.item)
//        case .delete:
//            guard let indexPath = indexPath else { fatalError() }
//            deletedIndexes?.insert(indexPath.item)
//        case .update:
//            guard let indexPath = indexPath else { fatalError() }
//            updatedIndexes?.insert(indexPath.item)
//        case .move:
//            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { fatalError() }
//            movedIndexes?.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
//        @unknown default:
//            fatalError()
//        }
//    }
//}
//
//
//
//import Foundation
//import CoreData
//
//struct NotepadStoreUpdate {
//    let insertedIndexes: IndexSet
//    let deletedIndexes: IndexSet
//}
//
//protocol DataProviderDelegate: AnyObject {
//    func didUpdate(_ update: NotepadStoreUpdate)
//}
//
//protocol DataProviderProtocol {
//    var numberOfSections: Int { get }
//    func numberOfRowsInSection(_ section: Int) -> Int
//    func object(at: IndexPath) -> NotepadRecord?
//    func addRecord(_ record: NotepadRecord) throws
//    func deleteRecord(at indexPath: IndexPath) throws
//}
//
//// MARK: - DataProvider
//final class DataProvider: NSObject {
//
//    enum DataProviderError: Error {
//        case failedToInitializeContext
//    }
//
//    weak var delegate: DataProviderDelegate?
//
//    private let context: NSManagedObjectContext
//    private let dataStore: NotepadDataStore
//    private var insertedIndexes: IndexSet?
//    private var deletedIndexes: IndexSet?
//
//    private lazy var fetchedResultsController: NSFetchedResultsController<ManagedRecord> = {
//
//        let fetchRequest = NSFetchRequest<ManagedRecord>(entityName: "ManagedRecord")
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
//
//        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
//                                                                  managedObjectContext: context,
//                                                                  sectionNameKeyPath: nil,
//                                                                  cacheName: nil)
//        fetchedResultsController.delegate = self
//        try? fetchedResultsController.performFetch()
//        return fetchedResultsController
//    }()
//
//    init(_ dataStore: NotepadDataStore, delegate: DataProviderDelegate) throws {
//        guard let context = dataStore.managedObjectContext else {
//            throw DataProviderError.failedToInitializeContext
//        }
//        self.delegate = delegate
//        self.context = context
//        self.dataStore = dataStore
//    }
//}
//
//// MARK: - DataProviderProtocol
//extension DataProvider: DataProviderProtocol {
//    var numberOfSections: Int {
//        fetchedResultsController.sections?.count ?? 0
//    }
//
//    func numberOfRowsInSection(_ section: Int) -> Int {
//        fetchedResultsController.sections?[section].numberOfObjects ?? 0
//    }
//
//    func object(at indexPath: IndexPath) -> NotepadRecord? {
//        fetchedResultsController.object(at: indexPath)
//    }
//
//    func addRecord(_ record: NotepadRecord) throws {
//        try? dataStore.add(record)
//    }
//
//    func deleteRecord(at indexPath: IndexPath) throws {
//        let record = fetchedResultsController.object(at: indexPath)
//        try? dataStore.delete(record)
//    }
//}
//
//// MARK: - NSFetchedResultsControllerDelegate
//extension DataProvider: NSFetchedResultsControllerDelegate {
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        insertedIndexes = IndexSet()
//        deletedIndexes = IndexSet()
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        delegate?.didUpdate(NotepadStoreUpdate(
//                insertedIndexes: insertedIndexes!,
//                deletedIndexes: deletedIndexes!
//            )
//        )
//        insertedIndexes = nil
//        deletedIndexes = nil
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//
//        switch type {
//        case .delete:
//            if let indexPath = indexPath {
//                deletedIndexes?.insert(indexPath.item)
//            }
//        case .insert:
//            if let indexPath = newIndexPath {
//                insertedIndexes?.insert(indexPath.item)
//            }
//        default:
//            break
//        }
//    }
//}
