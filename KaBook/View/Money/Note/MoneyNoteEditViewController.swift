//
//  MoneyNoteEditViewController.swift
//  KaBook
//
//  Created by takeda yuri on 2021/04/12.
//

import UIKit
import RealmSwift
import AMColorPicker

//moneyTopNoteTableView更新プロトコル
protocol MoneyTopNoteTableViewReloadDelegate: AnyObject {
    func moneyTopNoteTableViewReload()
}

class MoneyNoteEditViewController: UIViewController {
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var moneyView: UIView!
    @IBOutlet weak var moneyTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var noteTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var moneyPlusButton: UIButton!
    @IBOutlet weak var moneyMinusButton: UIButton!
    @IBOutlet weak var addNoteButton: UIButton!
    @IBOutlet weak var addNoteButtonTopMarginConstraint: NSLayoutConstraint!
    
    weak var moneyTopNoteTableViewReloadDelegate: MoneyTopNoteTableViewReloadDelegate?
    
    var picker: UIImagePickerController! = UIImagePickerController()
    
    private lazy var moneyNoteEditAccessoryView: MoneyNoteEditAccessoryView = {
        let view = MoneyNoteEditAccessoryView()
        view.frame = .init(x: 0,y: 0,width: view.frame.width,height: accessoryHeight)
        view.moneyNoteEditAccessoryViewDelegate = self
        return view
    }()
    
    var noteDate: String?
    
