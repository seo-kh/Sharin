//
//  3DItem.swift
//  Sharin
//
//  Created by james seo on 2023/03/20.
//

import Foundation

struct Item: Identifiable {
    var id: String = UUID().uuidString
    var title: String
    var date: Date
    var usdzURL: String
    
    static let dummy: [Item] = [
        Item(title: "너무나 아름다운 튤립아닌가요?? 하하", date: .now.advanced(by: -1000.0), usdzURL: "flower_tulip"),
        Item(title: "신나신나는 노래와함께~", date: .now.advanced(by: -3000.0), usdzURL: "gramophone"),
        Item(title: "티비로 떠나보는 세계여행~!!", date: .now.advanced(by: 1000.0), usdzURL: "tv_retro"),
        Item(title: "화분에 주는 물은 여기서 나오지요!", date: .now.advanced(by: 4000.0), usdzURL: "wateringcan"),
    ]
}
