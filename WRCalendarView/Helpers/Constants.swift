//
//  Constants.swift
//  Pods
//
//  Created by wayfinder on 2017. 4. 26..
//
//

import Foundation

public enum SupplementaryViewKinds {
    static let columnHeader = "ColumnHeader"
    static let rowHeader = "RowHeader"
    static let defaultCell = "DefaultCell"
}

public enum DecorationViewKinds {
    static let todayBackground = "TodayBackground"
    static let columnHeaderBackground = "ColumnHeaderBackground"
    static let rowHeaderBackground = "RowHeaderBackground"
    static let currentTimeIndicator = "CurrentTimeIndicator"
    static let currentTimeGridline = "CurrentTimeGridline"
    static let verticalGridline = "VerticalGridline"
    static let horizontalGridline = "HorizontalGridline"
    static let cornerHeader = "CornerHeader"
}

public enum ReuseIdentifiers {
    static let columnHeader = WRColumnHeader.className
    static let rowHeader = WRRowHeader.className
    static let defaultCell = WREventCell.className
}

public enum CalendarType {
    case week
    case day
}

public enum HourGridDivision: Int {
    case none = 0
    case minutes_5 = 5
    case minutes_10 = 10
    case minutes_15 = 15
    case minutes_20 = 20
    case minutes_30 = 30
}

enum ScrollDirection {
    case none
    case crazy
    case left
    case right
    case up
    case down
    case horizontal
    case vertical
}

