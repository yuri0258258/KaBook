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
    
    var date: String!
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
    }
    
    
    @objc private func tappedbackButton(){
     navigationController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func tappedNoteAddButton(_ sender: Any) {
        print("データ書き込み開始")
        guard let notetext = noteTextView.text else {
            return
        }
            let realm = try! Realm()
             
            try! realm.write {
                //日付表示の内容とスケジュール入力の内容が書き込まれる。
                let calendarRealm = [CalendarRealm(value: ["date": "2021/04/11", "event": notetext])]
                realm.add(calendarRealm)
                print("データ書き込み中")
            }

        print("データ書き込み完了")

        //前のページに戻る
        dismiss(animated: true, completion: nil)
    }
}
