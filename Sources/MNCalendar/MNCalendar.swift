import Foundation

public protocol MNCalendarType {
    func getNumberOfDaysInMonth(from date: Date) -> Int
    func getNumberOfDaysInWeek(from date: Date) -> Int
    func getMonth(of date: Date) -> Int
    func getYear(of date: Date) -> Int
    func moveToNextMonth()
    func moveToPreviousMonth()
    func getNumberOfItemsForCurrentMode() -> (dates: [Date], count: Int)
}

public enum MNCalendarMode {
    case week
    case month
}

public class MNCalendar {
    private let calendar: Calendar
    private let timeZone: TimeZone

    private(set) var mode: MNCalendarMode = .month
    private var currentDates: [Date] = []
    private var currentDate: Date {
        didSet {
            updateCurrent(withDate: currentDate)
        }
    }
    private var currentComponents: DateComponents {
        calendar.dateComponents(in: timeZone, from: currentDate)
    }
    
    public init(calendar: Calendar = .current, timeZone: TimeZone = .current, initialDate: Date = .init()) {
        self.calendar = calendar
        self.timeZone = timeZone
        self.currentDate = initialDate
    }
    
    private func updateCurrent(withDate date: Date) {
        
    }
}

extension MNCalendar: MNCalendarType {
    public func getNumberOfDaysInMonth(from date: Date) -> Int {
        
    }
    
    public func getNumberOfDaysInWeek(from date: Date) -> Int {
        
    }
    
    public func getMonth(of date: Date) -> Int {
        calendar.component(.month, from: date)
    }
    
    public func getYear(of date: Date) -> Int {
        calendar.component(.year, from: date)
    }
    
    public func moveToNextMonth() {
        var components = DateComponents()
        components.day = 1
        guard let updatedDate = calendar.date(byAdding: components, to: currentDate) else {
            assert(false)
            return
        }
        self.currentDate = updatedDate
    }
    
    public func moveToPreviousMonth() {
        var components = DateComponents()
        components.day = -1
        guard let updatedDate = calendar.date(byAdding: components, to: currentDate) else {
            assert(false)
            return
        }
        self.currentDate = updatedDate
    }
    
    public func getNumberOfItemsForCurrentMode() -> (dates: [Date], count: Int) {
        fatalError()
    }
    
    
}
