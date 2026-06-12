import UIKit

final class StatisticsViewController: UIViewController {
    private let trackerRecordStore = TrackerRecordStore()
    private let completedTrackersCard = StatisticsCardView()
    
    private lazy var statisticsPlaceholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .statisticsPlaceholder)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var statisticsPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("nothing_analyze", comment: "")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.textColor = Colors.navigationTintColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var statisticsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 12
        stackView.addArrangedSubview(completedTrackersCard)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatistics()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("statistics", comment: "")
        view.backgroundColor = Colors.collectionViewBackgroundColor
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(statisticsPlaceholderImageView)
        view.addSubview(statisticsPlaceholderLabel)
        view.addSubview(statisticsStackView)
        
        NSLayoutConstraint.activate([
            statisticsPlaceholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statisticsPlaceholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            statisticsPlaceholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statisticsPlaceholderLabel.topAnchor.constraint(equalTo: statisticsPlaceholderImageView.bottomAnchor),
            
            statisticsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 77),
            statisticsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            statisticsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        updateStatistics()
    }
    
    private func updateStatistics() {
        statisticsStackView.isHidden = trackerRecordStore.totalCompletedTrackers == 0
        statisticsPlaceholderImageView.isHidden = trackerRecordStore.totalCompletedTrackers != 0
        statisticsPlaceholderLabel.isHidden = trackerRecordStore.totalCompletedTrackers != 0
        completedTrackersCard.configure(title: NSLocalizedString("completed_trackers", comment: ""), value: "\(trackerRecordStore.totalCompletedTrackers)")
    }
}
