import SwiftUI

// MARK: - UI视图组件

struct ThereminWaveformView: View {
    let waveformData: [Float]
    let frequency: Double
    let amplitude: Double
  
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let midY = height / 2
              
                guard !waveformData.isEmpty else { return }
              
                let xStep = width / CGFloat(waveformData.count - 1)
              
                for (index, value) in waveformData.enumerated() {
                    let x = CGFloat(index) * xStep
                    let y = midY - CGFloat(value) * height * 0.4
                  
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(
                LinearGradient(
                    colors: [
                        Color.cyan.opacity(0.8),
                        Color.blue.opacity(0.6),
                        Color.purple.opacity(0.4)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 2, lineCap: .round)
            )
            .shadow(color: .cyan, radius: 5)
        }
        .background(
            Rectangle()
                .fill(Color.black.opacity(0.8))
                .overlay(
                    // 网格背景
                    Grid()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                )
        )
        .cornerRadius(12)
    }
}

struct Grid: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let spacing: CGFloat = 20
      
        // 垂直线
        for x in stride(from: 0, through: rect.width, by: spacing) {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: rect.height))
        }
      
        // 水平线
        for y in stride(from: 0, through: rect.height, by: spacing) {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
        }
      
        return path
    }
}

struct FrequencyDisplay: View {
    let frequency: Double
    let noteName: String
  
