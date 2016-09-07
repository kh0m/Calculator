//
//  GraphView.swift
//  Calculator
//
//  Created by Hom, Kenneth on 9/7/16.
//  Copyright © 2016 Hom, Kenneth. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {
    let axesDrawer = AxesDrawer()
    
    @IBInspectable
    var origin: CGPoint = CGPoint(x: 0.0,y: 0.0) {
        didSet {setNeedsDisplay()}
    }
    
    @IBInspectable
    var scale: CGFloat = 1.0 {didSet {setNeedsDisplay()}}
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        axesDrawer.drawAxesInRect(self.bounds, origin: origin, pointsPerUnit: 50*scale)
    }
 
    func changeScale(recognizer: UIPinchGestureRecognizer){
        switch recognizer.state {
        case .Changed, .Ended:
            scale *= recognizer.scale
            recognizer.scale = 1.0
        default: break
        }
    }
    
    func moveOrigin(recognizer: UIPanGestureRecognizer){
        switch recognizer.state {
        case .Changed, .Ended:
            let translation = recognizer.translationInView(self)
            origin = CGPoint(x: origin.x+translation.x, y: origin.y+translation.y)
            recognizer.setTranslation(CGPointZero, inView: self)
        default: break
        }
    }
}
