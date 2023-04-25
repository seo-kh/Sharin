//
//  Item.swift
//  Sharin
//
//  Created by james seo on 2023/03/20.
//

import Foundation

struct Item: Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var img: String
    var usdz: String
}
