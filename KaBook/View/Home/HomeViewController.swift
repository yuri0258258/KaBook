//
//  ViewController.swift
//  KaBook
//
//  Created by takeda yuri on 2021/03/23.
//

import UIKit
import RealmSwift

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
        let height:CGFloat = 430
        
        return .init(width: width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = chartListCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChartListCollectionViewCell
        //月の取得
        let date = Date()
        //総資産(仮)
        var totalMoney = 10000000
        if indexPath.row == 0 {
            //年間収支
            let year = date.get(.year)
            cell.chartTermLabel.text = "年間収支（\(year)年）"
            cell.chartView.leftAxis.axisMaximum = 3000000
        }else if indexPath.row == 1{
            //月間収支
            let thisMonth = date.get(.month)
            cell.chartTermLabel.text = "月間収支（\(thisMonth)月）"
            cell.chartView.leftAxis.axisMaximum = 300000
            
            //今月の日数を取得
            let calendar = Calendar(identifier: .gregorian)
            var components = DateComponents()
            components.year = date.get(.year)
            // 日数を求めたい次の月。13になってもOK。ドキュメントにも、月もしくは月数とある
            components.month = thisMonth + 1
            // 日数を0にすることで、前の月の最後の日になる
            components.day = 0
            // 求めたい月の最後の日のDateオブジェクトを得る
            let date = calendar.date(from: components)!
            let dayCount = calendar.component(.day, from: date)
            
            //今月が一桁の場合の処理(Realmデータと合わせる)
            var thisMonthString = "\(thisMonth)"
            if thisMonth < 10 {
                thisMonthString = "0\(thisMonth)"
            }
            
            for day in 0..<dayCount {
                //Realmからの取得
                let realm = try! Realm()
                var result = realm.objects(CalendarRealm.self)
  
                //日が一桁の場合の処理(Realmデータと合わせる)
                if day + 1 < 10 {
                    //日付のデータをRealmから探して、取得
                    result = result.filter("date = '\(date.get(.year))/\(thisMonthString)/0\(day + 1)'")
                    for data in result {
                        if  let money = Int(data.money)  {
                            totalMoney += money
                            print(totalMoney)
                        }
                    }
                }else{
                    //日が二桁の場合の処理
                    //日付のデータをRealmから探して、取得
                    result = result.filter("date = '\(date.get(.year))/\(thisMonthString)/\(day + 1)'")
                    for data in result {
                        if  let money = Int(data.money)  {
                            totalMoney += money
                            print(totalMoney)
                        }
                    }
                }
            }
            let rawData: [Int] = [100000,100000,100000,100000]
            cell.initDisplay(data: rawData)
        }
        return cell
    }
}
