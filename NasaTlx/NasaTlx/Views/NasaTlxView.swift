import SwiftUI
import Sliders

enum ApplicationConstants {
    static let maxSliderWidth: CGFloat = 500
    static let defaultMaxHeight: CGFloat = 20
    static let maxOffset: CGFloat = 15
}

struct NasaTlxView: View {
    @State
    private var sliderValue: Double = 0.0
    
    @EnvironmentObject
    var assesmentRating: AssesmentRating
    
    @State
    var isPresented: Bool = true
    
    var body: some View {
        SimulationView()
    }
}

struct InstructionView: View {
    @EnvironmentObject
    var assesmentRating: AssesmentRating
    
    @State
    private var showAlert: Bool = false
    
    @Environment(\.presentationMode)
    private var mode: Binding<PresentationMode>
    
    @State
    var title: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            let frame = geometry.frame(in: .local);
            let width = geometry.size.width
            let height = geometry.size.height
            Rectangle()
                .foregroundColor(.white)
                .frame(width: width, height: height)
                .offset(x: frame.minX, y:frame.minY)
            VStack {
                Text("The evaluation you're about to perform is a technique that has been developed by NASA to assess the relative importance of six factors in determining how much workload you experienced while performing  a task that you recently completed.").bold()
                    .padding(.trailing)
                    .foregroundColor(.black)
            }.offset(x: frame.minX + 15, y: frame.minY * height)
            
            VStack {
                Text("Those six factors are defined on the following page. Read through them to make sure you understand what each factor means. If you have any questions, please ask your administrator.")
                    .foregroundColor(.black).bold().padding(.trailing)
            }.offset(x: frame.minX + 15, y: frame.minY + 0.10 * height)
            
            self.bottomView(DefinitionView(), false)
                .offset(x: frame.midX - 100,  y: frame.maxY - 80)
                .navigationBarItems(trailing: Button("Quit") {
                    print("Quit")
                    self.showAlert = true
                })
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Quit Trial?"), message: Text("You will lose responses for this trial if you choose to quit now."), primaryButton: .default(Text("Continue").bold()) {
                self.assesmentRating.clear()
                self.mode.wrappedValue.dismiss()
            }, secondaryButton: .cancel())
        }
        .onAppear {
            self.title = "Instructions"
        }
        .onDisappear {
            self.title = ""
            self.assesmentRating.clear()
        }
        .navigationTitle(self.title)
        .gesture(DragGesture(minimumDistance: 0).onEnded { value in
            print(value.time)
        })
    }
}

struct RatingScaleView: View {
    
    @EnvironmentObject
    var assesmentRating: AssesmentRating
    
    @State
    private var showAlert: Bool = false
    
    @Environment(\.presentationMode)
    private var mode: Binding<PresentationMode>
    
    @State
    var title: String = ""
    var body: some View {
        GeometryReader { geometry in
            let frame = geometry.frame(in: .local);
            let width = geometry.size.width
            let height = geometry.size.height
            Rectangle()
                .foregroundColor(.white)
                .frame(width: width, height: height)
                .offset(x: frame.minX, y:frame.minY)
            VStack {
                Text("You'll now be presented with a series of rating scales.").bold()
                    .padding(.trailing)
                    .foregroundColor(.black)
            }.offset(x: frame.minX + 15, y: frame.minY + 0.01 * height)
            
            VStack {
                Text("For each of the six scales, evaluate the task you recently performed by tapping on the scale's location that matches your experience. Each line has two endpoint descriptors that describe the scale.")
                    .foregroundColor(.black).bold().padding(.trailing)
            }.offset(x: frame.minX + 15, y: frame.minY + 0.05 * height)
            
            VStack {
                Text("Consider your responses carefully in distinguishing among the different task conditions, and consider each state individually.")
                    .foregroundColor(.black).bold().padding(.trailing)
            }.offset(x: frame.minX + 15, y: frame.minY + 0.14 * height)
            
            self.bottomView(
                MentalDemandView(valueRange : 0...100, step: 1), false
            )
                .offset(x: frame.midX - 100,  y: frame.maxY - 80)
                .navigationBarItems(trailing: Button("Quit") {
                    self.showAlert = true
                })
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Quit Trial?"), message: Text("You will lose responses for this trial if you choose to quit now."), primaryButton: .default(Text("Continue")) {
                self.assesmentRating.clear()
                self.mode.wrappedValue.dismiss()
                
            }, secondaryButton: .cancel())
        }
        .onAppear {
            self.title = "Ratings Scales"
        }
        .onDisappear {
            self.title = ""
        }
        .navigationTitle(self.title)
        .gesture(DragGesture(minimumDistance: 0).onEnded { value in
            print(value.time)
        })
    }
}

struct DefinitionView: View {
    @EnvironmentObject
    var assesmentRating: AssesmentRating
    
    @State
    private var showAlert: Bool = false
    
    @Environment(\.presentationMode)
    private var mode: Binding<PresentationMode>
    
    @State
    var title: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            let frame = geometry.frame(in: .local);
            let width = geometry.size.width
            let height = geometry.size.height
            
            Rectangle()
                .foregroundColor(.white)
                .frame(width: width, height: height)
                .offset(x: frame.minX, y:frame.minY)
            
            self.mentalDemand(geometry: geometry)
            self.physicalDemand(geometry: geometry)

            self.temporalDemand(geometry: geometry)
            self.performanceDemand(geometry: geometry)
            self.effort(geometry: geometry)
            self.Frustation(geometry: geometry)
            
