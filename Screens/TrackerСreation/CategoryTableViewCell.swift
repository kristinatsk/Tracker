import UIKit

final class CategoryTableViewCell: UITableViewCell {
    private lazy var categoryTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(categoryTitleLabel)
        
        NSLayoutConstraint.activate([
            categoryTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            categoryTitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(title: String, isSelectedCategory: Bool) {
        categoryTitleLabel.text = title
        self.accessoryType = isSelectedCategory ? .checkmark : .none
        self.backgroundColor = .secondarySystemBackground
    }
    

}
