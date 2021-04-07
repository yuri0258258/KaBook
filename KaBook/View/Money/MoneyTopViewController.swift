// MoneyTopViewController.swift
// KaBook
// Created by takeda yuri on 2021/04/06.

import UIKit
import FSCalendar
import CalculateCalendarLogic
import RealmSwift

class MoneyTopViewController: UIViewController {
    //スケジュール内容
    let labelDate = UILabel(frame: CGRect(x: 5, y: 650, width: 400, height: 50))
    //「主なスケジュール」の表示
    let labelTitle = UILabel(frame: CGRect(x: 0, y: 600, width: 180, height: 50))
    //日付の表示
    let carendarDate = UILabel(frame: CGRect(x: 5, y: 500, width: 200, height: 100))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        carendarViewSetUp()
        
        //日付表示設定
        carendarDate.text = ""
        carendarDate.font = UIFont.systemFont(ofSize: 60.0)
        carendarDate.textColor = .black
        view.addSubview(carendarDate)
        
        //「主なスケジュール」表示設定
        labelTitle.text = ""
        labelTitle.textAlignment = .center
        labelTitle.font = UIFont.systemFont(ofSize: 20.0)
        view.addSubview(labelTitle)
        
        //スケジュール内容表示設定
        labelDate.text = ""
        labelDate.font = UIFont.systemFont(ofSize: 18.0)
        view.addSubview(labelDate)
    
        //スケジュール追加ボタン
        let addBtn = UIButton(frame: CGRect(x:self.view.frame.size.width - 80, y: self.view.frame.size.height - 300, width: 60, height: 60))
        addBtn.setTitle("+", for: UIControl.State())
        addBtn.setTitleColor(.white, for: UIControl.State())
        addBtn.backgroundColor = .orange
        addBtn.layer.cornerRadius = 30.0
        addBtn.addTarget(self, action: #selector(onClick(_:)), for: .touchUpInside)
        view.addSubview(addBtn)
    }
    
    
    //画面遷移(スケジュール登録ページ)
    @objc func onClick(_: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let SecondController = storyboard.instantiateViewController(withIdentifier: "Insert")
        present(SecondController, animated: true, completion: nil)
    }
    
    
    private func setUpViews(){
        //navまわり
        if let navigationBar = self.navigationController?.navigationBar {
            navigationItem.title = "収支"
            navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white,.font: UIFont(name: "HiraginoSans-W3", size: 24) as Any]
            navigationBar.navigationBarGradientBackGround(navigationBar: navigationBar, safeAreaTop: self.additionalSafeAreaInsets.top)
        }
    }
    
    //カレンダーのレイアウト
    private func carendarViewSetUp(){
        //ステータスバーの高さ
        let statusBarheight = getStatusBarHeight()
        // ナビゲーションバーの高さ
        let navigationBar = (navigationController?.navigationBar.frame.size.height)!
        //カレンダー部分
        let carendarView = FSCalendar(frame: CGRect(x: 0, y: statusBarheight + navigationBar + 20, width: UIScreen.main.bounds.size.width, height: 400))
        
        carendarView.dataSource = self
        carendarView.delegate = self
        carendarView.today = nil
        carendarView.tintColor = .red
        view.backgroundColor = .white
        carendarView.backgroundColor = .white
        
        // ヘッダを変更する
        carendarView.appearance.headerDateFormat = "YYYY年MM月"
        carendarView.calendarWeekdayView.weekdayLabels[0].text = "日"
        carendarView.calendarWeekdayView.weekdayLabels[1].text = "月"
        carendarView.calendarWeekdayView.weekdayLabels[2].text = "火"
        carendarView.calendarWeekdayView.weekdayLabels[3].text = "水"
        carendarView.calendarWeekdayView.weekdayLabels[4].text = "木"
        carendarView.calendarWeekdayView.weekdayLabels[5].text = "金"
        carendarView.calendarWeekdayView.weekdayLabels[6].text = "土"
        view.addSubview(carendarView)
    }
}


//MARK: - FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance
extension MoneyTopViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance{
    //カレンダースクロールした時にリロード
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        calendar.reloadData()
    }
    
    // 祝日判定を行い結果を返すメソッド
    func judgeHoliday(_ date : Date) -> Bool {
        //祝日判定用のカレンダークラスのインスタンス
        let tmpCalendar = Calendar(identifier: .gregorian)
        // 祝日判定を行う日にちの年、月、日を取得
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        let holiday = CalculateCalendarLogic()
    
        return holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
    }
    
    // date型 -> 年月日をIntで取得
    func getDay(_ date:Date) -> (Int,Int,Int){
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        return (year,month,day)
    }
    
    //曜日判定
    func getWeekIdx(_ date: Date) -> Int{
        let tmpCalendar = Calendar(identifier: .gregorian)
        return tmpCalendar.component(.weekday, from: date)
    }
    
    // 土日や祝日の日の文字色を変える
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        // 現在表示されているページの月とセルの月が異なる場合には nil を戻す
        if Calendar.current.compare(date, to: calendar.currentPage, toGranularity: .month) != .orderedSame {
            return nil
        }
        
        //祝日判定をする
        if self.judgeHoliday(date){
            return UIColor.red
        }
        
        //土日の判定
        let weekday = self.getWeekIdx(date)
        if weekday == 1 {
            return UIColor.red
        }
        else if weekday == 7 {
            return UIColor.blue
        }
        return nil
    }
    
    //カレンダー処理(スケジュール表示処理)
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition){
        labelTitle.text = "主なスケジュール"
        labelTitle.backgroundColor = .orange
        view.addSubview(labelTitle)
        //予定がある場合、スケジュールをDBから取得・表示する。
        //無い場合、「スケジュールはありません」と表示。
        labelDate.text = "スケジュールはありません"
        labelDate.textColor = .lightGray
        view.addSubview(labelDate)
 
        let tmpDate = Calendar(identifier: .gregorian)
        let year = tmpDate.component(.year, from: date)
        let month = tmpDate.component(.month, from: date)
        let day = tmpDate.component(.day, from: date)
        let m = String(format: "%02d", month)
        let d = String(format: "%02d", day)
        let da = "\(year)/\(m)/\(d)"
    
        //クリックしたら、日付が表示される。
        carendarDate.text = "\(m)/\(d)"
        view.addSubview(carendarDate)
        //スケジュール取得
        let realm = try! Realm()
        var result = realm.objects(CalendarRealm.self)
        result = result.filter("date = '\(da)'")
        print(result)
        for ev in result {
            if ev.date == da {
                labelDate.text = ev.event
                labelDate.textColor = .black
                view.addSubview(labelDate)
            }
        }
    }
}

