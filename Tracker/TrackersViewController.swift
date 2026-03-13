import UIKit

final class TrackersViewController: UIViewController {
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: LeftAlignedCollectionViewFlowLayout())
    
    private var visibleCategories: [TrackerCategory] = []
    
    private var categories: [TrackerCategory] = [
        TrackerCategory(
            title: "Домашний уют",
            trackers:[
                Tracker(
                    id: UUID(),
                    name: "Поливать растения",
                    color: .systemGreen,
                    emoji: "👍",
                    schedule:[.friday]
                )
            ]
        )
    ] {
        didSet {
            updatePlaceHolderVisibility()
        }
    }
    
    private var completedTrackers: [TrackerRecord] = []
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .starPlaceholder)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .white
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTrackerTapped)
        )
        
        addButton.tintColor = .black
        navigationItem.leftBarButtonItem = addButton
        
        
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
        
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "trackerCollectionViewCell")
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor),
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        ])
        
    }
    @objc private func addTrackerTapped() {
        let newTracker = TrackerTypeSelectionViewController()
        present(newTracker, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let calendar = Calendar.current
        let filterWeekday = calendar.component(.weekday, from: selectedDate)
        
        guard let selectedWeekDay = WeekDay(rawValue: filterWeekday) else { return }
        
        visibleCategories = []
        
        for category in categories {
            let filteredTrackers = category.trackers.filter { $0.schedule.contains(selectedWeekDay) }
            
            if !filteredTrackers.isEmpty {
                
                let newCategory = TrackerCategory(title: category.title, trackers: filteredTrackers)
                visibleCategories.append(newCategory)
            }
        }
        collectionView.reloadData()
        updatePlaceHolderVisibility()
        
    }
    
    private func updatePlaceHolderVisibility() {
        placeholderImageView.isHidden = !visibleCategories.isEmpty
        placeholderLabel.isHidden = !visibleCategories.isEmpty
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return visibleCategories[section].trackers.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trackerCollectionViewCell", for: indexPath) as! TrackerCollectionViewCell
        cell.delegate = self
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        
        let completedDays = completedTrackers.filter { $0.id == tracker.id }.count
        let isCompletedToday = completedTrackers.contains(where: {$0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: datePicker.date) })
        
        cell.configure(tracker: tracker, isCompletedToday: isCompletedToday, completedDays: completedDays)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! SupplementaryView
        view.titleLabel.text = visibleCategories[indexPath.section].title
        
        return view
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellsPerRow = 2.0
        let leftInset = 16.0
        let rightInset = 16.0
        let cellSpacing = 9.0
        let paddingWidth: CGFloat = leftInset + rightInset + (cellsPerRow - 1) * cellSpacing
        let availableWidth = collectionView.frame.width - paddingWidth
        let cellWidth = availableWidth/CGFloat(cellsPerRow)
        
        return CGSize(width: cellWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        /*let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
         */
        return CGSize(width: collectionView.frame.width, height: 18.0)
    }
}

extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func completeTracker(id: UUID) {
        guard datePicker.date <= Date() else { return }
        if let index = completedTrackers.firstIndex(where: { $0.id == id && Calendar.current.isDate($0.date, inSameDayAs: datePicker.date) }) {
            completedTrackers.remove(at: index)
        } else {
            completedTrackers.append(TrackerRecord(id: id, date: datePicker.date))
        }
        collectionView.reloadData()
    }
}
