//
//  VideoCacheAction.swift
//  PlayerLogic
//
//  Created by qq on 2024.10.03.
//

import Foundation

struct VideoCacheAction {
    
    enum ActionType {
        case local
        case remote
    }
    
    let actionType: ActionType
    let range: NSRange
    
}
