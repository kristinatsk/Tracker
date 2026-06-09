import UIKit

final class TrackerTypeSelectionViewController: UIViewController {
    weak var delegate: TrackerCreationDelegate?
    
    private lazy var typeSelectionLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("tracker_creation", comment: "")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var typeSelectionHabitButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("habit", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var typeSelectionIrregularButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("irregular", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(typeSelectionLabel)
        view.addSubview(typeSelectionHabitButton)
        view.addSubview(typeSelectionIrregularButton)
        
        NSLayoutConstraint.activate([
            typeSelectionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            typeSelectionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            
            typeSelectionHabitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            typeSelectionHabitButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            typeSelectionHabitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            typeSelectionHabitButton.heightAnchor.constraint(equalToConstant: 60),
            
            
            typeSelectionIrregularButton.topAnchor.constraint(equalTo: typeSelectionHabitButton.bottomAnchor, constant: 16),
            typeSelectionIrregularButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            typeSelectionIrregularButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            typeSelectionIrregularButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        typeSelectionHabitButton.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        typeSelectionIrregularButton.addTarget(self, action: #selector(irregularButtonTapped), for: .touchUpInside)
    }
    
    @objc private func habitButtonTapped() {
        
        let newHabit = TrackerCreationViewController(isHabit: true)
        newHabit.delegate = delegate
        let navHabitController = UINavigationController(rootViewController: newHabit)
        present(navHabitController, animated: true)
    }
    
    @objc private func irregularButtonTapped() {
        let newIrregular = TrackerCreationViewController(isHabit: false)
        newIrregular.delegate = delegate
        let navIrregularController = UINavigationController(rootViewController: newIrregular)
        present(navIrregularController, animated: true)
    }
}

