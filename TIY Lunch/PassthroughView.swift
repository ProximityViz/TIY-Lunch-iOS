//
//  PassthroughView.swift
//  TIY Lunch
//
//  Created by Mollie on 2/11/15.
//  Copyright (c) 2015 Proximity Viz LLC. All rights reserved.
//

import UIKit

class PassthroughView: UIView {

    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        for subview in subviews as [UIView] {
            if !subview.hidden && subview.alpha > 0 && subview.userInteractionEnabled && subview.pointInside(convertPoint(point, toView: subview), withEvent: event) {
                return true
            }
        }
        return false
    }

}
