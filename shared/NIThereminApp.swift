//
//  NIThereminApp.swift
//  NITheremin
//
//  Created by 白 on 2025/5/24.
//  Copyright © 2025 Apple. All rights reserved.
//

import SwiftUI
import NearbyInteraction
import os

#if os(watchOS)
import WatchKit
#else
import UIKit
#endif

@main
struct WatchNIDemoApp: App {
    
    private var niManager: NearbyInteractionManager?
    
    
    init() {
        var isSupported: Bool
        if #available(iOS 16.0, watchOS 9.0, *) {
            isSupported = NISession.deviceCapabilities.supportsPreciseDistanceMeasurement
        } else {
            isSupported = NISession.isSupported
        }
        if isSupported {
            niManager = NearbyInteractionManager()
        }
    }
    
    @State var distance: Double?
    
    var body: some Scene {
        WindowGroup {
            Group {
                if let niManager = niManager {
                    ContentView(niManager: niManager)
                } else {
                    Text("设备不支持该功能!")
                }
            }
            .multilineTextAlignment(.center)
            #if os(iOS)
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = true
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
            #endif
        }
    }
    
}
