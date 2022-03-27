//
//  Extension+View.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 8/11/21.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder
    func hidden(_ isHidden: Bool) -> some View {
        if isHidden {
            EmptyView()
        } else {
            self
        }
    }
}
