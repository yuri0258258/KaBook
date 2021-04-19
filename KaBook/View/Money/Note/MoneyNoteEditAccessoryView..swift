//
//  MoneyNoteEditAccessoryView..swift
//  KaBook
//
//  Created by takeda yuri on 2021/04/19.
//

import UIKit

class MoneyNoteEditAccessoryView: UIView {
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var textBoldButton: UIButton!
    @IBOutlet weak var textLineButton: UIButton!
    @IBOutlet weak var textColor: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibInit()
        setUpView()
    }

    private func setUpView() {
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
        print("tappedPhotoButton")
    }
    
    @IBAction func tappedTextBoldButton(_ sender: Any) {
        print("tappedTextBoldButton")
    }
    @IBAction func tappedTextLineButton(_ sender: Any) {
        print("tappedTextLineButton")
    }
    @IBAction func tappedTextColorButton(_ sender: Any) {
        print("tappedTextColorButton")
    }
}
