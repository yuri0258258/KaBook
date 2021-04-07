//
//  Navigation.swift
//  KaBook
//
//  Created by takeda yuri on 2021/04/08.
//

import UIKit

func getStatusBarHeight() -> CGFloat {
   var statusBarHeight: CGFloat = 0
   if #available(iOS 13.0, *) {
       let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
       statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
   } else {
       statusBarHeight = UIApplication.shared.statusBarFrame.height
   }
   return statusBarHeight
}