            self.bottomView(RatingScaleView(), false)
                .offset(x: frame.midX - 100,  y: frame.maxY - 80)
                .navigationBarItems(trailing: Button("Quit") {
                    print("Quit")
                    self.showAlert = true
                })
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Quit Trial?"), message: Text("You will lose responses for this trial if you choose to quit now."), primaryButton: .default(Text("Continue")) {
                self.assesmentRating.clear()
                self.mode.wrappedValue.dismiss()
            }, secondaryButton: .cancel())
        }
        .onAppear {
            self.title = "Definitions"
        }
        .onDisappear {
            self.title = ""
        }
        .navigationTitle(self.title)
        .gesture(DragGesture(minimumDistance: 0).onEnded { value in
            print(value.time)
        })
    }
    
    private func mentalDemand(geometry: GeometryProxy) -> some View {
        let frame = geometry.frame(in: .local);
        _ = geometry.size.width
        let height = geometry.size.height
        return Group {
            HStack {
                Text("Mental Demand").bold()
                Text("(Low/High)").bold().padding(.trailing).font(.custom("", size: 16))
            }.offset(x: frame.minX + 15, y: frame.minY + 0.01 * height)
            
            VStack {
                Text("How much mental and perceptualactivity was required (for example, thinking, deciding, calculating, remembering, looking, searching, etc)? Was the task easy or demanding, simple or complex, forgiving or exacting?").bold().font(.custom("", size: 16))
                    .padding(.trailing)
                    .foregroundColor(.black)
            }.offset(x: frame.minX + 15, y: frame.minY + 0.03 * height)
        }
    }
    
    private func physicalDemand(geometry: GeometryProxy) -> some View {
        let frame = geometry.frame(in: .local);
        _ = geometry.size.width
        let height = geometry.size.height
        return Group {
            HStack {
                Text("Physical Demand").bold()
                Text("(Low/High)").bold().padding(.trailing).font(.custom("", size: 16))
            }.offset(x: frame.minX + 15, y: frame.minY + 0.10 * height)
            
            VStack {
                Text("How much physical activity was required (for example, puling, pushing, turning, controlling, looking, activating, etc)? Was the task easy or demanding, slow or brisk, slack or strenous, restful or laborious?").bold().font(.custom("", size: 16))
                    .padding(.trailing)
                    .foregroundColor(.black)
            }.offset(x: frame.minX + 15, y: frame.minY + 0.12 * height)
        }
    }
    
    private func temporalDemand(geometry: GeometryProxy) -> some View {
        let frame = geometry.frame(in: .local);
        _ = geometry.size.width
        let height = geometry.size.height
        return Group {
            HStack {
                Text("Temporal Demand").bold()
                Text("(Low/High)").bold().padding(.trailing).font(.custom("", size: 16))
            }.offset(x: frame.minX + 15, y: frame.minY + 0.18 * height)
            
            VStack {
                Text("How much time pressure did you deel due to the rate or pace at which the tasks or task elements occurred? Was the pace slow or rapid and frantic?").bold().font(.custom("", size: 16))
                    .padding(.trailing)
                    .foregroundColor(.black)
            }.offset(x: frame.minX + 15, y: frame.minY + 0.20 * height)
        }
    }
    
    private func performanceDemand(geometry: GeometryProxy) -> some View {
        let frame = geometry.frame(in: .local);
        _ = geometry.size.width
        let height = geometry.size.height
        return Group {
            HStack {
                Text("Performance Demand").bold()
                Text("(Good/Poor)").bold().padding(.trailing).font(.custom("", size: 16))
            }.offset(x: frame.minX + 15, y: frame.minY + 0.26 * height)
            
            VStack {
                Text("How succesful do you think you were in accomplishing the goals of the task set by the experimenter (or yourself)? How satisfied were you with your performance in accomplishng thsese goals?").bold().font(.custom("", size: 16))
                    .padding(.trailing)
                    .foregroundColor(.black)
            }.offset(x: frame.minX + 15, y: frame.minY + 0.28 * height)
        }
    }
    
    private func effort(geometry: GeometryProxy) -> some View {
        let frame = geometry.frame(in: .local);
        _ = geometry.size.width
        let height = geometry.size.height
        return Group {
            HStack {
                Text("Effort").bold()
                Text("(Low/High)").bold().padding(.trailing).font(.custom("", size: 16))
            }.offset(x: frame.minX + 15, y: frame.minY + 0.34 * height)
            
            VStack {
                Text("How hard did you have to work (mentally and physically) to accomplish your level of performance?").bold().font(.custom("", size: 16))
                    .padding(.trailing)
                    .foregroundColor(.black)
            }.offset(x: frame.minX + 15, y: frame.minY + 0.36 * height)
        }
    }

    private func Frustation(geometry: GeometryProxy) -> some View {
        let frame = geometry.frame(in: .local);
        _ = geometry.size.width
        let height = geometry.size.height
        return Group {
            HStack {
                Text("Frustation").bold()
                Text("(Low/High)").bold().padding(.trailing).font(.custom("", size: 16))
            }.offset(x: frame.minX + 15, y: frame.minY + 0.40 * height)
            
            VStack {
                Text("How insecure, discouraged, irritated, stressed, and annoyed versus secure, gratified, context, relaxed, and complacent did you fell during the task?").bold().font(.custom("", size: 16))
                    .padding(.trailing)
                    .foregroundColor(.black)
            }.offset(x: frame.minX + 15, y: frame.minY + 0.42 * height)
        }
    }
}

