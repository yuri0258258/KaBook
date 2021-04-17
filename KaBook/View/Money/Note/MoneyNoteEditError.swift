//
//  MoneyNoteEditError.swift
//  KaBook
//
//  Created by takeda yuri on 2021/04/15.
//

import UIKit

enum MoneyNoteEditError:Error {
    case noteTextNoneError
    case error2
}

extension MoneyNoteEditError:LocalizedError{
    var errorDescription:String?{
        switch self {
        case .noteTextNoneError:
            return "ノート内容に記述がありません。"
        case .error2:
            return "エラーメッセージ_２"
        }
    }
}
