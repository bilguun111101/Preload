//
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
        
        //        print("VideoCacheManager.calculateCachedSize()   :    ", VideoCacheManager.calculateCachedSize())
        //        //        VideoCacheManager.cleanAllCache()
        //        VideoPreloadManager.shared.preloadByteCount = 1024 * 1024
        //        print("before : ", VideoCacheManager.calculateCachedSize())
        //        do {
        //            try? VideoCacheManager.cleanAllCache()
        //        }
        //        VideoPreloadManager.shared.set(waiting: [
        //            URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
        //        ])
        //
        
        
        playerView.translatesAutoresizingMaskIntoConstraints = false
        //        playerView.play(for: URL(string: "https://dev-goodtech.s3.dualstack.ap-southeast-1.amazonaws.com/a7c05203-58f6-4bd8-9434-4ca71b5f8d8c.mp4")!)
        playerView.play(for: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)
        view.addSubview(playerView)
        playerView.backgroundColor = .brown
        
        NSLayoutConstraint.activate([
            playerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            playerView.widthAnchor.constraint(equalToConstant: 200),
            playerView.heightAnchor.constraint(equalToConstant: 300),
            playerView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
        ])
        //
        //
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            print("after : ", VideoCacheManager.calculateCachedSize())
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
            print("after after : ", VideoCacheManager.calculateCachedSize())
        })
        //        // Do any additional setup after loading the view.
        //    }
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminate(_:)), name: UIApplication.willTerminateNotification, object: nil)
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
