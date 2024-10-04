//
//  VideoPreloadManager.swift
//  PlayerLogic
//
//  Created by qq on 2024.10.03.
//

import Foundation

public class VideoPreloadManager: NSObject {
    
    public static let shared = VideoPreloadManager()
    
    public var preloadByteCount: Int = 1024 * 1024 // = 1M
    
    public var didStart: (() -> Void)?
    public var didPause: (() -> Void)?
    public var didFinish: ((Error?) -> Void)?
    
    private var downloader: VideoDownloader?
    private var isAutoStart: Bool = true
    private var waitingQueue: [URL] = []
    private var processing = [URL : Bool]()
    
    public func set(waiting: [URL]) {
        downloader = nil
        print("set waiting : ", waiting)
        waitingQueue = waiting
        if isAutoStart { start() }
    }
    
    func start() {
        guard downloader == nil, waitingQueue.count > 0 else {
            downloader?.resume()
            return
        }
        
        isAutoStart = true
        
        let url = waitingQueue.removeFirst()
        
        guard
            !VideoLoadManager.shared.loaderMap.keys.contains(url),
            let cacheHandler = try? VideoCacheHandler(url: url) else {
            return
        }
        print("cacheHandler : ", cacheHandler)
        downloader = VideoDownloader(url: url, cacheHandler: cacheHandler)
        downloader?.delegate = self
        downloader?.download(from: 0, length: preloadByteCount)
        
        print("download : ", downloader as Any)
        
        if cacheHandler.configuration.downloadedByteCount < preloadByteCount {
            didStart?()
        }
    }
    
    func pause() {
        downloader?.suspend()
        didPause?()
        isAutoStart = false
    }
    
    func remove(url: URL) {
        if let index = waitingQueue.firstIndex(of: url) {
            waitingQueue.remove(at: index)
        }
        
        if downloader?.url == url {
            downloader = nil
        }
    }
    
}

extension VideoPreloadManager: VideoDownloaderDelegate {
    
    public func downloader(_ downloader: VideoDownloader, didReceive response: URLResponse) {
        
    }
    
    public func downloader(_ downloader: VideoDownloader, didReceive data: Data) {
        
    }
    
    public func downloader(_ downloader: VideoDownloader, didFinished error: Error?) {
        self.downloader = nil
        start()
        didFinish?(error)
    }
    
}
