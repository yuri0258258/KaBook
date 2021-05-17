//
//  ChartListCollectionViewCell.swift
//  KaBook
//
//  Created by takeda yuri on 2021/04/01.
//

import UIKit
import Charts

class ChartListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var chartTermLabel: UILabel!
    @IBOutlet weak var totalMoneyLabel: UILabel!
    @IBOutlet weak var previousRatioLabel: UILabel!
    
    // チャートデータ
      var lineDataSet: LineChartDataSet!
    
    override func awakeFromNib(){
        super.awakeFromNib()
        setUpViews()
    }
    
    private func setUpViews(){
        // y軸のプロットデータ(検証用)
        let rawData: [Int] = [100000,110000,90000,60000,100000,100000,100000,120000,140000,180000,150000,200000]
        initDisplay(data: rawData)
    }
    
      private func initDisplay(data: [Int]) {
        let dataEntries = data.enumerated().map { BarChartDataEntry(x: Double($0.offset + 1), y: Double($0.element)) }
           
           lineDataSet = LineChartDataSet(entries: dataEntries, label: "")
           chartView.data = LineChartData(dataSet: lineDataSet)
           
           // x軸のラベルをボトムに表示
           chartView.xAxis.labelPosition = .bottom
           // x軸のラベル数をデータの数に設定
           chartView.xAxis.labelCount = dataEntries.count - 1
           // タップでプロットを選択できないようにする
           chartView.highlightPerTapEnabled = false
           chartView.leftAxis.axisMaximum = 250000 //y左軸最大値
           chartView.leftAxis.axisMinimum = 0 //y左軸最小値
           chartView.leftAxis.labelCount = 11 //y軸ラベルの表示数
           chartView.leftAxis.drawTopYLabelEntryEnabled = true // y軸の最大値のみ表示
           chartView.leftAxis.forceLabelsEnabled = true //最小最大値ラベルを必ず表示?
           chartView.rightAxis.enabled = false // Y軸右軸(値)を非表示
//        chartView.leftAxis.description = "（月）"
           chartView.extraTopOffset = 25 // 上から20pxオフセット
           chartView.legend.enabled = false // 左下のラベル非表示
           chartView.pinchZoomEnabled = true // ピンチズームオフ
           chartView.doubleTapToZoomEnabled = false // ダブルタップズームオフ
           // グラフアニメーション
           chartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
           // グラフの色
           lineDataSet.colors = [UIColor.rgb(red: 12, green: 120, blue: 200)]
           // プロットの色
           lineDataSet.circleColors = [UIColor.rgb(red: 58, green: 236, blue: 150)]
           // プロットの大きさ
           lineDataSet.circleRadius = 3.0
           //ラインの太さ
           lineDataSet.lineWidth = 5
           lineDataSet.drawValuesEnabled = false
      }
}
