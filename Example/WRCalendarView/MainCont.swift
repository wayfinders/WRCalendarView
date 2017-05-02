//
//  ViewController.swift
//  WRCalendarView
//
//  Created by wayfinder on 04/26/2017.
//  Copyright (c) 2017 wayfinder. All rights reserved.
//

import UIKit
import DropDownMenuKit
import WRCalendarView

class MainCont: UIViewController {
    @IBOutlet weak var weekView: WRWeekView!

    var titleView: DropDownTitleView!
    var navigationBarMenu: DropDownMenu!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCalendarData()
        
        let title = prepareNavigationBarMenuTitleView()
        prepareNavigationBarMenu(title)
        updateMenuContentOffsets()
        
        //add today button
        let rightButton = UIBarButtonItem(title: "Today", style: .plain, target: self, action: #selector(moveToToday))
        navigationItem.rightBarButtonItem = rightButton
        
        //add events
        weekView.addEvent(event: WREvent.make(date: Date(), chunk: 2.hours, title: "#1"))
        weekView.addEvent(event: WREvent.make(date: Date(), chunk: 1.hours, title: "#2"))
        weekView.addEvent(event: WREvent.make(date: Date().add(90.minutes), chunk: 1.hours, title: "#3"))
        weekView.addEvent(event: WREvent.make(date: Date().add(110.minutes), chunk: 1.hours, title: "#4"))

        weekView.addEvent(event: WREvent.make(date: Date().add(1.days), chunk: 1.hours, title: "tomorrow"))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationBarMenu.container = view
    }
    
    func moveToToday() {
        weekView.setCalendarDate(Date(), animated: true)
    }
    
    // MARK: - WRCalendarView
    func setupCalendarData() {
        weekView.setCalendarDate(Date())
        weekView.delegate = self
    }
    
    // MARK: - DropDownMenu
    func prepareNavigationBarMenuTitleView() -> String {
        titleView = DropDownTitleView(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        titleView.addTarget(self,
                            action: #selector(willToggleNavigationBarMenu(_:)),
                            for: .touchUpInside)
        titleView.addTarget(self,
                            action: #selector(didToggleNavigationBarMenu(_:)),
                            for: .valueChanged)
        titleView.titleLabel.textColor = UIColor.black
        titleView.title = "Week"
        
        navigationItem.titleView = titleView
        
        return titleView.title!
    }
    
    func prepareNavigationBarMenu(_ currentChoice: String) {
        navigationBarMenu = DropDownMenu(frame: view.bounds)
        navigationBarMenu.delegate = self
        
        let firstCell = DropDownMenuCell()
        
        firstCell.textLabel!.text = "Week"
        firstCell.menuAction = #selector(choose(_:))
        firstCell.menuTarget = self
        if currentChoice == "Week" {
            firstCell.accessoryType = .checkmark
        }
        
        let secondCell = DropDownMenuCell()
        
        secondCell.textLabel!.text = "Day"
        secondCell.menuAction = #selector(choose(_:))
        secondCell.menuTarget = self
        if currentChoice == "Day" {
            firstCell.accessoryType = .checkmark
        }
        
        navigationBarMenu.menuCells = [firstCell, secondCell]
        navigationBarMenu.selectMenuCell(firstCell)
        
        // If we set the container to the controller view, the value must be set
        // on the hidden content offset (not the visible one)
        navigationBarMenu.visibleContentOffset =
            navigationController!.navigationBar.frame.size.height + statusBarHeight()
        
        // For a simple gray overlay in background
        navigationBarMenu.backgroundView = UIView(frame: navigationBarMenu.bounds)
        navigationBarMenu.backgroundView!.backgroundColor = UIColor.black
        navigationBarMenu.backgroundAlpha = 0.7
    }
    
    func willToggleNavigationBarMenu(_ sender: DropDownTitleView) {
        if sender.isUp {
            navigationBarMenu.hide()
        } else {
            navigationBarMenu.show()
        }
    }
    
    func updateMenuContentOffsets() {
        navigationBarMenu.visibleContentOffset =
            navigationController!.navigationBar.frame.size.height + statusBarHeight()
    }
    
    func didToggleNavigationBarMenu(_ sender: DropDownTitleView) {
    }
    
    func choose(_ sender: AnyObject) {
        if let sender = sender as? DropDownMenuCell {
            titleView.title = sender.textLabel!.text
        
            switch titleView.title! {
            case "Week":
                weekView.calendarType = .week
            case "Day":
                weekView.calendarType = .day
            default:
                break
            }
        }
        
        if titleView.isUp {
            titleView.toggleMenu()
        }
    }
    
    func statusBarHeight() -> CGFloat {
        let statusBarSize = UIApplication.shared.statusBarFrame.size
        return min(statusBarSize.width, statusBarSize.height)
    }
}

extension MainCont: DropDownMenuDelegate {
    func didTapInDropDownMenuBackground(_ menu: DropDownMenu) {
        titleView.toggleMenu()
    }
}

extension MainCont: WRWeekViewDelegate {
    func view(startDate: Date, interval: Int) {
        print(startDate, interval)
    }
    
    func tap(date: Date) {
        print(date)
    }
    
    func selectEvent(_ event: WREvent) {
        print(event.title)
    }
}
