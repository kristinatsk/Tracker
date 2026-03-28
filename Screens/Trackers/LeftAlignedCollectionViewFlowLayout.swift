import UIKit

final class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        
        let attributesCopy = attributes?.map { $0.copy() as! UICollectionViewLayoutAttributes }
        
        var initialLeftMargin = sectionInset.left
        
        if let collectionView = collectionView,
           let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
           let inset = delegate.collectionView?(collectionView, layout: self, insetForSectionAt: 0) {
            initialLeftMargin = inset.left
        }
        
        var leftMargin = initialLeftMargin
        var maxY: CGFloat = -1.0
        
        attributesCopy?.filter { $0.representedElementCategory == .cell }.forEach { layoutAttribute in
            
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = initialLeftMargin
            }
            layoutAttribute.frame.origin.x = leftMargin
            
            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        
        return attributesCopy
    }
}
