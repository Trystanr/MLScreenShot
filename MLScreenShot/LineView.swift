//
//  LineView.swift
//  MLScreenShot
//
//  Created by Trystan Rivers on 2020/11/03.
//  Copyright © 2020 Trystan Rivers. All rights reserved.
//

import Cocoa
import Foundation
import CoreGraphics

class Line: NSView {
    var myClassVar: Int!
    var arrFaces: [NSRect]! = []
    
    override init(frame frameRect: NSRect) {
        super.init(frame:frameRect);
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    init(frame frameRect: NSRect, otherInfo:Int) {
        super.init(frame:frameRect);
    }
    
    func setVar(i: Int) {
        self.myClassVar  = i
    }
    
    func addFace(n: CGRect) {
        self.arrFaces.append(n)
    }

    override func draw(_ dirtyRect: NSRect) {
        let myPath = NSBezierPath()
        
        let clearPath = NSBezierPath()
        NSColor.red.setStroke()
        
        clearPath.move(to: NSPoint(x: 0, y: 0))
        clearPath.line(to: NSPoint(x: 0, y: self.frame.height))
        clearPath.line(to: NSPoint(x: self.frame.width, y: self.frame.height))
        clearPath.line(to: NSPoint(x: self.frame.width, y: 0))
        clearPath.line(to: NSPoint(x: 0, y: 0))
        
        for face in arrFaces {
            myPath.move(to: CGPoint(x: face.origin.x, y: face.origin.y))
            myPath.line(to: CGPoint(x: face.origin.x, y: face.origin.y + face.height))
            myPath.line(to: CGPoint(x: face.origin.x + face.width, y: face.origin.y + face.height))
            myPath.line(to: CGPoint(x: face.origin.x + face.width, y: face.origin.y))
            myPath.line(to: CGPoint(x: face.origin.x, y: face.origin.y))
            myPath.stroke()
        }
    }
}
