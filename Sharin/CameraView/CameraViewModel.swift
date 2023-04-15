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
    let item: AnyPublisher<Item?, Never>
    let itemPickerViewModel = ItemPickerViewModel()
    
    init() {
        self.item = itemPickerViewModel
                .itemPick
                .eraseToAnyPublisher()
    }
}
