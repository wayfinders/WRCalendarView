//
//  WRRowHeader.swift
//
//  Created by wayfinder on 2017. 3. 31..
//  Copyright © 2017년 Tong. All rights reserved.
//

import UIKit

class WRRowHeader: UICollectionReusableView {
    @IBOutlet weak var timeLbl: UILabel!
    let dateFormatter = DateFormatter()
    let calendar = Calendar.current
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dateFormatter.dateFormat = "HH:mm"
    }

    var date: Date? {
        didSet {
            if let date = date,
                calendar.component(.hour, from: date) != 0 && calendar.component(.hour, from: date) != 24 {
                timeLbl.text = dateFormatter.string(from: date)
            } else {
                timeLbl.text = ""
            }
        }
    }
}
