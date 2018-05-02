//
//  CalendarViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 4/15/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import JTAppleCalendar
import SVProgressHUD

class CalendarViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    let cellID = "cellID"
    let formatter = DateFormatter()
    let dateFormatterGet = DateFormatter()
    let dateFormatterPrint = DateFormatter()
    var selectedDate = Date()
    var passedDate: Date?
    var homeFeedController: HomeFeedController?
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    var dayStackView: UIStackView?
    var stackView = UIStackView()
    var yearAndMonthStackView: UIStackView?
    //day labels for calendar
    let yearLabel : UILabel =  {
        let yearLabel = UILabel()
        yearLabel.font = UIFont(name:"HelveticaNeue", size: 30.5)
        yearLabel.textAlignment = .left
        return yearLabel
    }()
    let monthLabel : UILabel =  {
        let monthLabel = UILabel()
        monthLabel.font = UIFont(name:"HelveticaNeue", size: 30.5)
        monthLabel.textAlignment = .center
        return monthLabel
    }()
    
    let sunLabel : UILabel =  {
        let sunLabel = UILabel()
        sunLabel.text = "Sun"
        sunLabel.font = UIFont(name:"HelveticaNeue", size: 16.5)
        sunLabel.textAlignment = .center
        return sunLabel
    }()
    
    let monLabel : UILabel =  {
        let monLabel = UILabel()
        monLabel.text = "Mon"
        monLabel.font = UIFont(name:"HelveticaNeue", size: 16.5)
        monLabel.textAlignment = .center
        return monLabel
    }()
    
    let tuesLabel : UILabel =  {
        let tuesLabel = UILabel()
        tuesLabel.text = "Tue"
        tuesLabel.font = UIFont(name:"HelveticaNeue", size: 16.5)
        tuesLabel.textAlignment = .center
        return tuesLabel
    }()
    let wedsLabel : UILabel =  {
        let wedsLabel = UILabel()
        wedsLabel.text = "Wed"
        wedsLabel.font = UIFont(name:"HelveticaNeue", size: 16.5)
        wedsLabel.textAlignment = .center
        return wedsLabel
    }()
    let thursLabel : UILabel =  {
        let thursLabel = UILabel()
        thursLabel.text = "Thu"
        thursLabel.font = UIFont(name:"HelveticaNeue", size: 16.5)
        thursLabel.textAlignment = .center
        return thursLabel
    }()
    let friLabel : UILabel =  {
        let friLabel = UILabel()
        friLabel.text = "Fri"
        friLabel.font = UIFont(name:"HelveticaNeue", size: 16.5)
        friLabel.textAlignment = .center
        return friLabel
    }()
    let satLabel : UILabel =  {
        let satLabel = UILabel()
        satLabel.text = "Sat"
        satLabel.font = UIFont(name:"HelveticaNeue", size: 16.5)
        satLabel.textAlignment = .center
        return satLabel
    }()
    
    let calendarCollectionView: JTAppleCalendarView = {
        let cv = JTAppleCalendarView(frame: .zero)
        cv.scrollDirection = .vertical
        cv.allowsSelection = true
        cv.backgroundColor = UIColor.rgb(red: 255, green: 255, blue: 255)
//        cv.allowsMultipleSelection = true
        cv.minimumInteritemSpacing = 0
        cv.minimumLineSpacing = 0
        cv.scrollingMode = .stopAtEachCalendarFrame
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        // Do any additional setup after loading the view.

    }
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
    
    @objc func setupNavBar(){
        self.navigationController?.navigationBar.isTranslucent = false

        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(GoBack))
        self.navigationItem.leftBarButtonItem = backButton
        
        let doneButton = UIBarButtonItem(image: UIImage(named: "icons8-checkmark-64"), style: .plain, target: self, action: #selector(beginDateFilter))
        navigationItem.rightBarButtonItem = doneButton
    }

    
    @objc func setupVC(){
        setupNavBar()
        calendarCollectionView.visibleDates { (visibleDates) in
            self.setupViewsOfCalendar(from: visibleDates)

        }
        dayStackView = UIStackView(arrangedSubviews: [sunLabel,monLabel,tuesLabel,wedsLabel,thursLabel,friLabel,satLabel])
        dayStackView?.distribution = .fillEqually
        dayStackView?.axis = .horizontal
        yearAndMonthStackView = UIStackView(arrangedSubviews: [monthLabel])
        yearAndMonthStackView?.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
//        yearAndMonthStackView?.isLayoutMarginsRelativeArrangement = true
        yearAndMonthStackView?.axis = .horizontal
        yearAndMonthStackView?.distribution = .fillEqually
        yearAndMonthStackView?.alignment = .center
        stackView.addArrangedSubview(yearAndMonthStackView!)
        stackView.addArrangedSubview(dayStackView!)
        stackView.addArrangedSubview(calendarCollectionView)
        stackView.axis = .vertical
        
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        calendarCollectionView.isPagingEnabled = true
        calendarCollectionView.calendarDataSource = self
        calendarCollectionView.calendarDelegate = self
        calendarCollectionView.showsHorizontalScrollIndicator = false
        calendarCollectionView.showsVerticalScrollIndicator = false
        calendarCollectionView.register(CalendarCell.self, forCellWithReuseIdentifier: cellID)
        if let curerntDate = passedDate {
            calendarCollectionView.scrollToDate(curerntDate, animateScroll: false)
            calendarCollectionView.selectDates([curerntDate])
        }else{
            calendarCollectionView.scrollToDate(Date(), animateScroll: false)
            calendarCollectionView.selectDates([Date()])
        }
        
    }
    
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo){
        let date = visibleDates.monthDates.first!.date
        self.formatter.dateFormat = "yyyy"
        self.yearLabel.text = self.formatter.string(from: date)
        self.formatter.dateFormat = "MMMM"
        self.monthLabel.text = self.formatter.string(from: date)
    }
    
    @objc func GoBack(){
        print("BACK TAPPED")
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func beginDateFilter(){
        print("Done Pressed")
        self.homeFeedController?.getSelectedDateFromCal(from: self.selectedDate)
        self.navigationController?.popViewController(animated: true)
        SVProgressHUD.dismiss(withDelay: 2)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CalendarViewController:JTAppleCalendarViewDataSource {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        print("displayed")
    }
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        // Get the current year
        let year = Calendar.current.component(.year, from: Date())
        navigationItem.title = "\(year) Calendar"
        let firstOfYear = Calendar.current.date(from: DateComponents(year: year, month: 1, day: 1))
        let lastOfYear = Calendar.current.date(from: DateComponents(year: year, month: 12, day: 13))
//        let parameter = ConfigurationParameters(startDate: firstOfYear!, endDate: lastOfYear!)
        let parameter = ConfigurationParameters(startDate: firstOfYear!, endDate: lastOfYear!, numberOfRows: 5, calendar: Calendar.current, generateInDates: .forAllMonths, generateOutDates: .off, firstDayOfWeek: .sunday, hasStrictBoundaries: true)
        return parameter
    }
    
}

