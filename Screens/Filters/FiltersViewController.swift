import UIKit

protocol FiltersViewControllerDelegate: AnyObject {
    func chooseFilter(title: String)
}

final class FiltersViewController: UIViewController {
    private let filters = [
        NSLocalizedString("all_trackers", comment: ""),
        NSLocalizedString("today_trackers", comment: ""),
        NSLocalizedString("completed_trackers", comment: ""),
        NSLocalizedString("uncompleted_trackers", comment: "")
    ]
    
    var selectedFilter: String?
    weak var delegate: FiltersViewControllerDelegate?
    
    private lazy var filtersTableView: UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.backgroundColor = UIColor(resource: .tableViewBackground)
        tableView.layer.cornerRadius = 16
        tableView.rowHeight = 75
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("filters", comment: "")
        view.backgroundColor = Colors.collectionViewBackgroundColor
        
        filtersTableView.delegate = self
        filtersTableView.dataSource = self
        
        
        view.addSubview(filtersTableView)
        
        NSLayoutConstraint.activate([
            filtersTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            filtersTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            filtersTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            filtersTableView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
}


extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = filters[indexPath.row]
        cell.accessoryType  = filters[indexPath.row] == selectedFilter ? .checkmark : .none
        return cell
    }
    
    
}

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let filter = filters[indexPath.row]
        delegate?.chooseFilter(title: filter)
        dismiss(animated: true)
    }
}

