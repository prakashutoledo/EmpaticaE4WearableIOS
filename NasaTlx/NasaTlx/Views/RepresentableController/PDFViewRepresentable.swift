//
//  PDFViewRepresentable.swift
//  MentalDemandDataCollector
//
//  Created by Prakash Khadka on 1/8/21.
//  Copyright © 2021 Prakash Khadka. All rights reserved.
//

import Foundation
import SwiftUI
import WebKit

struct PDFViewRepresentable : UIViewControllerRepresentable {
    let urlString: String
    
    func makeUIViewController(context: Context) -> WebViewController {
        return WebViewController(urlString: urlString)
    }
    
    func updateUIViewController(_ uiViewController: WebViewController, context: Context) {
    }
}

final class WebViewController : UIViewController {
    let urlString: String
    private var wkWebView = WKWebView()
    
    init(urlString: String) {
        self.urlString = urlString
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let request = URLRequest(url: URL(string: urlString)!)
        self.view.addSubview(wkWebView)
        wkWebView.frame = self.view.frame
        let rightTap = UITapGestureRecognizer(target: self, action: #selector(self.tapped(_:)))
        wkWebView.addGestureRecognizer(rightTap)
        wkWebView.isUserInteractionEnabled = true
        wkWebView.load(request)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func tapped(_ sender: UITapGestureRecognizer) {
        print("Tapped \(sender.location(in: wkWebView))")
    }
}
