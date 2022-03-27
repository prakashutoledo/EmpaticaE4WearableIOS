//
//  SimulationView.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 8/10/21.
//
import SwiftUI

public struct SimulationView: View {
    @State
    private var researchId: String = ""
    
    @State
    private var isProceed: Bool = false
    
    @State
    private var showTextField = true
    
    @State
    private var showButton = true
    
    @State
    private var showAlert = false
    
    @State
    private var showInformationAlert: Bool = false
    
    @State
    private var hideNavigationBar: Bool = true
    
    @State
    private var navigationBarTitle: String = ""
    
    @State
    private var showTasks: Bool = false
    
    @EnvironmentObject
    private var empaticaE4Servcice: EmpaticaE4Service
    
    @EnvironmentObject
    private var taskSimulationService: TaskSimulationService
    
    @EnvironmentObject
    private var webSocketService: WebSocketService
    
    @EnvironmentObject
    private var applicationPropertiesService: ApplicationPropertiesService
    
    private let zyBooksLogin = ZyBooksWebView(
        tabs: [StringPair(x: "UTOLEDO101ResearchFall2021", y: "Sign In to Zybooks")]
    )
    private let zyBooksSection1 = ZyBooksWebView(
        tabs: [StringPair(x: "UTOLEDO101ResearchFall2021/chapter/1/section/1", y: "Section 1.1")]
    )
    private let zyBooksTabbedView = ZyBooksWebView(
        tabs: [
            StringPair(x: "UTOLEDO101ResearchFall2021/chapter/2/section/1", y: "Section 2.1"),
            StringPair(x:"UTOLEDO101ResearchFall2021/chapter/3/section/2", y: "Physical Properties")
        ]
    )
    private let zinioPdfView = SafariWebView(urlString: "https://www.zinio.com/free-magazines")
    //private let chemistryTextbookView = SafariWebView(urlString:"https://openstax.org/books/chemistry/pages/1-introduction")
    //private let chemistryTextbookView = PDFView(urlString: "https://ideaslabut-s3.s3.us-east-2.amazonaws.com/CovalentBond.pdf")
    private let chemistryTextbookView = SafariWebView(urlString: "https://ideaslabut-s3.s3.us-east-2.amazonaws.com/CovalentBond.pdf")
    private var isBandConnected: Bool {
        return empaticaE4Servcice.connectedDevice.isPresent
    }
    
