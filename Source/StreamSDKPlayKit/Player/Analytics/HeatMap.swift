//
//  HeatMap.swift
//  AMGPlayKit
//
//  Created by Mike Hall on 31/03/2021.
//

import UIKit

class HeatMap {
    private let heatMapSize: Int = 20
    var heatMap: [Int] = []
    var sectionSpread: [TimeInterval] = []
    var sectionLength: TimeInterval = 0
    var duration: TimeInterval = 0
    var currentSection = 0
    var sectionStart: TimeInterval = 0
    var sectionEnd: TimeInterval = 0
    var currentSectionCount = 0
    var currentPosition: TimeInterval = 0
    
    
    private var openTimeChunk: OpenTimeChunk?
    private var timeChunkBag: ChunkBag = ChunkBag()
    
    init() {
        heatMap = Array(repeating: 0, count: heatMapSize)
        sectionSpread = Array(repeating: 0.0, count: heatMapSize)
    }
    
    func resetHeatMap(duration: TimeInterval) {
        heatMap = Array(repeating: 0, count: heatMapSize)
            currentSection = 0
            sectionStart = 0
            sectionEnd = 0
            self.duration = duration
        if (duration > 0.0) {
                sectionLength = duration / Double(heatMapSize)
                var count: TimeInterval = 0
            for a in 0..<heatMapSize {
                    sectionSpread[a] = count
                    count += sectionLength
                }
            } else {
                sectionLength = 0
                sectionSpread = Array(repeating: 0.0, count: heatMapSize)
            }
        initiateChunkBag()
        }

        func updateHeatMap(currentTime: TimeInterval) {
            if duration == 0.0 {
                return
            }
            currentPosition = currentTime
            if (currentTime < sectionStart || currentTime > sectionEnd) {
                markNewSection(currentTime: currentTime)
            } else if currentSectionCount > 5 {
                if currentSection < heatMap.count {
                    heatMap[currentSection] = 1
                }
            } else {
                currentSectionCount += 1
            }
        }

        func markNewSection(currentTime: TimeInterval) {
            currentSection = 0
            sectionSpread.forEach {time in
                if (currentTime > time + sectionLength) {
                    currentSection += 1
                }
            }
            if currentSection < sectionSpread.count {
            sectionStart = sectionSpread[currentSection]
            if (currentSection < heatMapSize - 1) {
                sectionEnd = sectionSpread[currentSection + 1]
            } else {
                sectionEnd = duration
            }
            }
        }

        func report() -> String {
            let stringArray = heatMap.map { String($0) }
            return stringArray.joined(separator:",")
        }
    
    func initiateChunkBag() {
        timeChunkBag.clear()
        openTimeChunk = OpenTimeChunk(start: 0)
    }
    
    func playheadMovedByUser(from: TimeInterval, to: TimeInterval){
        if let chunk = try? openTimeChunk?.close(at: from){
            timeChunkBag.add(chunk)
        }
        openTimeChunk = OpenTimeChunk(start: to)
    }
    
    func pause(at: TimeInterval){
        if let chunk = try? openTimeChunk?.close(at: at){
            timeChunkBag.add(chunk)
        }
    }
    
    func play(at: TimeInterval){
        openTimeChunk = OpenTimeChunk(start: at)
    }
    
    func playFinished(){
        if let chunk = try? openTimeChunk?.close(at: duration){
            timeChunkBag.add(chunk)
        }
    }
    
    func connectionDuration() -> Int64 {
        if let openTimeChunk = try? openTimeChunk?.currentChunk(at: currentPosition) {
        return timeChunkBag.totalTime(currentChunk: openTimeChunk)
        }
        return timeChunkBag.totalTime(currentChunk: TimeChunk())
    }
    
    func durationPlayed() -> Int64 {
        if let openTimeChunk = try? openTimeChunk?.currentChunk(at: currentPosition) {
            return timeChunkBag.nonRepeatedTime(currentChunk: openTimeChunk)    //.totalTime(currentChunk: openTimeChunk)
        }
        return timeChunkBag.nonRepeatedTime(currentChunk: TimeChunk())
    }
}
