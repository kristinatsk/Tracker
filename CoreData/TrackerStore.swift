import UIKit
import CoreData

struct TrackerStoreUpdate {
    let insertedSections: IndexSet
    let deletedSections: IndexSet
    let insertedCells: [IndexPath]
    let deletedCells: [IndexPath]
}

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}

protocol TrackerStoreProtocol {
    var numberOfSections: Int { get }
    var trackersIsEmpty: Bool { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at indexPath: IndexPath) -> TrackerCoreData
    func addRecord(_ tracker: Tracker, category: String) throws
    func deleteRecord(at indexPath: IndexPath) throws
    func headerTitle(for section: Int) -> String?
    func filterTracker(by day: WeekDay)
    
}

final class TrackerStore: NSObject {
    
    weak var delegate: TrackerStoreDelegate?
    
    private let context: NSManagedObjectContext
    private var insertedSections: IndexSet?
    private var deletedSections: IndexSet?
    private var insertedCells: [IndexPath]?
    private var deletedCells: [IndexPath]?
    
    private lazy var fetchedResultsController: NSFetchedResultsController <TrackerCoreData> = {
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        
        try? fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }()
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

extension TrackerStore: TrackerStoreProtocol {
    var trackersIsEmpty: Bool {
        fetchedResultsController.fetchedObjects?.isEmpty ?? true
    }
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> TrackerCoreData {
        fetchedResultsController.object(at: indexPath)
    }
    
    func addRecord(_ tracker: Tracker, category: String) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = tracker.color.toHexString()
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule.map { String($0.rawValue) }.joined(separator: ",")
        
        let categoryRequest = TrackerCategoryCoreData.fetchRequest()
        categoryRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), category)
        
        let categoryCoreData = (try? context.fetch(categoryRequest))?.first ?? TrackerCategoryCoreData(context: context)
        categoryCoreData.title = category
        trackerCoreData.category = categoryCoreData
        
        try context.save()
    }
    
    func deleteRecord(at indexPath: IndexPath) throws {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        context.delete(trackerCoreData)
        try context.save()
    }
    
    func headerTitle(for section: Int) -> String? {
        fetchedResultsController.sections?[section].name
    }
    
    func filterTracker(by day: WeekDay) {
        let predicate = NSPredicate(format: "%K CONTAINS %@", #keyPath(TrackerCoreData.schedule), String(day.rawValue))
        
        fetchedResultsController.fetchRequest.predicate = predicate
        
        try? fetchedResultsController.performFetch()
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate{
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedSections = IndexSet()
        deletedSections = IndexSet()
        insertedCells = [IndexPath]()
        deletedCells = [IndexPath]()
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.didUpdate(TrackerStoreUpdate(
            insertedSections: insertedSections!,
            deletedSections: deletedSections!,
            insertedCells: insertedCells!,
            deletedCells: deletedCells!
            )
        )
        
        insertedSections = nil
        deletedSections = nil
        insertedCells = nil
        deletedCells = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedCells?.append(indexPath)
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedCells?.append(indexPath)
            }
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange sectionInfo: any NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .delete:
            deletedSections?.insert(sectionIndex)
        case .insert:
            insertedSections?.insert(sectionIndex)
        default:
            break
        }
    }
}

