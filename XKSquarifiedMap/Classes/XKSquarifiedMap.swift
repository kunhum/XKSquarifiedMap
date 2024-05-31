//
//  Created by kenneth on 2022/6/16.
//

import UIKit
import SwifterSwift

public class XKSquarifiedMap: NSObject {
    
    public var values: [Double] = []
    fileprivate var containerSize: CGSize = .zero
    fileprivate var rects: [Rect] = []
    
    class Rect: Equatable {
        var area: Double = 0.0
        var frame: CGRect = .zero
        var value: Double = 0.0
        var isHor: Bool = false
        
        static func == (lhs: XKSquarifiedMap.Rect, rhs: XKSquarifiedMap.Rect) -> Bool {
            return lhs.area == rhs.area && lhs.frame == rhs.frame && lhs.value == rhs.value
        }
    }
    
    func createRects() {
        
        rects.removeAll()
        /// 同一空间内的Rect
        var zoomRects: [Rect] = []
        
        let viewArea = containerSize.width * containerSize.height
        
        let sum = values.sum()
        
        // 靠短边摆放
        var drawWidth = containerSize.width
        var drawHeight = containerSize.height
        
        var valueWidth = drawWidth
        var valueHeight = drawHeight
        
        var zoomWidth = drawWidth
        var zoomHeight = drawHeight
        
        var isHorDraw = containerSize.width > containerSize.height
        
        let updateDirectionClosure = {
            isHorDraw = drawWidth > drawHeight
        }
        
        for (i, value) in values.enumerated() {
                        
            let valueArea = value / sum * viewArea
            
            let newRect = Rect()
            newRect.area = valueArea
            newRect.value = value
            
            // --- 新增情况计算
            if isHorDraw {
                valueHeight = drawHeight
                valueWidth = valueArea / valueHeight
            } else {
                valueWidth = drawWidth
                valueHeight = valueArea / valueWidth
            }
            
            guard i > 0 else {
                newRect.frame = CGRect(x: 0, y: 0, width: valueWidth, height: valueHeight)
                if isHorDraw {
                    drawWidth = containerSize.width - valueWidth
                } else {
                    drawHeight = containerSize.height - valueHeight
                }
                newRect.isHor = valueWidth > valueHeight
                rects.append(newRect)
                zoomRects.append(newRect)
                updateDirectionClosure()
                continue
            }
            
            // --- 插入的情况计算
            let isHorInsert: Bool = zoomRects.last?.isHor ?? false
            
            let zoomArea = zoomRects.map { $0.area }.sum() + valueArea
            var zoomTotalHeight = 0.0
            var zoomTotalWidth = 0.0
            
            if isHorInsert {
                zoomTotalWidth = zoomRects.map({ $0.frame.width }).sum()
                zoomTotalHeight = zoomArea / zoomTotalWidth
                zoomHeight = zoomTotalHeight
                zoomWidth = valueArea / zoomHeight
                
            } else {
                zoomTotalHeight = zoomRects.map({ $0.frame.height }).sum()
                zoomTotalWidth = zoomArea / zoomTotalHeight
                zoomWidth = zoomTotalWidth
                zoomHeight = valueArea / zoomWidth
            }
            
            // 计算同一空间内的ratio
            let zoomRatio = max(zoomWidth/zoomHeight, zoomHeight/zoomWidth)
            // 计算新增ratio
            let valueRatio = max(valueWidth/valueHeight, valueHeight/valueWidth)
                        
            // 是否应该插入
            let shouldInsert = zoomRatio < valueRatio
            
            guard shouldInsert else {
                // 新增
                
                newRect.frame = CGRect(x: containerSize.width - drawWidth, y: containerSize.height - drawHeight, width: valueWidth, height: valueHeight)
                newRect.isHor = valueWidth > valueHeight
                rects.append(newRect)
                zoomRects.removeAll()
                zoomRects.append(newRect)
                
                if isHorDraw {
                    drawWidth = containerSize.width - newRect.frame.maxX
                } else {
                    drawHeight = containerSize.height - newRect.frame.maxY
                }
                
                updateDirectionClosure()
                
                continue
            }
            
            zoomRects.append(newRect)
            
            var updateX = 0.0
            var updateY = 0.0
            var updateWidth = 0.0
            var updateHeight = 0.0
            
            // 更新同一空间内的坐标
            for (i, rect) in zoomRects.enumerated() {
                                
                let lastRect = zoomRects[safe: i-1]
                
                if isHorInsert {
                    updateHeight = zoomTotalHeight
                    updateWidth = rect.area / updateHeight
                } else {
                    updateWidth = zoomTotalWidth
                    updateHeight = rect.area / updateWidth
                }
                
                if i == 0 {
                    updateX = rect.frame.origin.x
                    updateY = rect.frame.origin.y
                } else {
                    updateX = isHorInsert ? (lastRect?.frame.maxX ?? 0.0) : (lastRect?.frame.minX ?? 0.0)
                    updateY = isHorInsert ? (lastRect?.frame.minY ?? 0.0) : (lastRect?.frame.maxY ?? 0.0)
                }
                
                rect.frame = CGRect(x: updateX, y: updateY, width: updateWidth, height: updateHeight)
            }
            
            newRect.isHor = zoomRects.first?.isHor ?? false
            
            if isHorInsert {
                drawHeight = containerSize.height - (zoomRects.last?.frame.maxY ?? 0.0)
            } else {
                drawWidth = containerSize.width - (zoomRects.last?.frame.maxX ?? 0.0)
            }
            updateDirectionClosure()
            rects.append(newRect)
            
        }
        
    }
    
}

public extension XKSquarifiedMap {
    
    static func fetchRects(values: [Double], containerSize: CGSize) -> [CGRect] {
        let map = XKSquarifiedMap()
        let values = values.sorted(by: { $0 > $1 })
        let size = containerSize
        map.values = values
        map.containerSize = size
        map.createRects()
        return map.rects.map { $0.frame }
    }
}
