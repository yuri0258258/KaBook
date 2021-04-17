//
//  MoneyNoteEditViewController.swift
//  KaBook
//
//  Created by takeda yuri on 2021/04/12.
//

import UIKit
import RealmSwift

class MoneyNoteEditViewController: UIViewController {
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var moneyView: UIView!
    @IBOutlet weak var moneyTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var moneyPlusButton: UIButton!
    @IBOutlet weak var moneyMinusButton: UIButton!
    
    var noteDate: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    
    override func viewDidLayoutSubviews() {
        //これでスクロールの高さ調節
        contentViewHeightConstraint.constant = 1000
        //これなかったらスクロールしない
        contentScrollView.contentSize = contentView.frame.size
    }
    
    private func setUpViews(){
        //navまわり
        if let navigationBar = self.navigationController?.navigationBar {
            navigationItem.title = "収支ノート"
            navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white,.font: UIFont(name: "HiraginoSans-W3", size: 24) as Any]
            navigationBar.navigationBarGradientBackGround(navigationBar: navigationBar, safeAreaTop: self.additionalSafeAreaInsets.top)
            
            let backBarButton =  UIBarButtonItem(title: "戻る", style: .plain, target: self, action: #selector(tappedbackButton))
            navigationItem.leftBarButtonItem = backBarButton
            navigationItem.leftBarButtonItem?.tintColor = .white
        }
        //収支金額プラス、マイナスボタンまわり
        moneyPlusButton.setImage(UIImage(named: "plusButton"), for: .selected)
        moneyPlusButton.setImage(UIImage(named: "unselected_plusButton"), for: .normal)
        moneyMinusButton.setImage(UIImage(named: "minusButton"), for: .selected)
        moneyMinusButton.setImage(UIImage(named: "unselected_minusButton"), for: .normal)
        
        //moneyTextField
        moneyTextField.text = "0"
    }
    
    @IBAction func tappedPlusButton(_ sender: Any) {
        moneyPlusButton.isSelected = true
        moneyMinusButton.isSelected = false
    }
    
    @IBAction func tappedMinusButton(_ sender: Any) {
        moneyMinusButton.isSelected = true
        moneyPlusButton.isSelected = false
    }
    @objc private func tappedbackButton(){
        navigationController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func tappedNoteAddButton(_ sender: Any) {
        
        //エラーチェック
        //ノート内容が空の場合
        if noteTextView.text == "" {
            errorAlert(error: .noteTextNoneError)
            return
        }
        //moneyTextFieldの値が数字かどうか
        guard let _ = Int(moneyTextField.text!) else {
            errorAlert(error: .moneyTextNotIntError)
            return
        }
        
        guard let notetext = noteTextView.text else {
            return
        }
        
        let money = moneyTextFieldCheck(moneyTextField: moneyTextField)
        
        print("データ書き込み開始")
        let realm = try! Realm()
        try! realm.write {
            //日付表示の内容とスケジュール入力の内容が書き込まれる。
            let calendarRealm = [CalendarRealm(value: ["date": noteDate, "note": notetext,"money": money])]
            realm.add(calendarRealm)
            print("データ書き込み中")
        }
        print("データ書き込み完了")
        
        //前のページに戻る
        let storyboard = UIStoryboard(name: "MoneyTop", bundle: nil)
        let moneyTopViewController = storyboard.instantiateViewController(withIdentifier: "MoneyTopViewController") as! MoneyTopViewController
        let nav = UINavigationController(rootViewController: moneyTopViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true) {
            moneyTopViewController.moneyTopNoteTableView.reloadData()
        }
    }
    
    //moneyTextFieldの値のチェックと変換
    private func moneyTextFieldCheck(moneyTextField: UITextField) -> String{
        //moneyTextFieldの値が空か0の時は0を返す
        if (moneyTextField.text == "" || moneyTextField.text == "0"){
            return "0"
        }else{
            //収支金額プラスボタンとマイナスボタンのどちらが選ばれているかのチェック
            guard let money = Int(moneyTextField.text!) else {
                return "0"
            }
            if moneyMinusButton.isSelected {
                let minusMoney = "-\(abs(money))"
                return minusMoney
            }else{
                let plusMoney = "+\(abs(money))"
                return plusMoney
            }
        }
    }
    
    //エラー発生時のアラート処理
    private func errorAlert(error: MoneyNoteEditError){
        let ac = UIAlertController(title: "🚨", message: error.errorDescription, preferredStyle: .alert)
          ac.addAction(UIAlertAction(title: "OK", style: .default))
          present(ac,animated: true)
        print("エラー発生")
    }
}