struct MentalDemandView : View {
    @EnvironmentObject var assesmentRating: AssesmentRating
    
    @State
    private var showAlert: Bool = false
    
    @Environment(\.presentationMode)
    private var mode: Binding<PresentationMode>
    
    @State
    private var disableButton = true
    
    @State
    private var title = ""
    
    var valueRange : ClosedRange<Double>
    var step: Double
    var hideBackButton: Bool = false
    
    let maxWidth: CGFloat = 500
    let maxHeight: CGFloat = 30
    
    
    var body: some View {
        GeometryReader { geometry in
            let frame = geometry.frame(in: .local);
            let width = geometry.size.width
            let height = geometry.size.height
            
            Rectangle()
                .foregroundColor(.white)
                .frame(width: width, height: height)
                .offset(x: frame.minX, y:frame.minY)
            
            Text("Tap your response on the scale below")
                .frame(height: ApplicationConstants.defaultMaxHeight)
                .offset(x: frame.minX + ApplicationConstants.maxOffset, y:frame.minY)
            Text("Mental Demand").bold()
                .frame(height: ApplicationConstants.defaultMaxHeight).offset(x: frame.minX + ApplicationConstants.maxOffset, y:frame.minY + 0.36 * height)
            Text("How much mental and perceptual activity did you spend for this task?")
                .frame(height: ApplicationConstants.defaultMaxHeight).offset(x: frame.minX + ApplicationConstants.maxOffset, y:frame.minY + 0.38 * height)
            Slider(
                sliderValue:Binding<Double>(
                    get: {
                        return self.assesmentRating.mentalDemandValue ?? 0.0
                    },
                    set: {
                        self.assesmentRating.mentalDemandValue = $0
                    }
                ),
                valueRange: 0...100,
                step: 1,
                onEditingChanged: self.onChanged,
                onDragGesture: self.onDragGesture,
                isThumbHidden: self.assesmentRating.mentalDemandValue.isEmpty
            )
            .frame(width: self.maxWidth)
            .offset(x: frame.midX - self.maxWidth / 2, y: frame.minY + 0.445 * height)
            .navigationBarItems(trailing: Button("Quit") {
                print("Quit")
                self.showAlert = true
            })
            if self.hideBackButton {
                self.bottomView(ResultView(), self.disableButton)
                    .offset(x: frame.midX - 100,  y: frame.maxY - 80)
            }
            else {
                self.bottomView(PhysicalDemandView(valueRange : 0...100, step: 1), self.disableButton)
                    .offset(x: frame.midX - 100,  y: frame.maxY - 80)
            }

        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Quit Trial?"), message: Text("You will lose responses for this trial if you choose to quit now."), primaryButton: .default(Text("Continue")) {
                self.assesmentRating.clear()
                self.mode.wrappedValue.dismiss()
            }, secondaryButton: .cancel())
        }
        .onAppear {
            self.title = "1 of 6"
            self.disableButton = self.assesmentRating.mentalDemandValue.isEmpty
        }
        .onDisappear {
            self.title = ""
        }
        .navigationBarBackButtonHidden(self.hideBackButton)
        .navigationTitle(self.title)
        .gesture(DragGesture(minimumDistance: 0).onEnded { value in
            print(value.time)
        })
    }
    
    private func button(_ text: String, _ color: Color) -> some View {
        return Text(text).bold().frame(width: 200, height: 50)
            .foregroundColor(color)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(color, lineWidth: 2))
    }
    
    private func onDragGesture(hiddenThumb: Binding<Bool>) {
        if hiddenThumb.wrappedValue {
            hiddenThumb.wrappedValue = false
        }
        
        if self.disableButton {
            self.disableButton = false
        }
    }
    
    private func onChanged(val: Bool) -> Void {
        print("From changed")
    }
}

struct PhysicalDemandView : View {
    
    @EnvironmentObject
    private var assesmentRating: AssesmentRating
    
    @State
    private var showAlert: Bool = false
    
    @Environment(\.presentationMode)
    private var mode: Binding<PresentationMode>
    
    @State
    private var sliderValue: Double = 0.0;
    @State
    private var disableButton = true
    
    
    @State
    private var title = ""
    
    var valueRange : ClosedRange<Double>
    var step: Double
    var hideBackButton: Bool = false
    let maxWidth: CGFloat = 500
    let maxHeight: CGFloat = 30
    
