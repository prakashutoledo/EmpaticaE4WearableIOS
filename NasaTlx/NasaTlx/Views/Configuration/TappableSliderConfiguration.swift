import Foundation
import SwiftUI

public struct TappableSliderConfiguration {
    public let sliderValue: Binding<Double>
    public let valueRange: ClosedRange<Double>
    public let step: Double
    public let onDragGesture: (Binding<Bool>) -> Void
    public let onEditingChanged: (Bool) -> Void
    public var labelDescription: SliderLabel? = SliderLabel()
}

public struct SliderLabel {
    var left: String? = "Low"
    var right: String? = "High"
}
