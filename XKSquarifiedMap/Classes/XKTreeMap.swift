//
//  Created by kenneth on 2022/6/13.
//

import UIKit
import SwifterSwift

open class XKTreeMap: UICollectionView {
    
    public var treeValues: [Double] = [] {
        didSet {
            updateLayout()
        }
    }
    
    public var layout: TZYKTreeMapLayout? {
        return collectionViewLayout as? TZYKTreeMapLayout
    }
    
    public init() {
        super.init(frame: .zero, collectionViewLayout: TZYKTreeMapLayout())
        initMethod()
    }
    
    private override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension XKTreeMap {
    
    func initMethod() {
        
    }
    
    func updateLayout() {
        guard bounds != .zero else { return }
        let rects = XKSquarifiedMap.fetchRects(values: treeValues, containerSize: bounds.size)
        layout?.rects = rects
        reloadData()
    }
}

open class TZYKTreeMapLayout: UICollectionViewFlowLayout {
    
    var rects = [CGRect]() {
        didSet {
            invalidateLayout()
        }
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    open override var collectionViewContentSize: CGSize {
        return collectionView?.frame.size ?? .zero
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let att = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        guard let frame = rects[safe: indexPath.item] else {
            return att
        }
        let isNan = frame.origin.x.isNaN || frame.origin.y.isNaN || frame.size.width.isNaN || frame.size.height.isNaN
        guard isNan == false else {
            return att
        }
        att.frame = frame
        return att
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributeds = [UICollectionViewLayoutAttributes]()
        for (i, _) in rects.enumerated() {
            guard let att = layoutAttributesForItem(at: IndexPath(item: i, section: 0)) else {
                continue
            }
            attributeds.append(att)
        }
        return attributeds
    }
}
