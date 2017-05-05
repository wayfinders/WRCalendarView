//
//  WRWeekView.swift
//  Pods
//
//  Created by wayfinder on 2017. 4. 26..
//
//

import UIKit
import DateToolsSwift

public protocol WRWeekViewDelegate: NSObjectProtocol  {
    func view(startDate: Date, interval: Int)
    func tap(date: Date)
    func selectEvent(_ event: WREvent)
}

public class WRWeekView: UIView {
    let pageCount = 7
    let dateFormatter = DateFormatter()
    
    var collectionView: UICollectionView!
    var flowLayout: WRWeekViewFlowLayout!
    var initDate: Date!
    var startDate: Date!
    var initialContentOffset = CGPoint.zero
    var currentPage: Int!
    var loading = false
    var isFirst = true
    var daysToShow: Int = 0
    var daysToShowOnScreen: Int = 0
    var calendarDate: Date!
    var events = [WREvent]()
    var eventBySection = [String: [WREvent]]()
    
    public weak var delegate: WRWeekViewDelegate?
    
    public var calendarType: CalendarType = .week {
        didSet {
            isFirst = true
            updateView()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.timeZone = TimeZone.current
        
        flowLayout = WRWeekViewFlowLayout()
        flowLayout.delegate = self
        
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isDirectionalLockEnabled = true
        collectionView.bounces = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.white
        addSubview(collectionView)

        let views: [String: AnyObject] = ["collectionView": collectionView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", options: [], metrics: nil, views: views))
        
        registerViewClasses()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
    }
    
    func registerViewClasses() {
        let podBundle = Bundle(for: WRWeekView.self)
        let bundleURL = podBundle.url(forResource: "WRCalendarView", withExtension: "bundle")
        let bundle = Bundle(url: bundleURL!)!

        //cell
        collectionView.register(UINib.init(nibName: WREventCell.className, bundle: bundle),
                                forCellWithReuseIdentifier: ReuseIdentifiers.defaultCell)
        
        //supplementary
        collectionView.register(UINib.init(nibName: WRColumnHeader.className, bundle: bundle),
                                forSupplementaryViewOfKind: SupplementaryViewKinds.columnHeader,
                                withReuseIdentifier: ReuseIdentifiers.columnHeader)
        collectionView.register(UINib.init(nibName: WRRowHeader.className, bundle: bundle),
                                forSupplementaryViewOfKind: SupplementaryViewKinds.rowHeader,
                                withReuseIdentifier: ReuseIdentifiers.rowHeader)
        
        //decoration
        flowLayout.register(WRTodayBackground.self,
                            forDecorationViewOfKind: DecorationViewKinds.todayBackground)
        flowLayout.register(WRColumnHeaderBackground.self,
                            forDecorationViewOfKind: DecorationViewKinds.columnHeaderBackground)
        flowLayout.register(WRRowHeaderBackground.self,
                            forDecorationViewOfKind: DecorationViewKinds.rowHeaderBackground)
        flowLayout.register(WRGridLine.self,
                            forDecorationViewOfKind: DecorationViewKinds.verticalGridline)
        flowLayout.register(WRGridLine.self,
                            forDecorationViewOfKind: DecorationViewKinds.horizontalGridline)
        flowLayout.register(WRCornerHeader.self,
                            forDecorationViewOfKind: DecorationViewKinds.cornerHeader)
        flowLayout.register(WRCurrentTimeGridline.self,
                            forDecorationViewOfKind: DecorationViewKinds.currentTimeGridline)
        flowLayout.register(UINib(nibName: WRCurrentTimeIndicator.className, bundle: bundle),
                             forDecorationViewOfKind: DecorationViewKinds.currentTimeIndicator)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        flowLayout.sectionWidth = (frame.width - flowLayout.rowHeaderWidth) / CGFloat(daysToShowOnScreen)
    }
    
    func tapHandler(_ recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: self)
        
        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: getDateForX(point.x))
        let (hour, minute) = getDateForY(point.y)
        components.hour = hour
        components.minute = minute
        
        delegate?.tap(date: Calendar.current.date(from: components)!)
    }
    
    // MARK: - public actions
    public func setCalendarDate(_ date: Date, animated: Bool = false) {
        calendarDate = date
        updateView(animated)
    }
    
    // MARK: - events
    public func setEvents(events: [WREvent]) {
        self.events = events
        forceReload(true)
    }
    
    public func addEvent(event: WREvent) {
        events.append(event)
        forceReload(true)
    }
    
    public func addEvents(events: [WREvent]) {
        self.events.append(contentsOf: events)
        forceReload(true)
    }
    
    public func forceReload(_ reloadEvents: Bool) {
        if reloadEvents {
            groupEventsBySection()
        }
        flowLayout.invalidateLayoutCache()
        collectionView.reloadData()
    }

