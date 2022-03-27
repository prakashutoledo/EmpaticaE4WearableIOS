//
//  Extension+Path.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 8/13/21.
//
import SwiftUI

extension Path {
    init(_ startX: Int = 0, _ startY: Int = 0, maxWidth:Int, maxHeight: Int) {
        self.init()
        self.defaultSlider(x:startX, y:startY, maxWidth: maxWidth, maxHeight: maxHeight)
    }
    
    private mutating func defaultSlider(x: Int, y:Int, maxWidth: Int, maxHeight: Int) -> Void {
        self.move(to: CGPoint(x: x, y: y));
        self.addLine(to: CGPoint(x: maxWidth, y:y));
        for abscissa in stride(from: x, through: maxWidth, by: 25) {
            self.move(to: CGPoint(x: abscissa, y: y));
            self.addLine(to: CGPoint(x:abscissa, y: maxWidth / 2 == abscissa ? y - (2 * maxHeight): y - maxHeight));
        }
    }
}
