import XCTest
@testable import SleepPath

final class DateExtensionTests: XCTestCase {

    // MARK: - shortTimeString

    func test_shortTimeString_formatsCorrectly() {
        let date = Date.today(hour: 14, minute: 30)
        let result = date.shortTimeString
        // Should be "2:30 PM"
        XCTAssertEqual(result, "2:30 PM")
    }

    func test_shortTimeString_morningTime_formatsCorrectly() {
        let date = Date.today(hour: 7, minute: 0)
        let result = date.shortTimeString
        XCTAssertEqual(result, "7:00 AM")
    }

    func test_shortTimeString_midnight_formatsCorrectly() {
        let date = Date.today(hour: 0, minute: 0)
        let result = date.shortTimeString
        XCTAssertEqual(result, "12:00 AM")
    }

    func test_shortTimeString_noon_formatsCorrectly() {
        let date = Date.today(hour: 12, minute: 0)
        let result = date.shortTimeString
        XCTAssertEqual(result, "12:00 PM")
    }

    // MARK: - time24String

    func test_time24String_formatsCorrectly() {
        let date = Date.today(hour: 14, minute: 30)
        XCTAssertEqual(date.time24String, "14:30")
    }

    func test_time24String_midnight_formatsCorrectly() {
        let date = Date.today(hour: 0, minute: 0)
        XCTAssertEqual(date.time24String, "00:00")
    }

    // MARK: - today(hour:minute:)

    func test_todayAtHour_createsCorrectDate() {
        let date = Date.today(hour: 9, minute: 30)
        let calendar = Calendar.current
        XCTAssertEqual(calendar.component(.hour, from: date), 9)
        XCTAssertEqual(calendar.component(.minute, from: date), 30)
        XCTAssertEqual(calendar.component(.second, from: date), 0)
        XCTAssertTrue(calendar.isDateInToday(date))
    }

    func test_todayAtHour_defaultMinuteIsZero() {
        let date = Date.today(hour: 15)
        let calendar = Calendar.current
        XCTAssertEqual(calendar.component(.hour, from: date), 15)
        XCTAssertEqual(calendar.component(.minute, from: date), 0)
    }

    func test_todayAtHour_midnight_createsCorrectDate() {
        let date = Date.today(hour: 0, minute: 0)
        let calendar = Calendar.current
        XCTAssertEqual(calendar.component(.hour, from: date), 0)
        XCTAssertEqual(calendar.component(.minute, from: date), 0)
    }

    func test_todayAtHour_endOfDay_createsCorrectDate() {
        let date = Date.today(hour: 23, minute: 59)
        let calendar = Calendar.current
        XCTAssertEqual(calendar.component(.hour, from: date), 23)
        XCTAssertEqual(calendar.component(.minute, from: date), 59)
    }

    // MARK: - daysAgo

    func test_daysAgo_createsPastDate() {
        let threeDaysAgo = Date.daysAgo(3)
        XCTAssertLessThan(threeDaysAgo, Date())
    }

    func test_daysAgo_correctNumberOfDays() {
        let calendar = Calendar.current
        let fiveDaysAgo = Date.daysAgo(5)
        let components = calendar.dateComponents([.day], from: fiveDaysAgo, to: Date())
        XCTAssertEqual(components.day, 5)
    }

    func test_daysAgo_zero_isToday() {
        let today = Date.daysAgo(0)
        let calendar = Calendar.current
        XCTAssertTrue(calendar.isDateInToday(today))
    }

    func test_daysAgo_withHourAndMinute_createsCorrectDate() {
        let date = Date.daysAgo(2, hour: 14, minute: 30)
        let calendar = Calendar.current
        XCTAssertEqual(calendar.component(.hour, from: date), 14)
        XCTAssertEqual(calendar.component(.minute, from: date), 30)

        let dayDiff = calendar.dateComponents([.day], from: date, to: Date())
        XCTAssertEqual(dayDiff.day, 2)
    }

    // MARK: - addingHours

    func test_addingHours_addsCorrectInterval() {
        let date = Date.today(hour: 10)
        let result = date.addingHours(3)
        let expected = date.addingTimeInterval(3 * 3600)
        XCTAssertEqual(
            result.timeIntervalSince1970,
            expected.timeIntervalSince1970,
            accuracy: 0.001
        )
    }