    // MARK: - private actions
    //  Get date from point
    fileprivate func getDateForX(_ x: CGFloat) -> Date {
        let section = Int((x + collectionView.contentOffset.x - flowLayout.rowHeaderWidth) / flowLayout.sectionWidth)
        return Calendar.current.date(from: flowLayout.daysForSection(section))!
    }
    
    fileprivate func getDateForY(_ y: CGFloat) -> (Int, Int) {
        let adjustedY = y - flowLayout.columnHeaderHeight + collectionView.contentOffset.y - flowLayout.contentsMargin.top - flowLayout.sectionMargin.top
        let hour = Int(adjustedY / flowLayout.hourHeight)
        let minute = Int((adjustedY / flowLayout.hourHeight - CGFloat(hour)) * 60)
        let numberOfDivisions = 60 / flowLayout.hourGridDivisionValue.rawValue
        var finalMinute: Int = minute
        var diff = Int.max
        
        for index in 0...numberOfDivisions {
            if abs(flowLayout.hourGridDivisionValue.rawValue * index - minute) < diff {
                finalMinute = flowLayout.hourGridDivisionValue.rawValue * index
                diff = abs(flowLayout.hourGridDivisionValue.rawValue * index - minute)
            }
        }
        return (hour, finalMinute)
    }
    
    fileprivate func groupEventsBySection() {
        eventBySection = events.group {
            if let date = $0.beginning {
                return dateFormatter.string(from: date)
            } else {
                return ""
            }
        }
    }
    
    fileprivate func updateView(_ animated: Bool = false) {
        switch calendarType {
        case .week:
            daysToShowOnScreen = 7
            let weekComponent = Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: calendarDate)
            startDate = Calendar.current.date(from: weekComponent)
        case .day:
            daysToShowOnScreen = 1
            startDate = calendarDate
        }

        currentPage = Int(pageCount / 2) + 1
        daysToShow = daysToShowOnScreen * pageCount
        initDate = startDate - (daysToShowOnScreen * (currentPage - 1)).days
        
        DispatchQueue.main.async { [unowned self] in
            self.layoutSubviews()
            self.forceReload(false)
            self.setCurrentPage(self.currentPage, animated: animated)
            
            // 처음 화면이 보여지거나 schedule type이 바뀔때만 현재 시간 보여줌
            if self.isFirst {
                self.flowLayout.scrollCollectionViewToCurrentTime()
                self.isFirst = false
            }
        }
    }
    
    fileprivate func loadNextPage() {
        guard !loading else { return }
        DispatchQueue.main.async { [unowned self] in
            self.loading = true
            self.daysToShow = self.daysToShow + self.daysToShowOnScreen
            self.forceReload(false)
            self.loading = false
        }
    }
    
    fileprivate func loadPrevPage() {
        guard !loading else { return }
        DispatchQueue.main.async { [unowned self] in
            self.loading = true
            self.daysToShow = self.daysToShow + self.daysToShowOnScreen
            self.initDate = self.initDate - self.daysToShowOnScreen.days
            self.forceReload(false)
            self.setCurrentPage(self.currentPage + 1, animated: false)
            self.loading = false
        }
    }
    
    fileprivate func setCurrentPage(_ _currentPage: Int, animated: Bool = true) {
        currentPage = _currentPage
        let pageWidth = CGFloat(daysToShowOnScreen) * flowLayout.sectionWidth
        if currentPage < 1 { currentPage = 1 }
        
        collectionView.setContentOffset(CGPoint.init(x: pageWidth * CGFloat(currentPage - 1),
        y: collectionView.contentOffset.y),
                                        animated: animated)
        
        delegate?.view(startDate: flowLayout.dateForColumnHeader(at: IndexPath(row: 0, section: (currentPage - 1) * daysToShowOnScreen)),
                       interval: daysToShowOnScreen)
    }
    
    // directionalLockEnabled 이 제대로 작동안해서 직접 막아야 함
    fileprivate func determineScrollDirection() -> ScrollDirection {
        var scrollDirection: ScrollDirection
        
        if initialContentOffset.x != collectionView.contentOffset.x &&
            initialContentOffset.y != collectionView.contentOffset.y {
            scrollDirection = .crazy
        } else {
            if initialContentOffset.x > collectionView.contentOffset.x {
                scrollDirection = .left
            } else if initialContentOffset.x < collectionView.contentOffset.x {
                scrollDirection = .right
            } else if initialContentOffset.y > collectionView.contentOffset.y {
                scrollDirection = .up
            } else if initialContentOffset.y < collectionView.contentOffset.y {
                scrollDirection = .down
            } else {
                scrollDirection = .none
            }
        }
        return scrollDirection
    }
    
    fileprivate func determineScrollDirectionAxis() -> ScrollDirection {
        let scrollDirection = determineScrollDirection()
        
        switch scrollDirection {
        case .left, .right:
            return .horizontal
        case .up, .down:
            return .vertical
        default:
            return .none
        }
    }
}