    private let accessoryHeight:CGFloat = 70
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        setUpNotification()
        tappedView()
    }
    
    //他画面がタップされた時にdismissKeyboard()が呼ばれる関数
    private func tappedView(){
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
    }
    
    //キーボード閉じる
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
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
        moneyTextField.delegate = self
        
        //noteTextView
        noteTextView.delegate = self
        noteTextView.textContainerInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        noteTextView.layer.cornerRadius = 5
        noteTextView.inputAccessoryView = moneyNoteEditAccessoryView
        noteTextView.keyboardDismissMode = .interactive
    }
    
    //キーボードの通知処理
    private func setUpNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //キーボードの出現処理
    @objc private func keyboardWillShow(notification: NSNotification){
        guard let userInfo = notification.userInfo else {
            return
        }
        
        if let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            if keyboardFrame.height <= accessoryHeight {
                return
            }
            
            let contentInsentBottom = keyboardFrame.height
            
            //キーボードの領域を作る
            let contentInsent = UIEdgeInsets(top: 0, left: 0, bottom: contentInsentBottom, right: 0)
            
            contentScrollView.contentInset = contentInsent
            contentScrollView.scrollIndicatorInsets = contentInsent
        }
    }
    
    //キーボードが非表示になった時の処理
    @objc private func keyboardWillHide(){
        print("隠れる")
        let contentInsent = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        contentScrollView.contentInset = contentInsent
        contentScrollView.scrollIndicatorInsets = contentInsent
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
        
        guard  let noteData = noteTextView.attributedText.toNSData() else {
            return
        }
        
        guard let noteDate = noteDate else {
            return
        }
        
        let money = moneyTextFieldCheck(moneyTextField: moneyTextField)
        
        print("データ書き込み開始")
        let realm = try! Realm()
        try! realm.write {
            //日付表示の内容とスケジュール入力の内容が書き込まれる。
            let calendarRealm = [CalendarRealm(value: ["date": noteDate,"money": money,"notedata":noteData])]
            realm.add(calendarRealm)
            print("データ書き込み中")
        }
        print("データ書き込み完了")
        
        //前のページに戻るのとデータの更新
        self.dismiss(animated: true) {
            self.moneyTopNoteTableViewReloadDelegate?.moneyTopNoteTableViewReload()
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
                let plusMoney = "\(abs(money))"
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
    
    //ボタンの選択の論理値の変更
    private func accessoryViewButtonFalse(button: UIButton){
        button.isSelected = false
        button.backgroundColor =  .clear
    }
    
    //NoteTextViewのリサイズ処理
    private func resizeNoteTextView(){
        noteTextView.sizeToFit()
        let resizedHeight = noteTextView.frame.size.height
        let defaultNoteTextViewHeightConstant:CGFloat = 200
        let screenSizeHeight = UIScreen.main.bounds.size.height - ((self.navigationController?.navigationBar.frame.size.height)! + self.view.safeAreaInsets.bottom + self.view.safeAreaInsets.top)
        
        if resizedHeight > noteTextViewHeight.constant {
            noteTextViewHeight.constant = resizedHeight
            noteTextView.frame.size = CGSize(width: view.frame.width - 20, height: resizedHeight)
        }else{
            noteTextViewHeight.constant = defaultNoteTextViewHeightConstant
            noteTextView.frame.size = CGSize(width: view.frame.width - 20, height: resizedHeight)
        }
        
        //画面のスクロールと可変画面
        let noteTextViewAddingHeight = noteTextView.frame.size.height - defaultNoteTextViewHeightConstant
        let contentHeight = (noteTextViewAddingHeight + screenSizeHeight) - (moneyView.frame.height + 50)
        
        contentView.frame.size.height = contentHeight
        contentScrollView.contentSize = CGSize(width: view.frame.width , height: contentView.frame.size.height)
    }
}
//MARK: - UITextFieldDelegate
extension MoneyNoteEditViewController: UITextFieldDelegate{
    // returnボタン押下で閉じる場合
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - UITextFieldDelegate
extension MoneyNoteEditViewController: UITextViewDelegate{
    //テキストに変更がかけられた時に呼ばれる処理
    func textViewDidChange(_ textView: UITextView) {
        resizeNoteTextView()
    }
}
//MARK: - UIImagePickerControllerDelegate
extension MoneyNoteEditViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    //メモに画像を貼り付ける処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            
            let fullString = NSMutableAttributedString(attributedString: noteTextView.attributedText)
            //カーソルの位置を取得する
            var textViewCursor = 0
            if let selectedRange = noteTextView.selectedTextRange {
                textViewCursor = noteTextView.offset(from: noteTextView.beginningOfDocument, to: selectedRange.start)
            }
            // ScreenSize
            let screenWidth = self.view.bounds.width
            //画像サイズ
            var imageWidth = image.size.width
            
            //画像の横幅調整
            if imageWidth > noteTextView.frame.size.width {
                imageWidth = screenWidth - 70
            }
            
            let image = UIImage(cgImage: image.cgImage!).aspectWidthResize(image: image, width: Double(imageWidth))
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = image
            let imageString = NSAttributedString(attachment: imageAttachment)
            fullString.insert(imageString, at: textViewCursor)
            // TextViewに画像を含んだテキストをセット
            noteTextView.attributedText = fullString
            resizeNoteTextView()
        }
        dismiss(animated: true, completion: nil)
    }
}

//MARK:- MoneyNoteEditAccessoryViewDelegate
extension MoneyNoteEditViewController: MoneyNoteEditAccessoryViewDelegate{
    
    //写真貼り付けボタン
    func moneyNoteEditAccessoryViewTappedPhotoButton() {
        //PhotoLibraryから画像を選択
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        //デリゲートを設定する
        picker.delegate = self
        //現れるピッカーNavigationBarの文字色を設定する
        picker.navigationBar.tintColor = UIColor.white
        //現れるピッカーNavigationBarの背景色を設定する
        picker.navigationBar.barTintColor = UIColor.gray
        //ピッカーを表示する
        present(picker, animated: true, completion: nil)
    }
    
