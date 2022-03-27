//
//  Extension+Array.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 1/9/22.
//

import Foundation

extension Array {
    func chunks(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
