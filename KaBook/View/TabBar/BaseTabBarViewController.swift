//
//  BaseTabBarViewController.swift
//  KaBook
//
//  Created by takeda yuri on 2021/03/29.
//

import UIKit

class BaseTabBarViewController: UITabBarController {
    
    enum ControllerName: Int{
        case home,money,note,menu
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    
    private func setUpViews(){
        object_setClass(tabBar, CustomTabBar.self)
        viewControllers?.enumerated().forEach({ (index,viewController) in
            if let name = ControllerName.init(rawValue: index) {
                switch name {
                case .home:
                    self.setTabBarImage(viewController: viewController, imageName: "tabbar-unselected-home", selectedImageName: "tabbar-selected-home",title:"ホーム")
                case .money:
                    self.setTabBarImage(viewController: viewController, imageName: "tabbar-unselected-money", selectedImageName: "tabbar-selected-money",title:"収支")
                case .note:
                    self.setTabBarImage(viewController: viewController, imageName: "tabbar-unselected-note", selectedImageName: "tabbar-selected-note",title:"ノート")
                case .menu:
                    self.setTabBarImage(viewController: viewController, imageName: "tabbar-unselected-menu", selectedImageName: "tabbar-selected-menu",title:"メニュー")
                }
            }
        })
    }
    
    private func setTabBarImage(viewController:UIViewController,imageName:String,selectedImageName:String,title:String){
        viewController.tabBarItem.selectedImage = UIImage(named: selectedImageName)?.resize(size: .init(width: 30, height: 30))?.withRenderingMode(.alwaysOriginal)
        viewController.tabBarItem.image = UIImage(named: imageName)?.resize(size: .init(width: 30, height: 30))?.withRenderingMode(.alwaysOriginal)
        viewController.tabBarItem.title = title
    }
    
}
//高さ変更
class CustomTabBar: UITabBar {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = 70
        sizeThatFits.height += safeAreaInsets.bottom

        return sizeThatFits
    }
}
