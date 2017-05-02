//
//  WRCurrentTimeIndicator.swift
//
//  Created by wayfinder on 2017. 4. 6..
//  Copyright © 2017년 revo. All rights reserved.
//

import UIKit
import DateToolsSwift

class WRCurrentTimeIndicator: UICollectionReusableView {
    @IBOutlet weak var timeLbl: UILabel!
    let dateFormatter = DateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dateFormatter.dateFormat = "HH:mm"
        
        let timer = Timer(fireAt: Date() + 1.minutes, interval: TimeInterval(60), target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .defaultRunLoopMode)
        
        updateTimer()
    }
    
    func updateTimer() {
        timeLbl.text = dateFormatter.string(from: Date())
    }
}
