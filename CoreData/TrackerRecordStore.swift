import UIKit
import CoreData

struct TrackerRecordUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol TrackerRecordDelegate: AnyObject {
    func didUpdate(_ update: TrackerRecordUpdate)
}

protocol TrackerRecordStoreProtocol {
    func countCompletedDays(_ id: UUID) -> Int
    func isCompletedToday(_ date: Date, id: UUID) -> Bool
    func addRecord(_ id: UUID, date: Date) throws
    func deleteRecord(id: UUID, date: Date) throws
}

final class TrackerRecordStore: NSObject {
    
    //MARK: Properties
    weak var delegate: TrackerRecordDelegate?
    private let context: NSManagedObjectContext
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
    
    //MARK: Core Data
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        
        try? fetchedResultsController.performFetch()
        
        return fetchedResultsController
        
    }()
    
    //MARK: Init
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to get AppDelegate")
        }
        let context = appDelegate.persistentContainer.viewContext
        
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

extension TrackerRecordStore: TrackerRecordStoreProtocol {
    func countCompletedDays(_ id: UUID) -> Int {
        let idRequest = TrackerRecordCoreData.fetchRequest()
        idRequest.predicate = NSPredicate(format: "%K == %@", "id", id as NSUUID)
        return (try? context.count(for: idRequest)) ?? 0
        
    }
    
    func isCompletedToday(_ date: Date, id: UUID) -> Bool {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@ AND %K == %@", "id", id as NSUUID, "date", date as NSDate)
        return ((try? context.count(for: request)) ?? 0) > 0 
    }
    
    func addRecord(_ id: UUID, date: Date) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.id = id
        trackerRecordCoreData.date = date
        
        try context.save()
    }
    
    func deleteRecord(id: UUID, date: Date) throws {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@ AND %K == %@", "id", id as NSUUID, "date", date as NSDate)
        let records = try context.fetch(request)
        if let object = records.first {
            context.delete(object)
        }
        try context.save()
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.didUpdate(TrackerRecordUpdate(
            insertedIndexes: insertedIndexes ?? [],
            deletedIndexes: deletedIndexes ?? []
            )
        )
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }
}
