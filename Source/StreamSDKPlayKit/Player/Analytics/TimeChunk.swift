//
//  TimeChunk.swift
//  AMGPlayKitUtils
//
//  Created by Sam Easterby-Smith on 12/12/2020.
//

import Foundation

/// An open variant of TimeChunk
struct OpenTimeChunk{
    let start: TimeInterval
    func close(at end:TimeInterval) throws ->TimeChunk {
        return try TimeChunk(start, end)
    }
    
    func currentChunk(at end:TimeInterval) throws ->TimeChunk {
        return try TimeChunk(start, end)
    }
    
    
}

/// A TimeChunk represents a closed range of time.
struct TimeChunk: Hashable {
    enum TimeChunkError: Error {
        case endIsBeforeStart
        case lengthIsZero
    }
    
    let start: TimeInterval
    let end: TimeInterval // End should be greater than start
    
    init() {
        self.start = 0
        self.end = 0
    }
    
    init(_ start: TimeInterval, _ end: TimeInterval) throws {
        guard end != start else { throw TimeChunkError.lengthIsZero }
        guard end > start else { throw TimeChunkError.endIsBeforeStart }
        self.start = start
        self.end = end
    }
    
    /// Test whether this chunk intersects with another given chunk
    func intersects(with otherChunk: TimeChunk) -> Bool {
        if (self.start < otherChunk.start && self.end > otherChunk.start) ||
            (otherChunk.start < self.start && otherChunk.end > self.start){
            return true
        }
        return false
    }
    
    /// Merge this chunk with another. If they intersect it returns a new TimeChunk. If they do not intersect it returns `nil`
    func union(with otherChunk: TimeChunk) throws -> TimeChunk? {
        if self.intersects(with: otherChunk){
            return try TimeChunk(min(self.start, otherChunk.start), max(self.end,otherChunk.end))
        }
        return nil
    }
    
    /// The duration of this chunk
    var duration: TimeInterval {
        return end - start
    }
}


struct ChunkBag {
    private var chunks = Set<TimeChunk>()
    
    var count: Int {
        return chunks.count
    }
    var normalisedCount: Int {
        return normalisedChunks.count
    }
    
    /// Produces the
    var normalisedTime: TimeInterval {
        normalisedChunks.reduce(0, { $0 + $1.duration })
    }
    
    /// Produces an ordered array of TimeChunks - normalised such that any overlapping chunks are merged.
    var normalisedChunks: Array<TimeChunk> {
        let sorted = chunks.sorted(by: {$0.start < $1.start})
        let reduced = sorted.reduce(Array<TimeChunk>()) { (result, chunk) -> Array<TimeChunk> in
            var result = result
            if let lastChunk = result.last, let union = try? lastChunk.union(with:chunk){
                result.removeLast()
                result.append(union)
            } else {
                result.append(chunk)
            }
            return result
        }
        return reduced
    }
    
    mutating func add(_ chunk: TimeChunk){
        chunks.insert(chunk)
    }
    
    mutating func clear(){
        chunks.removeAll()
    }
    
    func countIntersecting(_ intersecting: TimeChunk)->Int {
        let filtered = chunks.filter { (timeChunk) -> Bool in
            timeChunk.intersects(with: intersecting)
        }
        return filtered.count
    }
    
    func nonRepeatedTimeChunks(currentChunk: TimeChunk) -> Array<TimeChunk> {
        var allChunks: [TimeChunk] = Array(chunks)
        allChunks.append(currentChunk)
        let sorted = allChunks.sorted(by: {$0.start < $1.start})
        let reduced = sorted.reduce(Array<TimeChunk>()) { (result, chunk) -> Array<TimeChunk> in
            var result = result
            if let lastChunk = result.last, let union = try? lastChunk.union(with:chunk){
                result.removeLast()
                result.append(union)
            } else {
                result.append(chunk)
            }
            return result
        }
        return reduced
    }
    
    func nonRepeatedTime(currentChunk: TimeChunk) -> Int64 {
        let time = nonRepeatedTimeChunks(currentChunk: currentChunk).reduce(0, { $0 + $1.duration })
        return Int64(time * 1000)
    }
    
    func totalTime(currentChunk: TimeChunk) -> Int64 {
        var allChunks: [TimeChunk] = Array(chunks)
        allChunks.append(currentChunk)
        let time = allChunks.reduce(0, { $0 + $1.duration })
        return Int64(time * 1000)
    }

}

extension ChunkBag {
    
    static let heatmapSize = 20
    
    func generateHeatmap(totalDuration: TimeInterval) -> [Int]{
        guard totalDuration > 0  else {
            return Self.emptyHeatmap
        }
        let fragmentLength = totalDuration / Double(Self.heatmapSize)
        var heatmap: [Int] = Self.emptyHeatmap
        
        for index in 0 ..< Self.heatmapSize {
            let startTime = Double(index) * fragmentLength
            let endTime = Double(index+1) * fragmentLength
            
            if let timeChunk = try? TimeChunk(startTime,endTime) {
                heatmap[index] = self.countIntersecting(timeChunk)
            }
            
        }
        return heatmap
    }
    
    static var emptyHeatmap: [Int] {
        var heatmap: [Int] = []
        for _ in 0 ..< heatmapSize {
            heatmap.append(0)
        }
        return heatmap
    }
}
