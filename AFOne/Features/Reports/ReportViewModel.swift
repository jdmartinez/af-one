import Foundation
import SwiftUI

/// ReportViewModel - Manages clinical report generation and display
@MainActor
final class ReportViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var selectedPeriod: TimePeriod = .month
    @Published var reportText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let reportGenerator = ReportGenerator.shared
    
    // MARK: - Computed Properties
    
    /// Period date range for display
    var periodDateRangeLabel: String {
        let formatter = DateFormatter()
        
        switch selectedPeriod {
        case .day:
            formatter.dateFormat = "MMM d, h a"
            let now = Date()
            let start = Calendar.current.date(byAdding: .day, value: -1, to: now)!
            return "\(formatter.string(from: start)) - \(formatter.string(from: now))"
        case .week:
            formatter.dateFormat = "MMM d"
            let now = Date()
            let start = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: now)!
            return "\(formatter.string(from: start)) - \(formatter.string(from: now))"
        case .month:
            formatter.dateFormat = "MMM d"
            let now = Date()
            let start = Calendar.current.date(byAdding: .month, value: -1, to: now)!
            return "\(formatter.string(from: start)) - \(formatter.string(from: now))"
        case .sixMonths:
            formatter.dateFormat = "MMM yyyy"
            let now = Date()
            let start = Calendar.current.date(byAdding: .month, value: -6, to: now)!
            return "\(formatter.string(from: start)) - \(formatter.string(from: now))"
        case .oneYear:
            formatter.dateFormat = "MMM yyyy"
            let now = Date()
            let start = Calendar.current.date(byAdding: .year, value: -1, to: now)!
            return "\(formatter.string(from: start)) - \(formatter.string(from: now))"
        }
    }
    
    /// Whether there's a report to display
    var hasReport: Bool {
        !reportText.isEmpty
    }
    
    // MARK: - Public Methods
    
    /// Generate a clinical report for the selected period
    func generateReport() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let text = try await reportGenerator.generateReport(period: selectedPeriod)
            reportText = text
            isLoading = false
        } catch {
            errorMessage = "Failed to generate report: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// Clear the current report
    func clearReport() {
        reportText = ""
        errorMessage = nil
    }
}
