import UIKit

final class StatisticsCardView: UIView {
    let statisticsDigitLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let statisticsTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(statisticsDigitLabel)
        addSubview(statisticsTitleLabel)
        
        NSLayoutConstraint.activate([
            statisticsDigitLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            statisticsDigitLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            
            statisticsTitleLabel.topAnchor.constraint(equalTo: statisticsDigitLabel.bottomAnchor, constant: 7),
            statisticsTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            statisticsTitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
            
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, value: String){
        statisticsDigitLabel.text = value
        statisticsTitleLabel.text = title
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.sublayers?.filter  { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        addGradientBorder()
    }
    
    private func addGradientBorder() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [
            UIColor.red.cgColor,
            UIColor.green.cgColor,
            UIColor.blue.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 1
        shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 16).cgPath
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.black.cgColor
        
        gradientLayer.mask = shapeLayer
        
        layer.addSublayer(gradientLayer)
    }
}
