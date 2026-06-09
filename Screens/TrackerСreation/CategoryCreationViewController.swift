import UIKit


final class CategoryCreationViewController: UIViewController {
    
    private let trackerCategoryCoreStore = TrackerCategoryStore()
    
    var categoryToEdit: String?
    
    private lazy var categoryTitleTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor(resource: .tableViewBackground)
        textField.layer.cornerRadius = 16
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var createCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("done", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.backgroundColor = .lightGray
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if let editTitle = categoryToEdit {
            title = NSLocalizedString("edit_category", comment: "")
            categoryTitleTextField.text = categoryToEdit
            textChanged()
        } else {
            title = NSLocalizedString("new_category", comment: "")
        }
        
        categoryTitleTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        createCategoryButton.addTarget(self, action: #selector(createCategoryButtonTapped), for: .touchUpInside)
        
        view.addSubview(categoryTitleTextField)
        view.addSubview(createCategoryButton)
        
        NSLayoutConstraint.activate([
            categoryTitleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            categoryTitleTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoryTitleTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            categoryTitleTextField.heightAnchor.constraint(equalToConstant: 75),
            
            createCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createCategoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            createCategoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            createCategoryButton.heightAnchor.constraint(equalToConstant: 60)
            
            
        ])
    }
    
    @objc private func textChanged() {
        if let text = categoryTitleTextField.text , !text.isEmpty {
            createCategoryButton.isEnabled = true
            createCategoryButton.backgroundColor = .black
        } else {
            createCategoryButton.isEnabled = false
            createCategoryButton.backgroundColor = .lightGray
        }
    }
    
    @objc private func createCategoryButtonTapped() {
        guard let newCategoryTitle = categoryTitleTextField.text else { return }
        if let oldCategoryTitle = categoryToEdit {
            try? trackerCategoryCoreStore.updateCategory(oldTitle: oldCategoryTitle, newTitle: newCategoryTitle)
        } else {
            try? trackerCategoryCoreStore.addCategory(with: newCategoryTitle)
        }
        dismiss(animated: true)
    }
}


