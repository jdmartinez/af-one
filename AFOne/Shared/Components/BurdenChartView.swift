import SwiftUI
import Charts

struct BurdenChartView: View {
    let data: [BurdenDataPoint]
    let period: TimePeriod
    
    var body: some View {
        Chart(data) { dataPoint in
            switch period {
            case .day:
                BarMark(
                    x: .value("Time", dataPoint.date, unit: .hour),
                    y: .value("Burden", dataPoint.percentage)
                )
                .foregroundStyle(Color.accentColor.gradient)
            case .week, .month:
                LineMark(
                    x: .value("Date", dataPoint.date, unit: .day),
                    y: .value("Burden", dataPoint.percentage)
                )
                .foregroundStyle(Color.accentColor)
                .interpolationMethod(.catmullRom)
                
                PointMark(
                    x: .value("Date", dataPoint.date, unit: .day),
                    y: .value("Burden", dataPoint.percentage)
                )
                .foregroundStyle(Color.accentColor)
            }
        }
        .chartYScale(domain: 0...100)
        .chartYAxis {
            AxisMarks(position: .leading, values: [0, 25, 50, 75, 100]) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let intValue = value.as(Int.self) {
                        Text("\(intValue)%")
                            .font(.caption2)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisGridLine()
                AxisValueLabel()
            }
        }
    }
}

#Preview {
    BurdenChartView(
        data: [
            BurdenDataPoint(date: Date().addingTimeInterval(-86400 * 6), percentage: 15),
            BurdenDataPoint(date: Date().addingTimeInterval(-86400 * 5), percentage: 25),
            BurdenDataPoint(date: Date().addingTimeInterval(-86400 * 4), percentage: 10),
            BurdenDataPoint(date: Date().addingTimeInterval(-86400 * 3), percentage: 30),
            BurdenDataPoint(date: Date().addingTimeInterval(-86400 * 2), percentage: 20),
            BurdenDataPoint(date: Date().addingTimeInterval(-86400), percentage: 5),
            BurdenDataPoint(date: Date(), percentage: 12)
        ],
        period: .week
    )
    .frame(height: 200)
    .padding()
}
