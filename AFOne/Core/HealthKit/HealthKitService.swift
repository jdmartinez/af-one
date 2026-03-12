import Foundation
import HealthKit

/// HealthKitError - Error types for HealthKit operations
enum HealthKitError: Error, LocalizedError {
    case dataNotAvailable
    case authorizationDenied
    case queryFailed(Error)
    case invalidData
    case noData
    case notAvailable

    var errorDescription: String? {
        switch self {
        case .dataNotAvailable:
            return "Health data is not available on this device"
        case .authorizationDenied:
            return "HealthKit authorization was denied"
        case .queryFailed(let error):
            return "HealthKit query failed: \(error.localizedDescription)"
        case .invalidData:
            return "Invalid health data format"
        case .noData:
            return "No health data available"
        case .notAvailable:
            return "Feature not available on this device"
        }
    }
}

/// MedicationInfo - Medication information from HealthKit
struct MedicationInfo: Identifiable {
    let id: UUID
    let name: String
    let dose: String?
    let frequency: String?
    let startDate: Date?
    let endDate: Date?
}

/// RhythmStatus - Current rhythm state
enum RhythmStatus: String, Codable {
    case normal = "Normal"
    case af = "AF Detected"
    case unknown = "Unknown"
}

/// HealthKitService - Singleton for all HealthKit interactions
@MainActor
@Observable
final class HealthKitService {
    static let shared = HealthKitService()

    private let healthStore = HKHealthStore()
    private var lastFetchDate: Date?

    private init() {}

    // MARK: - Authorization

    /// Check if HealthKit data is available on this device
    func isHealthDataAvailable() -> Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    /// Request authorization for all required health types
    func requestAuthorization() async throws -> Bool {
        guard isHealthDataAvailable() else {
            throw HealthKitError.dataNotAvailable
        }

        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .atrialFibrillationBurden)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKObjectType.electrocardiogramType(),
            HKObjectType.characteristicType(forIdentifier: .bloodType)!,
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
        ]

        let typesToWrite: Set<HKSampleType> = []

        return try await withCheckedThrowingContinuation { continuation in
            healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { success, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }

    // MARK: - Fetch Methods

    /// Fetch current rhythm status
    func fetchCurrentRhythmStatus() async -> RhythmStatus {
        do {
            let burden = try await fetchAfBurden(from: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, to: Date())
            if let latestBurden = burden.first {
                if latestBurden.percentage > 0 {
                    return .af
                }
            }
            return .normal
        } catch {
            return .unknown
        }
    }

    /// Fetch AF Burden for a date range
    func fetchAfBurden(from startDate: Date, to endDate: Date) async throws -> [AFBurden] {
        guard let afBurdenType = HKObjectType.quantityType(forIdentifier: .atrialFibrillationBurden) else {
            throw HealthKitError.dataNotAvailable
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: afBurdenType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                    return
                }

                guard let quantitySamples = samples as? [HKQuantitySample] else {
                    continuation.resume(returning: [])
                    return
                }

                let burdens = quantitySamples.map { sample in
                    AFBurden(
                        date: sample.startDate,
                        percentage: sample.quantity.doubleValue(for: .percent()),
                        sampleCount: sample.quantitySampleType?.samplesWereAggregatedFromRelatedSamples ?? false ? 1 : 0
                    )
                }
                continuation.resume(returning: burdens)
            }
            healthStore.execute(query)
        }
    }

    /// Fetch rhythm episodes for a date range
    func fetchEpisodes(from startDate: Date, to endDate: Date) async throws -> [RhythmEpisode] {
        // For now, return sample data since actual AF episode detection
        // requires specific HealthKit ECG/irregular rhythm data
        // In production, this would query ECG results or use Apple Watch's AF detection

        // Return sample data for development
        return [
            RhythmEpisode(
                id: UUID(),
                startDate: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!,
                endDate: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!,
                averageHR: 125,
                peakHR: 145,
                rhythmType: .af
            ),
            RhythmEpisode(
                id: UUID(),
                startDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                endDate: Calendar.current.date(byAdding: .hour, value: -23, to: Date())!,
                averageHR: 110,
                peakHR: 132,
                rhythmType: .af
            ),
            RhythmEpisode(
                id: UUID(),
                startDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
                endDate: Calendar.current.date(byAdding: .hour, value: -71, to: Date())!,
                averageHR: 95,
                peakHR: 118,
                rhythmType: .af
            )
        ]
    }

    /// Fetch heart rate samples for a date range
    func fetchHeartRateSamples(from startDate: Date, to endDate: Date) async throws -> [HeartRateReading] {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            throw HealthKitError.dataNotAvailable
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: heartRateType,
                predicate: predicate,
                limit: 100,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                    return
                }

                guard let quantitySamples = samples as? [HKQuantitySample] else {
                    continuation.resume(returning: [])
                    return
                }

                let readings = quantitySamples.map { sample in
                    HeartRateReading(
                        id: UUID(),
                        timestamp: sample.startDate,
                        bpm: Int(sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))),
                        source: sample.sourceRevision.source.name
                    )
                }
                continuation.resume(returning: readings)
            }
            healthStore.execute(query)
        }
    }

    // MARK: - Emergency Info

    /// Read emergency contact from HealthKit
    func fetchEmergencyContacts() async -> [String] {
        // HealthKit doesn't provide direct access to Medical ID emergency contacts
        // This would require using HealthKit's emergency contacts feature
        // For now, return sample data
        return ["Jane Doe (Spouse): 555-0123"]
    }

    /// Read medical conditions from HealthKit
    func fetchMedicalConditions() async -> [String] {
        // HealthKit doesn't provide direct access to Medical ID conditions
        // This would require using HealthKit's health records feature
        // For now, return sample data
        return ["Atrial Fibrillation"]
    }

    /// Read medications from HealthKit
    func fetchMedications() async throws -> [MedicationInfo] {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }
        
        if #available(iOS 18.0, *) {
            return try await fetchMedicationsiOS18()
        } else {
            return try await fetchMedicationsLegacy()
        }
    }

    @available(iOS 18.0, *)
    private func fetchMedicationsiOS18() async throws -> [MedicationInfo] {
        let queryDescriptor = HKUserAnnotatedMedicationQueryDescriptor()
        
        do {
            let medications = try await queryDescriptor.result(for: healthStore)
            
            return medications.map { medication in
                MedicationInfo(
                    id: UUID(),
                    name: medication.nickname ?? "Medication",
                    dose: nil,
                    frequency: medication.hasSchedule ? "As scheduled" : nil,
                    startDate: nil,
                    endDate: nil
                )
            }
        } catch {
            throw HealthKitError.queryFailed(error)
        }
    }

    private func fetchMedicationsLegacy() async throws -> [MedicationInfo] {
        return []
    }

    /// Fetch medication dose events
    func fetchMedicationDoseEvents(for medication: MedicationInfo, from: Date, to: Date) async throws -> [Date] {
        return []
    }
}
