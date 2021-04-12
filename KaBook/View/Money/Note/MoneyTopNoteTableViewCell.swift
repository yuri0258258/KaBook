//
//  MoneyTopNoteTableViewCell.swift
//  KaBook
//
//  Created by takeda yuri on 2021/04/11.
//

import UIKit

protocol MoneyTopNoteTableViewCellDelegate: class{
    func MoneyTopNoteTableViewCelltappedDetailButton()
}

class MoneyTopNoteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var moneyTopNoteTableViewCellDateLabel: UILabel!
    @IBOutlet weak var moneyTopNoteTableViewCellTextView: UITextView!
    @IBOutlet weak var moneyTopNoteTableViewCellDetailButton: UIButton!
    
   weak var moneyTopNoteTableViewCellDelegate:MoneyTopNoteTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        SetUpViews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func SetUpViews(){
    }
    @IBAction func tappedDetailButton(_ sender: Any) {
        moneyTopNoteTableViewCellDelegate?.MoneyTopNoteTableViewCelltappedDetailButton()
    }
}