    private var isValidId : Bool {
        return !self.researchId.isEmpty
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if self.showTextField {
                    HStack {
                        Image(systemName: "person").foregroundColor(.orange).frame(height: 40)
                        TextField("Enter Id", text: self.$researchId).border(Color.black).background(Color.orange).frame(height: 40)
                    }.frame(height: 40).padding(.horizontal, 300)
                }
                
                if self.isValidId {
                    Button(action: self.proceedButtonAction) {
                        self.rectangle(text: "Proceed")
                    }
                }

                if self.isProceed  {
                    if self.isBandConnected {
                        if self.showTasks {
                            GeometryReader { geometryProxy in
                                let frame = geometryProxy.frame(in: .local)
                                Text("After completing the task, you will be asked to self report your workload using the NASA Task Load Index (TLX) survey.")
                                    .bold()
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .offset(x: frame.minX, y: frame.minY)
                                
                                
                                self.taskList()
                                    .offset(x: frame.maxX / 2 - 112.5, y: frame.maxY / 2 - 200)
                            }
                        }
                        else {
                            NavigationLink(destination: self.zyBooksLogin.onDisappear(perform: self.onZybooksLoginDisappearAction)) {
                                self.rectangle(text: "Start")
                            }
                        }
                    }
                    else {
                        self.rectangle(text: "Start", isTapGesture: true)
                    }
                }
            }
            .navigationBarTitle(self.navigationBarTitle, displayMode: .inline)
            .navigationBarItems(
                trailing: NavigationLink(destination: EmpaticaSettingsView()) {
                    Image(systemName: "gear").foregroundColor(.black)
                }
            )
            .navigationBarHidden(self.hideNavigationBar)
        }
        .customInformationAlert(
            isPresented: self.$showInformationAlert,
            title: "No Device Connected",
            bodyText:"Connect to E4 device using settings"
        )
        .customAlert(
            isPresented: self.$showAlert,
            title: "Informed Consent",
            bodyText: "By continuing, I confirm that I have completed the informed consent form and decided to take part in this research.",
            okAction: self.customAlertOkAction
        )
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear(perform: self.onSimulationViewAppear)
        .statusBar(hidden: true)
    }
    
    @ViewBuilder
    private func taskList() -> some View {
        VStack(spacing: 20) {
            NavigationLink(destination: DoubleNavigationView(
                view: AnyView(self.zinioPdfView),
                viewTitle: "Read Article 1",
                viewType: .safari,
                nasaTlxTitle: "Nasa TLX Read Article 1"
            )) {
                self.rectangle(
                    text: "Read magazine article (~10-15 min)",
                    isHighlightable: self.taskSimulationService.currentTaskCounter == 0,
                    isStrikeThrough: self.taskSimulationService.currentTaskCounter > 0,
                    width: 225
                )
            }
            .disabled(self.taskSimulationService.currentTaskCounter != 0)
            
            NavigationLink(destination: DoubleNavigationView(
                view: AnyView(self.chemistryTextbookView),
                viewTitle: "Read Textbook",
                viewType: .safari,
                nasaTlxTitle: "Nasa TLX Read Textbook"
            )) {
                self.rectangle(
                    text: "Read a portion of a\nchemistry textbook\n(~15-20 min)",
                    isHighlightable: self.taskSimulationService.currentTaskCounter == 1,
                    isStrikeThrough: self.taskSimulationService.currentTaskCounter > 1,
                    width: 225,
                    height: 70
                )
            }
            .disabled(self.taskSimulationService.currentTaskCounter != 1)
            
            NavigationLink(destination: DoubleNavigationView(
                view: AnyView(self.zyBooksSection1),
                viewTitle: "Zybook Section 1.1",
                viewType: .zyBooks,
                nasaTlxTitle: "Nasa TLX Read Zybook"
            )) {
                self.rectangle(
                    text: "Read zyBook section and watch all animations (~15-25 min)",
                    isHighlightable: self.taskSimulationService.currentTaskCounter == 2,
                    isStrikeThrough: self.taskSimulationService.currentTaskCounter > 2,
                    width: 215,
                    height: 80
                )
            }
            .disabled(self.taskSimulationService.currentTaskCounter != 2)
            
            NavigationLink(destination: DoubleNavigationView(
                view: AnyView(self.zyBooksTabbedView),
                viewTitle: "Challange Activities",
                viewType: .zyBooks,
                nasaTlxTitle: "Nasa TLX Challange Activities"
            )) {
                self.rectangle(
                    text: "Complete zyBook challenge problems\n(~15-25 min)",
                    isHighlightable: self.taskSimulationService.currentTaskCounter == 3,
                    isStrikeThrough: self.taskSimulationService.currentTaskCounter > 3,
                    width: 225,
                    height: 80
                )
            }
            .disabled(self.taskSimulationService.currentTaskCounter != 3)
            
            NavigationLink(destination: MainNavigationView()) {
                self.rectangle(
                    text: "Read magazine article (~10-15 min)",
                    isHighlightable: self.taskSimulationService.currentTaskCounter == 4,
                    isStrikeThrough: self.taskSimulationService.currentTaskCounter > 4,
                    width: 225
                )
            }
            .disabled(self.taskSimulationService.currentTaskCounter != 4)
        }
    }
    
    private func onZybooksLoginDisappearAction() -> Void {
        self.showTasks = true
    }
    
    private func rectangle(text: String, isTapGesture: Bool = false, isHighlightable: Bool = true, isStrikeThrough: Bool = false, width: Double = 120, height: Double = 50) -> AnyView {
        var text: Text = Text(text).foregroundColor(.black)
        var backgroundColor: Color = Color.gray
        
        if isHighlightable {
            text = text.bold()
            backgroundColor = Color.orange
        }
    
        if isStrikeThrough {
            text = text.strikethrough()
        }
        
        let rectangle = RoundedRectangle(cornerRadius: 32)
                  .stroke()
                  .foregroundColor(.black)
                  .background(backgroundColor.cornerRadius(32))
                  .overlay(text.multilineTextAlignment(.center))
                  .frame(width: width, height: height, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        
        if isTapGesture {
           return AnyView(rectangle.onTapGesture(perform: self.onRectangleTapped))
        }
        
        return AnyView(rectangle)
    }

    private func onRectangleTapped() -> Void {
        self.showInformationAlert = true
    }
    
    private func proceedButtonAction() -> Void {
        self.showAlert = true
    }
    
    private func onSimulationViewAppear() -> Void {
        EmpaticaE4Service.currentView = "Main Window"
        
        self.webSocketService.disconnect(closeEventLoopGroup: false)
        self.webSocketService.connect(
            url: applicationPropertiesService.getProperty(propertyName: "webSocket.connection.uri")!
        )
    }
    
    private func customAlertOkAction() -> Void {
        EmpaticaE4Service.subjectId = self.researchId
        self.navigationBarTitle = "Id: \(self.researchId)"
        self.showTextField = false
        self.showButton = false
        self.researchId = ""
        self.hideNavigationBar = false
        
        let message: EmpaticaE4Band = EmpaticaE4Band()
        
        let e4Band: Device = Device()
        e4Band.connected = self.isBandConnected
        e4Band.serialNumber = self.empaticaE4Servcice.connectedDevice?.serialNumber ?? nil
        
        message.subjectId = EmpaticaE4Service.subjectId
        message.fromView = EmpaticaE4Service.currentView
        message.device = e4Band
        
        self.webSocketService.sendMessage(payload: message)
        self.isProceed = true
    }
}
