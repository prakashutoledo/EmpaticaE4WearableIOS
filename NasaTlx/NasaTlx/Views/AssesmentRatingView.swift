//
//  AssesmentRatingView.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 1/24/22.
//

import SwiftUI

struct AssesmentRatingView : View {
    static let maxWidth: CGFloat = 500
    static let maxHeight: CGFloat = 30
    
    @State
    private var frustationSliderValue: Double = 0.0;
    
    @State
    private var showAlert: Bool = false
    
    @State
    private var isFrustationInfo: Bool = false
    
    @State
    private var isFrustationThumb: Bool = true
    
    @State
    private var isEffortInfo: Bool = false
    
    @State
    private var isPerformanceInfo: Bool = false
    
    @State
    private var isTemporalDemandInfo: Bool = false
    
    @State
    private var isPhysicalDemandInfo: Bool = false
    
    @State
    private var isMentalDemandInfo: Bool = false
    
    @EnvironmentObject
    private var assesmentRating: AssesmentRating
    
    var body: some View {
        GeometryReader(
            content: self.assesmentRatingContent
        )
        .onDisappear {
            assesmentRating.clear()
        }
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    private func assesmentRatingContent(geometry: GeometryProxy) -> some View {
        let frame = geometry.frame(in: .local);
        let width = geometry.size.width
        let height = geometry.size.height
        
        Group {
            Rectangle()
                .foregroundColor(.white)
                .frame(width: width, height: height)
                .offset(x: frame.minX, y:frame.minY)
            Text("You've finished the task. Click on each scale at the point that best indicates your experience of the task. You may tap any responses below to change your answer.")
                .foregroundColor(.black)
                .bold().font(.custom("", size: 16))
                .offset(x: frame.minX, y: frame.minY + 0.04 * height)
                .padding()
            
            Text("Tap info sign for more information about given scale below. If you're ready to submit your responses tap Next.")
                .foregroundColor(.black)
                .bold()
                .font(.custom("", size: 16))
                .frame(height: ApplicationConstants.defaultMaxHeight)
                .offset(x: frame.minX, y: frame.minY + 0.09 * height)
                .padding()
            
            Text("Rating Scale Summary").bold().fontWeight(.heavy)
                .offset(x: frame.minX + 20, y: frame.minY + 0.17 * height)
            
            self.mentalDemandView(geometry: geometry)
            self.physicalDemandView(geometry: geometry)
            self.temporalDemandView(geometry: geometry)
            self.performanceView(geometry: geometry);
            self.effortView(geometry: geometry)
            self.frustationView(geometry: geometry)
        }
    }
    
    private func mentalDemandView(geometry: GeometryProxy) -> some View {
        let frame = geometry.frame(in: .local);
        let height = geometry.size.height
        return Group {
            Text("Mental Demand")
                .bold()
                .frame(width: 700, alignment: .leading)
                .offset(x: frame.minX + 20, y: frame.minY + 0.20 * height)
            Image(systemName: "info.circle")
                .frame(width: 20, height: 20)
                .offset(x: frame.maxX - 40, y: frame.minY + 0.20 * height)
                .onTapGesture {
                    self.isMentalDemandInfo.toggle()
                }
            if self.isMentalDemandInfo {
                Text("How much mental and perceptual activity was required (e.g. thinking, deciding, calculating, remembering, looking, searching, etc)? Was the task easy or demanding, simple or complex, exacting or forgiving?")
                    .foregroundColor(.black)
                    .bold().font(.custom("", size: 16))
                    .frame(width: AssesmentRatingView.maxWidth, alignment: .leading)
                    .offset(x: frame.midX - AssesmentRatingView.maxWidth / 2 , y: frame.minY + 0.23 * height)
                    .onTapGesture {
                        self.isMentalDemandInfo.toggle()
                    }
            }
            else {
                Text("How mentally demanding was the task?")
                    .foregroundColor(.black)
                    .bold().font(.custom("", size: 16))
                    .frame(width: AssesmentRatingView.maxWidth, alignment: .trailing)
                    .offset(x: frame.midX - AssesmentRatingView.maxWidth / 2 , y: frame.minY + 0.20 * height)
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
                    onDragGesture: self.onDragGesture,
                    isThumbHidden: self.assesmentRating.mentalDemandValue.isEmpty
                )
                .frame(width: AssesmentRatingView.maxWidth)
                .offset(x: frame.midX - AssesmentRatingView.maxWidth / 2 , y: frame.minY + 0.23 * height)
            }
        }
        
    }
    
