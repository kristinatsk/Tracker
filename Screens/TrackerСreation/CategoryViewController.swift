import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func chooseCategory(title: String)
}

final class CategoryViewController: UIViewController {
    private var viewModel = CategoryViewModel(for: TrackerCategoryStore())
    weak var delegate: CategoryViewControllerDelegate?
    var selectedCategory: String? {
        get {
            viewModel.selectedCategory
        }
        set {
            viewModel.selectedCategory = newValue
        }
    }
    
    private lazy var categoryTableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(resource: .tableViewBackground)
        tableView.layer.cornerRadius = 16
        tableView.rowHeight = 75
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private lazy var categoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var categoryPlaceholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .starPlaceholder)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var categoryPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно объединить по смыслу"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 0
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Категория"
        
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        viewModel.onCategoriesUpdated = { [weak self] _ in
            
            self?.updateCategoryPlaceHolderVisibility()
            self?.categoryTableView.reloadData()
        }
        
        view.addSubview(categoryTableView)
        view.addSubview(categoryButton)
        view.addSubview(categoryPlaceholderImageView)
        view.addSubview(categoryPlaceholderLabel)
        
        categoryButton.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        
        
        NSLayoutConstraint.activate([
            
            categoryTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            categoryTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoryTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            categoryTableView.bottomAnchor.constraint(equalTo: categoryButton.topAnchor, constant: -24),
            
            categoryPlaceholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            categoryPlaceholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            categoryPlaceholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            categoryPlaceholderLabel.topAnchor.constraint(equalTo: categoryPlaceholderImageView.bottomAnchor),
            categoryPlaceholderLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 288),
            
            categoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            categoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            categoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            categoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        updateCategoryPlaceHolderVisibility()
    }
    
    private func updateCategoryPlaceHolderVisibility() {
        let isEmpty = viewModel.categoriesIsEmpty
        categoryPlaceholderImageView.isHidden = !isEmpty
        categoryPlaceholderLabel.isHidden = !isEmpty
        categoryTableView.isHidden = isEmpty
    }
    
    
    @objc func addCategoryButtonTapped() {
        let newCategoryVC = CategoryCreationViewController()
        let categoryNavController = UINavigationController(rootViewController: newCategoryVC)
        present(categoryNavController, animated: true, completion: nil)
    }
    
}

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfCategories
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let categoryTitle = viewModel.categoryTitle(at: indexPath)
        cell.textLabel?.text = categoryTitle
        cell.backgroundColor = .secondarySystemBackground
        if cell.textLabel?.text == viewModel.selectedCategory {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
            
        return cell
    }
    
}

extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        guard let categoryTitle = viewModel.categoryTitle(at: indexPath) else { return }
        delegate?.chooseCategory(title: categoryTitle)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let categoryTitle = viewModel.categoryTitle(at: indexPath) else { return nil }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: "Редактировать") { [weak self] _ in
                let editCategory = CategoryCreationViewController()
                editCategory.categoryToEdit = categoryTitle
                let categoryNavController = UINavigationController(rootViewController: editCategory)
                self?.present(categoryNavController, animated: true, completion: nil)
            }
            
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                let alertController = UIAlertController(
                    title: "Эта категория точно не нужна?",
                    message: nil,
                    preferredStyle: .actionSheet
                    )
                let delete = UIAlertAction(title: "Удалить", style: .destructive) { _ in
                    self?.viewModel.deleteCategory(at: indexPath)
                }
                
                let cancel = UIAlertAction(title: "Отменить", style: .cancel)
                
                alertController.addAction(delete)
                alertController.addAction(cancel)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self?.present(alertController, animated: true)
                }
                

                
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
}


