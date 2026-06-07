import UIKit

protocol TrackerCreationDelegate: AnyObject {
    func createTracker(trackerName: String, schedule: [Int], emoji: String?, color: UIColor?, category: String?)
    func updateTracker(id: UUID, trackerName: String, schedule: [Int], emoji: String?, color: UIColor?, category: String?)
}

final class TrackerCreationViewController: UIViewController {
    weak var delegate: TrackerCreationDelegate?
    private var selectedSchedule: [Int] = []
    private let isHabit: Bool
    private var tableViewConstraint: NSLayoutConstraint?
    private let emojis: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱",
                                    "😇", "😡", "🥶", "🤔", "🙌", "🍔",
                                    "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    private let colors: [UIColor] = [UIColor(resource:.colorSelection1), UIColor(resource:.colorSelection2),
                                     UIColor(resource:.colorSelection3), UIColor(resource:.colorSelection4),
                                     UIColor(resource:.colorSelection5), UIColor(resource:.colorSelection6),
                                     UIColor(resource:.colorSelection7), UIColor(resource:.colorSelection8),
                                     UIColor(resource:.colorSelection9), UIColor(resource:.colorSelection10),
                                     UIColor(resource:.colorSelection11), UIColor(resource:.colorSelection12),
                                     UIColor(resource:.colorSelection13), UIColor(resource:.colorSelection14),
                                     UIColor(resource:.colorSelection15), UIColor(resource:.colorSelection16),
                                     UIColor(resource:.colorSelection17), UIColor(resource:.colorSelection18)
                                    ]
    
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    var selectedCategory: String?
    var trackerToEdit: Tracker?
    
    
    init(isHabit: Bool) {
        self.isHabit = isHabit
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    private lazy var trackerNameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor(resource: .tableViewBackground)
        textField.layer.cornerRadius = 16
        textField.placeholder = "Введите название трекера"
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
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
    
    private lazy var scrollCreationView: UIScrollView = {
        let scrollView = UIScrollView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    

    
    private lazy var emojiAndColorsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 34
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 24, left: 16, bottom: 24, right: 16)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: "emojiCell")
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        return collectionView
    }()
    
    private lazy var colorsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: "colorsCell")
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        return collectionView
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
        
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        
        colorsCollectionView.delegate = self
        colorsCollectionView.dataSource = self
        
        view.addSubview(scrollCreationView)
        scrollCreationView.addSubview(emojiAndColorsStackView)
        emojiAndColorsStackView.addArrangedSubview(trackerNameTextField)
        emojiAndColorsStackView.addArrangedSubview(warningLabel)
        emojiAndColorsStackView.addArrangedSubview(creationTableView)
        emojiAndColorsStackView.addArrangedSubview(emojiCollectionView)
        emojiAndColorsStackView.addArrangedSubview(colorsCollectionView)
        
        view.addSubview(buttonsStackView)
       
        
        setupUIForEditing()
        
        NSLayoutConstraint.activate([

            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),

            self.isHabit ? creationTableView.heightAnchor.constraint(equalToConstant: 150) : creationTableView.heightAnchor.constraint(equalToConstant: 75),
            
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
            
            scrollCreationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollCreationView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor),
            scrollCreationView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollCreationView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            emojiAndColorsStackView.topAnchor.constraint(equalTo: scrollCreationView.contentLayoutGuide.topAnchor),
            emojiAndColorsStackView.leadingAnchor.constraint(equalTo: scrollCreationView.contentLayoutGuide.leadingAnchor),
            emojiAndColorsStackView.trailingAnchor.constraint(equalTo: scrollCreationView.contentLayoutGuide.trailingAnchor),
            emojiAndColorsStackView.bottomAnchor.constraint(equalTo: scrollCreationView.contentLayoutGuide.bottomAnchor),
            emojiAndColorsStackView.widthAnchor.constraint(equalTo: scrollCreationView.frameLayoutGuide.widthAnchor),
            
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 198),
            
            colorsCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 34),
            colorsCollectionView.heightAnchor.constraint(equalToConstant: 198)
            
            
        ])
    }
    
    @objc private func cancelButtonTapped() {
        trackerToEdit != nil ? (self.dismiss(animated: true)) : (self.presentingViewController?.presentingViewController?.dismiss(animated: true))
    }
    
    @objc private func createButtonTapped() {
        guard let trackerName = trackerNameTextField.text else { return }
        guard let _ = selectedEmoji else { return }
        guard let _ = selectedColor else { return }
        guard let _ = selectedCategory else { return }
        
        if let id = trackerToEdit?.id {
            delegate?.updateTracker(id: id, trackerName: trackerName, schedule: selectedSchedule, emoji: selectedEmoji, color: selectedColor, category: selectedCategory)
        } else {
            delegate?.createTracker(trackerName: trackerName, schedule: selectedSchedule, emoji: selectedEmoji, color: selectedColor, category: selectedCategory)
        }
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
    private func setupUIForEditing() {
        if let trackerToEdit  {
            selectedColor = trackerToEdit.color
            selectedEmoji = trackerToEdit.emoji
            trackerNameTextField.text = trackerToEdit.name
            selectedSchedule = trackerToEdit.schedule.compactMap { WeekDay.allCases.firstIndex(of: $0) }
            textChanged()
            
        }
        
        if let unwrappedEmoji = selectedEmoji,
            let emojiIndex = emojis.firstIndex(of: unwrappedEmoji)
        {
            let indexPath = IndexPath(row: emojiIndex, section: 0)
            emojiCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
        
        if let unwrappedColor = selectedColor,
           let colorIndex = colors.firstIndex(where: { $0.toHexString() == unwrappedColor.toHexString() })
        {
            let indexPath = IndexPath(row: colorIndex, section: 0)
            colorsCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
        
        createButton.setTitle("Сохранить", for: .normal)
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
            scheduleCell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 400)
            return scheduleCell
        } else if indexPath.row == 0 {
            var categoryCell = UITableViewCell(style: .subtitle, reuseIdentifier: "Категория")
            categoryCell.textLabel?.text = "Категория"
            categoryCell.detailTextLabel?.text = selectedCategory
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
        scheduleVC.selectedWeekDays = self.selectedSchedule
        
        let newCategoryVC = CategoryViewController()
        let categoryNavController = UINavigationController(rootViewController: newCategoryVC)
        newCategoryVC.delegate = self
        newCategoryVC.selectedCategory = self.selectedCategory
        indexPath.row == 0 ? present(categoryNavController, animated: true, completion: nil) : present(scheduleNavController, animated: true, completion: nil)
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

extension TrackerCreationViewController: CategoryViewControllerDelegate {
    func chooseCategory(title: String) {
        self.selectedCategory = title
        creationTableView.reloadData()
    }
}


extension TrackerCreationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView == emojiCollectionView ? emojis.count : colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     
        if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath) as! EmojiCollectionViewCell
            let emoji = emojis[indexPath.row]
            selectedEmoji == emoji ? (cell.backgroundColor = .systemGray6) : (cell.backgroundColor = .clear)
            cell.layer.cornerRadius = 16
            cell.configure(emoji: emoji)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorsCell", for: indexPath) as! ColorCollectionViewCell
            let color = colors[indexPath.row]
            cell.configure(color: color)
            if selectedColor?.toHexString() == color.toHexString() {
                cell.layer.borderWidth = 3
                cell.layer.borderColor = color.withAlphaComponent(0.3).cgColor
            } else {
                cell.layer.borderWidth = 0
                cell.layer.borderColor = .none
            }
            cell.layer.cornerRadius = 12
            return cell
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! SupplementaryView
        
        collectionView == emojiCollectionView ? (view.titleLabel.text = "Emoji") : (view.titleLabel.text = "Цвет")
        
        return view
    }
    
}


extension TrackerCreationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 5

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 24, left: 3, bottom: 24, right: 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as! EmojiCollectionViewCell
            cell.backgroundColor = .systemGray6
            selectedEmoji = emojis[indexPath.row]
        } else {
            let cell = collectionView.cellForItem(at: indexPath) as! ColorCollectionViewCell
            cell.layer.borderWidth = 3
            cell.layer.borderColor = colors[indexPath.row].withAlphaComponent(0.3).cgColor
            selectedColor = colors[indexPath.row]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell
            cell?.backgroundColor = .clear
        } else {
            let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell
            cell?.layer.borderWidth = 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 18)
    }
    
}
