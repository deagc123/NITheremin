//
//  AudioManager.swift
//  WatchNIDemo
//
//  Created by 白 on 2025/5/18.
//  Copyright © 2025 Apple. All rights reserved.
//

import Foundation
import AVFoundation
import SwiftUI

class AudioManager {
    private let engine = AVAudioEngine()
    private var currentFrequency: Double = 440.0
    private var phase: Double = 0.0
    private let sampleRate: Double
    private let lock = NSLock()
    
    init() {
        // 获取硬件采样率
        let hardwareFormat = engine.mainMixerNode.outputFormat(forBus: 0)
        sampleRate = hardwareFormat.sampleRate
        
        setupAudioSession()
        setupAudioEngine()
    }
    
    // 配置音频会话
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("音频会话配置失败: \(error)")
        }
    }
    
    // 配置音频引擎
    private func setupAudioEngine() {
        let inputFormat = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate,
            channels: 1
        )!
        
        // 创建音频源节点
        let sourceNode = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self else { return noErr }
            
            let pointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            for buffer in pointer {
                let frames = buffer.mData?.assumingMemoryBound(to: Float32.self)
                let channelCount = Int(buffer.mNumberChannels)
                
                // 获取当前频率和相位
                self.lock.lock()
                let frequency = self.currentFrequency
                var phase = self.phase
                self.lock.unlock()
                
                let phaseIncrement = (2 * .pi * frequency) / self.sampleRate
                
                // 生成正弦波
                for frame in 0..<Int(frameCount) {
                    let value = sin(phase) * 0.5 // 降低音量避免削波
                    for channel in 0..<channelCount {
                        frames?[frame * channelCount + channel] = Float32(value)
                    }
                    phase += phaseIncrement
                    if phase >= 2 * .pi { phase -= 2 * .pi } // 相位归一化
                }
                
                // 保存相位
                self.lock.lock()
                self.phase = phase
                self.lock.unlock()
            }
            return noErr
        }
        
        engine.attach(sourceNode)
        engine.connect(sourceNode, to: engine.mainMixerNode, format: inputFormat)
        
        // 启动引擎
        do {
            try engine.start()
        } catch {
            print("引擎启动失败: \(error)")
        }
    }
    
    // 更新频率
    func updateFrequency(_ frequency: Double) {
        lock.lock()
        currentFrequency = frequency
        lock.unlock()
    }
}
