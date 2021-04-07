//
//  NavigationExtentions.swift
//  KaBook
//
//  Created by takeda yuri on 2021/03/31.
//

import UIKit

extension UINavigationBar {
    func navigationBarGradientBackGround(navigationBar: UINavigationBar,safeAreaTop: CGFloat,color1: CGColor = UIColor.rgb(red: 55, green: 161, blue: 246).cgColor, color2: CGColor = UIColor.rgb(red: 58, green: 236, blue: 150).cgColor){
        // CAGradientLayerの初期化
        let gradient = CAGradientLayer()

        // gradientがnavigationBar + safeAreaと同サイズになるよう設定
        var bounds = navigationBar.bounds
        bounds.size.height += safeAreaTop
        gradient.frame = bounds

        // グラデーションに使用する色の設定
        gradient.colors = [color1, color2]

        // グラデーションの開始・終了ポイント位置を直接指定(0-1で指定する)
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)

        if let image = getImageFrom(gradientLayer: gradient) {
            // 関数2を用いて生成したimageをセットする
            navigationBar.setBackgroundImage(image, for: .default)
        }
    }

    func getImageFrom(gradientLayer: CAGradientLayer) -> UIImage? {
        var gradientImage: UIImage?
        // gradientLayerと同サイズの描画環境CurrentContextに設定
        UIGraphicsBeginImageContext(gradientLayer.frame.size)

        // さっき作成した描画環境ほんまにある？
        if let context = UIGraphicsGetCurrentContext() {
            // レイヤーをcontextに描画する
            gradientLayer.render(in: context)
            // 描画されたcontextをimageに変換してresize
            gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        }

        // 最初に設定したCurrentContextをスタックメモリー上からさようなら
        UIGraphicsEndImageContext()

        // UIImageをreturn
        return gradientImage
    }
}