    var body: some View {
        GeometryReader { geometry in
            let frame = geometry.frame(in: .local);
            let width = geometry.size.width
            let height = geometry.size.height
            
            Rectangle()
                .foregroundColor(.white)
                .frame(width: width, height: height)
                .offset(x: frame.minX, y:frame.minY)
            
            Text("Tap your response on the scale below")
                .frame(height: ApplicationConstants.defaultMaxHeight)
                .offset(x: frame.minX + ApplicationConstants.maxOffset, y:frame.minY)
            Text("Physical Demand").bold()
                .frame(height: ApplicationConstants.defaultMaxHeight).offset(x: frame.minX + ApplicationConstants.maxOffset, y:frame.minY + 0.36 * height)
            Text("How much physical activity did you spend for this task?")
                .frame(height: ApplicationConstants.defaultMaxHeight).offset(x: frame.minX + ApplicationConstants.maxOffset, y:frame.minY + 0.38 * height)
            Slider(
                sliderValue:Binding<Double>(
                    get: {
                        return self.assesmentRating.physicalDemandValue ?? 0.0
                    },
                    set: {
                        self.assesmentRating.physicalDemandValue = $0
                    }
                ),
                valueRange: 0...100,
                step: 1,
                onEditingChanged: self.onChanged,
                onDragGesture: self.onDragGesture,
                isThumbHidden: self.assesmentRating.physicalDemandValue.isEmpty
            )
            .frame(width: self.maxWidth)
            .offset(x: frame.midX - self.maxWidth / 2, y: frame.minY + 0.445 * height)
            .navigationBarItems(trailing: Button("Quit") {
                print("Quit")
                self.showAlert = true
            })
            if self.hideBackButton {
                self.bottomView(ResultView(), self.disableButton)
                    .offset(x: frame.midX - 100,  y: frame.maxY - 80)
            }
            else {
                self.bottomView(TemporalDemandView(valueRange : 0...100, step: 1), self.disableButton)
                    .offset(x: frame.midX - 100,  y: frame.maxY - 80)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Quit Trial?"), message: Text("You will lose responses for this trial if you choose to quit now."), primaryButton: .default(Text("Continue")) {
                self.assesmentRating.clear()
                self.mode.wrappedValue.dismiss()
            }, secondaryButton: .cancel())
        }
        .onAppear {
            self.title = "2 of 6"
            self.disableButton = self.assesmentRating.physicalDemandValue.isEmpty
        }
        .onDisappear {
            self.title = ""
        }
        .navigationBarBackButtonHidden(self.hideBackButton)
        .navigationTitle(self.title)
        .gesture(DragGesture(minimumDistance: 0).onEnded { value in
            print(value.time)
        })
    }
    
    private func button(_ text: String, _ color: Color) -> some View {
        return Text(text).bold().frame(width: 200, height: 50)
            .foregroundColor(color)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(color, lineWidth: 2))
    }
    
    private func onDragGesture(hiddenThumb: Binding<Bool>) {
        if hiddenThumb.wrappedValue {
            hiddenThumb.wrappedValue = false
        }
        
        if self.disableButton {
            self.disableButton = false
        }
        print(self.sliderValue)
    }
    
    private func onChanged(val: Bool) -> Void {
        print("From changed \(self.sliderValue )")
    }
}

struct TemporalDemandView : View {
    @EnvironmentObject
    private var assesmentRating: AssesmentRating
    
    
    @State
    private var showAlert: Bool = false
    
    @Environment(\.presentationMode)
    private var mode: Binding<PresentationMode>
    @State
    private var sliderValue: Double = 0.0;
    @State
    private var disableButton = true
    
    @State
    private var title = ""
    
    var valueRange : ClosedRange<Double>
    var step: Double
    var hideBackButton: Bool = false
    let maxWidth: CGFloat = 500
    let maxHeight: CGFloat = 30
    
    var body: some View {
        GeometryReader { geometry in
            let frame = geometry.frame(in: .local);
            let width = geometry.size.width
            let height = geometry.size.height
            
            Rectangle()
                .foregroundColor(.white)
                .frame(width: width, height: height)
                .offset(x: frame.minX, y:frame.minY)
            
            Text("Tap your response on the scale below")
                .frame(height: ApplicationConstants.defaultMaxHeight)
                .offset(x: frame.minX + ApplicationConstants.maxOffset, y:frame.minY)
            Text("Temporal Demand").bold()
                .frame(height: ApplicationConstants.defaultMaxHeight).offset(x: frame.minX + ApplicationConstants.maxOffset, y:frame.minY + 0.36 * height)
            Text("How much time pressure did you feel in order to complete this task?")
                .frame(height: ApplicationConstants.defaultMaxHeight).offset(x: frame.minX + ApplicationConstants.maxOffset, y:frame.minY + 0.38 * height)
            Slider(
                sliderValue:Binding<Double>(
                    get: {
                        (self.assesmentRating.temporalDemandValue ?? 0.0)
                    },
                    set: {
                        self.assesmentRating.temporalDemandValue = $0
                    }
                ),
                valueRange: 0...100,
                step: 1,
                onEditingChanged: self.onChanged,
                onDragGesture: self.onDragGesture,
                isThumbHidden: self.assesmentRating.temporalDemandValue.isEmpty
            )
            .frame(width: self.maxWidth)
            .offset(x: frame.midX - self.maxWidth / 2, y: frame.minY + 0.445 * height)
            .navigationBarItems(trailing: Button("Quit") {
                print("Quit")
                self.showAlert = true
            })
            if self.hideBackButton {
                self.bottomView(ResultView(), self.disableButton)
                    .offset(x: frame.midX - 100,  y: frame.maxY - 80)
            }
            else {
                self.bottomView(PerformanceView(valueRange : 0...100, step: 1), self.disableButton)
                    .offset(x: frame.midX - 100,  y: frame.maxY - 80)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Quit Trial?"), message: Text("You will lose responses for this trial if you choose to quit now."), primaryButton: .default(Text("Continue")) {
                self.assesmentRating.clear()
                self.mode.wrappedValue.dismiss()
            }, secondaryButton: .cancel())
        }
        .onAppear {
            self.title = "3 of 6"
            self.disableButton = self.assesmentRating.temporalDemandValue.isEmpty
        }
        .onDisappear {
            self.title = ""
        }
        .navigationBarBackButtonHidden(self.hideBackButton)
        .navigationTitle(self.title)
        .gesture(DragGesture(minimumDistance: 0).onEnded { value in
            print(value.time)
        })
    }
    
    private func button(_ text: String, _ color: Color) -> some View {
        return Text(text).bold().frame(width: 200, height: 50)
            .foregroundColor(color)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(color, lineWidth: 2))
    }
    
    private func onDragGesture(hiddenThumb: Binding<Bool>) {
        if hiddenThumb.wrappedValue {
            hiddenThumb.wrappedValue = false
        }
        
        if self.disableButton {
            self.disableButton = false
        }
        print(self.sliderValue)
    }
    
    private func onChanged(val: Bool) -> Void {
        print("From changed \(self.sliderValue )")
    }
}

