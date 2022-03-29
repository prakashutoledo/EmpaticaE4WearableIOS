//
//  NavigationView.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 1/27/22.
//
import SwiftUI
import Foundation

public class ViewTitleMapper: Triple<AnyView, String, ViewType> {

}

struct MainNavigationView : View {
    static let buttonWidth: CGFloat = 70
    static let buttonHeight: CGFloat = 40
    
    @Environment(\.presentationMode)
    private var mode: Binding<PresentationMode>
    
    @EnvironmentObject
    private var assesmentRating: AssesmentRating
    
    @EnvironmentObject
    private var empaticaE4Service: EmpaticaE4Service
    
    @EnvironmentObject
    private var webSocketService: WebSocketService
    
    @State
    var showSetting: Bool = false
    
    @State
    private var backToMainAlert = false
    
    @State
    private var incompleteNasaTLXAlert = false
    
    @State
    private var showTaskCompletion = false
    
    @State
    private var hideNavigationBar: Bool = true
    
    @State
    var stack: Stack<ViewTitleMapper>? = nil
    
    @EnvironmentObject
    private var taskSimulationService: TaskSimulationService
    
    @State
    private var nextTaskBarName: String = "Next"
    
    @State
    private var currentTab = 0
    
    @State
    private var currentView: ViewTitleMapper
    
    private let zyBooksLogout = ZyBooksWebView(
        tabs: [StringPair(x: "UTOLEDO101ResearchFall2021", y: "Sign Out from Zybooks")]
    )

    private var navigationNextStack: Stack<ViewTitleMapper> {
        if let existing = stack {
            return existing
        }
        self.stack = Stack<ViewTitleMapper>(
            [
                ViewTitleMapper(
                    x:  AnyView(EmpaticaSettingsView(alignment: true)),
                    y: "Data Grid",
                    z: ViewType.any
                ),
                
                ViewTitleMapper(
                    x:  AnyView(ZyBooksWebView(
                        tabs: [StringPair(x: "UTOLEDO101ResearchFall2021", y: "Sign Out from zybooks")]
                    )),
                    y: "Sign Out from zyBooks",
                    z: ViewType.zyBooks
                ),
                ViewTitleMapper(x: AnyView(AssesmentRatingView()), y: "NASA TLX Read Article 2", z: ViewType.rating)
            ]
        )
        return stack!
    }
    
    private let navigationBackStack: Stack<AnyView> = Stack<AnyView>()
    private var alignment: Bool
    
    init(alignment:Bool = false) {
        self.alignment = false
        self._currentView = State(
            initialValue: ViewTitleMapper(
                x:  AnyView(SafariWebView(urlString: "https://www.zinio.com/free-magazines")),
                y: "Read Article 2",
                z: ViewType.safari
            )
        )
    }
    
    var body : some View {
        GeometryReader(
            content: self.mainNavigationContent
        )
        .customInformationAlert(
            isPresented: self.$showTaskCompletion,
            title: "Congratulations!",
            bodyText: "You have completed \(self.currentView.y) task",
            okAction: self.backToMainAction
        )
        .customAlert(
            isPresented: self.$backToMainAlert,
            title: "Back To Tasks?",
            bodyText: "\(self.currentView.y) will be incomplete.\nDo you want to continue?",
            okAction: self.backToMainAction
        )
        .customInformationAlert(
            isPresented: self.$incompleteNasaTLXAlert ,
            title: "Confirm All Selection?",
            bodyText: "One or more rating has not been selected. Please select all rating to proceed!"
        )
        .onAppear(perform: self.onAppearAction)
        .onDisappear(perform: self.onDisappearAction)
        .navigationBarHidden(self.hideNavigationBar)
    }
    
