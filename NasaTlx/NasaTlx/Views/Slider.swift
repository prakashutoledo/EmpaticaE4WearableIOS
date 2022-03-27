import SwiftUI
import Sliders

struct Slider: View {
    private var configuration: TappableSliderConfiguration
    
    @State
    private var isThumbHidden: Bool = false
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.reader(geometry: geometry)
                self.drawSliderMarks(geometry: geometry)
            }
            .frame(maxHeight: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            
            if let labelDescription = configuration.labelDescription {
                HStack {
                    Text(labelDescription.left!).foregroundColor(.black).padding(.trailing)
                    Spacer()
                    Text(labelDescription.right!).foregroundColor(.black).padding(.leading)
                }
            }
        }
    }
    
    private func drawSliderMarks(geometry: GeometryProxy) -> some View {
        let frame: CGRect = geometry.frame(in: .local)
        return Path(Int(frame.origin.x), Int(geometry.size.height/2 + 20), maxWidth: Int(geometry.size.width), maxHeight: 20).stroke(Color.gray, lineWidth: 1)
    }
    
    private func reader(geometry: GeometryProxy) -> some View {
        let frame: CGRect = geometry.frame(in: .local)
        return self.valueSlider.valueSliderStyle(self.defaultStyle)
            .frame(width: geometry.size.width, height:frame.size.height)
            .gesture(DragGesture(minimumDistance: 0).onEnded { value in
                self.onDragComplete(geometry: geometry, value: value)
            })
    }
    
    private func onDragComplete(geometry: GeometryProxy,value: DragGesture.Value) -> Void {
        let percent = min(max(0, Double(value.location.x / geometry.size.width * 1)), 1)
        let newValue = self.configuration.valueRange.lowerBound + round(percent * (self.configuration.valueRange.upperBound - self.configuration.valueRange.lowerBound))
        self.configuration.sliderValue.wrappedValue = newValue
        self.configuration.onDragGesture(self.$isThumbHidden)
    }
    
    private var valueSlider: some View {
        ValueSlider(
            value: self.configuration.sliderValue,
            in: self.configuration.valueRange,
            step: self.configuration.step,
            onEditingChanged: self.configuration.onEditingChanged
        )
    }
    
    private var defaultStyle: AnyValueSliderStyle {
        AnyValueSliderStyle(
            HorizontalValueSliderStyle(
                track: self.defaultSliderTrack(Rectangle().foregroundColor(.clear))
                    .background(Rectangle().foregroundColor(.white) ,alignment: .bottom)
                    .frame(height: 40),
                thumb: Rectangle().foregroundColor(.red).hidden(self.isThumbHidden),
                thumbSize: CGSize(width:2, height: 40)
            )
        )
    }
    
    private func defaultSliderTrack<Track>(_ view: Track) -> some View where Track: View {
        return HorizontalTrack(view: view)
    }
}

extension Slider {
    init(_ configuration: TappableSliderConfiguration, _ isThumbHidden: Bool) {
        self.configuration = configuration;
        self._isThumbHidden = State(initialValue: isThumbHidden)
    }
}

extension Slider {
    public init(
        sliderValue: Binding<Double>,
        valueRange: ClosedRange<Double>,
        step: Double,
        onEditingChanged: @escaping (Bool) -> Void = {_ in},
        onDragGesture: @escaping (Binding<Bool>) -> Void = {_ in},
        labelDescription: SliderLabel = SliderLabel(),
        isThumbHidden: Bool = false
    ) {
        self.init(
            TappableSliderConfiguration(
                sliderValue: sliderValue,
                valueRange: valueRange,
                step: step,
                onDragGesture: onDragGesture,
                onEditingChanged: onEditingChanged,
                labelDescription: labelDescription
            ),isThumbHidden
        )
    }
}
