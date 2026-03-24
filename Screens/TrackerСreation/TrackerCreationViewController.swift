import UIKit

protocol TrackerCreationDelegate: AnyObject {
    func createTracker(trackerName: String, schedule: [Int])
}

final class TrackerCreationViewController: UIViewController {
    weak var delegate: TrackerCreationDelegate?
    private var selectedSchedule: [Int] = []
    private let isHabit: Bool
    
    init(isHabit: Bool) {
        self.isHabit = isHabit
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    private lazy var trackerNameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 16
        textField.placeholder = "Введите название трекера"
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var creationTableView: UITableView = {
        let tableView = UITableView()
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(resource: .tableViewBackground)
        tableView.layer.cornerRadius = 16
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 75
        return tableView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.backgroundColor = .lightGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var warningLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor(resource: .warningLabel)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = self.isHabit ? "Новая привычка" : "Новое нерегулярное событие"
        
        creationTableView.dataSource = self
        creationTableView.delegate = self
        trackerNameTextField.delegate = self
        
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        trackerNameTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        
        view.addSubview(creationTableView)
        view.addSubview(trackerNameTextField)
        view.addSubview(buttonsStackView)
        view.addSubview(warningLabel)
        
        NSLayoutConstraint.activate([
            trackerNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            trackerNameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackerNameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            warningLabel.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 8),
            warningLabel.centerXAnchor.constraint(equalTo: trackerNameTextField.centerXAnchor),
            
            creationTableView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 62),
            creationTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            creationTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            self.isHabit ? creationTableView.heightAnchor.constraint(equalToConstant: 150) : creationTableView.heightAnchor.constraint(equalToConstant: 75),
            
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60)
            
        ])
    }
    
    @objc private func cancelButtonTapped() {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let trackerName = trackerNameTextField.text else { return }
        delegate?.createTracker(trackerName: trackerName, schedule: selectedSchedule)
    }
    
    @objc private func textChanged() {
        if let text = trackerNameTextField.text, !text.isEmpty {
            createButton.isEnabled = true
            createButton.backgroundColor = .black
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .lightGray
        }
    }
}

extension TrackerCreationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isHabit ? 2 : 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath.row == 1 {
            var scheduleCell = UITableViewCell(style: .subtitle, reuseIdentifier: "Расписание")
            scheduleCell.textLabel?.text = "Расписание"
            let allDays = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
            var resultString = ""
            if selectedSchedule.count == 7 {
                resultString = "Каждый день"
            } else {
                resultString = selectedSchedule.map { allDays[$0] }.joined(separator: ", ")

            }
            scheduleCell.detailTextLabel?.text = resultString
            scheduleCell.accessoryType = .disclosureIndicator
            scheduleCell.layer.masksToBounds = true
            scheduleCell.layer.cornerRadius = 16
            scheduleCell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            scheduleCell.backgroundColor = .secondarySystemBackground
            
            return scheduleCell
        } else if indexPath.row == 0 {
            var categoryCell = UITableViewCell(style: .subtitle, reuseIdentifier: "Категория")
            categoryCell.textLabel?.text = "Категория"
            categoryCell.detailTextLabel?.text = "Важное"
            categoryCell.accessoryType = .disclosureIndicator
            categoryCell.layer.masksToBounds = true
            categoryCell.layer.cornerRadius = 16
            categoryCell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            categoryCell.backgroundColor = .secondarySystemBackground
            
            return categoryCell
        }
        
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension TrackerCreationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let scheduleVC = ScheduleViewController()
        let scheduleNavController = UINavigationController(rootViewController: scheduleVC)
        scheduleVC.delegate = self
        indexPath.row == 0 ? print("Переход к Категориям") : present(scheduleNavController, animated: true, completion: nil)
    }
}

extension TrackerCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        let isWithinLimit = updatedText.count <= 38
        warningLabel.isHidden = isWithinLimit
        
        return isWithinLimit
    }
}

extension TrackerCreationViewController: ScheduleViewControllerDelegate {
    func completeSchedule(data: [Int]) {
        self.selectedSchedule = data
        dismiss(animated: true)
        creationTableView.reloadData()
    }
}
