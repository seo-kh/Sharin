//
//  CameraViewModel.swift
//  Sharin
//
//  Created by james seo on 2023/03/30.
//

import Foundation
import Combine

final class CameraViewModel {
    private var cancellables = Set<AnyCancellable>()
    let assetName: AnyPublisher<String?, Never>
    let itemPickerViewModel = ItemPickerViewModel()
    var asset: String?
    
    init() {
        self.assetName = itemPickerViewModel.itemPick
                .eraseToAnyPublisher()
        
        assetName
            .assign(to: \.asset, on: self)
            .store(in: &cancellables)
    }
}