extension CalendarViewController: JTAppleCalendarViewDelegate {
    
    func handleCellSelected(view: JTAppleCell, cellState: CellState){
        guard let validCell = view as? CalendarCell else {
            return
        }
        if validCell.isSelected {
            validCell.daySelectionOverlay.isHidden = false
        }else {
            validCell.daySelectionOverlay.isHidden = true
        }
        
    }
    
    func handleCellTextColor(view: JTAppleCell, cellState: CellState){
        guard let validCell = view as? CalendarCell else {
            return
        }
        if validCell.isSelected {
            validCell.sectionNameLabel.textColor = UIColor.white
        }else {
            if cellState.dateBelongsTo == .thisMonth{
                validCell.sectionNameLabel.textColor = UIColor.black
            }else{
                validCell.sectionNameLabel.textColor = UIColor.lightGray

            }
        }
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
    
    
    
    //display the cell
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CalendarCell
        cell.sectionNameLabel.text = cellState.text
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        return cell
    }
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CalendarCell else {
            return
        }
        validCell.bounce()
        selectedDate = date
        print(date.description)
        handleCellSelected(view: validCell, cellState: cellState)
        handleCellTextColor(view: validCell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CalendarCell else {
            return
        }
        handleCellSelected(view: validCell, cellState: cellState)
        handleCellTextColor(view: validCell, cellState: cellState)
    }
}
