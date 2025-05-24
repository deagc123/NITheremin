import SwiftUI

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
    @State private var volume: Double = 0.5
    @State private var frequencyRange: Double = 1.0
    let connectionDirections = "请连接手表应用"
    
    var body: some View {
        if #available(iOS 17.0, *) {
            VStack(spacing: 20) {
                if niManager.isConnected {
                    if let distance = niManager.distance {
                        Text("距离: \(String(format: "%.2f", distance))米")
                            .font(.headline)
                        
                        // 音量控制滑块
                        VStack {
                            Text("音量: \(String(format: "%.1f", volume * 100))%")
                                .font(.subheadline)
                            Slider(value: $volume, in: 0...1) { _ in
                                audioManager.updateVolume(volume)
                            }
                        }
                        .padding(.horizontal)
                        
                        // 频率范围控制滑块
                        VStack {
                            Text("频率范围: \(String(format: "%.1f", frequencyRange))倍")
                                .font(.subheadline)
                            Slider(value: $frequencyRange, in: 0.5...2.0) { _ in
                                audioManager.updateFrequencyRange(frequencyRange)
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        Text("-")
                    }
                } else {
                    Text(connectionDirections)
                }
            }
            .onChange(of: niManager.distance) { newValue in
                if let distance = newValue {
                    audioManager.updateFrequency(distance)
                }
            }
        } else {
            VStack(spacing: 20) {
                if niManager.isConnected {
                    if let distance = niManager.distance {
                        Text("距离: \(String(format: "%.2f", distance))米")
                            .font(.headline)
                        
                        // 音量控制滑块
                        VStack {
                            Text("音量: \(String(format: "%.1f", volume * 100))%")
                                .font(.subheadline)
                            Slider(value: $volume, in: 0...1) { _ in
                                audioManager.updateVolume(volume)
                            }
                        }
                        .padding(.horizontal)
                        
                        // 频率范围控制滑块
                        VStack {
                            Text("频率范围: \(String(format: "%.1f", frequencyRange))倍")
                                .font(.subheadline)
                            Slider(value: $frequencyRange, in: 0.5...2.0) { _ in
                                audioManager.updateFrequencyRange(frequencyRange)
                            }
                        }
                        .padding(.horizontal)
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
}
