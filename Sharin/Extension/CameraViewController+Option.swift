//
//  CameraViewController+Option.swift
//  Sharin
//
//  Created by james seo on 2023/04/04.
//

import Foundation

extension CameraViewController {
    enum Option: CaseIterable {
        case find
        case store
        
        var systemName: String {
            switch self {
            case .find: return "magnifyingglass"
            case .store: return "square.and.arrow.down"
            }
        }
    }
}