    private func physicalDemandView(geometry: GeometryProxy) -> some View {
        let frame = geometry.frame(in: .local);
        let height = geometry.size.height
        return Group {
            Divider().offset(x: frame.minX, y: frame.minY + 0.32 * height)
            Text("Physical Demand")
                .bold()
                .frame(width: 700, alignment: .leading)
                .offset(x: frame.minX + 20, y: frame.minY + 0.325 * height)
            Image(systemName: "info.circle")
                .frame(width: 20, height: 20)
                .offset(x: frame.maxX - 40, y: frame.minY + 0.325 * height)
                .onTapGesture {
                    self.isPhysicalDemandInfo.toggle()
                }
            
            if self.isPhysicalDemandInfo {
                Text("How much physical activity was required (e.g. pushing, pulling, turning, controlling, activating, etc)? Was the task easy or demanding, slow or brisk, slack or strenuous, restful or laborious?")
                    .foregroundColor(.black)
                    .bold().font(.custom("", size: 16))
                    .frame(width: AssesmentRatingView.maxWidth, alignment: .leading)
                    .offset(x: frame.midX - AssesmentRatingView.maxWidth / 2 , y: frame.minY + 0.355 * height)
                    .onTapGesture {
                        self.isPhysicalDemandInfo.toggle()
                    }
            }
            else {
                Text("How physically demanding was the task?")
                    .foregroundColor(.black)
                    .bold().font(.custom("", size: 16))
                    .frame(width: AssesmentRatingView.maxWidth, alignment: .trailing)
                    .offset(x: frame.midX - AssesmentRatingView.maxWidth / 2 , y: frame.minY + 0.325 * height)
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
                    onDragGesture: self.onDragGesture,
                    isThumbHidden: self.assesmentRating.physicalDemandValue.isEmpty)
                    .frame(width: AssesmentRatingView.maxWidth)
                    .offset(x: frame.midX - AssesmentRatingView.maxWidth / 2 , y: frame.minY + 0.355 * height)
            }
        }
    }
    
    private func temporalDemandView(geometry: GeometryProxy) -> some View {
        let frame = geometry.frame(in: .local);
        let height = geometry.size.height
        return Group {
            Divider().offset(x: frame.minX, y: frame.minY + 0.445 * height)
            Text("Temporal Demand")
                .bold()
                .frame(width: 700, alignment: .leading)
                .offset(x: frame.minX + 20, y: frame.minY + 0.45 * height)
            Image(systemName: "info.circle")
                .frame(width: 20, height: 20)
                .offset(x: frame.maxX - 40, y: frame.minY + 0.45 * height)
                .onTapGesture {
                    self.isTemporalDemandInfo.toggle()
                }
            if self.isTemporalDemandInfo {
                Text("How much time pressure did you feel due to the rate of pace at which the tasks or task elements occurred? Was the pace slow and leisurely or rapid and frantic?\nNote the locations of the endpoints are different before answering.")
                    .foregroundColor(.black)
                    .bold().font(.custom("", size: 16))
                    .frame(width: AssesmentRatingView.maxWidth, alignment: .leading)
                    .offset(x: frame.midX - AssesmentRatingView.maxWidth / 2 , y: frame.minY + 0.465 * height)
                    .onTapGesture {
                        self.isTemporalDemandInfo.toggle()
                    }
            }
            else {
                Text("How hurried or rushed was the pace of the task?")
                    .foregroundColor(.black)
                    .bold().font(.custom("", size: 16))
                    .frame(width: AssesmentRatingView.maxWidth, alignment: .trailing)
                    .offset(x: frame.midX - AssesmentRatingView.maxWidth / 2 , y: frame.minY + 0.45 * height)

                Slider(
                    sliderValue: Binding<Double>(
                        get: {
                            (self.assesmentRating.temporalDemandValue ?? 0.0)
                        },
                        set: {
                            self.assesmentRating.temporalDemandValue = $0
                        }
                    ),
                    valueRange: 0...100,
                    step: 1,
                    onDragGesture: self.onDragGesture,
                    labelDescription: SliderLabel(left: "Low", right: "High"),
                    isThumbHidden:  self.assesmentRating.temporalDemandValue.isEmpty
                )
                .frame(width: AssesmentRatingView.maxWidth)
                .offset(x: frame.midX - AssesmentRatingView.maxWidth / 2 , y: frame.minY + 0.48 * height)
            }
        }
    }
    
    private func performanceView(geometry: GeometryProxy) -> some View {
        let frame = geometry.frame(in: .local);
        let height = geometry.size.height
        return Group {
            Divider().offset(x: frame.minX, y: frame.minY + 0.57 * height)
            Text("Performance")
                .bold()
                .frame(width: 700, alignment: .leading)
                .offset(x: frame.minX + 20, y: frame.minY + 0.575 * height)
            Image(systemName: "info.circle")
                .frame(width: 20, height: 20)
                .offset(x: frame.maxX - 40, y: frame.minY + 0.575 * height)
                .onTapGesture {
                    self.isPerformanceInfo.toggle()
                }
            
            if self.isPerformanceInfo {
                Text("How successful do you think you were in accomplishing the goals of the task set by the experimenter (or yourself)? How satisfied were you with your performance in accomplishing these goals?")
                    .foregroundColor(.black)
                    .bold().font(.custom("", size: 16))
                    .frame(width: AssesmentRatingView.maxWidth, alignment: .leading)
                    .offset(x: frame.midX - AssesmentRatingView.maxWidth / 2 , y: frame.minY + 0.575 * height)
                    .onTapGesture {
                        self.isPerformanceInfo.toggle()
                    }
            }
            else {
                Text("How successful you were in accomplishing what you were asked to do?")
                    .foregroundColor(.black)
                    .bold().font(.custom("", size: 16))
                    .frame(width: AssesmentRatingView.maxWidth, alignment: .trailing)
                    .offset(x: frame.midX - AssesmentRatingView.maxWidth / 2 , y: frame.minY + 0.575 * height)
                Slider(
                    sliderValue: Binding<Double>(
                        get: {
                            (self.assesmentRating.performanceValue ?? 0.0)
                        },
                        set: {
                            self.assesmentRating.performanceValue = $0
                        }
                    ),
                    valueRange: 0...100,
                    step: 1,
                    onDragGesture: self.onDragGesture,
                    labelDescription: SliderLabel(left: "Good", right: "Poor"),
                    isThumbHidden: self.assesmentRating.performanceValue.isEmpty
                )
                .frame(width: AssesmentRatingView.maxWidth)
               .offset(x: frame.midX - AssesmentRatingView.maxWidth / 2 , y: frame.minY + 0.626 * height)
            }
        }
    }
    
    private func effortView(geometry: GeometryProxy) -> some View {
        let frame = geometry.frame(in: .local);
        let height = geometry.size.height
        return Group {
            Divider().offset(x: frame.minX, y: frame.minY + 0.716 * height)
            Text("Effort")
                .bold()
                .frame(width: 700, alignment: .leading)
                .offset(x: frame.minX + 20, y: frame.minY + 0.721 * height)
            Image(systemName: "info.circle")
                .frame(width: 20, height: 20)
                .offset(x: frame.maxX - 40, y: frame.minY + 0.721 * height)
                .onTapGesture {
                    self.isEffortInfo.toggle()
                }
            if self.isEffortInfo {
                Text("How hard did you have to work (mentally and physically) to accomplish your level of performance?                                        ")
                    .foregroundColor(.black)
                    .bold().font(.custom("", size: 16))
                    .frame(width: AssesmentRatingView.maxWidth, alignment: .leading)
                    .offset(x: frame.midX - AssesmentRatingView.maxWidth / 2 , y: frame.minY + 0.721 * height)
                    .onTapGesture {
                        self.isEffortInfo.toggle()
                    }
            }
            else {
                Text("How hard did you have to work to accomplish your level of performance?")
                    .foregroundColor(.black)
                    .bold().font(.custom("", size: 16))
                    .frame(width: AssesmentRatingView.maxWidth, alignment: .trailing)
                    .offset(x: frame.midX - AssesmentRatingView.maxWidth / 2 , y: frame.minY + 0.721 * height)
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
                    onDragGesture: self.onDragGesture,
                    isThumbHidden: assesmentRating.effortLevelValue.isEmpty)
                    .frame(width: AssesmentRatingView.maxWidth)
                    .offset(x: frame.midX - AssesmentRatingView.maxWidth / 2 , y: frame.minY + 0.750 * height)
            }
        }
    }
    
    private func frustationView(geometry: GeometryProxy) -> some View {
        let frame = geometry.frame(in: .local);
        let height = geometry.size.height
        return Group {
            Divider().offset(x: frame.minX, y: frame.minY + 0.838 * height)
            Text("Frustration").bold()
                .frame(width: 700, alignment: .leading)
                .offset(x: frame.minX + 20, y: frame.minY + 0.843 * height)
            Image(systemName: "info.circle")
                .frame(width: 20, height: 20)
                .offset(x: frame.maxX - 40, y: frame.minY + 0.843 * height)
                .onTapGesture {
                    self.isFrustationInfo.toggle()
                }
            if self.isFrustationInfo {
                Text("How insecure, discouraged, irritated, stressed and annoyed versus secure, gratified, content, relaxed and complacent did you feel during the task?")
                    .foregroundColor(.black)
                    .bold().font(.custom("", size: 16))
                    .frame(width: AssesmentRatingView.maxWidth, alignment: .leading)
                    .offset(x: frame.midX - AssesmentRatingView.maxWidth / 2 , y: frame.minY + 0.843 * height)
                    .onTapGesture {
                        self.isFrustationInfo.toggle()
                    }
            }
            else {
                Text("How insecure, discouraged, irritated, stressed, and annoyed were you?")
                    .foregroundColor(.black)
                    .bold().font(.custom("", size: 16))
                    .frame(width: AssesmentRatingView.maxWidth, alignment: .trailing)
                    .offset(x: frame.midX - AssesmentRatingView.maxWidth / 2 , y: frame.minY + 0.843 * height)
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
                        onDragGesture: self.onDragGesture,
                        isThumbHidden: self.assesmentRating.frustationLevelValue.isEmpty
                )
                
                    .frame(width: AssesmentRatingView.maxWidth)
                .offset(x: frame.midX - AssesmentRatingView.maxWidth / 2 , y: frame.minY + 0.890 * height)
            }
        }
    }
    
    private func onDragGesture(hiddenThumb: Binding<Bool>) {
        if hiddenThumb.wrappedValue {
            hiddenThumb.wrappedValue = false
        }
    }
}
