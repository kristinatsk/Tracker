import UIKit

class CustomTabBarController: UITabBarController {
    
    private lazy var customTabBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [trackerButton, statisticsButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var trackerButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        config.imagePlacement = .top
        config.imagePadding = 4
        config.title = "Трекеры"
        config.image = UIImage(resource: .trackersIcon)
        button.configuration = config
        button.addTarget(self, action: #selector(trackerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var statisticsButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        config.imagePlacement = .top
        config.imagePadding = 4
        config.title = "Статистика"
        config.image = UIImage(resource: .statisticsIcon)
        button.configuration = config
        button.addTarget(self, action: #selector(statisticsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        tabBar.isHidden = true
        
        view.addSubview(customTabBarView)
        customTabBarView.addSubview(separatorLine)
        customTabBarView.addSubview(buttonsStackView)
        
        trackerButton.addTarget(self, action: #selector(trackerButtonTapped), for: .touchUpInside)
        statisticsButton.addTarget(self, action: #selector(statisticsButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            
            customTabBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            customTabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            customTabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            customTabBarView.heightAnchor.constraint(equalToConstant: 84),
            
            separatorLine.topAnchor.constraint(equalTo: customTabBarView.topAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: customTabBarView.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: customTabBarView.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            buttonsStackView.bottomAnchor.constraint(equalTo: customTabBarView.bottomAnchor),
            buttonsStackView.leadingAnchor.constraint(equalTo: customTabBarView.leadingAnchor),
            buttonsStackView.trailingAnchor.constraint(equalTo: customTabBarView.trailingAnchor),
            buttonsStackView.topAnchor.constraint(equalTo: separatorLine.bottomAnchor)
            
            
        ])
        updateButtonStates()
    }
    
    @objc private func trackerButtonTapped() {
        self.selectedIndex = 0
        updateButtonStates()
    }
    
    @objc private func statisticsButtonTapped() {
        self.selectedIndex = 1
        updateButtonStates()
    }
    
    private func updateButtonStates() {
        if self.selectedIndex == 0 {
            trackerButton.tintColor = .systemBlue
            statisticsButton.tintColor = .systemGray
        } else {
            trackerButton.tintColor = .systemGray
            statisticsButton.tintColor = .systemBlue
        }
    }
}
