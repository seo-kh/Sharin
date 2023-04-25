//
//  NetworkManager.swift
//  Sharin
//
//  Created by james seo on 2023/04/24.
//

import Foundation
import Combine

final class NetworkManager: NSObject {
    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "usdz")
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
        return session
    }()
    
    var task: URLSessionDownloadTask?
    var target: URL?
    var isLoading = CurrentValueSubject<Bool, Never>(false)
    
    func getTargetURL(item: Item) -> URL {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(item.name + ".usdz", conformingTo: .usdz) else { fatalError() }
        return url
    }
    
    func startDownloading(item: Item) {
        self.target = getTargetURL(item: item)
        if !FileManager.default.fileExists(atPath: target!.path()) {
            self.isLoading.send(true)
            let url = URL(string: item.usdz)!
            task = session.downloadTask(with: url)
            task?.resume()
        }
    }
}

extension NetworkManager: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard ((try? location.checkResourceIsReachable()) != nil) else { return }
        
        do {
            _ = try FileManager.default.replaceItemAt(target!, withItemAt: location)
            self.isLoading.send(false)
        } catch {
            print(error)
        }
    }
    
    
}
