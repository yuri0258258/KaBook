//
//  MoneyNoteEditAccessoryView..swift
//  KaBook
//
//  Created by takeda yuri on 2021/04/19.
//

import UIKit

protocol MoneyNoteEditAccessoryViewDelegate: AnyObject{
    func moneyNoteEditAccessoryViewTappedPhotoButton()
    func moneyNoteEditAccessoryViewTappedTextBoldButton()
    func moneyNoteEditAccessoryViewTappedTextLineButton()
    func moneyNoteEditAccessoryViewTappedTextColorButton()
}

class MoneyNoteEditAccessoryView: UIView {
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var textBoldButton: UIButton!
    @IBOutlet weak var textLineButton: UIButton!
    @IBOutlet weak var textColorButton: UIButton!
    
    weak var moneyNoteEditAccessoryViewDelegate:MoneyNoteEditAccessoryViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibInit()
        setUpView()
    }

    private func setUpView() {
        photoButton.layer.cornerRadius = photoButton.frame.width / 2
        textBoldButton.layer.cornerRadius = textBoldButton.frame.width / 2
        textLineButton.layer.cornerRadius = textLineButton.frame.width / 2
        textColorButton.layer.cornerRadius = textColorButton.frame.width / 2
    }
    
    override var intrinsicContentSize: CGSize{
        return .zero
    }
    
    private func nibInit() {
        let nib = UINib(nibName: "MoneyNoteEditAccessoryView", bundle: nil)
      guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
        return
      }
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @IBAction func tappedPhotoButton(_ sender: Any) {
        moneyNoteEditAccessoryViewDelegate?.moneyNoteEditAccessoryViewTappedPhotoButton()
    }
    
    @IBAction func tappedTextBoldButton(_ sender: Any) {
        moneyNoteEditAccessoryViewDelegate?.moneyNoteEditAccessoryViewTappedTextBoldButton()
    }
    @IBAction func tappedTextLineButton(_ sender: Any) {
        moneyNoteEditAccessoryViewDelegate?.moneyNoteEditAccessoryViewTappedTextLineButton()
    }
    @IBAction func tappedTextColorButton(_ sender: Any) {
        moneyNoteEditAccessoryViewDelegate?.moneyNoteEditAccessoryViewTappedTextColorButton()
    }
}
