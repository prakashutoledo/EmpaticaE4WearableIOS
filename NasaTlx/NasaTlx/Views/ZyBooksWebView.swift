//
//  ZyBooksWebView.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 1/22/22.
//

import SwiftUI

class StringPair : Pair<String, String> {
    
}

struct ZyBooksWebView : View {
    private static let zyBooksUrl = "https://learn.zybooks.com/zybook/"
    
    @State
    private var currentTab = 0
    
    @State
    private var firstTabOpacity: Double = 1.0
    
    @State
    private var secondTabOpacity: Double = 1.0
    
    let tabs: [StringPair]
    
    public init(tabs: [StringPair]) {
        self.tabs = tabs
    }
    
    var body: some View {
        GeometryReader { geometry in
            let frame = geometry.frame(in: .local);
            let width = geometry.size.width
        
            if tabs.count > 0 {
                if tabs.count == 2 {
                    if let secondTab = tabs.last {
                        SafariWebView(urlString: "\(ZyBooksWebView.zyBooksUrl)\(secondTab.x)")
                            .offset(x: frame.minX, y: frame.minY)
                            .opacity(self.secondTabOpacity)
                    }
                }

                
                if let firstTab = tabs.first {
                    SafariWebView(urlString: "\(ZyBooksWebView.zyBooksUrl)\(firstTab.x)")
                        .offset(x: frame.minX, y: frame.minY)
                        .opacity(self.firstTabOpacity)
                }
            }

            self.rectangle(cornerRadius: 0.0, width: width)
                .offset(x: frame.minX + 220, y: frame.minY)
            
            if tabs.count > 0 {
                Picker(selection: self.$currentTab, label: Text("")) {
                    if let firstTab = tabs.first {
                        Text(firstTab.y).tag(0)
                    }
                    
                    if tabs.count == 2 {
                        if let secondTab = tabs.last {
                            Text(secondTab.y).tag(1)
                        }
                    }
                }
                .gesture(DragGesture(minimumDistance: 0).onEnded(self.onPickerDragAction))
                .pickerStyle(SegmentedPickerStyle())
                .offset(x: frame.minX + 220, y: frame.minY + 3)
                .frame(width: 400, height: 35.0, alignment: .center)
            }
        }.navigationBarHidden(true)
    }
    
    private func onPickerDragAction(value: DragGesture.Value) -> Void {
        if tabs.count != 2 {
            return
        }

        if value.location.x > 200 {
            self.currentTab = 1
            self.secondTabOpacity = 1.0
            self.firstTabOpacity = 0.0
            
        }
        else {
            self.currentTab = 0
            self.secondTabOpacity = 0.0
            self.firstTabOpacity = 1.0
        }
    }
    
    private func rectangle(cornerRadius: Double, width: Double = 50) -> some View {
        return Rectangle()
            .frame(
                width: width,
                height: 43,
                alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/
            )
            .foregroundColor(Color(UIColor(
                red: 247/255,
                green: 247/255,
                blue: 247/255,
                alpha: 1
            )))
            .cornerRadius(cornerRadius)
    }
}
