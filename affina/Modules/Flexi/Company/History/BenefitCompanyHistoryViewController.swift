//
//  AppreciateHistoryViewController.swift
//  affina
//
//  Created by Dylan on 24/10/2022.
//

import UIKit
import FSCalendar

class BenefitCompanyHistoryViewController: BaseViewController {

    @IBOutlet weak var tableView: ContentSizedTableView!
    
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    
    private lazy var calendarView: BaseView = {
        let view = BaseView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .appColor(.whiteMain)
        view.cornerRadius = 16
        return view
    }()
    
    private lazy var calendarDoneButton: BaseButton = {
        let button = BaseButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("DONE".localize(), for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.appColor(.blueMain), for: .normal)
        button.customFont = "Raleway-Semibold-14"
        return button
    }()
    
    private lazy var calendar: FSCalendar = {
        // In loadView or viewDidLoad
        let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: 320, height: 300))
        calendar.dataSource = self
        calendar.delegate = self
        calendar.backgroundColor = .appColor(.whiteMain)
        calendar.scrollDirection = .horizontal
        calendar.allowsMultipleSelection = true
        calendar.swipeToChooseGesture.isEnabled = true // Swipe-To-Choose
        calendar.today = nil
        calendar.select(nil)
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0;
        return calendar
    }()
    
    private var startDate = Date()
    private var endDate = Date()
    private var arrayDate = [Date]()
    private var currentSelectedDate: Date? = Date()
    
    private var items: [VoucherHistoryModel] = []
    
    private let presenter = RewardHistoryViewPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupHeaderView()
        containerBaseView.hide()
        
        scrollViewTopConstraint.constant = UIConstants.Layout.headerHeight
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: RewardHistoryTableViewCell.nib, bundle: nil), forCellReuseIdentifier: RewardHistoryTableViewCell.cellId)
        
        
        grayScreen.addTapGestureRecognizer { [weak self] in
            guard let self = self else { return }
            for date in self.calendar.selectedDates {
                self.calendar.deselect(date)
            }
            self.arrayDate = []
            
            self.hideCalendarView()
        }
        grayScreen.frame = .init(x: 0, y: 0, width: UIConstants.Layout.screenWidth, height: UIConstants.Layout.screenHeight)
        
        
        view.addSubview(calendarView)
        calendarView.addSubview(calendarDoneButton)
        calendarView.addSubview(calendar)
        calendarView.isHidden = true
        calendarView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(UIConstants.Layout.screenHeight/2)
        }
        
        calendarDoneButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(10)
            //            make.height.equalTo(30)
        }
        calendarDoneButton.addTapGestureRecognizer { [weak self] in
            guard let self = self else { return }
            self.hideCalendarView()
            self.applyFilter()
        }
        
        calendar.snp.makeConstraints { make in
            make.top.equalTo(calendarDoneButton.snp.bottom)//.offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            //            make.height.equalTo(UIConstants.Layout.screenHeight/2 - 30)
        }
        
        let currentTimestamp = Date().timeIntervalSince1970
        presenter.delegate = self
        presenter.getSMEVoucherHistory(fromDate: (Date().timestampOfXYearsLaterFromNow(-1) ?? -1)*1000, toDate: currentTimestamp * 1000)
        
    }

    private func setupHeaderView() {
        addBlurEffect(headerBaseView)
        headerBaseView.backgroundColor = .appColor(.blueUltraLighter)?.withAlphaComponent(0.65)
        
        labelBaseTitle.text = "HISTORY_OF_REDEEM".capitalized.localize()
        labelBaseTitle.font = UIConstants.Fonts.appFont(.Bold, 16)
        labelBaseTitle.textColor = .appColor(.black)
        rightBaseImage.image = UIImage(named: "ic_calendar")?.withRenderingMode(.alwaysTemplate)
        rightBaseImage.tintColor = .appColor(.textBlack)
        rightBaseImage.addTapGestureRecognizer { [weak self] in
            guard let self = self else { return }
            self.showCalendarView()
        }

    }
    
    /// Handle after date selected from FSCalendar
    fileprivate func handleForDateSelect() {
        if !arrayDate.isEmpty {
            if arrayDate[0] == currentSelectedDate {
                calendar.deselect(arrayDate[0])
                arrayDate.remove(at: 0)
                currentSelectedDate = nil
                return
            } else if arrayDate[arrayDate.count - 1] == currentSelectedDate {
                calendar.deselect(arrayDate[arrayDate.count - 1])
                arrayDate.remove(at: arrayDate.count - 1)
                currentSelectedDate = nil
                return
            }
        }
        /// Range mode
        /// Deselect all date
        for date in arrayDate {
            calendar.deselect(date)
        }
        
        /// If endDate > currentSelectedDate > start date
        if startDate...endDate ~= currentSelectedDate ?? Date() {
            /// Get nearest index of startDate, endDate with currentSelectedDate
            if let nearestDate = [startDate.timeIntervalSince1970, endDate.timeIntervalSince1970].nearest(to: (currentSelectedDate ?? Date()).timeIntervalSince1970) {
                if nearestDate.offset == 0 { /// If nearest with start date
                                             /// Set start date as current selected
                    startDate = currentSelectedDate ?? Date()
                } else { /// Nearest with end date
                         /// Set end date as current selected
                    endDate = currentSelectedDate ?? Date()
                }
            }
        }
        
        /// Reset array date
        arrayDate.removeAll()
        
        ///Set start date is minimum, end date is maximum
        startDate = min(startDate, currentSelectedDate ?? Date(), endDate)
        endDate = max(startDate, currentSelectedDate ?? Date(), endDate)
        ///Set array date
        arrayDate = Date.dates(from: startDate, to: endDate)
        
        /// Select all array date
        for date in arrayDate {
            calendar.select(date)
        }
    }
    
    private func hideCalendarView() {
        calendarView.isHidden = true
        grayScreen.removeFromSuperview()
    }
    
    private func showCalendarView() {
        
        calendarView.isHidden = false
        view.addSubview(grayScreen)
        view.bringSubviewToFront(calendarView)
    }
    
    private func applyFilter() {
        if arrayDate.isEmpty { return }
        presenter.getSMEVoucherHistory(fromDate: arrayDate[0].timeIntervalSince1970 * 1000, toDate: arrayDate[arrayDate.count - 1].timeIntervalSince1970 * 1000 + 86399000)
    }
}

// MARK: UITableViewDelegate + Datasource
extension BenefitCompanyHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RewardHistoryTableViewCell.cellId, for: indexPath) as? RewardHistoryTableViewCell else { return UITableViewCell() }
        cell.cellType = .company
        cell.item = items[indexPath.row]
        
        return cell
    }
}

// MARK: RewardHistoryViewDelegate
extension BenefitCompanyHistoryViewController: RewardHistoryViewDelegate {
    func lockUI() {
        lockScreen()
    }
    
    func unlockUI() {
        unlockScreen()
    }
    
    func updateListHistory(list: [VoucherHistoryModel]) {
        items = list
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
}

// MARK: FSCalendarDelegate, FSCalendarDataSource
extension BenefitCompanyHistoryViewController: FSCalendarDelegate, FSCalendarDataSource {
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date(timeIntervalSince1970: 0)
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
        
        currentSelectedDate = date
        handleForDateSelect()
        
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        return appearance.selectionColor
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        //        print("deselect")
        currentSelectedDate = date
        handleForDateSelect()
        
    }
}
