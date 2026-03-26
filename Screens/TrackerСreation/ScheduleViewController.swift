import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func completeSchedule(data: [Int])
}

final class ScheduleViewController: UIViewController {
    var selectedWeekDays: [Int] = []
    weak var delegate: ScheduleViewControllerDelegate?
    
    private lazy var scheduleTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(resource: .tableViewBackground)
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        return tableView
    }()
    
    private lazy var scheduleDoneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Расписание"
        
        view.addSubview(scheduleTableView)
        view.addSubview(scheduleDoneButton)
        
        scheduleDoneButton.addTarget(self, action: #selector(scheduleDoneButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            scheduleTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            scheduleTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            scheduleTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            scheduleTableView.heightAnchor.constraint(equalToConstant: 525),
            
            scheduleDoneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            scheduleDoneButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            scheduleDoneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            scheduleDoneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func scheduleDoneButtonTapped() {
        delegate?.completeSchedule(data: selectedWeekDays)
        dismiss(animated: true)
    }
}

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WeekDay.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = WeekDay.allCases[indexPath.row].weekName
        let daySwitch = UISwitch()
        daySwitch.tag = indexPath.row
        daySwitch.onTintColor = .systemBlue
        daySwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        cell.accessoryView = daySwitch
        cell.backgroundColor = UIColor(resource: .tableViewBackground)
        if indexPath.row == WeekDay.allCases.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 400)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        }
        return cell
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        if sender.isOn {
            selectedWeekDays.append(sender.tag)
        } else {
            selectedWeekDays.removeAll{ $0 == sender.tag }
        }
    }
}