struct PerformanceView : View {
    
    @EnvironmentObject
    private var assesmentRating: AssesmentRating
    
    @State
    private var showAlert: Bool = false
    
    @Environment(\.presentationMode)
    private var mode: Binding<PresentationMode>
    
    @State
    private var sliderValue: Double = 0.0;
    @State
    private var disableButton = true
    
    @State
    private var title = ""
    
    var valueRange : ClosedRange<Double>
    var step: Double
    var hideBackButton: Bool = false
    let maxWidth: CGFloat = 500
    let maxHeight: CGFloat = 30
    
    var body: some View {
        GeometryReader { geometry in
            let frame = geometry.frame(in: .local);
            let width = geometry.size.width
            let height = geometry.size.height
            
            Rectangle()
                .foregroundColor(.white)
                .frame(width: width, height: height)
                .offset(x: frame.minX, y:frame.minY)
            
            Text("Tap your response on the scale below")
                .frame(height: ApplicationConstants.defaultMaxHeight)
                .offset(x: frame.minX + ApplicationConstants.maxOffset, y:frame.minY)
            Text("Performance Demand").bold()
                .frame(height: ApplicationConstants.defaultMaxHeight).offset(x: frame.minX + ApplicationConstants.maxOffset, y:frame.minY + 0.36 * height)
            Text("How successful do you think you were in accomplishing the goals of the task?")
                .frame(height: ApplicationConstants.defaultMaxHeight).offset(x: frame.minX + ApplicationConstants.maxOffset, y:frame.minY + 0.38 * height)
            Slider(
                sliderValue:Binding<Double>(
                    get: {
                        (self.assesmentRating.performanceValue ?? 0.0)
                    },
                    set: {
                        self.assesmentRating.performanceValue = $0
                    }
                ),
                valueRange: 0...100,
                step: 1,
                onEditingChanged: self.onChanged,
                onDragGesture: self.onDragGesture,
                labelDescription: SliderLabel(left: "Good", right: "Bad"),
                isThumbHidden: self.assesmentRating.performanceValue.isEmpty
            )
            .frame(width: self.maxWidth)
            .offset(x: frame.midX - self.maxWidth / 2, y: frame.minY + 0.445 * height)
            .navigationBarItems(trailing: Button("Quit") {
                print("Quit")
                self.showAlert = true
            })
            if self.hideBackButton {
                self.bottomView(ResultView(), self.disableButton)
                    .offset(x: frame.midX - 100,  y: frame.maxY - 80)
            }
            else {
                self.bottomView(EffortView(valueRange : 0...100, step: 1), self.disableButton)
                    .offset(x: frame.midX - 100,  y: frame.maxY - 80)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Quit Trial?"), message: Text("You will lose responses for this trial if you choose to quit now."), primaryButton: .default(Text("Continue")) {
                self.assesmentRating.clear()
                self.mode.wrappedValue.dismiss()
            }, secondaryButton: .cancel())
        }
        .onAppear {
            self.title = "4 of 6"
            self.disableButton = self.assesmentRating.performanceValue.isEmpty
        }
        .onDisappear {
           self.title = ""
        }
        .navigationBarBackButtonHidden(self.hideBackButton)
        .navigationTitle(self.title)
        .gesture(DragGesture(minimumDistance: 0).onEnded { value in
            print(value.time)
        })
    }
    
    private func button(_ text: String, _ color: Color) -> some View {
        return Text(text).bold().frame(width: 200, height: 50)
            .foregroundColor(color)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(color, lineWidth: 2))
    }
    
    private func onDragGesture(hiddenThumb: Binding<Bool>) {
        if hiddenThumb.wrappedValue {
            hiddenThumb.wrappedValue = false
        }
        
        if self.disableButton {
            self.disableButton = false
        }
        print(self.sliderValue)
    }
    
    private func onChanged(val: Bool) -> Void {
        print("From changed \(self.sliderValue )")
    }
}

struct EffortView : View {
    
    @EnvironmentObject
    private var assesmentRating: AssesmentRating
    
    @State
    private var showAlert: Bool = false
    
    @Environment(\.presentationMode)
    private var mode: Binding<PresentationMode>
    @State
    private var sliderValue: Double = 0.0;
    @State
    private var disableButton = true
    
    @State
    private var title = ""
    
    var valueRange : ClosedRange<Double>
    var step: Double
    var hideBackButton: Bool = false
    let maxWidth: CGFloat = 500
    let maxHeight: CGFloat = 30
    
