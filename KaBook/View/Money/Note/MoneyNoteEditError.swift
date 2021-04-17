//
//  MoneyNoteEditError.swift
//  KaBook
//
//  Created by takeda yuri on 2021/04/15.
//

import UIKit

enum MoneyNoteEditError:Error {
    case noteTextNoneError
    case moneyTextNotIntError
}

extension MoneyNoteEditError:LocalizedError{
    var errorDescription:String?{
        switch self {
        case .noteTextNoneError:
            return "ノート内容に記述がありません。"
        case .moneyTextNotIntError:
            return "収支金額には数字を入力してください。"
        }
    }
}
