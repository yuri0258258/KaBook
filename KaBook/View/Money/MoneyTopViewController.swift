// MoneyTopViewController.swift
// KaBook
// Created by takeda yuri on 2021/04/06.

import UIKit
import FSCalendar
import CalculateCalendarLogic
import RealmSwift

class MoneyTopViewController: UIViewController {
    @IBOutlet weak var carendarView: FSCalendar!
    
    @IBOutlet weak var moneyTopNoteTableView: UITableView!
    
    private var cellId = "cellId"
    
    var moneyTopNoteTableViewCellDateLabelText = ""
    
    var moneyTopNoteTableViewCellTextViewText = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        carendarViewSetUp()
        
        //tableview
        moneyTopNoteTableView.delegate = self
        moneyTopNoteTableView.dataSource = self
        moneyTopNoteTableView.tableFooterView = UIView()
        moneyTopNoteTableView.register(UINib(nibName: "MoneyTopNoteTableViewCell", bundle: nil),forCellReuseIdentifier: cellId)
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
        carendarView.dataSource = self
        carendarView.delegate = self
        carendarView.today = nil
        carendarView.backgroundColor = .white
        carendarView.headerHeight = 80
        carendarView.weekdayHeight = 50
        carendarView.calendarWeekdayView.backgroundColor = UIColor.rgb(red: 55, green: 161, blue: 246)

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
        let tmpDate = Calendar(identifier: .gregorian)
        let year = tmpDate.component(.year, from: date)
        let month = tmpDate.component(.month, from: date)
        let day = tmpDate.component(.day, from: date)
        let m = String(format: "%02d", month)
        let d = String(format: "%02d", day)
        let date = "\(year)/\(m)/\(d)"
    
        //クリックしたら、日付が表示される。
        moneyTopNoteTableViewCellDateLabelText = "\(m)/\(d)"
        //クリックされた日付にノートがない場合のノート内容
        moneyTopNoteTableViewCellTextViewText = "書き込みがありません。"
        //スケジュール取得
        let realm = try! Realm()
        var result = realm.objects(CalendarRealm.self)
        print(result)
        //タップした日付のデータをRealmから探して、メモ内容を変数に格納
        result = result.filter("date = '\(date)'")
        for data in result {
            if data.date == date {
                moneyTopNoteTableViewCellTextViewText = data.event
            }
        }
        moneyTopNoteTableView.reloadData()
    }
}

//MARK: - UITableViewDelegate
extension MoneyTopViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = moneyTopNoteTableView.dequeueReusableCell(withIdentifier: cellId,for:indexPath) as! MoneyTopNoteTableViewCell
        cell.moneyTopNoteTableViewCellDateLabel.text = moneyTopNoteTableViewCellDateLabelText
        cell.moneyTopNoteTableViewCellTextView.text = moneyTopNoteTableViewCellTextViewText
        cell.moneyTopNoteTableViewCellDelegate = self
        return cell
    }
}

//MARK: - MoneyTopNoteTableViewCellDelegate
extension MoneyTopViewController: MoneyTopNoteTableViewCellDelegate {
    func MoneyTopNoteTableViewCelltappedDetailButton() {
        let storyboard = UIStoryboard(name: "MoneyNoteEdit", bundle: nil)
        let moneyNoteEditViewController = storyboard.instantiateViewController(withIdentifier: "MoneyNoteEditViewController")
        let nav = UINavigationController(rootViewController: moneyNoteEditViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
}
