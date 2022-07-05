//
//  XKSquarifiedMap.swift
//  Demos
//
//  Created by kenneth on 2022/6/16.
//

import UIKit

public class XKSquarifiedMap: NSObject {
    
    public var values: [Double] = []
    fileprivate var containerSize: CGSize = .zero
    /// 当前绘制空间尺寸
    fileprivate var drawSize: CGSize = .zero
    fileprivate var rects: [Rect] = []
    
    class Rect: Equatable {
        var area: CGFloat = 0.0
        var frame: CGRect = .zero
        var value: Double = 0.0
        weak var father: Rect?
        var isHor: Bool?
        
        static func == (lhs: XKSquarifiedMap.Rect, rhs: XKSquarifiedMap.Rect) -> Bool {
            return lhs.area == rhs.area && lhs.frame == rhs.frame && lhs.value == rhs.value
        }
    }
    
    func createRect(index: Int, total: Double, area: CGFloat)  {
        
        guard index < values.count else { return }
        guard index == rects.count else { return }
        
        // 靠短边摆放
        let curValue   = values[index]
        let valueArea  = ceil(curValue / total * area)
        let viewWidth  = containerSize.width
        let viewHeight = containerSize.height
        
        let drawWidth  = drawSize.width
        let drawHeight = drawSize.height
        var valueX     = viewWidth - drawWidth
        var valueY     = viewHeight - drawHeight
        
        var valueWidth  = 0.0
        var valueHeight = 0.0
        var valueRatio  = 0.0
        
        let valueRect = Rect()
        valueRect.area = valueArea
        valueRect.value = curValue
        valueRect.father = valueRect
        
        let calsulateValueSizeClosure = {
            if drawWidth > drawHeight {
                valueHeight = drawHeight
                valueWidth = valueArea / valueHeight
            } else {
                valueWidth = drawWidth
                valueHeight = valueArea / valueWidth
            }
        }
        let setRectFrameClosure = {
            valueRect.frame = CGRect(x: valueX, y: valueY, width: valueWidth, height: valueHeight)
        }
        let calculateRatioClosure = {
            valueRatio = max(valueWidth/valueHeight, valueHeight/valueWidth)
        }
        
        calsulateValueSizeClosure()
        guard index > 0 else {
            setRectFrameClosure()
            appendRect(valueRect, isFirst: true, isNew: true)
            return
        }
        
        guard let lastRect = rects.last else { return }
        
        // 新增
        calsulateValueSizeClosure()
        calculateRatioClosure()
        
        // 放到同一区域
        let zoomRects = rects.filter { rect in
            return rect.father == lastRect.father
        }
        let zoomArea = zoomRects.reduce(0) { partialResult, rect in
            return partialResult + rect.area
        } + valueArea
        // 水平插入还是垂直插入
        let isHor = lastRect.frame.maxX == viewWidth
        
        var zoomWidth  = 0.0
        var zoomHeight = 0.0
        
        if isHor {
            zoomWidth = valueArea / zoomArea * drawWidth
            zoomHeight = valueArea / zoomWidth
        } else {
            zoomHeight = valueArea / zoomArea * drawHeight
            zoomWidth = valueArea / zoomHeight
        }
        
        let zoomRatio = max(zoomWidth/zoomHeight, zoomHeight/zoomWidth)
        
        guard zoomRatio <= valueRatio else {
            // 新增比较合适
            setRectFrameClosure()
            appendRect(valueRect, isFirst: false, isNew: true)
            return
        }
        
        // 插入比较合适
        lastRect.father?.isHor = isHor
        valueRect.father = lastRect.father
        
        let zoomRectWidthSum = zoomRects.reduce(0) { partialResult, rect in
            return partialResult + rect.frame.width
        }
        let zoomRectHeightSum = zoomRects.reduce(0) { partialResult, rect in
            return partialResult + rect.frame.height
        }
        
        // 更新同一区域的frame
        for (i, zoomRect) in zoomRects.enumerated() {
            
            var rectX: CGFloat = 0.0
            var rectY: CGFloat = 0.0
            var rectWidth = 0.0
            var rectHeight = 0.0
            
            if isHor {
                rectWidth = zoomRect.area / zoomArea * zoomRectWidthSum
                rectHeight = zoomRect.area / rectWidth
            } else {
                rectHeight = zoomRect.area / zoomArea * zoomRectHeightSum
                rectWidth = zoomRect.area / rectHeight
            }
            
            let updataZoomFrameClosure = {
                zoomRect.frame = CGRect(x: rectX, y: rectY, width: rectWidth, height: rectHeight)
            }
            
            guard i > 0 else {
                rectX = zoomRect.frame.minX
                rectY = zoomRect.frame.minY
                updataZoomFrameClosure()
                continue
            }
            
            // 其实是一定有值的
            guard i-1 < zoomRects.count else { continue }
            let zoomLastRect = zoomRects[i-1]
            
            rectX = isHor ? zoomLastRect.frame.maxX : zoomLastRect.frame.minX
            rectY = isHor ? zoomLastRect.frame.minY : zoomLastRect.frame.maxY
            updataZoomFrameClosure()
        }
        
        let zoomX = isHor ? lastRect.frame.maxX : lastRect.frame.minX
        let zoomY = isHor ? lastRect.frame.minY : lastRect.frame.maxY
        
        valueX = zoomX
        valueY = zoomY
        valueWidth = zoomWidth
        valueHeight = zoomHeight
        setRectFrameClosure()
        appendRect(valueRect, isFirst: false, isNew: false)
    }
    