    @ViewBuilder
    private func mainNavigationContent(geometryProxy: GeometryProxy) -> some View {
        let frame = geometryProxy.frame(in: .local);
        let width = geometryProxy.size.width
        let height = geometryProxy.size.height
        
        Group {
            currentView.x
                .frame(width: width, height: height)
                .offset(x: frame.minX, y: frame.minY)
            Group {
                ZStack {
                    self.rectangle(cornerRadius: 3.0)
                    self.button(
                        text: "Tasks",
                        action: self.toMainView
                    ).offset(x: frame.minX, y: frame.minY)
                }

                if currentView.z != .zyBooks {
                    self.rectangle(cornerRadius: 0.0, width: width)
                            .offset(x: frame.minX + ((currentView.z == .any) ? 70 : 220), y: frame.minY)
                    Picker(selection: self.$currentTab, label: Text("")) {
                        Text(currentView.y).tag(0)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .offset(x: frame.minX +  220, y: frame.minY + 3)
                    .frame(width: 400, height: 35.0, alignment: .center)
                }
                
                ZStack {
                    self.rectangle(cornerRadius: 3.0)
                    self.button(
                        text: self.nextTaskBarName,
                        action: self.toNextView
                    )
                }
                .offset(x: frame.maxX - MainNavigationView.buttonWidth, y: frame.minY)
            }

        }
    }
    
    private func backToMainAction() -> Void {
        self.mode.wrappedValue.dismiss()
        EmpaticaE4Service.currentView = "Main Window"
    }
    
    private func navigationTitle(text: String) -> some View {
        return Text(text)
            .bold()
            .frame(
                width: 200,
                height: MainNavigationView.buttonHeight,
                alignment: .center
            )
            .foregroundColor(Color.black)
    }
    
    private func rectangle(cornerRadius: Double, width: Double = 50) -> some View {
        return Rectangle()
            .frame(
                width: width,
                height: MainNavigationView.buttonHeight,
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
    
    private func button(text: String, action: @escaping () -> Void) -> some View {
        return Button(text, action: action)
            .frame(
                width: MainNavigationView.buttonWidth,
                height: MainNavigationView.buttonHeight,
                alignment: .center
            )
            .background(Color(UIColor(
                red: 247/255,
                green: 247/255,
                blue: 247/255,
                alpha: 1
            )))
            .foregroundColor(Color.blue)
            .cornerRadius(3.0)
    }
    
    private func onAppearAction() -> Void {
        EmpaticaE4Service.currentView = currentView.y
        empaticaE4Service.startDeviceSession()
        self.hideNavigationBar = true
        self.sendWebSocketMessage()
    }
    
    private func sendWebSocketMessage() -> Void {
        let message: EmpaticaE4Band = EmpaticaE4Band()
        
        let e4Band: Device = Device()
        e4Band.connected = empaticaE4Service.connectedDevice.isPresent
        e4Band.serialNumber = empaticaE4Service.connectedDevice?.serialNumber ?? ""
        
        message.subjectId = EmpaticaE4Service.subjectId
        message.fromView = EmpaticaE4Service.currentView
        message.device = e4Band

        self.webSocketService.sendMessage(payload: message)

    }
    
    private func onDisappearAction() -> Void {
        self.hideNavigationBar = false
        empaticaE4Service.stopDeviceSession()
        self.taskSimulationService.currentTaskCounter = self.taskSimulationService.currentTaskCounter + 1
    }
    
    private func toMainView() -> Void {
        self.backToMainAlert.toggle()
    }
    
    private func toNextView() -> Void {
        if .rating == currentView.z {
            if !assesmentRating.isRated() {
                self.incompleteNasaTLXAlert = true
                return
            }
            
            assesmentRating.subjectId = EmpaticaE4Service.subjectId
            assesmentRating.taskName = currentView.y

            empaticaE4Service.insertAssesmentRating(assesmentRating: assesmentRating)
        }
        
        if navigationNextStack.size() == 1 {
            self.nextTaskBarName = "Done"
        }
        
        if let nextView = navigationNextStack.pop() {
            EmpaticaE4Service.currentView = nextView.y
            self.sendWebSocketMessage()
            currentView = nextView
        }
        else {
            self.showTaskCompletion =  true
            EmpaticaE4Service.storeSession = false
        }
    }
}

struct DoubleNavigationView : View {
    static let buttonWidth: CGFloat = 70
    static let buttonHeight: CGFloat = 40
    
    @Environment(\.presentationMode)
    private var mode: Binding<PresentationMode>
    
    @EnvironmentObject
    private var assesmentRating: AssesmentRating
    
    @EnvironmentObject
    private var empaticaE4Service: EmpaticaE4Service
    
    @EnvironmentObject
    private var webSocketService: WebSocketService
    
    @State
    var showSetting: Bool = false
    
    @State
    private var backToMainAlert = false
    
    @State
    private var incompleteNasaTLXAlert = false
    
    @State
    private var showTaskCompletion = false
    
    @State
    private var hideNavigationBar: Bool = true
    
    @EnvironmentObject
    private var taskSimulationService: TaskSimulationService
    
    @EnvironmentObject
    private var applicationPropertiesService: ApplicationPropertiesService
    
    @State
    private var currentView: ViewTitleMapper

    @State
    private var tlxView: ViewTitleMapper
    
    @State
    private var nextTaskBarName: String = "Next"
    
    @State
    private var viewTitle: String
    
    @State
    private var currentTab = 0
    
    init(view: AnyView, viewTitle: String, viewType: ViewType, nasaTlxTitle: String) {
        // SwiftUI doesn't allows to change state value during initialization
        // So, need to add initial state value this way so that view modification do gets changed
        self._viewTitle = State(
            initialValue: viewTitle
        )
        
        self._currentView = State(
            initialValue:ViewTitleMapper(x: view, y: viewTitle, z: viewType)
        )
        
        self._tlxView = State(
            initialValue: ViewTitleMapper(x: AnyView(AssesmentRatingView()), y: nasaTlxTitle, z: .rating)
        )
    }
    
    var body : some View {
        GeometryReader(
            content: self.navigationContent
        )
        .customInformationAlert(
            isPresented: self.$showTaskCompletion,
            title: "Congratulations!",
            bodyText: "You have completed \(self.viewTitle) task",
            okAction: self.taskCompleteAction
        )
        .customAlert(
            isPresented: self.$backToMainAlert,
            title: "Back To Tasks?",
            bodyText: "\(self.viewTitle) task will be incomplete.\nDo you want to continue?",
            okAction: self.backToMainAction
        )
        .customInformationAlert(
            isPresented: self.$incompleteNasaTLXAlert ,
            title: "Confirm All Selection?",
            bodyText: "One or more rating has not been selected. Please select all rating to proceed!"
        )
        .onAppear(perform: self.onAppearAction)
        .onDisappear(perform: self.onDisappearAction)
        .navigationBarHidden(self.hideNavigationBar)
    }
    
    @ViewBuilder
    private func navigationContent(geometryProxy: GeometryProxy) -> some View {
        let frame = geometryProxy.frame(in: .local);
        let width = geometryProxy.size.width
        let height = geometryProxy.size.height
        
        currentView.x
            .frame(width: width, height: height)
            .offset(x: frame.minX, y: frame.minY)

        ZStack {
            self.rectangle(cornerRadius: 3.0)
            self.button(
                text: "Tasks",
                action: self.toTasksView
            ).offset(x: frame.minX, y: frame.minY)
        }

        if .zyBooks != currentView.z {
            self.rectangle(cornerRadius: 0.0, width: width)
                    .offset(x: frame.minX + 220, y: frame.minY)
            Picker(selection: self.$currentTab, label: Text("")) {
                Text(currentView.y).tag(0)
            }
            .pickerStyle(SegmentedPickerStyle())
            .offset(x: frame.minX + 220, y: frame.minY + 3)
            .frame(width: 400, height: 35.0, alignment: .center)
        }

        ZStack {
            self.rectangle(cornerRadius: 3.0)
            self.button(
                text: self.nextTaskBarName,
                action: self.toNextView
            )
        }
        .offset(x: frame.maxX - MainNavigationView.buttonWidth, y: frame.minY)
    
    }
    
    private func backToMainAction() -> Void {
        self.mode.wrappedValue.dismiss()
        EmpaticaE4Service.currentView = "Main Window"
    }
    
    private func taskCompleteAction() -> Void {
        self.mode.wrappedValue.dismiss()
        EmpaticaE4Service.currentView = "Main Window"
        self.taskSimulationService.currentTaskCounter = self.taskSimulationService.currentTaskCounter + 1
    }
    
    private func navigationTitle(text: String) -> some View {
        return Text(text)
            .bold()
            .frame(
                width: 200,
                height: DoubleNavigationView.buttonHeight,
                alignment: .center
            )
            .foregroundColor(Color.black)
    }
    
    private func rectangle(cornerRadius: Double, width: Double = 50) -> some View {
        return Rectangle()
            .frame(
                width: width,
                height: DoubleNavigationView.buttonHeight,
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
    
    private func button(text: String, action: @escaping () -> Void) -> some View {
        return Button(text, action: action)
            .frame(
                width: DoubleNavigationView.buttonWidth,
                height: DoubleNavigationView.buttonHeight,
                alignment: .center
            )
            .background(Color(UIColor(
                red: 247/255,
                green: 247/255,
                blue: 247/255,
                alpha: 1
            )))
            .foregroundColor(Color.blue)
            .cornerRadius(3.0)
    }
    
    private func onAppearAction() -> Void {
        EmpaticaE4Service.currentView = currentView.y
        empaticaE4Service.startDeviceSession()
        self.hideNavigationBar = true
        self.sendWebSocketMessage()
    }
    
    private func sendWebSocketMessage() -> Void {
        let message: EmpaticaE4Band = EmpaticaE4Band()
        
        let e4Band: Device = Device()
        e4Band.connected = empaticaE4Service.connectedDevice.isPresent
        e4Band.serialNumber = empaticaE4Service.connectedDevice?.serialNumber ?? ""
        
        message.subjectId = EmpaticaE4Service.subjectId
        message.fromView = EmpaticaE4Service.currentView
        message.device = e4Band
        self.webSocketService.sendMessage(payload: message)
    }
    
    private func onDisappearAction() -> Void {
        self.hideNavigationBar = false
        empaticaE4Service.stopDeviceSession()
    }
    
    private func toTasksView() -> Void {
        self.backToMainAlert.toggle()
    }
    
    private func toNextView() -> Void {
            if .rating == currentView.z {
                if !assesmentRating.isRated() {
                    self.incompleteNasaTLXAlert = true
                    return
                }
                
                assesmentRating.subjectId = EmpaticaE4Service.subjectId
                assesmentRating.taskName = currentView.y

                empaticaE4Service.insertAssesmentRating(assesmentRating: assesmentRating)
            }

        
        if "Next" == self.nextTaskBarName {
            currentView = tlxView
            EmpaticaE4Service.currentView = currentView.y
            self.nextTaskBarName = "Done"
            self.sendWebSocketMessage()
        }
        else {
            self.webSocketService.disconnect(closeEventLoopGroup: false)
            self.webSocketService.connect(
                url : self.applicationPropertiesService.getProperty(propertyName: "webSocket.connection.uri")!
            )
            self.showTaskCompletion = true
        }
    }
}