extension WRWeekView: UICollectionViewDelegate, UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return daysToShow
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let date = flowLayout.dateForColumnHeader(at: indexPath)
        let key = dateFormatter.string(from: date)
        
        if let events = eventBySection[key], indexPath.item < events.count {
            let event = events[indexPath.item]
            delegate?.selectEvent(event)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let date = flowLayout.dateForColumnHeader(at: IndexPath(item: 0, section: section))
        let key = dateFormatter.string(from: date)
        
        if let events = eventBySection[key] {
            return events.count
        } else {
            return 0
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let date = flowLayout.dateForColumnHeader(at: indexPath)
        let key = dateFormatter.string(from: date)
        let events = eventBySection[key]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifiers.defaultCell,
                                                      for: indexPath) as? WREventCell
        guard cell != nil else { fatalError() }
        guard events != nil else { fatalError() }
        
        cell!.event = events![indexPath.row]
        
        return cell!
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var view: UICollectionReusableView
        
        if kind == SupplementaryViewKinds.columnHeader {
            let columnHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                               withReuseIdentifier: ReuseIdentifiers.columnHeader,
                                                                               for: indexPath) as! WRColumnHeader
            columnHeader.date = flowLayout.dateForColumnHeader(at: indexPath)
            view = columnHeader
        } else if kind == SupplementaryViewKinds.rowHeader {
            let rowHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                            withReuseIdentifier: ReuseIdentifiers.rowHeader,
                                                                            for: indexPath) as! WRRowHeader
            rowHeader.date = flowLayout.dateForTimeRowHeader(at: indexPath)
            view = rowHeader
        } else {
            view = UICollectionReusableView()
        }
        
        return view
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        initialContentOffset = scrollView.contentOffset
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // y방향 스크롤시에는 페이징 불필요
        if velocity.x == 0 && velocity.y != 0 { return }
        
        targetContentOffset.pointee = scrollView.contentOffset
        let pageWidth = CGFloat(daysToShowOnScreen) * flowLayout.sectionWidth
        var assistanceOffset: CGFloat = pageWidth / 3.0
        
        if velocity.x < 0 {
            assistanceOffset = -assistanceOffset
        }
        
        let assistedScrollPosition = (scrollView.contentOffset.x + assistanceOffset) / pageWidth
        let currentPage = Int(round(assistedScrollPosition)) + 1
        
        setCurrentPage(currentPage)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if currentPage < Int(pageCount / 2) {
            loadPrevPage()
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollDirection = determineScrollDirectionAxis()
        var newOffset: CGPoint
        
        if scrollDirection != .vertical && scrollDirection != .horizontal {
            if abs(scrollView.contentOffset.x) > abs(scrollView.contentOffset.y) {
                newOffset = CGPoint(x: scrollView.contentOffset.x, y: initialContentOffset.y);
            } else {
                newOffset = CGPoint(x: initialContentOffset.x, y: scrollView.contentOffset.y);
            }
            scrollView.contentOffset = newOffset
        }
        
        let currentOffset = scrollView.contentOffset.x
        let maximumOffset = scrollView.contentSize.width - scrollView.frame.width
        let diff: CGFloat = 50
        
        if maximumOffset - currentOffset <= diff {
            loadNextPage()
        }
    }
}

extension WRWeekView: WRWeekViewFlowLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: WRWeekViewFlowLayout, dayForSection section: Int) -> Date {
        let date = initDate + section.days
        return date
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: WRWeekViewFlowLayout, startTimeForItemAtIndexPath indexPath: IndexPath) -> Date {
        let date = flowLayout.dateForColumnHeader(at: indexPath)
        let key = dateFormatter.string(from: date)

        if let events = eventBySection[key] {
            let event = events[indexPath.item]
            return event.beginning!
        } else {
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: WRWeekViewFlowLayout, endTimeForItemAtIndexPath indexPath: IndexPath) -> Date {
        let date = flowLayout.dateForColumnHeader(at: indexPath)
        let key = dateFormatter.string(from: date)
        
        if let events = eventBySection[key] {
            let event = events[indexPath.item]
            return event.end!
        } else {
            fatalError()
        }
    }
}

// for groupBy
extension Sequence {
    func group<U: Hashable>(by key: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        var categories: [U: [Iterator.Element]] = [:]
        for element in self {
            let key = key(element)
            if case nil = categories[key]?.append(element) {
                categories[key] = [element]
            }
        }
        return categories
    }
}
