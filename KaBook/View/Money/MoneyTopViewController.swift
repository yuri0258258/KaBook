// MoneyTopViewController.swift
// KaBook
// Created by takeda yuri on 2021/04/06.

import UIKit
import FSCalendar
import CalculateCalendarLogic
import RealmSwift
import PKHUD

class MoneyTopViewController: UIViewController {
    @IBOutlet weak var carendarView: FSCalendar!
    
    @IBOutlet weak var moneyTopNoteTableView: UITableView!
    
    private var cellId = "cellId"
    
    var moneyTopNoteTableViewHeight:CGFloat = 350
    
    private var carendarDate: String?
    
    var moneyTopNoteTableViewCellDateLabelText = ""
    
    var moneyTopNoteTableViewCellMoneyLabelText = "0"
    
    
    var noteData:NSAttributedString?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        carendarViewSetUp()
    }
    
    
    private func setUpViews(){
        //navまわり
        if let navigationBar = self.navigationController?.navigationBar {
            navigationItem.title = "収支"
            navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white,.font: UIFont(name: "HiraginoSans-W3", size: 24) as Any]
            navigationBar.navigationBarGradientBackGround(navigationBar: navigationBar, safeAreaTop: self.additionalSafeAreaInsets.top)
        }
        
        //tableview
        moneyTopNoteTableView.delegate = self
        moneyTopNoteTableView.dataSource = self
        moneyTopNoteTableView.tableFooterView = UIView()
        moneyTopNoteTableView.register(UINib(nibName: "MoneyTopNoteTableViewCell", bundle: nil),forCellReuseIdentifier: cellId)
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
    
    //カレンダー処理(ノート表示処理)
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let tmpDate = Calendar(identifier: .gregorian)
        let year = tmpDate.component(.year, from: date)
        let month = tmpDate.component(.month, from: date)
        let day = tmpDate.component(.day, from: date)
        let m = String(format: "%02d", month)
        let d = String(format: "%02d", day)
        let date = "\(year)/\(m)/\(d)"
        carendarDate = "\(year)/\(m)/\(d)"
        //クリックしたら、日付が表示される。
        moneyTopNoteTableViewCellDateLabelText = "\(m)/\(d)"
        //クリックされた日付にノートがない場合のノート内容
        let attributedString: [NSAttributedString.Key : Any] = [
            .font : UIFont.systemFont(ofSize: 14)
        ]
        
        noteData = NSAttributedString(string: "書き込みがありません。", attributes: attributedString)
        moneyTopNoteTableViewCellMoneyLabelText = "0"
        fetchRealmMoneyTopNoteTableView(date: date)
    }
    
    //カレンダーとノートの更新
    func fetchRealmMoneyTopNoteTableView(date: String){
        //スケジュール取得
        let realm = try! Realm()
        var result = realm.objects(CalendarRealm.self)
        //タップした日付のデータをRealmから探して、メモ内容を変数に格納
        result = result.filter("date = '\(date)'")
        for data in result {
            if data.date == date {
                noteData = data.notedata?.toAttributedString()
                moneyTopNoteTableViewCellMoneyLabelText = data.money
            }
        }
        moneyTopNoteTableView.reloadData()
    }

    //Realmから受け取ったデータを変換してmoneyTopNoteTableViewCellMoneyLabelTextに入れる
    private func moneyTopNoteTableViewCellMoneyLabelTextConversion(moneyLabel: UILabel,moneyLabelText: String){
        guard let money = Int(moneyLabelText) else {
            return
        }
        
        switch money {
        case 0:
            moneyLabel.text = "0円"
            moneyLabel.textColor = .black
        case let money where money > 0:
            moneyLabel.text = "+\(abs(money))円"
            moneyLabel.textColor = .red
        case let money where money < 0:
            moneyLabel.text = "-\(abs(money))円"
            moneyLabel.textColor = .blue
        default:
            moneyLabel.text = "0円"
        }
    }
}

//MARK: - UITableViewDelegate
extension MoneyTopViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return moneyTopNoteTableViewHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = moneyTopNoteTableView.dequeueReusableCell(withIdentifier: cellId,for:indexPath) as! MoneyTopNoteTableViewCell
        //最初の読み込み時には表示しない
        if noteData == nil {
            cell.MoneyTopNoteTableViewCellContentView.isHidden = true
        }else{
            cell.MoneyTopNoteTableViewCellContentView.isHidden = false
        }
        //ノートの書き込みがない場合のボタンテキスト変更
        if noteData?.string == "書き込みがありません。" {
            cell.moneyTopNoteTableViewCellDetailButton.isHidden = true
            cell.moneyTopNoteTableViewCellDetailButton.isEnabled = false
            cell.moneyTopNoteTableViewCellEditButton.isHidden = false
            cell.moneyTopNoteTableViewCellEditButton.isEnabled = true
        }else{
            cell.moneyTopNoteTableViewCellDetailButton.isHidden = false
            cell.moneyTopNoteTableViewCellDetailButton.isEnabled = true
            cell.moneyTopNoteTableViewCellEditButton.isHidden = true
            cell.moneyTopNoteTableViewCellEditButton.isEnabled = false
        }
        
        moneyTopNoteTableViewCellMoneyLabelTextConversion(moneyLabel: cell.moneyTopNoteTableViewCellMoneyLabel, moneyLabelText: moneyTopNoteTableViewCellMoneyLabelText)
        cell.moneyTopNoteTableViewCellDateLabel.text = moneyTopNoteTableViewCellDateLabelText
        cell.moneyTopNoteTableViewCellTextView.attributedText = noteData
        
        //ノート内容の高さだけcellの高さを高くする
        let moneyTopNoteTableViewCellTextViewHeight:CGFloat = 33
        cell.moneyTopNoteTableViewCellTextView.sizeToFit()
        if cell.moneyTopNoteTableViewCellTextView.frame.size.height > moneyTopNoteTableViewCellTextViewHeight {
            moneyTopNoteTableViewHeight += cell.moneyTopNoteTableViewCellTextView.frame.size.height - moneyTopNoteTableViewCellTextViewHeight
        }else{
            moneyTopNoteTableViewHeight = 350
        }
        cell.moneyTopNoteTableViewCellDelegate = self
        return cell
    }
}

//MARK: - MoneyTopNoteTableViewCellDelegate
extension MoneyTopViewController: MoneyTopNoteTableViewCellDelegate {
    
    func moneyTopNoteTableViewCelltappedEditButton() {
        let storyboard = UIStoryboard(name: "MoneyNoteEdit", bundle: nil)
        let moneyNoteEditViewController = storyboard.instantiateViewController(withIdentifier: "MoneyNoteEditViewController") as! MoneyNoteEditViewController
        moneyNoteEditViewController.noteDate = carendarDate
        moneyNoteEditViewController.moneyTopNoteTableViewReloadDelegate = self
        let nav = UINavigationController(rootViewController: moneyNoteEditViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    func moneyTopNoteTableViewCelltappedDetailButton() {
        print("収支ノート画面に遷移。準備中。")
    }
}

//MARK:- MoneyTopNoteTableViewReloadDelegate
extension MoneyTopViewController: MoneyTopNoteTableViewReloadDelegate{
    func moneyTopNoteTableViewReload() {
        moneyTopNoteTableView.performBatchUpdates({
            guard let date = carendarDate else {return}
            HUD.show(.progress)
            self.fetchRealmMoneyTopNoteTableView(date: date)
        }) { (finished) in
            HUD.hide()
        }
    }}
