//
//  EmpaticaSettingsView.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 8/10/21.
//
import SwiftUI
import SwiftUICharts

struct EmpaticaSettingsView: View {
    @State
    private var animateProgress = false
    
    @State
    private var animateSmallCircle = false
    
    @State
    private var animateLargeCircle = false
    
    @State
    private var animateSound = false
    
    @State
    private var isSearching = false
    
    @State
    private var heartOpacity: Double = 1.0
    
    @State
    private var showSyncTimestampAlert = false

    @EnvironmentObject
    private var empaticaService: EmpaticaE4Service
    
    @EnvironmentObject
    private var ntpService: NTPSyncService
    
    @EnvironmentObject
    private var applicationPropertiesService: ApplicationPropertiesService
    
    @EnvironmentObject
    private var webSocketService: WebSocketService
    
    let mixedColorStyle = ChartStyle(backgroundColor: Color.white, accentColor: Colors.OrangeStart, secondGradientColor: Colors.GradientNeonBlue, textColor: Color.red, legendTextColor: Color.black, dropShadowColor: Colors.DarkPurple)
    
    private var alignment: Bool
    
    init(alignment: Bool = false) {
        self.alignment = alignment
    }
    
    private var alignmentOffsetY: Double {
        return self.alignment ? 40.0 : 0.0
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(#colorLiteral(red: 0.6823529412, green: 0.8352941176, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0.6117647059, green: 0.6078431373, blue: 1, alpha: 1))]),
                startPoint: .topLeading,
                endPoint: .bottomLeading
            ).edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/).opacity(0.8).blur(radius: 10)
            