    func appendRect(_ rect: Rect, isFirst: Bool, isNew: Bool) {
        print(rect.frame)
        rects.append(rect)
        
        let viewWidth = containerSize.width
        let viewHeight = containerSize.height
        
        let fatherMaxX = rect.father?.frame.maxX ?? 0.0
        let fatherMaxY = rect.father?.frame.maxY ?? 0.0
        let fatherMinX = rect.father?.frame.minX ?? 0.0
        let fatherMinY = rect.father?.frame.minY ?? 0.0
        
        var zoomWidth = viewWidth - fatherMaxX
        var zoomHeight = viewHeight - fatherMaxY
        
        let updateZoomSizeClosure = { [weak self] in
            self?.drawSize = CGSize(width: zoomWidth, height: zoomHeight)
        }
        
        if isFirst || isNew {
            
            if fatherMaxX == viewWidth {
                zoomWidth = viewWidth - fatherMinX
            }
            if fatherMaxY == viewHeight {
                zoomHeight = viewHeight - fatherMinY
            }
            updateZoomSizeClosure()
            return
        }
        
        guard let isHor = rect.father?.isHor else {
            updateZoomSizeClosure()
            return
        }
        
        if isHor {
            zoomHeight = viewHeight - fatherMaxY
            zoomWidth = viewWidth - fatherMinX
        } else {
            zoomWidth = viewWidth - fatherMaxX
            zoomHeight = viewHeight - fatherMinY
        }
        
        updateZoomSizeClosure()
    }

}

public extension XKSquarifiedMap {
    
    static func fetchRects(values: [Double], containerSize: CGSize) -> [CGRect] {
        let map = XKSquarifiedMap()
        map.rects.removeAll()
        let values = values.sorted { value1, value2 in
            return value1 >= value2
        }.map { ceil($0) }
        let size = CGSize(width: ceil(containerSize.width), height: ceil(containerSize.height))
        map.values = values
        map.containerSize = size
        map.drawSize = size
        let area = size.width * size.height
        let total = values.reduce(into: 0, +=)
        for (i, _) in values.enumerated() {
            map.createRect(index: i, total: total, area: area)
        }
        return map.rects.map { rect -> CGRect in
            return rect.frame
        }
    }
}
