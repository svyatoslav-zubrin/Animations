//
//  SZUFluidPageAnimationView.swift
//  SZUAnimations
//
//  Created by Slava Zubrin on 10/31/16.
//  Copyright © 2016 Slava Zubrin. All rights reserved.
//

import UIKit

protocol IFluidPageAnimation {
    func set(progress: CGFloat)
}

struct Circle {
    let center: CGPoint
    let radius: CGFloat

    enum Position {
        case Left, Right
    }
    
    func rect() -> CGRect {
        return CGRect(x: center.x - radius,
                      y: center.y - radius,
                      width: 2.0 * radius,
                      height: 2.0 * radius)
    }
}

// MARK: - Animation view -

class SZUFluidPageAnimationView: UIView {
    
    enum SpurType {
        case Linear, Quadratic
    }
    
    private var _spurType: SpurType = .Linear
    var spurType: SpurType {
        get {
            return _spurType
        }
        set {
            guard _spurType != newValue else {
                return
            }
            _spurType = newValue
            state = nil // update state for new spur type
            set(progress: progress) // will redraw the view
        }
    }
    
    fileprivate var progress: CGFloat = 0.0
    fileprivate var state: SZUAnimationStateProtocol!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        set(progress: progress)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        set(progress: progress)
    }
    
    override func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.beginPath()
        if let context = context {
            state.path(progress: progress, context: context)
        }
        context?.drawPath(using: CGPathDrawingMode.fillStroke)
    }
    
}

extension SZUFluidPageAnimationView: IFluidPageAnimation {
    
    func set(progress: CGFloat) {
        
        guard (progress >= 0) && (progress <= 1) else {
            print("ERROR: Incorrect progress value")
            return
        }
        
        if self.progress != progress || state == nil {
            self.progress = progress
            if self.progress >= 0 && self.progress <= 0.33 {
                state = SZUFirstQuarterAnimationState(provider: self, spurType: spurType);
            } else if self.progress > 0.33 && self.progress <= 0.66 {
                state = SZUSecondQuarterAnimationState(provider: self, spurType: spurType);
            } else if self.progress > 0.66 && self.progress <= 1.0 {
                state = SZUThirdQuarterAnimationState(provider: self, spurType: spurType);
            }

            setNeedsDisplay()
        }
    }
}

extension SZUFluidPageAnimationView: SZUAnimationStateDataProvider {
    func maxRadius(circlePosition: Circle.Position) -> CGFloat {
        return bounds.size.height / 4
    }
    
    func circleCenter(position: Circle.Position) -> CGPoint {
        let unit = bounds.size.width / 4
        switch position {
        case .Left:
            return CGPoint(x: unit, y: bounds.size.height / 2)
        case .Right:
            return CGPoint(x: bounds.size.width - unit, y: bounds.size.height / 2)
        }
    }
    
    fileprivate func minProgress(state: SZUAnimationStateProtocol) -> CGFloat {
        if let _ = state as? SZUFirstQuarterAnimationState {
            return 0.0
        } else if let _ = state as? SZUSecondQuarterAnimationState {
            return 0.33
        } else {
            return 0.66
        }
    }
    
    fileprivate func maxProgress(state: SZUAnimationStateProtocol) -> CGFloat {
        if let _ = state as? SZUFirstQuarterAnimationState {
            return 0.33
        } else if let _ = state as? SZUSecondQuarterAnimationState {
            return 0.66
        } else {
            return 1.0
        }
    }
}

// MARK: - Animation states -

fileprivate protocol SZUAnimationStateDataProvider {
    func maxRadius(circlePosition: Circle.Position) -> CGFloat
    func circleCenter(position: Circle.Position) -> CGPoint
    func minProgress(state: SZUAnimationStateProtocol) -> CGFloat
    func maxProgress(state: SZUAnimationStateProtocol) -> CGFloat
}

fileprivate protocol SZUAnimationStateProtocol  {
    func path(progress: CGFloat, context: CGContext)
}

