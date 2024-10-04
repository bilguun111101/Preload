//
//  VideoDownloadInfo.swift
//  PlayerLogic
//
//  Created by qq on 2024.10.03.
//

import Foundation

struct VideoDownloadInfo: Codable {
    
    let byteCount: Int
    let spendTime: TimeInterval
    let startTime: Date
    
    var speed: Double {
        return Double(byteCount) / 1024 / spendTime
    }
    
    init(byteCount: Int, spendTime: TimeInterval, startTime: Date) {
        self.byteCount = byteCount
        self.spendTime = spendTime
        self.startTime = startTime
    }
    
}
