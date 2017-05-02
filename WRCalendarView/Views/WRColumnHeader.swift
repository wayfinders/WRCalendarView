//
//  ScheduleWeekColumnHeader.swift
//  Argos
//
//  Created by wayfinder on 2017. 4. 2..
//  Copyright © 2017년 Tong. All rights reserved.
//

import UIKit
import DateToolsSwift

class WRColumnHeader: UICollectionReusableView {
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var weekdayLbl: UILabel!
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        dateFormatter.locale = Locale(identifier: "en_US")
    }
    
    var date: Date? {
        didSet {
            if let date = date {
                let weekday = calendar.component(.weekday, from: date) - 1
                
                dayLbl.text = String(calendar.component(.day, from: date))
                weekdayLbl.text = dateFormatter.shortWeekdaySymbols[weekday].uppercased()
                weekdayLbl.textColor = UIColor(hexString: "333333")
                
                if date.isSameDay(date: Date()) {
                    dayLbl.textColor = UIColor(hexString: "1398f2")
                    backgroundColor = UIColor(hexString: "f5f8fd")
                } else {
                    switch weekday {
                    case 0: // sunday
                        dayLbl.textColor = UIColor(hexString: "fe4646")
                    case 6:
                        dayLbl.textColor = UIColor(hexString: "3573ff")
                    default:
                        dayLbl.textColor = UIColor(hexString: "aaaaaa")
                    }
                    backgroundColor = UIColor.white
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dayLbl.text = ""
        weekdayLbl.text = ""
    }
}
