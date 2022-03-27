//
//  PDFView.swift
//  MentalDemandDataCollector
//
//  Created by Prakash Khadka on 1/8/21.
//  Copyright © 2021 Prakash Khadka. All rights reserved.
//

import Foundation
import SwiftUI

struct PDFView: View {
    var urlString: String
    
    var body: some View {
        PDFViewRepresentable(urlString: urlString)
    }
}
