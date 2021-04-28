//
//  NSDataExtention.swift
//  KaBook
//
//  Created by takeda yuri on 2021/04/29.
//

import Foundation

extension NSData {
    func toAttributedString() -> NSAttributedString? {
        let data = Data(referencing: self)
        let options : [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.rtfd,
            .characterEncoding: String.Encoding.utf8
        ]
        
        return try? NSAttributedString(data: data,
                                       options: options,
                                       documentAttributes: nil)
    }
}
