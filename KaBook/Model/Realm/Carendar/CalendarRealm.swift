//
//  CalendarRealm.swift
//  KaBook
//
//  Created by takeda yuri on 2021/04/08.
//

import Foundation
import RealmSwift

class CalendarRealm: Object {
    @objc dynamic var date: String = ""
    @objc dynamic var note: String = ""
    @objc dynamic var money: String = "0"
}
