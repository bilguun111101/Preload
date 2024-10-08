//
//  AVAssetResourceLoadingRequest.swift
//  PlayerLogic
//
//  Created by qq on 2024.10.03.
//

import AVFoundation

extension AVAssetResourceLoadingRequest {
    var url: URL? {
        request.url?.deconstructed
    }
}
