
//  ViewController.swift
//  PlayerLogic
//
//  Created by qq on 2024.10.03.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var playerView = VideoPlayerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(
            "VideoCacheManager.calculateCachedSize()   :    ",
            VideoCacheManager.calculateCachedSize()
        )
        
        VideoPreloadManager.shared.preloadByteCount = 1024 * 1024
        
        print("before : ", VideoCacheManager.calculateCachedSize())
        do {
            try? VideoCacheManager.cleanAllCache()
        }
        //        VideoPreloadManager.shared.set(waiting: [
        //            URL(string: "https://dev-goodtech.s3.dualstack.ap-southeast-1.amazonaws.com/2b54b9b0-1125-42cb-aa04-5dfd05238ff1.mp4")!
        //        ])
        //                478e85f4d90edd8b50cafa165e238851.mp4
        //        VideoPreloadManager.shared.set(waiting: [
        //            URL(string: "https://dev-goodtech.s3.dualstack.ap-southeast-1.amazonaws.com/2b54b9b0-1125-42cb-aa04-5dfd05238ff1.mp4")!
//                ])
        
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.play(for: URL(string: "https://dev-goodtech.s3.dualstack.ap-southeast-1.amazonaws.com/2b54b9b0-1125-42cb-aa04-5dfd05238ff1.mp4")!)
//        playerView.play(for: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)
        playerView.backgroundColor = .black
//        playerView.play(for: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)
//        let url = URL(string: "https://dev-goodtech.s3.dualstack.ap-southeast-1.amazonaws.com/2b54b9b0-1125-42cb-aa04-5dfd05238ff1.mp4")
//        if let targetURL = url {
////            playerView.play(for: URL(string: "https://dev-goodtech.s3.dualstack.ap-southeast-1.amazonaws.com/2b54b9b0-1125-42cb-aa04-5dfd05238ff1.mp4")!)
//            playerView.play(for: targetURL)
//        }
        
        //                playerView.play(for: URL(string: "https://dev-goodtech.s3.dualstack.ap-southeast-1.amazonaws.com/ccefe5bc-eeb2-456a-8269-2e7b43b7340c.mp4")!)
//        playerView.play(for: URL(string: "https://dev-goodtech.s3.dualstack.ap-southeast-1.amazonaws.com/1185d3ec-2dbf-421a-8860-cc6fa8b982ef.mp4")!)
        
        view.addSubview(playerView)
        
        NSLayoutConstraint.activate([
            playerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            //            playerView.widthAnchor.constraint(equalToConstant: 200),
            //                    playerView.heightAnchor.constraint(equalToConstant: 300),
            playerView.heightAnchor.constraint(equalTo: view.heightAnchor),
            playerView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
        ])
        
//        if let url = URL(string: "https://dev-goodtech.s3.dualstack.ap-southeast-1.amazonaws.com/1185d3ec-2dbf-421a-8860-cc6fa8b982ef.mp4") {
//            let session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
//            let task = session.dataTask(with: url)
////            { location, response, error in
////                if let error = error {
////                    print("Download failed with error: \(error)")
////                    return
////                }
////                if let location = location {
////                    print("Failed to download video, no file location : ", location)
////                }
////                if let response = response {
////                    print("s dkljjhas fjhs jakhf    response : ", response)
////                }
////            }
//            task.resume()
//        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            print("after : ", VideoCacheManager.calculateCachedSize())
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
            print("after after : ", VideoCacheManager.calculateCachedSize())
        })
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillTerminate(_:)),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    let ioQueue = DispatchQueue(label: "com.PlayerDownload.isQueue")
    
    @objc func applicationWillTerminate(_ notification : Notification) {
        ioQueue.async {
            VideoCacheManager.removeExpiredData()
        }
    }
}

extension ViewController: URLSessionDelegate {
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("session ::     ::    ::    ::    ::    ::    ::    ::    ", challenge)
    }
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
    }
}