    var body: some View {
        VStack(spacing: 8) {
            // 音符名称
            Text(noteName)
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
          
            // 频率数值
            Text("\(String(format: "%.1f", frequency)) Hz")
                .font(.system(size: 16, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct ThereminSlider: View {
    let title: String
    let value: Double
    let range: ClosedRange<Double>
    let unit: String
    let onChange: (Double) -> Void
  
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
              
                Spacer()
              
                Text("\(String(format: "%.1f", value))\(unit)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)
            }
          
            Slider(value: Binding(
                get: { value },
                set: { onChange($0) }
            ), in: range) {
                // Label
            } minimumValueLabel: {
                Text("\(String(format: "%.1f", range.lowerBound))")
                    .font(.caption)
                    .foregroundColor(.gray)
            } maximumValueLabel: {
                Text("\(String(format: "%.1f", range.upperBound))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .accentColor(.cyan)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct ConnectionStatus: View {
    let isConnected: Bool
    let distance: Double?
  
    var body: some View {
        HStack(spacing: 12) {
            // 连接状态指示器
            Circle()
                .fill(isConnected ? Color.green : Color.red)
                .frame(width: 12, height: 12)
                .shadow(color: isConnected ? .green : .red, radius: 4)
          
            VStack(alignment: .leading, spacing: 2) {
                Text(isConnected ? "已连接" : "未连接")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
              
                if let distance = distance {
                    Text("距离: \(String(format: "%.2f", distance))m")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.gray)
                }
            }
          
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - 主UI视图

struct ThereminUI: View {
    @ObservedObject var audioManager: UIAudioManager
    @ObservedObject var niManager: NearbyInteractionManager
  
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景渐变
                LinearGradient(
                    colors: [
                        Color.black,
                        Color.purple.opacity(0.3),
                        Color.blue.opacity(0.2),
                        Color.black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
              
                // 主要内容
                VStack(spacing: 20) {
                    // 标题
                    Text("Digital Theremin")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.cyan, .blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .cyan, radius: 10)
                        .padding(.top)
                  
                    // 连接状态
                    ConnectionStatus(
                        isConnected: niManager.isConnected,
                        distance: niManager.distance
                    )
                  
                    if niManager.isConnected {
                        // 频率显示
                        FrequencyDisplay(
                            frequency: audioManager.visualFrequency,
                            noteName: audioManager.getNoteName(frequency: audioManager.visualFrequency)
                        )
                      
                        // 波形显示
                        ThereminWaveformView(
                            waveformData: audioManager.waveformData,
                            frequency: audioManager.visualFrequency,
                            amplitude: audioManager.visualAmplitude
                        )
                        .frame(height: 120)
                        .padding(.horizontal)
                      
                        // 控制面板
                        VStack(spacing: 16) {
                            // 音量控制
                            ThereminSlider(
                                title: "音量",
                                value: audioManager.currentVolume / 0.8 * 100,
                                range: 0...100,
                                unit: "%"
                            ) { newValue in
                                audioManager.updateVolume(newValue / 100.0)
                            }
                          
                            // 频率范围控制
                            ThereminSlider(
                                title: "频率范围",
                                value: audioManager.frequencyRange,
                                range: 0.5...2.0,
                                unit: "x"
                            ) { newValue in
                                audioManager.updateFrequencyRange(newValue)
                            }
                        }
                        .padding(.horizontal)
                      
                        // 实时信息面板
                        HStack(spacing: 20) {
                            VStack {
                                Text("振幅")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(String(format: "%.2f", audioManager.visualAmplitude))
                                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                                    .foregroundColor(.cyan)
                            }
                          
                            Divider()
                                .frame(height: 30)
                                .background(Color.gray.opacity(0.3))
                          
                            VStack {
                                Text("状态")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(audioManager.isPlaying ? "播放中" : "已停止")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(audioManager.isPlaying ? .green : .red)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.4))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal)
                      
                    } else {
                        // 未连接状态显示
                        VStack(spacing: 20) {
                            Image(systemName: "wave.3.right.circle")
                                .font(.system(size: 64))
                                .foregroundColor(.gray.opacity(0.5))
                          
                            Text("请连接配对设备")
                                .font(.headline)
                                .foregroundColor(.gray)
                          
                            Text("等待设备连接以开始演奏...")
                                .font(.subheadline)
                                .foregroundColor(.gray.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                  
                    Spacer()
                }
              
                // 环境光效
                if niManager.isConnected && audioManager.visualAmplitude > 0.1 {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.cyan.opacity(audioManager.visualAmplitude * 0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 50,
                                endRadius: 200
                            )
                        )
                        .frame(width: 400, height: 400)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        .animation(.easeInOut(duration: 0.3), value: audioManager.visualAmplitude)
                        .allowsHitTesting(false)
                }
            }
        }
        .onChange(of: niManager.distance) { newDistance in
            if let distance = newDistance {
                audioManager.updateFrequency(distance)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - 更新后的ContentView

struct ContentView: View {
    @ObservedObject var niManager: NearbyInteractionManager
  
#if os(watchOS)
    let connectionDirections = "请连接手机应用"
    var body: some View {
        VStack(spacing: 10) {
            Text("Digital Theremin")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
          
            if niManager.isConnected {
                if let distance = niManager.distance {
                    VStack(spacing: 8) {
                        Text("距离")
                            .font(.caption)
                            .foregroundColor(.gray)
                      
                        Text("\(String(format: "%.2f", distance))m")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(.cyan)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                            )
                    )
                } else {
                    Text("连接中...")
                        .foregroundColor(.orange)
                }
              
                // 连接状态指示器
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("已连接")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                .padding(.top, 5)
              
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "applewatch.radiowaves.left.and.right")
                        .font(.title2)
                        .foregroundColor(.gray)
                  
                    Text(connectionDirections)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding()
        .preferredColorScheme(.dark)
    }
#else
    @StateObject private var audioManager = UIAudioManager()
    let connectionDirections = "请连接手表应用"
  
    var body: some View {
        ThereminUI(audioManager: audioManager, niManager: niManager)
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = true
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
    }
#endif
}

// MARK: - 预览

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(niManager: NearbyInteractionManager())
            .preferredColorScheme(.dark)
    }
}

struct ThereminUI_Previews: PreviewProvider {
    static var previews: some View {
        ThereminUI(
            audioManager: UIAudioManager(),
            niManager: NearbyInteractionManager()
        )
        .preferredColorScheme(.dark)
    }
}
#endif
