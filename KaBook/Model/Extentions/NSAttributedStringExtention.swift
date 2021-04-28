//
//  NSAttributedStringExtention.swift
//  KaBook
//
//  Created by takeda yuri on 2021/04/29.
//

import Foundation

extension NSAttributedString {
    func toNSData() -> NSData? {
        let options : [NSAttributedString.DocumentAttributeKey: Any] = [
            .documentType: NSAttributedString.DocumentType.rtfd,
            .characterEncoding: String.Encoding.utf8
        ]

        let range = NSRange(location: 0, length: length)
        guard let data = try? data(from: range, documentAttributes: options) else {
            return nil
        }

        return NSData(data: data)
    }
}
