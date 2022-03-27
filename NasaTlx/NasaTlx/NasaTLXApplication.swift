//
//  NasaTlxApp.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 2/10/21.
//

import SwiftUI

@main
struct NasaTLXApplication: App {
    @Environment(\.scenePhase)
    private var scenePhase: ScenePhase
    
    @ObservedObject
    private var empaticaService: EmpaticaE4Service
    
    @ObservedObject
    private var ntpService: NTPSyncService
    
    @ObservedObject
    private var assesmentRating: AssesmentRating
    
    @ObservedObject
    private var taskSimulationService: TaskSimulationService
    
    @ObservedObject
    private var webSocketService: WebSocketService
    
    @ObservedObject
    private var applicationPropertiesService: ApplicationPropertiesService

    init() {
        self.empaticaService = EmpaticaE4Service.singleton
        self.ntpService = NTPSyncService.singleton
        self.taskSimulationService = TaskSimulationService.singleton
        self.webSocketService = WebSocketService.singleton
        self.applicationPropertiesService = ApplicationPropertiesService.singleton
        self.assesmentRating = AssesmentRating()
        
        self.applicationPropertiesService.load()
        EmpaticaE4Service.currentView = "Main Window"
    }
    
    var body: some Scene {
        WindowGroup {
            SimulationView()
                .environmentObject(self.empaticaService)
                .environmentObject(self.ntpService)
                .environmentObject(self.assesmentRating)
                .environmentObject(self.taskSimulationService)
                .environmentObject(self.webSocketService)
                .environmentObject(self.applicationPropertiesService)
            
        }
        .onChange(of: scenePhase, perform: changeScenePhase)
    }
    
    private func changeScenePhase(newScenePhase: ScenePhase) -> Void {
        switch newScenePhase {
            case .active:
                print("Application resumed")
                self.empaticaService.prepareForResume()
                break
            case .background:
                print("Application in background")
                self.empaticaService.prepareForBackground()
                break
            case .inactive:
                break
            @unknown default:
                print("Unknown scene phase")
        }
    }
}
