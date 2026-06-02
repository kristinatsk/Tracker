import Foundation

typealias Binding<T> = (T) -> Void



final class CategoryViewModel {
    
    var selectedCategory: String?
    var onCategoriesUpdated: Binding<Void>?
    var categoriesIsEmpty: Bool {
        model.categoriesIsEmpty
    }
    var numberOfCategories: Int {
        model.numberOfCategories
    }
    
    private let model: TrackerCategoryStore
    
    init(for model: TrackerCategoryStore) {
        self.model = model
        model.delegate = self
    }
    
    func categoryTitle(at indexPath: IndexPath) -> String? {
        model.categoryTitle(at: indexPath)
    }
}

extension CategoryViewModel: TrackerCategoryDelegate {
    func didUpdate(_ update: TrackerCategoryUpdate) {
        onCategoriesUpdated?(())
    }
}
