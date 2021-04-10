//
//  ViewController.swift
//  KaBook
//
//  Created by takeda yuri on 2021/03/23.
//

import UIKit

class HomeViewController: UIViewController {
    
    private var cellId = "cellId"

    @IBOutlet weak var chartListCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    
    private func setUpViews(){
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.topItem!.titleView = UIImageView(image:UIImage(named: "logo-title")?.resize(size: .init(width: 150, height: 25)))
            navigationBar.navigationBarGradientBackGround(navigationBar: navigationBar, safeAreaTop: self.additionalSafeAreaInsets.top)
        }
        
        chartListCollectionView.delegate = self
        chartListCollectionView.dataSource = self
        chartListCollectionView.register(UINib(nibName: "ChartListCollectionViewCell", bundle: nil),forCellWithReuseIdentifier: cellId)
    }
    
    
}

//MARK: - UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width
        
        return .init(width: width, height: 410)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = chartListCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChartListCollectionViewCell
       
        return cell
    }
}
