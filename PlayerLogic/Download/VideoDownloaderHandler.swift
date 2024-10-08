//
//  VideoDownloaderHandler.swift
//  PlayerLogic
//
//  Created by qq on 2024.10.03.
//

import Foundation
import AVFoundation

extension Notification.Name {
    
    public static let VideoDownloadProgressDidChanged = Notification.Name(rawValue: "me.gesen.player.downloader.progress.changed")
    
    public static let VideoDownloadDidFinished = Notification.Name("me.gesen.player.downloader.finished")
    
}

private let delegateQueue: OperationQueue = {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 2
    return queue
}()

protocol VideoDownloaderHandlerDelegate: AnyObject {
    
    func handler(_ handler: VideoDownloaderHandler, didReceive response: URLResponse)
    func handler(_ handler: VideoDownloaderHandler, didReceive data: Data, isLocal: Bool)
    func handler(_ handler: VideoDownloaderHandler, didFinish error: Error?)
    
}

class VideoDownloaderHandler {
    
    weak var delegate: VideoDownloaderHandlerDelegate?
    
    private let url: URL
    private var actions: [VideoCacheAction]
    private let cacheHandler: VideoCacheHandler
    
    private var session: URLSession?
    private var sessionDelegate: VideoDownloaderSessionDelegateHandler?
    private var task: URLSessionDataTask?
    
    private var isCancelled = false
    private var startOffset = 0
    private var lastNotifyTime: TimeInterval = 0
    private var isPreload: Bool = false
    
    //    init(url: URL, actions: [VideoCacheAction], cacheHandler: VideoCacheHandler, isPreload: Bool) {
    init(url: URL, actions: [VideoCacheAction], cacheHandler: VideoCacheHandler) {
        //        self.isPreload = isPreload
        self.url = url
        self.actions = actions
        self.cacheHandler = cacheHandler
    }
    
    deinit {
        cancel()
    }
    
    func start() {
        processActions()
    }
    
    func cancel() {
        session?.invalidateAndCancel()
        isCancelled = true
    }
    
    func resume() {
        task?.resume()
    }
    
    func suspend() {
        task?.suspend()
    }
    
}

extension VideoDownloaderHandler: VideoDownloaderSessionDelegateHandlerDelegate {
//extension VideoDownloaderHandler: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let trust = challenge.protectionSpace.serverTrust
        completionHandler(.useCredential, trust != nil ? URLCredential(trust: trust!) : nil)
//        completionHandler(.performDefaultHandling, nil)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        print("response : :: : : : : : : :: : :  ::: : : : : ", response.mimeType)
//        guard
//            let mimeType = response.mimeType,
//            mimeType.contains("video/")
//        else {
//            print("sha 2  kslj ks jskj jljs lk jslk jslk .jsl kjs ")
////            completionHandler(.cancel);
////            return
//            continue
//        }
        delegate?.handler(self, didReceive: response)
        
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        //        guard !isCancelled && !isPreload else { return }
        guard !isCancelled else { return }
        
        let range = NSRange(location: startOffset, length: data.count)
        if cacheHandler.cache(data: data, for: range) {
            cacheHandler.save()
            
            startOffset += data.count
            
            delegate?.handler(self, didReceive: data, isLocal: false)
            notifyProgress(flush: false)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        cacheHandler.save()
        if let error = error as NSError? {
            delegate?.handler(self, didFinish: error)
            notifyFinished(error: error)
            isCancelled = true
            print("dataTask   :  ssss  ", error)
        } else {
            notifyProgress(flush: true)
            notifyFinished(error: nil)
            processActions()
        }
    }
    
}

private extension VideoDownloaderHandler {
    
    func processActions() {
        guard !isCancelled else { return }
        print("dataTask   :    process")
        guard let action = actions.first else {
            delegate?.handler(self, didFinish: nil)
            return
        }
        
        actions.removeFirst()
        
        guard action.actionType == .remote else {
            let data = cacheHandler.cachedData(for: action.range)
            delegate?.handler(self, didReceive: data, isLocal: true)
            processActions()
            return
        }
        
        sessionDelegate = VideoDownloaderSessionDelegateHandler(delegate: self)
        
        session = URLSession(
            configuration: .default,
            delegate: VideoDownloaderSessionDelegateHandler(delegate: self),
            delegateQueue: .main
        )
        
        var urlRequest = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 60
        )
        
        urlRequest.setValue("video/mp4", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "GET"
        
        let start = action.range.location
        let end = action.range.location + action.range.length - 1
        urlRequest.addValue("bytes=\(start)-\(end)", forHTTPHeaderField: "Range")
        print("bytes=\(start)-\(end)")
        
        for field in VideoLoadManager.shared.customHTTPHeaderFields?(url) ?? [:] {
            urlRequest.addValue(field.value, forHTTPHeaderField: field.key)
        }
        
        startOffset = start
        
        task = session?.dataTask(with: urlRequest)
        
        task?.resume()
    }
        
        func notifyProgress(flush: Bool) {
            let currentTime = CFAbsoluteTimeGetCurrent()
            guard lastNotifyTime < currentTime - 0.1 || flush else { return }
            lastNotifyTime = currentTime
            
            let configuration = cacheHandler.configuration
            NotificationCenter.default.post(
                name: .VideoDownloadProgressDidChanged,
                object: nil,
                userInfo: ["configuration": configuration]
            )
        }
        
        func notifyFinished(error: Error?) {
            let configuration = cacheHandler.configuration
            var userInfo: [AnyHashable: Any] = ["configuration": configuration]
            if let error = error { userInfo[NSURLErrorKey] = error }
            
            NotificationCenter.default.post(
                name: .VideoDownloadDidFinished,
                object: nil,
                userInfo: userInfo
            )
        }
}