fileprivate class SZUBaseAnimationState: SZUAnimationStateProtocol {
    var provider: SZUAnimationStateDataProvider!
    var spurGenerator: ISpurGenerator = LinearSpurGenerator()

    var internalProgress: CGFloat = 0 // 0..1, specific for the particular anumation state
    var lCircle = Circle(center: CGPoint.zero, radius: 0.0)
    var rCircle = Circle(center: CGPoint.zero, radius: 0.0)
    
    init(provider: SZUAnimationStateDataProvider, spurType: SZUFluidPageAnimationView.SpurType) {
        self.provider = provider
        if spurType == .Quadratic {
            self.spurGenerator = QuadraticSpurGenerator()
        }
    }
    
    func calcInternalProgress(externalProgress: CGFloat) {
        let maxExternalProgress = provider.maxProgress(state: self)
        let minExternalProgress = provider.minProgress(state: self)
        internalProgress = (externalProgress - minExternalProgress) / (maxExternalProgress - minExternalProgress)
    }
    
    // MARK: SZUAnimationStateProtocol

    internal func path(progress: CGFloat, context: CGContext) {
        // TODO: throw error, should be overriden by ancestors
    }
}

fileprivate class SZUFirstQuarterAnimationState: SZUBaseAnimationState {
    internal override func path(progress: CGFloat, context: CGContext) {
        context.setLineWidth(3.0)
        context.setStrokeColor(UIColor.red.cgColor)
        context.setFillColor(UIColor.red.cgColor)
        
        calcInternalProgress(externalProgress: progress)
        setupCircles()
        
        context.addEllipse(in: lCircle.rect())
//        context.addEllipse(in: CGRect(x: xmin, y: lCircle.center.y, width: 5, height: 5))
        
        let borders = (lBorder: CGPoint(x: lCircle.center.x, y:lCircle.radius),
                       rBorder: CGPoint(x: rCircle.center.x, y:rCircle.radius))
        let spurPoints = spurGenerator.spurPoints(borders: borders, minimaX: xmin, baseY: 0)
        if spurPoints.count > 1 {
            let spurPoints = spurPoints.map { CGPoint(x: $0.x, y: $0.y + lCircle.center.y) }
            context.move(to: spurPoints[0])
            for point in spurPoints {
                context.addLine(to: point)
            }
        }
    }
    
    private func setupCircles() {
        let initCircleRadius = provider.maxRadius(circlePosition: .Left)
        let finlCircleRadius = provider.maxRadius(circlePosition: .Left) / 2.0
        let delta = finlCircleRadius - initCircleRadius
        
        lCircle = Circle(center: provider.circleCenter(position: .Left),
                         radius: initCircleRadius + delta * internalProgress)
        rCircle = Circle(center: provider.circleCenter(position: .Right),
                         radius: 0) // no right circle at this state
    }

    var xmin: CGFloat {
        let min = lCircle.rect().size.width + lCircle.rect().origin.x
        let max = rCircle.rect().origin.x
        return min + (max - min) * internalProgress
    }
}

fileprivate class SZUSecondQuarterAnimationState: SZUBaseAnimationState {
    internal override func path(progress: CGFloat, context: CGContext) {
        context.setLineWidth(3.0)
        context.setStrokeColor(UIColor.red.cgColor)
        context.setFillColor(UIColor.red.cgColor)
        
        calcInternalProgress(externalProgress: progress)
        setupCircles()
        
        context.addEllipse(in: lCircle.rect())
        context.addEllipse(in: rCircle.rect())
//        context.addEllipse(in: CGRect(x: xmin, y: lCircle.center.y, width: 5, height: 5))
        
        let borders = (lBorder: CGPoint(x: lCircle.center.x, y:lCircle.radius),
                       rBorder: CGPoint(x: rCircle.center.x, y:rCircle.radius))
        let spurPoints = spurGenerator.spurPoints(borders: borders, minimaX: xmin, baseY: 0)
        if spurPoints.count > 1 {
            let spurPoints = spurPoints.map { CGPoint(x: $0.x, y: $0.y + lCircle.center.y) }
            context.move(to: spurPoints[0])
            for point in spurPoints {
                context.addLine(to: point)
            }
        }
    }
    
    private func setupCircles() {
        let initCircleRadius = provider.maxRadius(circlePosition: .Left) / 2.0
        let finlCircleRadius = CGFloat(0.0)
        let delta = finlCircleRadius - initCircleRadius

        lCircle = Circle(center: provider.circleCenter(position: .Left),
                         radius: initCircleRadius + delta * internalProgress)
        rCircle = Circle(center: provider.circleCenter(position: .Right),
                         radius: finlCircleRadius - delta * internalProgress)
    }
    
    var xmin: CGFloat {
        let min = lCircle.rect().size.width + lCircle.rect().origin.x
        let max = rCircle.rect().origin.x
        return min + (max - min) * (1 - internalProgress)
    }
}

