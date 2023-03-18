//
//  UITabBar+.swift
//  Sharin
//
//  Created by james seo on 2023/03/19.
//

// reference : https://velog.io/@leejh3224/iOS-TabBar-shadow-%EC%BB%A4%EC%8A%A4%ED%84%B0%EB%A7%88%EC%9D%B4%EC%A7%95-trjugzee87

import UIKit

extension UITabBar {
    // 기본 그림자 스타일을 초기화해야 커스텀 스타일을 적용할 수 있다.
    static func clearShadow() {
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().backgroundColor = UIColor.systemBackground
    }
}
