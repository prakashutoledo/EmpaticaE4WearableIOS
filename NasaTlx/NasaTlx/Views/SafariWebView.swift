//
//  SafariView.swift
//  MentalDemandDataCollector
//
//  Created by Prakash Khadka on 1/8/21.
//  Copyright © 2021 Prakash Khadka. All rights reserved.
//

import Foundation
import SwiftUI

struct SafariWebView : View {
    @Environment(\.presentationMode)
    private var bindingMode: Binding<PresentationMode>

    var urlString: String
    
    var body: some View {
        SafariWebViewRepresentable(bindingMode: bindingMode, urlString: urlString)
    }
}