fileprivate class SZUThirdQuarterAnimationState: SZUBaseAnimationState {
    internal override func path(progress: CGFloat, context: CGContext) {
        context.setLineWidth(3.0)
        context.setStrokeColor(UIColor.red.cgColor)
        context.setFillColor(UIColor.red.cgColor)
        
        calcInternalProgress(externalProgress: progress)
        setupCircles()
        
        context.addEllipse(in: rCircle.rect())
//        context.addEllipse(in: CGRect(x: xmin, y: lCircle.center.y, width: 5, height: 5))
        
        let borders = (lBorder: CGPoint(x: lCircle.center.x, y:lCircle.radius),
                       rBorder: CGPoint(x: rCircle.center.x, y:rCircle.radius))
        let spurPoints = spurGenerator.spurPoints(borders: borders, minimaX: xmin, baseY: 0)
        if spurPoints.count > 1 {
            let spurPoints = spurPoints.map { CGPoint(x: $0.x, y: $0.y + lCircle.center.y) }
            context.move(to: spurPoints[0])
            for point in spurPoints {
                context.addLine(to: point)
            }
        }
    }
    
    private func setupCircles() {
        let initCircleRadius = provider.maxRadius(circlePosition: .Right) / 2.0
        let finlCircleRadius = provider.maxRadius(circlePosition: .Right)
        let delta = finlCircleRadius - initCircleRadius
        
        lCircle = Circle(center: provider.circleCenter(position: .Left),
                         radius: 0)
        rCircle = Circle(center: provider.circleCenter(position: .Right),
                         radius: initCircleRadius + delta * internalProgress)
    }
    
    var xmin: CGFloat {
        let min = lCircle.rect().size.width + lCircle.rect().origin.x
        let max = rCircle.rect().origin.x
        return min + (max - min) * internalProgress
    }
}

// MARK: - Spur generators -

typealias SpurBorders = (lBorder: CGPoint, rBorder: CGPoint)

protocol ISpurGenerator {
    func spurPoints(borders: SpurBorders, minimaX: CGFloat, baseY: CGFloat) -> Array<CGPoint>
}

class LinearSpurGenerator: ISpurGenerator {
    func spurPoints(borders: SpurBorders, minimaX: CGFloat, baseY: CGFloat = 0) -> Array<CGPoint> {
        var retval: Array<CGPoint> = []
        
        if borders.lBorder.y != 0 {
            retval.append(borders.lBorder)
        }
        
        retval.append(CGPoint(x: minimaX, y: baseY))
        
        if borders.rBorder.y != 0 {
            let rBorder = borders.rBorder
            retval.append(rBorder)
            retval.append(CGPoint(x: rBorder.x, y: -rBorder.y))
            retval.append(CGPoint(x: minimaX, y: -baseY))
        }
        
        if borders.lBorder.y != 0 {
            let lBorder = borders.lBorder
            retval.append(CGPoint(x: lBorder.x, y: -lBorder.y))
            retval.append(lBorder)
        }
        
        return retval
    }
}

class QuadraticSpurGenerator: ISpurGenerator {
    func spurPoints(borders: SpurBorders, minimaX: CGFloat, baseY: CGFloat) -> Array<CGPoint> {
        // TODO: implementation needed
        return []
    }
}

















