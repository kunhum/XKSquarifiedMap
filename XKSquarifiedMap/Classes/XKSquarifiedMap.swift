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
    fileprivate var rects: [Rect] = []
    
    class Rect: Equatable {
        var area: CGFloat = 0.0
        var frame: CGRect = .zero
        var value: Double = 0.0
        weak var father: Rect?
        
        static func == (lhs: XKSquarifiedMap.Rect, rhs: XKSquarifiedMap.Rect) -> Bool {
            return lhs.area == rhs.area && lhs.frame == rhs.frame && lhs.value == rhs.value
        }
    }
    
    func createRect(index: Int, total: Double, area: CGFloat)  {
        
        guard index < values.count else { return }
        guard index == rects.count else { return }
        
        // 靠短边摆放
        let curValue = values[index]
        let valueArea = curValue / total * area
        var curWidth = containerSize.width
        var curHeight = containerSize.height
        var valueWidth = 0.0
        var valueHeight = 0.0
        var valueX: CGFloat = 0.0
        var valueY: CGFloat = 0.0
        var valueRatio = 0.0
        
        let curRect = Rect()
        curRect.area = valueArea
        curRect.value = curValue
        curRect.father = curRect
        
        let calsulateValueSizeClosure = {
            if curWidth > curHeight {
                valueHeight = curHeight
                valueWidth = valueArea / valueHeight
            } else {
                valueWidth = curWidth
                valueHeight = valueArea / valueWidth
            }
        }
        let setRectFrameClosure = {
            curRect.frame = CGRect(x: valueX, y: valueY, width: valueWidth, height: valueHeight)
        }
        let calculateRatioClosure = {
            valueRatio = max(valueWidth/valueHeight, valueHeight/valueWidth)
        }
        
        calsulateValueSizeClosure()
        guard index > 0 else {
            setRectFrameClosure()
            rects.append(curRect)
            return
        }
        
        guard let lastRect = rects.last else { return }
        // 新建
        if ceil(lastRect.frame.maxX) == ceil(containerSize.width) {
            valueX = lastRect.father?.frame.origin.x ?? lastRect.frame.minX
            valueY = lastRect.frame.maxY
            // 向下新建
            curHeight -= lastRect.frame.maxY
            curWidth = containerSize.width - valueX
            
        } else {
            // 向右新建
            curWidth -= lastRect.frame.maxX
            curHeight = containerSize.height - (lastRect.father == lastRect ? lastRect.father?.frame.minY ?? 0.0 : 0.0)
            
            valueX = lastRect.father?.frame.maxX ?? lastRect.frame.maxX
            valueY = lastRect.father?.frame.origin.y ?? lastRect.frame.origin.y
        }
        
        calsulateValueSizeClosure()
        calculateRatioClosure()
        
        // 将同一区域的筛选出来
        let backRects = rects.filter { rect in
            return rect.father == lastRect.father //isHor ? rect.frame.minY == lastRect.frame.minY : rect.frame.minX == lastRect.frame.minX
        }
        
        let backWidthSum = backRects.reduce(0) { partialResult, rect in
            return partialResult + rect.frame.width
        }
        let backHeightSum = backRects.reduce(0) { partialResult, rect in
            return partialResult + rect.frame.height
        }
        
        // 水平插入还是垂直插入
        var isHor = lastRect.frame.width >= lastRect.frame.height
        if backRects.count > 1 {
            isHor = (backRects.first?.frame.origin.y ?? -1.0) == (backRects.last?.frame.origin.y ?? -2.0)
        }
        
        // 同一区域的权重和当前权重之和
        let backValueSum = backRects.reduce(0) { partialResult, rect in
            return partialResult + rect.value
        } + curValue
        
        // 计算同一区域Ratio
        let newWidth = isHor ? backWidthSum : lastRect.frame.width
        let newHeight = isHor ? lastRect.frame.height : backHeightSum
        
        var newValueHeight = curValue / backValueSum * newHeight
        var newValueWidth = curValue / backValueSum * newWidth
        
        if isHor {
            newValueHeight = valueArea / newValueWidth
        } else {
            newValueWidth = valueArea / newValueHeight
        }
        let newRatio = max(newValueWidth/newValueHeight, newValueHeight/newValueWidth)
        
        guard valueRatio >= newRatio else {
            setRectFrameClosure()
            rects.append(curRect)
            return
        }
        
        curRect.father = lastRect.father
        
        // 用新的排列
        var backX = 0.0
        var backY = 0.0
        var backWidth = 0.0
        var backHeight = 0.0
        // 更新同一区域的
        for (i, tmpRect) in backRects.enumerated() {
            
            if isHor {
                backY = lastRect.frame.origin.y
                if i > 0 {
                    backX = backRects[i-1].frame.maxX
                } else {
                    backX = tmpRect.frame.origin.x
                }
                backWidth = tmpRect.value / backValueSum * newWidth
                backHeight = tmpRect.area / backWidth
            } else {
                backX = lastRect.frame.origin.x
                if i > 0 {
                    backY = backRects[i-1].frame.maxY
                } else {
                    backY = tmpRect.frame.origin.y
                }
                backHeight = tmpRect.value / backValueSum * newHeight
                backWidth = tmpRect.area / backHeight
            }
            tmpRect.frame = CGRect(x: backX, y: backY, width: backWidth, height: backHeight)
        }
        
        if isHor {
            valueX = lastRect.frame.maxX
            valueY = lastRect.frame.origin.y
        } else {
            valueY = lastRect.frame.maxY
            valueX = lastRect.frame.origin.x
        }
        valueWidth = newValueWidth
        valueHeight = newValueHeight
        setRectFrameClosure()
        rects.append(curRect)
    }

}

public extension XKSquarifiedMap {
    
    static func fetchRects(values: [Double], containerSize: CGSize) -> [CGRect] {
        
        let map = XKSquarifiedMap()
        map.rects.removeAll()
        let values = values.sorted { value1, value2 in
            return value1 >= value2
        }
        map.values = values
        map.containerSize = containerSize
        let total = values.reduce(into: 0, +=)
        for (i, _) in values.enumerated() {
            map.createRect(index: i, total: total, area: containerSize.width * containerSize.height)
        }
        return map.rects.map { rect -> CGRect in
            return rect.frame
        }
    }
}
