//
//  CustomAlert.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 1/8/22.
//
import SwiftUI

struct CustomAlert: View {
    @Environment(\.colorScheme)
    private var colorScheme
    
    @State
    var isInformationAlert: Bool = false
    
    let title: String
    
    let bodyText: String
    
    let okAction: () -> Void;
    
    let cancelAction: () -> Void;
    
    var body: some View {
        VStack(spacing : 0) {
            VStack {
                Group {
                    Text("\(title)")
                        .bold()
                        .font(.title)
                        .frame(height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .padding(.top, 2)
                    Text(bodyText)
                        .font(.system(size: 15))
                        .multilineTextAlignment(.center)
                    Spacer()
                    Divider()
                }
            }.background(Color.orange)

            HStack {
                if !self.isInformationAlert {
                    self.cancelButton()
                    Divider()
                        .frame(height: 40)
                        .background(Color.black)
                }
                self.continueButton()
            }.background(Color.gray)
        }
        .frame(width: 300, height: 170, alignment: .center)
        .cornerRadius(12.0)
        .clipped()
    }
    
    public func cancelButton() -> some View {
        return Button(action: self.cancelAction) {
            Text("Cancel").bold()
        }
        .background(Color.white.cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/))
        .foregroundColor(.blue)
        .padding(.leading, 20)
        .frame(width: 142, height: 40, alignment: .leading)
    }
    
    public func continueButton() -> AnyView {
        let continueButton = Button(action: self.okAction) {
            Text("Continue")
        }
        .background(Color.white.cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/))
        .foregroundColor(.red)
        
        if self.isInformationAlert {
            return AnyView(continueButton
                .frame(width: 300, height: 40, alignment: .center))
        }
        return AnyView(continueButton.padding(.trailing, 20)
            .frame(width: 142, height: 40, alignment: .trailing))
    }
}

extension View {
    @ViewBuilder
    public func customInformationAlert(
        isPresented: Binding<Bool>,
        title: String,
        bodyText: String,
        okAction: @escaping () -> Void = {}
    ) -> some View {
        
        let newOkAction = {
            isPresented.wrappedValue.toggle()
            okAction()
        }
        
        GeometryReader { geometry in
            let frame = geometry.frame(in: .local)
            self.blur(
                radius: isPresented.wrappedValue ? 3.0 : 0.0,
                opaque: !isPresented.wrappedValue
            )
            .disabled(isPresented.wrappedValue)
            
            if isPresented.wrappedValue {
                Rectangle()
                    .opacity(0.1)
                    .frame(width: frame.maxX, height: frame.maxY)
                    .offset(x: frame.minX, y: frame.minY)
                
                CustomAlert(
                    isInformationAlert: true,
                    title: title,
                    bodyText: bodyText,
                    okAction: newOkAction,
                    cancelAction: {}
                )
                .offset(x: frame.midX - (300) / 2, y: frame.midY - 100)
            }
        }
    }
    
    @ViewBuilder
    public func customAlert(
        isPresented: Binding<Bool>,
        title: String,
        bodyText: String,
        okAction: @escaping () -> Void = {},
        cancelAction:  @escaping () -> Void = {}
    ) -> some View {
        
        let newOkAction = {
            isPresented.wrappedValue.toggle()
            okAction()
        }
        
        let newCancelAction = {
            isPresented.wrappedValue.toggle()
            cancelAction()
        }
        
        GeometryReader { geometry in
            let frame = geometry.frame(in: .local)
            
            self.blur(
                radius: isPresented.wrappedValue ? 3.0 : 0.0,
                opaque: !isPresented.wrappedValue
            )
            .disabled(isPresented.wrappedValue)
            
            if isPresented.wrappedValue {
                Rectangle()
                    .opacity(0.1)
                    .frame(width: frame.maxX, height: frame.maxY)
                    .offset(x: frame.minX, y: frame.minY)
                
                CustomAlert(
                    title: title,
                    bodyText: bodyText,
                    okAction: newOkAction,
                    cancelAction: newCancelAction
                )
                .offset(x: frame.midX - (300) / 2, y: frame.midY - 100)
            }
        }
    }
}