            if let device = empaticaService.connectedDevice {
                GeometryReader { geometry in
                    let frame = geometry.frame(in: .local)
                    self.showBatteryStatus(geometry: geometry)
                    self.showDeviceWristStatus(geometry: geometry)
                    self.showConnectedDevice(geometry: geometry, device: device)
                    self.createLineCharts(geometry: geometry)
                    self.showHeartRate(geometry: geometry)
                    
                    if !self.alignment {
                        self.OverlayButton()
                            .frame(
                                width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/,
                                height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/,
                                alignment: .center
                            )
                            .offset(x: frame.midX - 50, y: frame.maxY - 110)
                    }
                }
            }
            else {
                if !self.isSearching {
                    VStack {
                        Text("No devices connected").bold().foregroundColor(.black)
                        self.OverlayButton()
                    }
                }
                else {
                    if self.empaticaService.availableDevices.count > 0 {
                        VStack(alignment: .leading, spacing: 1) {
                            ForEach(self.empaticaService.availableDevices, id: \.self, content: self.showAvailableDevices)
                        }
                    }
                    else {
                        self.animateCircles()
                    }
                }
            }
        }
        .customInformationAlert(
            isPresented: self.$showSyncTimestampAlert,
            title: "Device Connection",
            bodyText: "Connecting to empatica e4 device will sync timestamp to NTP server `pool.ntp.org`",
            okAction: self.onShowSyncTimestampAlert
        )
        .onAppear(perform: self.onEmpaticaSettingsAppear)
        .onDisappear(perform: self.onEmpaticaSettingsDisappear)
        .navigationTitle(NasaTLXGlobals.empaticaE4Settings)
    }
    
    private func onShowSyncTimestampAlert() -> Void {
        self.isSearching.toggle()
        self.ntpService.syncTimestamp(
            ntpPool: self.applicationPropertiesService.getProperty(propertyName: "ntp.pool.uri")!
        )
        if empaticaService.connectedDevice.isPresent {
            self.empaticaService.disconnectDevice()
        }
        else {
            self.empaticaService.discoverDevices()
        }
    }
    
    private func onEmpaticaSettingsAppear() -> Void {
        if self.empaticaService.connectedDevice.isPresent {
            self.empaticaService.startGraphTimer()
            EmpaticaE4Service.showChart = true
        }
    }
    
    private func onEmpaticaSettingsDisappear() -> Void {
        EmpaticaE4Service.showChart = false
        self.empaticaService.endGraphTimer()
    }
    
    @ViewBuilder
    func showHeartRate(geometry: GeometryProxy) -> some View {
        let frame = geometry.frame(in: .local)
        ZStack {
            Image(systemName: "heart.fill")
                .resizable()
                .foregroundColor(.red)
                .opacity(self.heartOpacity)
            Text((self.empaticaService.currentIBI > 0) ?  "\(String(format: "%.2f", 60 / self.empaticaService.currentIBI)) bpm" : "---")
                .bold()
        }
        .frame(width: 100, height: 100, alignment: .leading)
        .offset(x: frame.midX - 50, y: frame.minY + 800 + (self.alignment ? 20.0 : 0.0))
    }
    
    @ViewBuilder
    func showDeviceWristStatus(geometry: GeometryProxy) -> some View {
        let frame = geometry.frame(in: .local)
        HStack(spacing: 2) {
            Image(systemName: "applewatch")
                .foregroundColor(.black)
            
            Text("\(self.empaticaService.deviceWristStatus)")
                .foregroundColor(.orange)
                .bold()
        }
        .frame(width: 160, height: 30, alignment: .trailing)
        .padding(5)
        .offset(x: frame.maxX - 170, y: frame.minY + self.alignmentOffsetY)
    }
    
    @ViewBuilder
    func showConnectedDevice(geometry: GeometryProxy, device: EmpaticaDeviceManager) -> some View {
        let frame = geometry.frame(in: .local)
        
        HStack(spacing: 0) {
            Text("Connected to ").bold().foregroundColor(.black)
            Text("\(device.serialNumber!)").bold().foregroundColor(.red)
        }
        .frame(width: 200, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .padding(4)
        .offset(x: frame.midX - 100, y: frame.minY + self.alignmentOffsetY)
    }
    
    @ViewBuilder
    func showBatteryStatus(geometry: GeometryProxy) -> some View {
        Group {
            let frame = geometry.frame(in: .local)
            Rectangle()
                .stroke()
                .foregroundColor(.clear)
                .background(Color.orange.cornerRadius(3.0))
                .frame(width: CGFloat(50 * self.empaticaService.batteryStatus / 100), height: 25, alignment: .leading)
                .padding(5)
                .offset(x: frame.minX + 2, y: frame.minY + 2 + self.alignmentOffsetY)
            
            Image(systemName: "battery.0")
                .resizable()
                .foregroundColor(.green)
                .frame(width: 60, height: 30, alignment: .leading)
                .padding(5)
                .offset(x: frame.minX, y: frame.minY + self.alignmentOffsetY)
            
            Text("\(self.empaticaService.batteryStatus) %")
                .bold()
                .frame(width: 60, height: 30, alignment: .center)
                .padding(5)
                .offset(x: frame.minX, y: frame.minY + self.alignmentOffsetY)
        }
    }
    
    @ViewBuilder
    func createLineCharts(geometry: GeometryProxy) -> some View {
        let width = geometry.size.width
        Group {
            self.lineViewGroup(
                viewTitle: "GSR",
                text: "\(self.empaticaService.currentGSR) μS",
                data: self.empaticaService.gsrData,
                geometry: geometry,
                lineOffsetx:  0,
                lineOffsetY: 50 + self.alignmentOffsetY,
                textOffsetX: 100,
                textOffsetY: 80 + self.alignmentOffsetY
            )

            self.lineViewGroup(
                viewTitle: "BVP",
                text: "\(self.empaticaService.currentBVP) PPG",
                data: self.empaticaService.bvpData,
                geometry: geometry,
                lineOffsetx:  width / 2,
                lineOffsetY: 50 + self.alignmentOffsetY,
                textOffsetX: width / 2 + 100,
                textOffsetY: 80 + self.alignmentOffsetY
            )
            
            self.lineViewGroup(
                viewTitle: "AccX",
                text: "\(self.empaticaService.currentAccX) g",
                data: self.empaticaService.accXData,
                geometry: geometry,
                lineOffsetx: 0,
                lineOffsetY: 400 + self.alignmentOffsetY,
                textOffsetX: 100,
                textOffsetY: 430 + self.alignmentOffsetY
            )
            
            self.lineViewGroup(
                viewTitle: "TEMP",
                text: "\(self.empaticaService.currentTemp) °C",
                data: self.empaticaService.temperatureData,
                geometry: geometry,
                lineOffsetx: width / 2,
                lineOffsetY: 400 + self.alignmentOffsetY,
                textOffsetX: width / 2 + 100,
                textOffsetY: 430 + self.alignmentOffsetY
            )
        }
    }
    
    private func lineViewGroup(viewTitle: String, text: String, data: [Double],
                               geometry: GeometryProxy, lineOffsetx: CGFloat, lineOffsetY: CGFloat, textOffsetX: CGFloat,
                               textOffsetY: CGFloat) -> some View {
        let frame = geometry.frame(in: .local)
        let width = geometry.size.width
        return Group {
            LineView(
                data: data,
                title: viewTitle,
                style: mixedColorStyle,
                valueSpecifier: "%.4f",
                legendSpecifier: "%.2f"
            )
            .frame(width: width / 2 - 10, height: 300, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .padding(5).offset(x: frame.minX + lineOffsetx, y: frame.minY + lineOffsetY)
            
            Text(text)
                .bold().offset(x:  frame.minX + textOffsetX, y: frame.minY + textOffsetY)
        }
    }
    
    @ViewBuilder
    func showAvailableDevices(device: EmpaticaDeviceManager) -> some View {
        HStack(spacing: 2) {
            Image(systemName: "applewatch")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 15, height: 20)
                .foregroundColor(.black)
            Text("\(device.serialNumber)")
                .font(.system(size: 20))
                .bold()
                .onTapGesture {
                self.empaticaDeviceTappedAction(device: device)
            }
        }.padding(.horizontal, 300)
    }
    
    private func empaticaDeviceTappedAction(device: EmpaticaDeviceManager) -> Void {
        self.empaticaService.connectToDevice(device: device)
        
        EmpaticaE4Service.currentView = "Empatica Settings"
        EmpaticaE4Service.showChart = true
        
        self.empaticaService.startGraphTimer()
        self.sendWebSocketMessage()
    }
    
    private func sendWebSocketMessage() -> Void {
        let message: EmpaticaE4Band = EmpaticaE4Band()
        
        let e4Band: Device = Device()
        
        let empaticaDeviceManager = self.empaticaService.connectedDevice
        e4Band.connected = empaticaDeviceManager.isPresent
        e4Band.serialNumber = empaticaDeviceManager?.serialNumber ?? ""
        
        message.subjectId = EmpaticaE4Service.subjectId
        message.fromView = EmpaticaE4Service.currentView
        message.device = e4Band
        
        self.webSocketService.sendMessage(payload: message)
    }
    
    @ViewBuilder
    private func OverlayButton() -> some View {
        Button(action: self.overlayButtonAction) {
            RoundedRectangle(cornerRadius: 32)
                .stroke()
                .foregroundColor(.black)
                .background(Color.orange.cornerRadius(32))
                .overlay(Text(empaticaService.connectedDevice.isPresent ? "Disconnect" : "Search").foregroundColor(.black).bold())
            
        }.frame(width: 120, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
    
    
    private func overlayButtonAction() -> Void {
        if !self.ntpService.isTimeSynced {
            self.showSyncTimestampAlert = true
            return
        }
        self.isSearching.toggle()
        if empaticaService.connectedDevice.isPresent {
            self.empaticaService.disconnectDevice()
        }
        else {
            self.empaticaService.discoverDevices()
        }
    }
    
    @ViewBuilder
    func animateCircles() -> some View {
        ZStack {
            Image(systemName: "waveform")
                .clipShape(Circle().offset(y: animateSound ? 10 : -15))
                .font(.largeTitle)
                .animation(Animation.interpolatingSpring(mass: 0.05, stiffness: 170, damping: 15, initialVelocity: 1).repeatForever(autoreverses: true))
                .onAppear() {
                    animateSound.toggle()
                }
            
            Circle()
                .stroke()
                .frame(width: UIScreen.main.bounds.width - 50, height: UIScreen.main.bounds.width - 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .scaleEffect(animateLargeCircle ? 1.2 : 0.73)
                .opacity(animateLargeCircle ? 0 : 1)
                .animation(Animation.easeOut(duration: 4).delay(1).repeatForever(autoreverses: false))
                .onAppear() {
                    animateLargeCircle.toggle()
                }
            
            Circle()
                .stroke()
                .frame(width: UIScreen.main.bounds.width - 100, height: UIScreen.main.bounds.width - 100, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .scaleEffect(animateSmallCircle ? 1.2 : 0.84)
                .opacity(animateSmallCircle ? 0 : 1)
                .animation(Animation.easeInOut(duration: 4).delay(1).repeatForever(autoreverses: false))
                .onAppear() {
                    animateSmallCircle.toggle()
                }
            
            Circle()
                .stroke(lineWidth: 4)
                .frame(width: UIScreen.main.bounds.width - 150, height: UIScreen.main.bounds.width - 150, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .opacity(0.2)
        }
    }
}
