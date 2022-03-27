//
//  SafariWebViewRepresentable.swift
//  MentalDemandDataCollector
//
//  Created by Prakash Khadka on 1/8/21.
//  Copyright © 2021 Prakash Khadka. All rights reserved.
//

import Foundation
import SafariServices
import SwiftUI
import UIKit

struct SafariWebViewRepresentable: UIViewControllerRepresentable {
    let bindingMode: Binding<PresentationMode>
    let urlString: String
    
    func makeUIViewController(context: Context) -> CancellableSafariWebViewController {
        return CancellableSafariWebViewController(bindingMode: bindingMode, urlString: urlString)
    }
    
    func updateUIViewController(_ uiViewController: CancellableSafariWebViewController, context: Context) {
    }
}

final class CancellableSafariWebViewController : UIViewController, SFSafariViewControllerDelegate, UIViewControllerTransitioningDelegate {
    private var bindingMode: Binding<PresentationMode>?
    private var urlString: String
    
    init(bindingMode: Binding<PresentationMode>, urlString: String) {
        self.bindingMode = bindingMode
        self.urlString = urlString
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let configuration = SFSafariViewController.Configuration()
        configuration.barCollapsingEnabled = false
        configuration.entersReaderIfAvailable = false
        let safariController = SFSafariViewController(url : URL(string: self.urlString)!, configuration: configuration)
        self.addChild(safariController)
        safariController.view.frame = self.view.frame
        self.view.addSubview(safariController.view)
        self.view.translatesAutoresizingMaskIntoConstraints = false
        safariController.delegate = self
    }
    
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true)
        self.dismiss(animated: true)
        bindingMode?.wrappedValue.dismiss()
    }
}

class TestController: SFSafariViewController {
    var getCurrentView: UIView {
        let uiView = UIView()
        self.view.addSubview(uiView)
        return view
    }
    
    @objc
    func myviewTapped(_ sender: UITapGestureRecognizer) {
        print("Tapped ")
    }
}