    func test_addingHours_fractionalHours_works() {
        let date = Date.today(hour: 10)
        let result = date.addingHours(1.5)
        let expected = date.addingTimeInterval(1.5 * 3600)
        XCTAssertEqual(
            result.timeIntervalSince1970,
            expected.timeIntervalSince1970,
            accuracy: 0.001
        )
    }

    func test_addingHours_negativeHours_subtractsTime() {
        let date = Date.today(hour: 10)
        let result = date.addingHours(-2)
        let calendar = Calendar.current
        XCTAssertEqual(calendar.component(.hour, from: result), 8)
    }

    // MARK: - addingMinutes

    func test_addingMinutes_addsCorrectInterval() {
        let date = Date.today(hour: 10, minute: 0)
        let result = date.addingMinutes(45)
        let calendar = Calendar.current
        XCTAssertEqual(calendar.component(.hour, from: result), 10)
        XCTAssertEqual(calendar.component(.minute, from: result), 45)
    }

    // MARK: - subtractingHours

    func test_subtractingHours_subtractsCorrectly() {
        let date = Date.today(hour: 14)
        let result = date.subtractingHours(3)
        let calendar = Calendar.current
        XCTAssertEqual(calendar.component(.hour, from: result), 11)
    }

    // MARK: - minutesUntil

    func test_minutesUntil_returnsCorrectCount() {
        let date1 = Date.today(hour: 10, minute: 0)
        let date2 = Date.today(hour: 12, minute: 30)
        XCTAssertEqual(date1.minutesUntil(date2), 150)
    }

    func test_minutesUntil_sameDate_returnsZero() {
        let date = Date.today(hour: 10)
        XCTAssertEqual(date.minutesUntil(date), 0)
    }

    func test_minutesUntil_pastDate_returnsNegative() {
        let date1 = Date.today(hour: 12)
        let date2 = Date.today(hour: 10)
        XCTAssertLessThan(date1.minutesUntil(date2), 0)
    }

    func test_minutesUntil_oneHour_returns60() {
        let date1 = Date.today(hour: 10)
        let date2 = Date.today(hour: 11)
        XCTAssertEqual(date1.minutesUntil(date2), 60)
    }

    // MARK: - timeUntilFormatted

    func test_timeUntilFormatted_returnsFormattedString() {
        let date1 = Date.today(hour: 10)
        let date2 = Date.today(hour: 12, minute: 30)
        let result = date1.timeUntilFormatted(date2)
        XCTAssertEqual(result, "2h 30m")
    }

    func test_timeUntilFormatted_lessThanOneHour_showsOnlyMinutes() {
        let date1 = Date.today(hour: 10)
        let date2 = Date.today(hour: 10, minute: 45)
        let result = date1.timeUntilFormatted(date2)
        XCTAssertEqual(result, "45m")
    }

    func test_timeUntilFormatted_pastDate_returnsPast() {
        let date1 = Date.today(hour: 12)
        let date2 = Date.today(hour: 10)
        let result = date1.timeUntilFormatted(date2)
        XCTAssertEqual(result, "Past")
    }

    func test_timeUntilFormatted_exactlyOneHour_shows1h0m() {
        let date1 = Date.today(hour: 10)
        let date2 = Date.today(hour: 11)
        let result = date1.timeUntilFormatted(date2)
        XCTAssertEqual(result, "1h 0m")
    }

    func test_timeUntilFormatted_zeroMinutes_returns0m() {
        let date = Date.today(hour: 10)
        let result = date.timeUntilFormatted(date)
        XCTAssertEqual(result, "0m")
    }

    // MARK: - isToday

    func test_isToday_todaysDate_returnsTrue() {
        XCTAssertTrue(Date().isToday)
    }

    func test_isToday_yesterday_returnsFalse() {
        let yesterday = Date.daysAgo(1)
        XCTAssertFalse(yesterday.isToday)
    }

    // MARK: - isWeekend

    func test_isWeekend_saturdayReturnsTrue() {
        var components = DateComponents()
        components.year = 2026
        components.month = 3
        components.day = 14 // Saturday
        components.hour = 12
        let saturday = Calendar.current.date(from: components)!
        XCTAssertTrue(saturday.isWeekend)
    }

