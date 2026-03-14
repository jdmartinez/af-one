import Foundation

// MARK: - DateFormatter Extensions

extension DateFormatter {
    /// Localized medium date format (e.g., "Jan 14, 2026")
    static let localizedMedium: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        return formatter
    }()
    
    /// Localized short date format (e.g., "1/14/26")
    static let localizedShort: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        return formatter
    }()
    
    /// Localized medium date and time format (e.g., "Jan 14, 2026 at 3:30 PM")
    static let localizedMediumWithTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale.current
        return formatter
    }()
    
    /// Localized time only format (e.g., "3:30 PM")
    static let localizedTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale.current
        return formatter
    }()
    
    /// Localized relative date format (e.g., "Today", "Yesterday", "2 days ago")
    static let localizedRelative: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale.current
        return formatter
    }()
    
    /// Day of week format (e.g., "Monday")
    static let localizedDayOfWeek: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale.current
        return formatter
    }()
    
    /// Month and year format (e.g., "January 2026")
    static let localizedMonthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale.current
        return formatter
    }()
}

// MARK: - NumberFormatter Extensions

extension NumberFormatter {
    /// Localized percentage format (e.g., "45%")
    static let localizedPercentage: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1
        formatter.locale = Locale.current
        return formatter
    }()
    
    /// Localized decimal format (e.g., "45.5")
    static let localizedDecimal: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        formatter.locale = Locale.current
        return formatter
    }()
    
    /// Localized currency format (e.g., "$45.99")
    static let localizedCurrency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter
    }()
    
    /// Heart rate format (e.g., "72 BPM")
    static func heartRateString(_ bpm: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let number = formatter.string(from: NSNumber(value: bpm)) ?? "\(bpm)"
        return "\(number) BPM"
    }
    
    /// AF Burden format (e.g., "5.2%")
    static func burdenString(_ burden: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: burden)) ?? "\(burden)%"
    }
}

// MARK: - Convenience Date Extensions

extension Date {
    /// Format date using localized medium style
    var mediumFormatted: String {
        DateFormatter.localizedMedium.string(from: self)
    }
    
    /// Format date using localized short style
    var shortFormatted: String {
        DateFormatter.localizedShort.string(from: self)
    }
    
    /// Format date and time using localized medium style
    var mediumWithTimeFormatted: String {
        DateFormatter.localizedMediumWithTime.string(from: self)
    }
    
    /// Format time only
    var timeFormatted: String {
        DateFormatter.localizedTime.string(from: self)
    }
    
    /// Format as relative date
    var relativeFormatted: String {
        DateFormatter.localizedRelative.localizedString(for: self, relativeTo: Date())
    }
    
    /// Format as day of week
    var dayOfWeekFormatted: String {
        DateFormatter.localizedDayOfWeek.string(from: self)
    }
    
    /// Format as month and year
    var monthYearFormatted: String {
        DateFormatter.localizedMonthYear.string(from: self)
    }
}

// MARK: - Locale Information

extension Locale {
    /// Current locale's language direction
    var isRightToLeft: Bool {
        let languageDirection = Locale.characterDirection(forLanguage: self.languageCode)
        return languageDirection == .rightToLeft
    }
    
    /// Current locale's language code
    var languageCode: String {
        self.language.languageCode?.identifier ?? "en"
    }
    
    /// Current locale's region code
    var regionCode: String?
    {
        self.region?.identifier
    }
}