    //テキスト太字ボタン
    func moneyNoteEditAccessoryViewTappedTextBoldButton(){
        moneyNoteEditAccessoryView.textBoldButton.isSelected = !moneyNoteEditAccessoryView.textBoldButton.isSelected
        if  moneyNoteEditAccessoryView.textBoldButton.isSelected {
            let textAttributes: [NSAttributedString.Key : Any] = [
                .font : UIFont.boldSystemFont(ofSize: 16)
            ]
            noteTextView.typingAttributes = textAttributes
            moneyNoteEditAccessoryView.textBoldButton.backgroundColor =  .rgb(red: 55, green: 161, blue: 246)
            
            accessoryViewButtonFalse(button: moneyNoteEditAccessoryView.textLineButton)
            accessoryViewButtonFalse(button: moneyNoteEditAccessoryView.textColorButton)
        }else{
            let textAttributes: [NSAttributedString.Key : Any] = [
                .font : UIFont.systemFont(ofSize: 14)
            ]
            noteTextView.typingAttributes = textAttributes
            moneyNoteEditAccessoryView.textBoldButton.backgroundColor = .clear
        }
    }
    
    //テキスト下線ボタン
    func moneyNoteEditAccessoryViewTappedTextLineButton(){
        moneyNoteEditAccessoryView.textLineButton.isSelected = !moneyNoteEditAccessoryView.textLineButton.isSelected
        if  moneyNoteEditAccessoryView.textLineButton.isSelected {
            let textAttributes: [NSAttributedString.Key : Any] = [
                .font : UIFont.systemFont(ofSize: 14),
                .underlineStyle: NSUnderlineStyle.single.rawValue,
            ]
            noteTextView.typingAttributes = textAttributes
            moneyNoteEditAccessoryView.textLineButton.backgroundColor =  .rgb(red: 55, green: 161, blue: 246)
            
            accessoryViewButtonFalse(button: moneyNoteEditAccessoryView.textBoldButton)
            accessoryViewButtonFalse(button: moneyNoteEditAccessoryView.textColorButton)
        }else{
            let textAttributes: [NSAttributedString.Key : Any] = [
                .font : UIFont.systemFont(ofSize: 14)
            ]
            noteTextView.typingAttributes = textAttributes
            moneyNoteEditAccessoryView.textLineButton.backgroundColor = .clear
        }
    }
    
    //テキスト色変えボタン
    func moneyNoteEditAccessoryViewTappedTextColorButton(){
        moneyNoteEditAccessoryView.textColorButton.isSelected = !moneyNoteEditAccessoryView.textColorButton.isSelected
        if  moneyNoteEditAccessoryView.textColorButton.isSelected {
            let colorPickerViewController = AMColorPickerViewController()
            colorPickerViewController.delegate = self
            present(colorPickerViewController, animated: true, completion: nil)
            
            moneyNoteEditAccessoryView.textColorButton.backgroundColor =  .rgb(red: 55, green: 161, blue: 246)
            accessoryViewButtonFalse(button: moneyNoteEditAccessoryView.textBoldButton)
            accessoryViewButtonFalse(button: moneyNoteEditAccessoryView.textLineButton)
        }else{
            let textAttributes: [NSAttributedString.Key : Any] = [
                .font : UIFont.systemFont(ofSize: 14),
                .foregroundColor : UIColor.rgb(red: 0, green: 0, blue: 0)
            ]
            noteTextView.typingAttributes = textAttributes
            moneyNoteEditAccessoryView.textColorButton.backgroundColor = .clear
        }
    }
}

//MARK:- MoneyNoteEditAccessoryViewDelegate
extension MoneyNoteEditViewController: AMColorPickerDelegate{
    func colorPicker(_ colorPicker: AMColorPicker, didSelect color: UIColor) {
        let textAttributes: [NSAttributedString.Key : Any] = [
            .font : UIFont.systemFont(ofSize: 14),
            .foregroundColor : color
        ]
        noteTextView.typingAttributes = textAttributes
        moneyNoteEditAccessoryView.textColorButton.backgroundColor =  .rgb(red: 55, green: 161, blue: 246)
    }
}
