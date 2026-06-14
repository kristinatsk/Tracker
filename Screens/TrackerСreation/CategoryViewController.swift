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
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private lazy var categoryButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("add_category", comment: ""), for: .normal)
        button.setTitleColor(Colors.collectionViewBackgroundColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.backgroundColor = Colors.navigationTintColor
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
        label.text = NSLocalizedString("group_habits", comment: "")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 0
        label.textColor = Colors.navigationTintColor
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.collectionViewBackgroundColor
        title = NSLocalizedString("category", comment: "")
        
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        viewModel.onCategoriesUpdated = { [weak self] _ in
            
            self?.updateCategoryPlaceHolderVisibility()
            self?.categoryTableView.reloadData()
        }
        viewModel.onCategorySelected = { [weak self] selectedTitle in
            self?.delegate?.chooseCategory(title: selectedTitle)
            self?.dismiss(animated: true)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CategoryTableViewCell
        
        let categoryTitle = viewModel.categoryTitle(at: indexPath)
        cell.configure(title: categoryTitle ?? "", isSelectedCategory: categoryTitle == viewModel.selectedCategory)

        return cell
    }
    
}

extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectCategory(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let categoryTitle = viewModel.categoryTitle(at: indexPath) else { return nil }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: NSLocalizedString("edit", comment: "")) { [weak self] _ in
                let editCategory = CategoryCreationViewController()
                editCategory.categoryToEdit = categoryTitle
                let categoryNavController = UINavigationController(rootViewController: editCategory)
                self?.present(categoryNavController, animated: true, completion: nil)
            }
            
            let deleteAction = UIAction(title: NSLocalizedString("delete", comment: ""), attributes: .destructive) { [weak self] _ in
                let alertController = UIAlertController(
                    title: NSLocalizedString("dont_need_category", comment: ""),
                    message: nil,
                    preferredStyle: .actionSheet
                    )
                let delete = UIAlertAction(title: NSLocalizedString("delete", comment: ""), style: .destructive) { _ in
                    self?.viewModel.deleteCategory(at: indexPath)
                }
                
                let cancel = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel)
                
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


