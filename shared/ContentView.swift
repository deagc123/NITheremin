/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The main view that displays the distance to the paired device.
*/

import SwiftUI

/// The main view that displays connection instructions and the distance to the
/// paired device.
struct ContentView: View {
    @ObservedObject var niManager: NearbyInteractionManager
    
    #if os(watchOS)
    let connectionDirections = "请连接手机应用"
    var body: some View {
        VStack(spacing: 10) {
            if niManager.isConnected {
                if let distance = niManager.distance {
                    Text("distance\(distance)")
                } else {
                    Text("-")
                }
            } else {
                Text(connectionDirections)
            }
        }
    }
    #else
    private let audioManager = AudioManager()
    @State private var frequency: Double = 440.0
    let connectionDirections = "请连接手表应用"
    
    
    var body: some View {
        if #available(iOS 17.0, *) {
            VStack(spacing: 10) {
                if niManager.isConnected {
                    if let distance = niManager.distance {
                        Text("distance\(distance)")
                    } else {
                        Text("-")
                    }
                } else {
                    Text(connectionDirections)
                }
                
            }
            .onChange(of: niManager.distance) {
                let frequency = niManager.distance!*1000
                audioManager.updateFrequency(frequency)
            }
        } else {
            VStack(spacing: 10) {
                if niManager.isConnected {
                    if let distance = niManager.distance {
                        Text("distance\(distance)")
                    } else {
                        Text("-")
                    }
                } else {
                    Text(connectionDirections)
                }
                
            }
            .onChange(of: niManager.distance!) { newValue in
                audioManager.updateFrequency(newValue)
                
            }
        }
    }
#endif
