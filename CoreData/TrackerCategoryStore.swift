import UIKit
import CoreData

struct TrackerCategoryUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol TrackerCategoryDelegate: AnyObject {
    func didUpdate(_ update: TrackerCategoryUpdate)
}
protocol TrackerCategoryStoreProtocol {
    var categoriesIsEmpty: Bool { get }
    var numberOfCategories: Int { get }
    func categoryTitle(at indexPath: IndexPath) -> String?
    func addCategory(with title: String) throws
    func deleteCategory(at indexPath: IndexPath) throws
    func updateCategory(oldTitle: String, newTitle: String) throws
}

final class TrackerCategoryStore: NSObject {
    
    // MARK: - Properties
    weak var delegate: TrackerCategoryDelegate?
    private let context: NSManagedObjectContext
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
    
    // MARK: - Core Data
    private lazy var fetchedResultsController: NSFetchedResultsController <TrackerCategoryCoreData> = {
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false)]
        
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
    
    // MARK: - Init
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

extension TrackerCategoryStore: TrackerCategoryStoreProtocol {

    var categoriesIsEmpty: Bool {
        fetchedResultsController.fetchedObjects?.isEmpty ?? true
    }
    
    var numberOfCategories: Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func categoryTitle(at indexPath: IndexPath) -> String? {
        fetchedResultsController.object(at: indexPath).title
    }
    
    func addCategory(with title: String) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.title = title
        
        try context.save()
    }
    
    func deleteCategory(at indexPath: IndexPath) throws {
        let object = fetchedResultsController.object(at: indexPath)
        context.delete(object)
        try context.save()
        
    }
    
    func updateCategory(oldTitle: String, newTitle: String) throws {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", "title", oldTitle)
        let result = try context.fetch(request)
        result.first?.title = newTitle
        try context.save()
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.didUpdate(TrackerCategoryUpdate(
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
