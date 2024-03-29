import Foundation

public protocol MNCalendarDelegate: AnyObject {
    func didChangeDisplayDates(_ dates: [Date], calendar: MNCalendar)
    func didChangeSelectedDate(_ date: Date, calendar: MNCalendar)
}

public protocol MNCalendarType {
    var dates: [Date] { get }
    var currentDate: Date { get }
    var selectedDate: Date? { get }
    func getNumberOfDaysInMonth(from date: Date) -> Int
    func getNumberOfDaysInWeek(from date: Date) -> Int
    func getMonth(of date: Date) -> Int
    func getYear(of date: Date) -> Int
    func moveToNextMonth()
    func moveToPreviousMonth()
    func getNumberOfItemsForCurrentMode() -> Int
    func isSameDay(_ source: Date, _ destination: Date) -> Bool
    func updateSelectedDate(_ date: Date)
}

public enum MNCalendarError: Error {
    case noDelegate
}

public enum MNCalendarMode {
    case week
    case month
}

public class MNCalendar {
    // MARK: - Constant
    private let calendar: Calendar
    private let timeZone: TimeZone
    private let daysPerWeek: Int = 7
    
    // MARK: - Accessible members from outside.
    public lazy var dates: [Date] = update()
    public var currentDate: Date = .init()
    public var selectedDate: Date?
    
    public var mode: MNCalendarMode = .month {
        didSet {
            update()
        }
    }
    public weak var delegate: MNCalendarDelegate?
    
    // MARK: - Initializer
    public init(calendar: Calendar = .current, timeZone: TimeZone = .current, delegate: MNCalendarDelegate?) {
        self.calendar = calendar
        self.timeZone = timeZone
        self.delegate = delegate
    }
    
    // MARK: - Private Methods
    @discardableResult
    private func update() -> [Date] {
        guard let delegate = delegate else {
            return []
        }
        var dates: [Date] = []
        guard let ordinalityOfFirstDay = calendar.ordinality(of: .day, in: .weekOfMonth, for: firstDateOfMonth(from: currentDate)) else {
            fatalError()
        }
        switch mode {
        case .month:
            for i in 0..<daysAcquisition(of: currentDate) {
                var dateComponents = DateComponents()
                dateComponents.day = i - (ordinalityOfFirstDay - 1)
                guard let date = calendar.date(byAdding: dateComponents, to: firstDateOfMonth(from: currentDate)) else {
                    fatalError()
                }
                dates.append(date)
            }
            
        case .week:
            for i in 0..<getNumberOfDaysInWeek(from: currentDate) {
                var dateComponents = DateComponents()
                dateComponents.day = i - (ordinalityOfFirstDay - 1)
                guard let date = calendar.date(byAdding: dateComponents, to: currentDate) else {
                    fatalError()
                }
                dates.append(date)
            }
        }
        self.dates = dates
        delegate.didChangeDisplayDates(dates, calendar: self)
        return dates
    }
    
    /// First day of current selecting  date-month.
    func firstDateOfMonth(from date: Date) -> Date {
        var components = calendar.dateComponents([.year, .month, .day],
                                             from: date)
        components.day = 1
        guard let firstDateMonth = calendar.date(from: components) else {
            fatalError()
        }
        return firstDateMonth
    }
    
    /// Number of days of selectedDate.
    func daysAcquisition(of date: Date) -> Int {
        guard let rangeOfWeeks = calendar.range(of: .weekOfMonth, in: .month, for: firstDateOfMonth(from: date)) else {
            fatalError()
        }
        let numberOfWeeks = rangeOfWeeks.count
        return numberOfWeeks * daysPerWeek
    }
}

extension MNCalendar: MNCalendarType {
    public func getNumberOfDaysInMonth(from date: Date) -> Int {
        var components = calendar.dateComponents(in: timeZone, from: date)
        let month = calendar.component(.month, from: date) + 1
        components.month = month
        components.day = 0
        guard let lastDate = calendar.date(from: components) else {
            fatalError()
        }
        let dayCount = calendar.component(.day, from: lastDate)
        return dayCount
    }
    
    public func getNumberOfDaysInWeek(from date: Date) -> Int {
        7
    }
    
    public func getMonth(of date: Date) -> Int {
        calendar.component(.month, from: date)
    }
    
    public func getYear(of date: Date) -> Int {
        calendar.component(.year, from: date)
    }
    
    public func moveToNextMonth() {
        var components = DateComponents()
        components.month = 1
        guard let updatedDate = calendar.date(byAdding: components, to: currentDate) else {
            assert(false)
            return
        }
        currentDate = updatedDate
        update()
    }
    
    public func moveToPreviousMonth() {
        var components = DateComponents()
        components.month = -1
        guard let updatedDate = calendar.date(byAdding: components, to: currentDate) else {
            assert(false)
            return
        }
        currentDate = updatedDate
        update()
    }
    
    public func getNumberOfItemsForCurrentMode() -> Int {
        dates.count
    }
    
    public func isSameDay(_ source: Date, _ destination: Date) -> Bool {
        calendar.isDate(source, inSameDayAs: destination)
    }
    
    public func updateSelectedDate(_ date: Date) {
        self.selectedDate = date
        delegate?.didChangeSelectedDate(date, calendar: self)
    }
}
