//
//  UIImageView+.swift
//  Sharin
//
//  Created by james seo on 2023/04/24.
//

import UIKit

extension UIImageView {
    func load(url: URL) {
        guard let path = NSSearchPathForDirectoriesInDomains(
            .cachesDirectory,
            .userDomainMask,
            true
        ).first else { return }
        
        var filePath = URL(fileURLWithPath: path)
        filePath.appendPathComponent(url.lastPathComponent)
        
        if !FileManager.default.fileExists(atPath: filePath.path) {
            DispatchQueue.global().async {
                [weak self] in
                if let data = try? Data(contentsOf: url) {
                    FileManager.default.createFile(atPath: filePath.path(), contents: data)
                    DispatchQueue.main.async { self?.image = UIImage(data: data) }
                }
            }
        } else {
            if let data = FileManager.default.contents(atPath: filePath.path()) {
                DispatchQueue.main.async { [weak self] in self?.image = UIImage(data: data) }
            }
        }
    }
}