    var body: some View {
        GeometryReader { geometry in
            let frame = geometry.frame(in: .local);
            let width = geometry.size.width
            let height = geometry.size.height
            
            Rectangle()
                .foregroundColor(.white)
                .frame(width: width, height: height)
                .offset(x: frame.minX, y:frame.minY)
            
            Text("Tap your response on the scale below")
                .frame(height: ApplicationConstants.defaultMaxHeight)
                .offset(x: frame.minX + ApplicationConstants.maxOffset, y:frame.minY)
            Text("Effort").bold()
                .frame(height: ApplicationConstants.defaultMaxHeight).offset(x: frame.minX + ApplicationConstants.maxOffset, y:frame.minY + 0.36 * height)
            Text("How hard did you have to work to accomplish your level of performance?")
                .frame(height: ApplicationConstants.defaultMaxHeight).offset(x: frame.minX + ApplicationConstants.maxOffset, y:frame.minY + 0.38 * height)
            Slider(
                sliderValue:Binding<Double>(
                    get: {
                        (self.assesmentRating.effortLevelValue ?? 0.0)
                    },
                    set: {
                        self.assesmentRating.effortLevelValue = $0
                    }
                ),
                valueRange: 0...100,
                step: 1,
                onEditingChanged: self.onChanged,
                onDragGesture: self.onDragGesture,
                isThumbHidden: self.assesmentRating.effortLevelValue.isEmpty
            )
            .frame(width: self.maxWidth)
            .offset(x: frame.midX - self.maxWidth / 2, y: frame.minY + 0.445 * height)
            .navigationBarItems(trailing: Button("Quit") {
                print("Quit")
                self.showAlert = true
            })
            
            if self.hideBackButton {
                self.bottomView(ResultView(), self.disableButton)
                    .offset(x: frame.midX - 100,  y: frame.maxY - 80)
            }
            else {
                self.bottomView(FrustationView(valueRange : 0...100, step: 1), self.disableButton)
                    .offset(x: frame.midX - 100,  y: frame.maxY - 80)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Quit Trial?"), message: Text("You will lose responses for this trial if you choose to quit now."), primaryButton: .default(Text("Continue")) {
                self.assesmentRating.clear()
                self.mode.wrappedValue.dismiss()
            }, secondaryButton: .cancel())
        }
        .onAppear {
            self.title = "5 of 6"
            self.disableButton = self.assesmentRating.effortLevelValue.isEmpty
        }
        .onDisappear {
            self.title = ""
        }
        .navigationBarBackButtonHidden(self.hideBackButton)
        .navigationTitle(self.title)
        .gesture(DragGesture(minimumDistance: 0).onEnded { value in
            print(value.time)
        })
    }
    
    private func button(_ text: String, _ color: Color) -> some View {
        return Text(text).bold().frame(width: 200, height: 50)
            .foregroundColor(color)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(color, lineWidth: 2))
    }
    
    private func onDragGesture(hiddenThumb: Binding<Bool>) {
        if hiddenThumb.wrappedValue {
            hiddenThumb.wrappedValue = false
        }
        
        if self.disableButton {
            self.disableButton = false
        }
        print(self.sliderValue)
    }
    
    private func onChanged(val: Bool) -> Void {
        print("From changed \(self.sliderValue )")
    }
}

struct FrustationView : View {
    
    @EnvironmentObject
    private var assesmentRating: AssesmentRating
    
    
    @State
    private var showAlert: Bool = false
    
    @Environment(\.presentationMode)
    private var mode: Binding<PresentationMode>
    
    @State
    private var sliderValue: Double = 0.0;
    @State
    private var disableButton = true
    
    @State
    private var title = ""
    
    var valueRange : ClosedRange<Double>
    var step: Double
    var hideBackButton: Bool = false
    let maxWidth: CGFloat = 500
    let maxHeight: CGFloat = 30
    
    var body: some View {
        GeometryReader { geometry in
            let frame = geometry.frame(in: .local);
            let width = geometry.size.width
            let height = geometry.size.height
            
            Rectangle()
                .foregroundColor(.white)
                .frame(width: width, height: height)
                .offset(x: frame.minX, y:frame.minY)
            
            Text("Tap your response on the scale below")
                .frame(height: ApplicationConstants.defaultMaxHeight)
                .offset(x: frame.minX + ApplicationConstants.maxOffset, y:frame.minY)
            Text("Frustation").bold()
                .frame(height: ApplicationConstants.defaultMaxHeight).offset(x: frame.minX + ApplicationConstants.maxOffset, y:frame.minY + 0.36 * height)
            Text("How insecure, discouraged, irritated, stressed, and annoyed were you during this task?")
                .frame(height: ApplicationConstants.defaultMaxHeight).offset(x: frame.minX + ApplicationConstants.maxOffset, y:frame.minY + 0.38 * height)
            Slider(
                sliderValue:Binding<Double>(
                    get: {
                        (self.assesmentRating.frustationLevelValue ?? 0.0)
                    },
                    set: {
                        self.assesmentRating.frustationLevelValue = $0
                    }
                ),
                valueRange: 0...100,
                step: 1,
                onEditingChanged: self.onChanged,
                onDragGesture: self.onDragGesture,
                isThumbHidden: self.assesmentRating.frustationLevelValue.isEmpty
            )
            .frame(width: self.maxWidth)
            .offset(x: frame.midX - self.maxWidth / 2, y: frame.minY + 0.445 * height)
            .navigationBarItems(trailing: Button("Quit") {
                print("Quit")
                self.showAlert = true
            })
            
            if self.hideBackButton {
                self.bottomView(ResultView(), self.assesmentRating.frustationLevelValue.isEmpty)
                    .offset(x: frame.midX - 100,  y: frame.maxY - 80)
            }
            else {
                self.bottomView(ResultView(), self.assesmentRating.frustationLevelValue.isEmpty)
                    .offset(x: frame.midX - 100,  y: frame.maxY - 80)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Quit Trial?"), message: Text("You will lose responses for this trial if you choose to quit now."), primaryButton: .default(Text("Continue")) {
                self.assesmentRating.clear()
                self.mode.wrappedValue.dismiss()
            }, secondaryButton: .cancel())
        }
        .onAppear {
            self.title = "6 of 6"
        }
        .onDisappear {
            self.title = ""
        }
        .navigationBarBackButtonHidden(self.hideBackButton)
        .navigationTitle(self.title)
        .gesture(DragGesture(minimumDistance: 0).onEnded { value in
            print(value.time)
        })
    }
    
    private func button(_ text: String, _ color: Color) -> some View {
        return Text(text).bold().frame(width: 200, height: 50)
            .foregroundColor(color)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(color, lineWidth: 2))
    }
    
    private func onDragGesture(hiddenThumb: Binding<Bool>) {
        if hiddenThumb.wrappedValue {
            hiddenThumb.wrappedValue = false
        }
        
        if self.disableButton {
            self.disableButton = false
        }
        print(self.sliderValue)
    }
    
    private func onChanged(val: Bool) -> Void {
        print("From changed \(self.sliderValue )")
    }
}

