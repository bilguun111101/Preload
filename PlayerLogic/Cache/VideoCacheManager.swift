//
//  VideoCacheManager.swift
//  PlayerLogic
//
//  Created by qq on 2024.10.03.
//

import Foundation
import CommonCrypto

private let identifier = NSTemporaryDirectory().appendingPathComponent("xs.player.downloader")

public enum VideoCacheManager {
    
    public static func cachedFilePath(for url: URL) -> String {
        print("identifier.appendingPathComponent(url.absoluteString.md5).appendingPathExtension(url.pathExtension)         ssss         ", identifier
            .appendingPathComponent(url.absoluteString.md5)
            .appendingPathExtension(url.pathExtension)!)
        return identifier
            .appendingPathComponent(url.absoluteString.md5)
            .appendingPathExtension(url.pathExtension)!
    }
    
    public static func cachedConfiguration(for url: URL) throws -> VideoCacheConfiguration {
        return try VideoCacheConfiguration
            .configuration(for: cachedFilePath(for: url))
    }
    
    public static func calculateCachedSize() -> UInt {
        let fileManager = FileManager.default
        let resourceKeys: Set<URLResourceKey> = [.totalFileAllocatedSizeKey]
        
        let fileContents = (try? fileManager.contentsOfDirectory(at: URL(fileURLWithPath: identifier), includingPropertiesForKeys: Array(resourceKeys), options: .skipsHiddenFiles)) ?? []
        
        return fileContents.reduce(0) { size, fileContent in
            guard
                let resourceValues = try? fileContent.resourceValues(forKeys: resourceKeys),
                resourceValues.isDirectory != true,
                let fileSize = resourceValues.totalFileAllocatedSize
            else { return size }
            
            return size + UInt(fileSize)
        }
    }
    
    public static func cleanAllCache() throws {
        let fileManager = FileManager.default
        let fileContents = try fileManager.contentsOfDirectory(atPath: identifier)
        
        for fileContent in fileContents {
            let filePath = identifier.appendingPathComponent(fileContent)
            try fileManager.removeItem(atPath: filePath)
        }
    }
    
    public static func removeExpiredData() {
        let diskCacheURL = URL(fileURLWithPath: identifier, isDirectory: true)
        let cacheContentDateKey : URLResourceKey = .creationDateKey
        let resourceKeys: Set<URLResourceKey> = [.isDirectoryKey, cacheContentDateKey, .totalFileAllocatedSizeKey]
        let fileManager : FileManager = .default
        let fileEnumerator = fileManager.enumerator(
            at: diskCacheURL,
            includingPropertiesForKeys: Array(resourceKeys),
            options: .skipsHiddenFiles,
            errorHandler: nil
        )
        //        let expirationDate : Date = Date(timeIntervalSinceNow: 60 * 60 * 60 * 7)
        let expirationDate : Date = Date(timeIntervalSinceNow: 60 * 60)
        var cacheFiles : [URL : [URLResourceKey : Any]] = [:]
        var currentCacheSize = 0
        var urlsToDelete : [URL] = []
        if let fileEnumerator = fileEnumerator {
            for case let fileURL as URL in fileEnumerator {
                autoreleasepool {
                    do {
                        let resourceValues : URLResourceValues = try fileURL.resourceValues(forKeys: resourceKeys)
                        if let isDirectory = resourceValues.isDirectory, isDirectory {
                            return
                        }
                        if let modifiedDate = resourceValues.creationDate {
                            print("modifiedDate : ", modifiedDate)
                            if modifiedDate >= expirationDate {
                                urlsToDelete.append(fileURL)
                                return
                            }
                        }
                        if let totalAllocatedSize = resourceValues.totalFileAllocatedSize {
                            currentCacheSize += totalAllocatedSize
                            cacheFiles[fileURL] = resourceValues.allValues
                        }
                    } catch {
                        print("error : \(error.localizedDescription)")
                    }
                }
            }
        }
        for fileURL in urlsToDelete {
            try? fileManager.removeItem(at: fileURL)
        }
        let maxDiskSize = 2 * 1024 * 1024 * 1024
        if currentCacheSize > maxDiskSize {
            let desiredCacheSize = maxDiskSize / 2
            let sortedFiles = cacheFiles.keys.sorted {
                let date1 = cacheFiles[$0]?[cacheContentDateKey] as? Date ?? Date.distantPast
                let date2 = cacheFiles[$1]?[cacheContentDateKey] as? Date ?? Date.distantPast
                return date1 < date2
            }
            
            for fileURL in sortedFiles {
                let exists: ()? = try? fileManager.removeItem(at: fileURL)
                if let resourceValues = cacheFiles[fileURL],
                   let totalAllocatedSize = resourceValues[.totalFileAllocatedSizeKey],
                   exists == nil {
                    currentCacheSize -= totalAllocatedSize as! Int
                    if currentCacheSize < desiredCacheSize {
                        break
                    }
                }
            }
        }
    }
}
