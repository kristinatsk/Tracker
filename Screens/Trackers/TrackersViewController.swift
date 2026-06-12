import UIKit

final class TrackersViewController: UIViewController {
            
    private var currentDate = Date()
    
    private let datePicker = UIDatePicker()
    
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: LeftAlignedCollectionViewFlowLayout())
    
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .starPlaceholder)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("what_track", comment: "")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = Colors.navigationTintColor
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var filterButton: UIButton = {
       let button = UIButton()
        button.setTitle(NSLocalizedString("filters", comment: ""), for: .normal)
        button.setTitleColor(Colors.collectionViewBackgroundColor, for: .normal)
        button.layer.cornerRadius = 16
        button.backgroundColor = UIColor(resource: .filterButton)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.report(event: "open", params: ["screen" : "Main"])
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.report(event: "close", params: ["screen" : "Main"])
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        title = NSLocalizedString("trackers", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = Colors.collectionViewBackgroundColor
        
        trackerStore.delegate = self
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTrackerTapped)
        )
        
        addButton.tintColor = Colors.navigationTintColor
        navigationItem.leftBarButtonItem = addButton
        
        
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = NSLocalizedString("search", comment: "")
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "trackerCollectionViewCell")
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        view.addSubview(filterButton)
        
        NSLayoutConstraint.activate([
            
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor),
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114)
        ])
        
        updatePlaceHolderVisibility()
        datePickerValueChanged(datePicker)
    }
    
    @objc private func addTrackerTapped() {
        AnalyticsService.report(event: "click", params: ["screen": "Main", "item": "add_track"])
        let typeSelectionVC = TrackerTypeSelectionViewController()
        typeSelectionVC.delegate = self
        present(typeSelectionVC, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        self.currentDate = sender.date
        let filterWeekday = Calendar.current.component(.weekday, from: currentDate)
        guard let selectedWeekDay = WeekDay(calendarWeekday: filterWeekday) else { return }
        let searchText = navigationItem.searchController?.searchBar.text ?? ""
        trackerStore.filterTracker(by: selectedWeekDay, searchText: searchText)
        collectionView.reloadData()
        updatePlaceHolderVisibility()
        
    }
    
    @objc private func filterButtonTapped() {
        AnalyticsService.report(event: "click", params: ["screen" : "Main", "item" : "filter"])
    }
    
    
    private func updatePlaceHolderVisibility() {
        let searchText = navigationItem.searchController?.searchBar.text ?? ""
        if !searchText.isEmpty {
            placeholderImageView.image = UIImage(resource: .searchTrackerError)
            placeholderLabel.text = NSLocalizedString("no_results", comment: "")
        } else {
            placeholderImageView.image = UIImage(resource: .starPlaceholder)
            placeholderLabel.text = NSLocalizedString("what_track", comment: "")
        }
        
        placeholderImageView.isHidden = !trackerStore.trackersIsEmpty
        placeholderLabel.isHidden = !trackerStore.trackersIsEmpty
        filterButton.isHidden = trackerStore.trackersIsEmpty
        
    }
    
}

extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return trackerStore.numberOfRowsInSection(section)
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return trackerStore.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trackerCollectionViewCell", for: indexPath) as! TrackerCollectionViewCell
        cell.delegate = self
        let tracker = trackerStore.object(at: indexPath)
        
        let startOfDay = Calendar.current.startOfDay(for: currentDate)
        
        let completedDays = trackerRecordStore.countCompletedDays(tracker.id ?? UUID())
        let isCompletedToday = trackerRecordStore.isCompletedToday(startOfDay, id: tracker.id ?? UUID())
        let newTracker = Tracker(
            id: tracker.id ?? UUID(),
            name: tracker.name ?? "",
            color: UIColor(hex: tracker.color ?? "") ?? .black,
            emoji: tracker.emoji ?? "",
            schedule: (tracker.schedule ?? "").components(separatedBy: ",").compactMap { Int($0) }.compactMap { WeekDay(rawValue: $0) },
            isPinned: tracker.isPinned
        )
        cell.configure(tracker: newTracker, isCompletedToday: isCompletedToday, completedDays: completedDays)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! SupplementaryView
        view.titleLabel.text = trackerStore.headerTitle(for: indexPath.section)
        
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
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let tracker = trackerStore.object(at: indexPath)
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let pinAction = UIAction(title: tracker.isPinned ? NSLocalizedString("unpin", comment: "") : NSLocalizedString("unpin", comment: "")) { [weak self] _ in
                let newTracker = Tracker(
                    id: tracker.id ?? UUID(),
                    name: tracker.name ?? "",
                    color: UIColor(hex: tracker.color ?? "") ?? .black,
                    emoji: tracker.emoji ?? "",
                    schedule: (tracker.schedule ?? "").components(separatedBy: ",").compactMap { Int($0) }.compactMap { WeekDay(rawValue: $0) },
                    isPinned: !tracker.isPinned
                )
                
                try? self?.trackerStore.updateTracker(tracker: newTracker, category: tracker.category?.title ?? NSLocalizedString("untitle", comment: ""))
                
            }
            let editAction = UIAction(title: NSLocalizedString("edit", comment: "")) { [weak self] _ in
                AnalyticsService.report(event: "click", params: ["screen" : "Main","item" : "edit"])
                let newTracker = Tracker(
                    id: tracker.id ?? UUID(),
                    name: tracker.name ?? "",
                    color: UIColor(hex: tracker.color ?? "") ?? .black,
                    emoji: tracker.emoji ?? "",
                    schedule: (tracker.schedule ?? "").components(separatedBy: ",").compactMap { Int($0) }.compactMap { WeekDay(rawValue: $0) },
                    isPinned: tracker.isPinned
                )
                
                let isHabit = !newTracker.schedule.isEmpty
                
                let editTracker = TrackerCreationViewController(isHabit: isHabit)
                editTracker.trackerToEdit = newTracker
                editTracker.selectedCategory = tracker.category?.title
                editTracker.delegate = self
                let trackerNavController = UINavigationController(rootViewController: editTracker)
                self?.present(trackerNavController, animated: true, completion: nil)
            }
            
            let deleteAction = UIAction(title: NSLocalizedString("delete", comment: ""), attributes: .destructive) { [weak self] _ in
                AnalyticsService.report(event: "click", params: ["screen" : "Main", "item" : "delete"])
                let alertController = UIAlertController(
                    title: NSLocalizedString("sure_delete_tracker", comment: ""),
                    message: nil,
                    preferredStyle: .actionSheet
                )
                
                let delete = UIAlertAction(title: NSLocalizedString("delete", comment: ""), style: .destructive) { _ in
                    try? self?.trackerStore.deleteTracker(at: indexPath)
                }
                
                let cancel = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel)
                
                alertController.addAction(delete)
                alertController.addAction(cancel)
                
                self?.present(alertController, animated: true)
            }
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }
}

extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func completeTracker(id: UUID) {
        AnalyticsService.report(event: "click", params: ["screen" : "Main", "item" : "track"])
        guard currentDate <= Date() else { return }
        let startOfDay = Calendar.current.startOfDay(for: currentDate)
        if trackerRecordStore.isCompletedToday(startOfDay, id: id) {
           try? trackerRecordStore.deleteRecord(id: id, date: startOfDay)
        } else {
            try? trackerRecordStore.addRecord(id, date: startOfDay)
        }
        collectionView.reloadData()
    }
}

extension TrackersViewController: TrackerCreationDelegate {
    func createTracker(trackerName: String, schedule: [Int], emoji: String?, color: UIColor?, category: String?) {

        let realSchedule = schedule.compactMap { WeekDay(scheduleIndex: $0) }
        
        let tracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: color ?? .black,
            emoji: emoji ?? "❓",
            schedule: realSchedule)
        
        try? trackerStore.addTracker(tracker, category: category ?? NSLocalizedString("without_category", comment: ""))
        
        updatePlaceHolderVisibility()
        self.dismiss(animated: true)
    }
    
    func updateTracker(id: UUID, trackerName: String, schedule: [Int], emoji: String?, color: UIColor?, category: String?) {
        let realSchedule = schedule.compactMap { WeekDay(scheduleIndex: $0) }
        
        let tracker = Tracker(
            id: id,
            name: trackerName,
            color: color ?? .black,
            emoji: emoji ?? "❓",
            schedule: realSchedule
            )
        
        try? trackerStore.updateTracker(tracker: tracker, category: category ?? NSLocalizedString("untitle", comment: ""))
        updatePlaceHolderVisibility()
        self.dismiss(animated: true)
    }
    
    
}

// MARK: - TrackerStoreDelegate
extension TrackersViewController: TrackerStoreDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        collectionView.performBatchUpdates {

            let insertedSections = update.insertedSections
            let deletedSections = update.deletedSections
            let insertedCells = update.insertedCells
            let deletedCells = update.deletedCells
            let updatedCells = update.updatedCells
            
            collectionView.insertItems(at: insertedCells)
            collectionView.deleteItems(at: deletedCells)
            collectionView.insertSections(insertedSections)
            collectionView.deleteSections(deletedSections)
            collectionView.reloadItems(at: updatedCells)
        }
    }
}

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text
        let filterWeekday = Calendar.current.component(.weekday, from: currentDate)
        guard let selectedWeekDay = WeekDay(calendarWeekday: filterWeekday) else { return }
        trackerStore.filterTracker(by: selectedWeekDay, searchText: text ?? "")
        collectionView.reloadData()
        updatePlaceHolderVisibility()
    }
    
    
}