struct ResultView : View {
    @State
    private var frustationSliderValue: Double = 0.0;
    
    
    @State
    private var showAlert: Bool = false
    
    @Environment(\.presentationMode)
    private var mode: Binding<PresentationMode>
    
    @EnvironmentObject
    private var assesmentRating: AssesmentRating
    static let maxWidth: CGFloat = 500
    static let maxHeight: CGFloat = 30
    @State
    private var title = ""
    
    var body: some View {
        GeometryReader { geometry in
            let frame = geometry.frame(in: .local);
            let width = geometry.size.width
            let height = geometry.size.height
            
            Group {
                Rectangle()
                    .foregroundColor(.white)
                    .frame(width: width, height: height)
                    .offset(x: frame.minX, y:frame.minY)
                Text("You've finished the evaluation. A summary of your responses is shown below for your review.You may tap any responses below to go back to the associated question and change your answer.")
                    .foregroundColor(.black)
                    .bold().font(.custom("", size: 16))
                    .offset(x: frame.minX + 20, y: frame.minY + 0.03 * height)
                
                Text("If you're ready to submit your responses tap Finish.")
                    .foregroundColor(.black)
                    .bold()
                    .font(.custom("", size: 16))
                    .frame(height: ApplicationConstants.defaultMaxHeight)
                    .offset(x: frame.minX + 20, y: frame.minY + 0.09 * height)
                
                Text("Rating Scale Summary").bold().fontWeight(.heavy)
                    .offset(x: frame.minX + 20, y: frame.minY + 0.17 * height)
            }
            
            self.mentalDemandView(geometry: geometry)
            self.physicalDemandView(geometry: geometry)
            self.temporalDemandView(geometry: geometry)
            self.performanceView(geometry: geometry);
            self.effortView(geometry: geometry)
            self.frustationView(geometry: geometry)
            Divider().offset(x: frame.minX, y: frame.minY + 0.855 * height)
            self.button("Finish", .blue).offset(x: frame.midX - 100,  y: frame.maxY - 80)
                .navigationBarItems(trailing: Button("Quit") {
                    print("Quit")
                    self.showAlert = true
                })
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Quit Trial?"), message: Text("You will lose responses for this trial if you choose to quit now."), primaryButton: .default(Text("Continue")) {
                self.assesmentRating.clear()
                
                self.mode.wrappedValue.dismiss()
            }, secondaryButton: .cancel())
        }.onAppear {
            self.title = "Evaluation Review"
        }.onDisappear {
            self.title = ""
        }
        .navigationTitle(self.title)
        .gesture(DragGesture(minimumDistance: 0).onEnded { value in
            print(value.time)
        })
    }
    

    private func mentalDemandView(geometry: GeometryProxy) -> some View {
        let frame = geometry.frame(in: .local);
        let height = geometry.size.height
        return Group {
            Text("Mental Demand")
                .bold()
                //.frame(width: 700, alignment: .leading)
                .offset(x: frame.minX + 20, y: frame.minY + 0.20 * height)
            
            NavigationLink(destination: MentalDemandView(valueRange : 0...100, step: 1, hideBackButton: true), label: {
                Slider(
                    sliderValue: Binding<Double>(
                        get: {
                            (self.assesmentRating.mentalDemandValue ?? 0.0)
                        },
                        set: {
                            self.assesmentRating.mentalDemandValue = $0
                        }
                    ),
                    valueRange: 0...100,
                    step: 1,
                    isThumbHidden: false
                )
                .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                .frame(width: ResultView.maxWidth)
            }).offset(x: frame.midX - ResultView.maxWidth / 2 , y: frame.minY + 0.23 * height)
        }
        
    }
    
    private func physicalDemandView(geometry: GeometryProxy) -> some View {
        let frame = geometry.frame(in: .local);
        let height = geometry.size.height
        return Group {
            Divider().offset(x: frame.minX, y: frame.minY + 0.305 * height)
            Text("Physical Demand")
                .bold()
                .frame(width: 700, alignment: .leading)
                .offset(x: frame.minX + 20, y: frame.minY + 0.31 * height)
            NavigationLink(destination: PhysicalDemandView(valueRange : 0...100, step: 1, hideBackButton: true), label: {
                Slider(
                    sliderValue:Binding<Double>(
                        get: {
                            (self.assesmentRating.physicalDemandValue ?? 0.0)
                        },
                        set: {
                            self.assesmentRating.physicalDemandValue = $0
                        }
                    ),
                    valueRange: 0...100,
                    step: 1,
                    isThumbHidden: false)
                    .disabled(true)
                    .frame(width: ResultView.maxWidth)
            }).offset(x: frame.midX - ResultView.maxWidth / 2 , y: frame.minY + 0.34 * height)
        }
    }
    
    private func temporalDemandView(geometry: GeometryProxy) -> some View {
        let frame = geometry.frame(in: .local);
        let height = geometry.size.height
        return Group {
            Divider().offset(x: frame.minX, y: frame.minY + 0.415 * height)
            Text("Temporal Demand")
                .bold()
                .frame(width: 700, alignment: .leading)
                .offset(x: frame.minX + 20, y: frame.minY + 0.42 * height)
            NavigationLink(destination: TemporalDemandView(valueRange : 0...100, step: 1, hideBackButton: true), label: {
                Slider(
                    sliderValue:Binding<Double>(
                        get: {
                            (self.assesmentRating.temporalDemandValue ?? 0.0)
                        },
                        set: {
                            self.assesmentRating.temporalDemandValue = $0
                        }
                    ),
                    valueRange: 0...100,
                    step: 1,
                    isThumbHidden: false)
                    .disabled(true)
                    .frame(width: ResultView.maxWidth)
            }).offset(x: frame.midX - ResultView.maxWidth / 2 , y: frame.minY + 0.45 * height)
        }
    }
    
    private func performanceView(geometry: GeometryProxy) -> some View {
        let frame = geometry.frame(in: .local);
        let height = geometry.size.height
        return Group {
            Divider().offset(x: frame.minX, y: frame.minY + 0.525 * height)
            Text("Performance")
                .bold()
                .frame(width: 700, alignment: .leading)
                .offset(x: frame.minX + 20, y: frame.minY + 0.53 * height)
            NavigationLink(destination: PerformanceView(valueRange : 0...100, step: 1, hideBackButton: true), label: {
                Slider(
                    sliderValue:Binding<Double>(
                        get: {
                            (self.assesmentRating.performanceValue ?? 0.0)
                        },
                        set: {
                            self.assesmentRating.performanceValue = $0
                        }
                    ),
                    valueRange: 0...100,
                    step: 1,
                    labelDescription: SliderLabel(),
                    isThumbHidden: false)
                    .disabled(true)
                    .frame(width: ResultView.maxWidth)
            }).offset(x: frame.midX - ResultView.maxWidth / 2 , y: frame.minY + 0.56 * height)
        }
    }
    
    private func effortView(geometry: GeometryProxy) -> some View {
        let frame = geometry.frame(in: .local);
        let height = geometry.size.height
        return Group {
            Divider().offset(x: frame.minX, y: frame.minY + 0.635 * height)
            Text("Effort")
                .bold()
                .frame(width: 700, alignment: .leading)
                .offset(x: frame.minX + 20, y: frame.minY + 0.64 * height)
            NavigationLink(destination: EffortView(valueRange : 0...100, step: 1, hideBackButton: true), label: {
                Slider(
                    sliderValue:Binding<Double>(
                        get: {
                            (self.assesmentRating.effortLevelValue ?? 0.0)
                        },
                        set: {
                            self.assesmentRating.effortLevelValue = $0
                        }
                    ),
                    valueRange: 0...100,
                    step: 1,
                    isThumbHidden: false)
                    .disabled(true)
                    .frame(width: ResultView.maxWidth)
            }).offset(x: frame.midX - ResultView.maxWidth / 2 , y: frame.minY + 0.67 * height)
        }
    }
    
    private func frustationView(geometry: GeometryProxy) -> some View {
        let frame = geometry.frame(in: .local);
        let height = geometry.size.height
        return Group {
            Divider().offset(x: frame.minX, y: frame.minY + 0.745 * height)
            Text("Frustation").bold()
                .frame(width: 700, alignment: .leading)
                .offset(x: frame.minX + 20, y: frame.minY + 0.75 * height)
            NavigationLink(destination: FrustationView(valueRange : 0...100, step: 1, hideBackButton: true), label: {
                Slider (
                    sliderValue:Binding<Double>(
                        get: {
                            (self.assesmentRating.frustationLevelValue ?? 0.0)
                        },
                        set: {
                            self.assesmentRating.frustationLevelValue = $0
                        }
                    ),
                    valueRange: 0...100,
                    step: 1,
                    isThumbHidden: false
                ).disabled(true).frame(width: ResultView.maxWidth)
            }).offset(x: frame.midX - ResultView.maxWidth / 2 , y: frame.minY + 0.78 * height)
        }
    }
}


fileprivate extension View {
    func debugPrint(value: Any) -> some View {
        print(value)
        return EmptyView()
    }
}


fileprivate extension View {
    @ViewBuilder
    func bottomView<NextView>(_ destination: NextView, _ isDisabledButton: Bool) -> some View where NextView : View {
        if isDisabledButton {
            self.button("Next", .gray)
        }
        else {
            AnyView(NavigationLink(destination: destination, label: {
                self.button("Next", .blue)
            }))
        }
    }
    
    func button(_ text: String, _ color: Color) -> some View {
        return Text(text).bold()
            .frame(width: 200, height: 50)
            .foregroundColor(color)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(color, lineWidth: 2))
    }
}
