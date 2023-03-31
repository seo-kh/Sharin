//
//  ContentViewController.swift
//  Sharin
//
//  Created by james seo on 2023/03/18.
//

import UIKit

class ContentViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        UITabBar.clearShadow()
        tabBar.layer.applyShadow(color: .gray, alpha: 0.3, x: 0, y: 0, blur: 12)
        
        let communityViewController = UIViewController()
        communityViewController.view.backgroundColor = .systemRed
        communityViewController.tabBarItem = UITabBarItem(title: "커뮤니티", image: .init(systemName: "person.3"), selectedImage: .init(systemName: "person.3.fill"))
        let cameraViewController = CameraViewController()
        cameraViewController.tabBarItem = UITabBarItem(title: "카메라", image: .init(systemName: "camera"), selectedImage: .init(systemName: "camera.fill"))
        let myPageViewController = UIViewController()
        myPageViewController.view.backgroundColor = .systemBlue
        myPageViewController.tabBarItem = UITabBarItem(title: "마이페이지", image: .init(systemName: "person"), selectedImage: .init(systemName: "person.fill"))
        
        self.viewControllers = [communityViewController, cameraViewController, myPageViewController].map { UINavigationController(rootViewController: $0) }
    }

}