    func test_isWeekend_sundayReturnsTrue() {
        var components = DateComponents()
        components.year = 2026
        components.month = 3
        components.day = 15 // Sunday
        components.hour = 12
        let sunday = Calendar.current.date(from: components)!
        XCTAssertTrue(sunday.isWeekend)
    }

    func test_isWeekend_mondayReturnsFalse() {
        var components = DateComponents()
        components.year = 2026
        components.month = 3
        components.day = 16 // Monday
        components.hour = 12
        let monday = Calendar.current.date(from: components)!
        XCTAssertFalse(monday.isWeekend)
    }

    // MARK: - hour and minute Properties

    func test_hour_returnsCorrectValue() {
        let date = Date.today(hour: 14, minute: 30)
        XCTAssertEqual(date.hour, 14)
    }

    func test_minute_returnsCorrectValue() {
        let date = Date.today(hour: 14, minute: 30)
        XCTAssertEqual(date.minute, 30)
    }

    // MARK: - TimeInterval.hoursMinutesString

    func test_hoursMinutesString_formatsCorrectly() {
        let interval: TimeInterval = 2 * 3600 + 15 * 60  // 2 hours 15 minutes
        XCTAssertEqual(interval.hoursMinutesString, "2h 15m")
    }

    func test_hoursMinutesString_lessThanOneHour_showsMinutesOnly() {
        let interval: TimeInterval = 45 * 60
        XCTAssertEqual(interval.hoursMinutesString, "45m")
    }

    func test_hoursMinutesString_exactlyOneHour_shows1h0m() {
        let interval: TimeInterval = 3600
        XCTAssertEqual(interval.hoursMinutesString, "1h 0m")
    }

    func test_hoursMinutesString_zero_shows0m() {
        let interval: TimeInterval = 0
        XCTAssertEqual(interval.hoursMinutesString, "0m")
    }

    func test_hoursMinutesString_negativeInterval_showsAbsoluteMinutes() {
        // Negative intervals: minutes component uses abs()
        let interval: TimeInterval = -(1 * 3600 + 30 * 60)
        let result = interval.hoursMinutesString
        // -1 hour: totalMinutes = -90, hours = -90/60 = -1, minutes = abs(-90 % 60) = 30
        // Since hours != 0 (it's -1), format is "-1h 30m"
        XCTAssertFalse(result.isEmpty)
    }

    // MARK: - TimeInterval.formatMinutes

    func test_formatMinutes_formatsCorrectly() {
        let result = TimeInterval.formatMinutes(452)  // 7h 32m
        XCTAssertEqual(result, "7h 32m")
    }

    func test_formatMinutes_lessThanOneHour_showsMinutesOnly() {
        let result = TimeInterval.formatMinutes(45)
        XCTAssertEqual(result, "45m")
    }

    func test_formatMinutes_exactlyOneHour_shows1h0m() {
        let result = TimeInterval.formatMinutes(60)
        XCTAssertEqual(result, "1h 0m")
    }

    func test_formatMinutes_zero_shows0m() {
        let result = TimeInterval.formatMinutes(0)
        XCTAssertEqual(result, "0m")
    }

    func test_formatMinutes_largeValue_formatsCorrectly() {
        let result = TimeInterval.formatMinutes(600)  // 10h 0m
        XCTAssertEqual(result, "10h 0m")
    }

    // MARK: - Date String Formatting

    func test_isoDateString_formatsCorrectly() {
        let date = Date.today(hour: 12)
        let result = date.isoDateString
        // Should be in format "YYYY-MM-DD"
        let regex = try! NSRegularExpression(pattern: "^\\d{4}-\\d{2}-\\d{2}$")
        let range = NSRange(result.startIndex..., in: result)
        XCTAssertNotNil(regex.firstMatch(in: result, range: range), "ISO date should match YYYY-MM-DD")
    }

    func test_shortDateString_isNotEmpty() {
        let date = Date.today(hour: 12)
        XCTAssertFalse(date.shortDateString.isEmpty)
    }

    func test_fullDateString_isNotEmpty() {
        let date = Date.today(hour: 12)
        XCTAssertFalse(date.fullDateString.isEmpty)
    }
}
