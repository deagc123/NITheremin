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
    
    // 添加滑动窗口数组
    private var distanceWindow: [Double] = []
    private let windowSize = 4
    
    // 添加特雷门琴音域范围
    private let minDistance: Double = 0.1  // 最小距离（米）
    private let maxDistance: Double = 1.0  // 最大距离（米）
    private let baseMinFrequency: Double = 220.0  // A3
    private let baseMaxFrequency: Double = 1760.0 // A6
    private var frequencyRange: Double = 1.0
    
    // 添加音量控制
    private var currentVolume: Double = 0.5
    private var volumeWindow: [Double] = []
    private let minVolume: Double = 0.0
    private let maxVolume: Double = 0.8  // 最大音量限制在0.8避免削波
    
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
                
                // 获取当前频率、相位和音量
                self.lock.lock()
                let frequency = self.currentFrequency
                var phase = self.phase
                let volume = self.currentVolume
                self.lock.unlock()
                
                let phaseIncrement = (2 * .pi * frequency) / self.sampleRate
                
                // 生成正弦波
                for frame in 0..<Int(frameCount) {
                    let value = sin(phase) * volume // 使用当前音量
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
        
        do {
            try engine.start()
        } catch {
            print("引擎启动失败: \(error)")
        }
    }
    
    func updateFrequency(_ frequency: Double) {
        // 更新滑动窗口
        distanceWindow.append(frequency)
        if distanceWindow.count > windowSize {
            distanceWindow.removeFirst()
        }
        
        // 计算平均值
        let averageDistance = distanceWindow.reduce(0.0, +) / Double(distanceWindow.count)
        
        // 将距离映射到频率范围
        let mappedFrequency = mapDistanceToFrequency(averageDistance)
        
        lock.lock()
        currentFrequency = mappedFrequency
        lock.unlock()
    }
    
    // 添加频率范围更新方法
    func updateFrequencyRange(_ range: Double) {
        frequencyRange = range
    }
    
    // 添加音量更新方法
    func updateVolume(_ volume: Double) {
        lock.lock()
        currentVolume = volume * maxVolume // 将0-1的值映射到0-maxVolume
        lock.unlock()
    }
    
    // 修改距离到频率的映射函数
    private func mapDistanceToFrequency(_ distance: Double) -> Double {
        // 限制距离在有效范围内
        let clampedDistance = min(max(distance, minDistance), maxDistance)
        
        // 使用对数映射使音高变化更自然
        let normalizedDistance = (clampedDistance - minDistance) / (maxDistance - minDistance)
        
        // 应用频率范围调整
        let adjustedMinFrequency = baseMinFrequency / frequencyRange
        let adjustedMaxFrequency = baseMaxFrequency * frequencyRange
        
        let logFrequency = adjustedMinFrequency * pow(adjustedMaxFrequency / adjustedMinFrequency, normalizedDistance)
        
        return logFrequency
    }
}
