import UIKit

final class OnboardingChildViewController: UIViewController {
    private lazy var onboardingImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var onboardingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = Colors.navigationTintColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var onboardingButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("thats_technology", comment: ""), for: .normal)
        button.setTitleColor(Colors.collectionViewBackgroundColor, for: .normal)
        button.backgroundColor = Colors.navigationTintColor
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let pageImage: UIImage
    private let pageText: String
    
    
    init(image: UIImage, text: String) {
        self.pageImage = image
        self.pageText = text
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        view.addSubview(onboardingImage)
        view.addSubview(onboardingLabel)
        view.addSubview(onboardingButton)
        
        onboardingLabel.text = pageText
        onboardingImage.image = pageImage
        
        onboardingButton.addTarget(self, action: #selector(onboardingButtonTapped), for: .touchUpInside)
       
        NSLayoutConstraint.activate([
            onboardingImage.topAnchor.constraint(equalTo: view.topAnchor),
            onboardingImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            onboardingImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            onboardingImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            onboardingLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            onboardingLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            onboardingLabel.bottomAnchor.constraint(equalTo: onboardingButton.topAnchor, constant: -160),
            
            onboardingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            onboardingButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            onboardingButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            onboardingButton.heightAnchor.constraint(equalToConstant: 60)
            
            
        ])
    }
    
    @objc func onboardingButtonTapped() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        
        guard let window = UIApplication.shared.windows.first else { return }
        
        let tabBarController = CustomTabBarController()
        
        let trackersViewController = TrackersViewController()
        let trackersNavigation = UINavigationController(rootViewController: trackersViewController)
        trackersNavigation.tabBarItem = UITabBarItem(title: NSLocalizedString("trackers", comment: ""), image: UIImage(resource: .trackersIcon), selectedImage: nil)
        
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("statistics", comment: ""), image: UIImage(resource: .statisticsIcon), selectedImage: nil)
        
        tabBarController.viewControllers = [trackersNavigation, statisticsViewController]
        
        window.rootViewController = tabBarController
    }
}
