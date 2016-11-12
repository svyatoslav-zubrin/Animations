//
//  SZUFluidPageIndicatorView.swift
//  SZUAnimations
//
//  Created by Slava Zubrin on 11/12/16.
//  Copyright © 2016 Slava Zubrin. All rights reserved.
//

import UIKit

@IBDesignable
class SZUFluidPageIndicatorView: UIView {
    
    let spurLayer: CAShapeLayer = CAShapeLayer()
    
    // dots for pages
    @IBInspectable var dotsNumber: Int = 5
    @IBInspectable var dotSize: CGFloat = 10.0
    @IBInspectable var dotDistance: CGFloat = 20.0
    @IBInspectable var dotColor: UIColor = .red
    
    // actual page mark
    @IBInspectable var markColor: UIColor = .green
    @IBInspectable var markSize: CGFloat = 14.0

    var markPosition: Int = 0
    private var markAnimatedPosition: CGFloat = 0.0

    fileprivate var rectToDrawIn: CGRect = .zero

    private func setup() {
        spurLayer.frame = self.frame
        self.layer.addSublayer(spurLayer)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func draw(_ rect: CGRect) {
        rectToDrawIn = rect
        
        let context = UIGraphicsGetCurrentContext()
        if context != nil {
//            context?.beginPath()
//            drawMark(context!)
//            context?.drawPath(using: CGPathDrawingMode.fillStroke)

            context?.beginPath()
            drawCircles(context!)
            context?.drawPath(using: CGPathDrawingMode.fillStroke)
        }
    }
    
    // MARK: User actions
    
    @IBAction func onLeft(sender: UIButton) {
        moveMarkLeft()
         
    }

    @IBAction func onRight(sender: UIButton) {
        moveMarkRight()
    }
}

// MARK: - Drawing

fileprivate extension SZUFluidPageIndicatorView {
    func drawCircles(_ context: CGContext) {
        guard dotsNumber > 0 else {
            return
        }
        
        context.setLineWidth(0.0)
        context.setStrokeColor(dotColor.cgColor)
        context.setFillColor(dotColor.cgColor)
        
        let marginH = (rectToDrawIn.size.width - calcDotsSize().width) / 2.0
        let marginV = (rectToDrawIn.size.height - calcDotsSize().height) / 2.0
        
        for i in 0..<dotsNumber {
            let rect = CGRect(x: marginH + CGFloat(i) * (dotSize + dotDistance),
                              y: marginV,
                              width: dotSize,
                              height: dotSize)
            context.addEllipse(in: rect)
        }
    }
    
    func drawMark(_ context: CGContext) {
        context.setLineWidth(0.0)
        context.setStrokeColor(markColor.cgColor)
        context.setFillColor(markColor.cgColor)

        let marginH = (rectToDrawIn.size.width - calcDotsSize().width) / 2.0
        let marginV = (rectToDrawIn.size.height - calcDotsSize().height) / 2.0
        let shift = (markSize - dotSize) / 2.0
        let rect = CGRect(x: marginH + CGFloat(markPosition) * (dotSize + dotDistance) - shift,
                          y: marginV - shift,
                          width: markSize,
                          height: markSize)
        context.addEllipse(in: rect)
    }
}

// MARK: - Mark animations

fileprivate extension SZUFluidPageIndicatorView {
    func moveMarkLeft() {
        
    }
    
    func moveMarkRight() {
        
    }
}

// MARK: - Geometry helpers

fileprivate extension SZUFluidPageIndicatorView {
    func calcDotsSize() -> CGSize {
        var width: CGFloat = 0.0
        if dotsNumber > 0 {
            width += CGFloat(dotsNumber) * (dotSize + dotDistance) - dotDistance;
        }
        return CGSize(width:width, height: dotSize)
    }
}
