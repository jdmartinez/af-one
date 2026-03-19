import Foundation
import SwiftUI
import HealthKit
import UIKit

// MARK: - Medication Class

enum MedicationClass: String, CaseIterable {
    case anticoagulante = "Anticoagulante"
    case betaBlocker = "β-bloqueante"
    case antiarrhythmic = "Antiarrítmico"
    case other = "Otro"

    var badgeColor: Color {
        switch self {
        case .anticoagulante: return .blue
        case .betaBlocker: return .green
        case .antiarrhythmic: return .purple
        case .other: return .gray
        }
    }
}

// MARK: - AF Type

enum AFType: String {
    case paroxysmal = "Paroxística"
    case persistent = "Persistente"
    case longStandingPersistent = "Persistente de larga duración"
    case unknown = "Desconocida"
}

// MARK: - Patient Info

struct PatientInfo: Equatable {
    let name: String
    let dateOfBirth: Date?
    let sex: String
    let knownDiagnoses: [String]

    var age: Int? {
        guard let dob = dateOfBirth else { return nil }
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dob, to: Date())
        return ageComponents.year
    }
}

// MARK: - Current Episode Data

struct CurrentEpisodeData: Equatable {
    let onsetTime: Date
    var elapsedTime: TimeInterval
    let currentHR: Int?
    let currentSpO2: Int?
    let onsetTimestamp: Date
    let hrTimestamp: Date?
    let spo2Timestamp: Date?
    let meanHR: Int?
    let peakHR: Int?
    let symptoms: [String]
    let hasECG: Bool

    var elapsedTimeFormatted: String {
        let hours = Int(elapsedTime / 3600)
        let minutes = Int((elapsedTime.truncatingRemainder(dividingBy: 3600)) / 60)
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}

// MARK: - AF History Summary

struct AFHistorySummary: Equatable {
    let thirtyDayBurdenTimeline: [Double] // daily burden percentages
    let episodeCount: Int
    let meanDuration: TimeInterval
    let burdenPercentage: Double
    let afType: AFType

    var meanDurationFormatted: String {
        let minutes = Int(meanDuration / 60)
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours)h \(remainingMinutes)m"
        }
    }
}

// MARK: - Categorized Medication

struct CategorizedMedication: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let dose: String?
    let medicationClass: MedicationClass
}

// MARK: - Medical History Item

struct MedicalHistoryItem: Identifiable, Equatable {
    let id = UUID()
    let category: String
    let description: String
    let date: Date?

    var categoryIcon: String {
        switch category {
        case "Diagnósticos": return "heart.text.square.fill"
        case "Cardioversiones": return "bolt.heart.fill"
        case "Alergias": return "allergens"
        case "Cardiólogo referente": return "stethoscope"
        default: return "doc.text.fill"
        }
    }

    var categoryColor: Color {
        switch category {
        case "Diagnósticos": return .red
        case "Cardioversiones": return .orange
        case "Alergias": return .purple
        case "Cardiólogo referente": return .blue
        default: return .gray
        }
    }
}

// MARK: - Emergency Report ViewModel

@MainActor
@Observable
final class EmergencyReportViewModel {

    // MARK: - Published Properties

    var patientInfo: PatientInfo?
    var currentEpisode: CurrentEpisodeData?
    var afHistory: AFHistorySummary?
    var medications: [MedicationClass: [CategorizedMedication]] = [:]
    var medicalHistory: [MedicalHistoryItem] = []
    var isLoading = false
    var generatedAt: Date = Date()
    var limitationsText: String = "Apple Watch no es un dispositivo médico certificado. La detección de FA puede tener falsos positivos y negativos. Este informe no sustituye el criterio médico profesional."

    // MARK: - Computed Properties

    var urgencyBadgeText: String {
        currentEpisode != nil ? "⚠️ URGENTE" : "📋 INFORME DE EMERGENCIA"
    }

    var elapsedTimeFormatted: String {
        guard let episode = currentEpisode else { return "--" }
        return episode.elapsedTimeFormatted
    }

    // MARK: - Timer Support

    private var elapsedTimer: Timer?

    // MARK: - Initialization

    init() {
        startElapsedTimer()
    }

    // MARK: - Data Loading

    func loadAllData() async {
        isLoading = true

        loadPatientData()
        loadCurrentEpisode()
        loadAFHistory()
        loadMedications()
        loadMedicalHistory()

        isLoading = false
    }

    // MARK: - Patient Data

    private func loadPatientData() {
        // Try to fetch from HealthKit
        if HKHealthStore.isHealthDataAvailable() {
            let store = HKHealthStore()
            do {
                let dateOfBirth = try store.dateOfBirthComponents()
                let biologicalSex = try store.biologicalSex()
                let dob = Calendar.current.date(from: dateOfBirth)
                let sexString = biologicalSex.biologicalSex == .female ? "Mujer" : "Hombre"

                patientInfo = PatientInfo(
                    name: "María García López",
                    dateOfBirth: dob,
                    sex: sexString,
                    knownDiagnoses: ["Fibrilación Auricular"]
                )
                return
            } catch {
                // Fall through to sample data
            }
        }

        // Sample data fallback
        let calendar = Calendar.current
        let sampleDOB = calendar.date(byAdding: .year, value: -68, to: Date())

        patientInfo = PatientInfo(
            name: "María García López",
            dateOfBirth: sampleDOB,
            sex: "Mujer",
            knownDiagnoses: ["Fibrilación Auricular"]
        )
    }

    // MARK: - Current Episode

    private func loadCurrentEpisode() {
        // Sample current episode data
        let onset = Date().addingTimeInterval(-2 * 3600) // 2 hours ago

        currentEpisode = CurrentEpisodeData(
            onsetTime: onset,
            elapsedTime: Date().timeIntervalSince(onset),
            currentHR: 118,
            currentSpO2: 97,
            onsetTimestamp: onset,
            hrTimestamp: Date().addingTimeInterval(-300),
            spo2Timestamp: Date().addingTimeInterval(-300),
            meanHR: 122,
            peakHR: 145,
            symptoms: ["Palpitaciones", "Disnea"],
            hasECG: true
        )
    }

    // MARK: - AF History

    private func loadAFHistory() {
        // Generate 30-day timeline
        let timeline = (0..<30).map { _ in Double.random(in: 0...15) }
        let avgBurden = timeline.reduce(0, +) / Double(timeline.count)

        afHistory = AFHistorySummary(
            thirtyDayBurdenTimeline: timeline,
            episodeCount: 23,
            meanDuration: 2100,
            burdenPercentage: avgBurden,
            afType: .paroxysmal
        )
    }

    // MARK: - Medications

    private func loadMedications() {
        // Sample medications with categorization
        let sampleMeds: [CategorizedMedication] = [
            CategorizedMedication(name: "Apixaban", dose: "5mg 2x/día", medicationClass: .anticoagulante),
            CategorizedMedication(name: "Metoprolol", dose: "50mg 1x/día", medicationClass: .betaBlocker),
            CategorizedMedication(name: "Amiodarona", dose: "200mg 1x/día", medicationClass: .antiarrhythmic)
        ]

        var categorized: [MedicationClass: [CategorizedMedication]] = [:]
        for med in sampleMeds {
            categorized[med.medicationClass, default: []].append(med)
        }
        medications = categorized
    }

    // MARK: - Medical History

    private func loadMedicalHistory() {
        let calendar = Calendar.current

        medicalHistory = [
            MedicalHistoryItem(
                category: "Diagnósticos",
                description: "Fibrilación Auricular paroxística",
                date: calendar.date(byAdding: .year, value: -3, to: Date())
            ),
            MedicalHistoryItem(
                category: "Diagnósticos",
                description: "Hipertensión arterial",
                date: calendar.date(byAdding: .year, value: -8, to: Date())
            ),
            MedicalHistoryItem(
                category: "Cardioversiones",
                description: "Cardioversión eléctrica - 2 procedimientos",
                date: calendar.date(byAdding: .month, value: -18, to: Date())
            ),
            MedicalHistoryItem(
                category: "Alergias",
                description: "Penicilina",
                date: nil
            ),
            MedicalHistoryItem(
                category: "Cardiólogo referente",
                description: "Dr. Juan Martínez - Hospital General",
                date: calendar.date(byAdding: .month, value: -6, to: Date())
            )
        ]
    }

    // MARK: - Timer

    private func startElapsedTimer() {
        elapsedTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateElapsedTime()
            }
        }
    }

    private func updateElapsedTime() {
        guard let episode = currentEpisode else { return }
        let newElapsed = Date().timeIntervalSince(episode.onsetTime)
        currentEpisode = CurrentEpisodeData(
            onsetTime: episode.onsetTime,
            elapsedTime: newElapsed,
            currentHR: episode.currentHR,
            currentSpO2: episode.currentSpO2,
            onsetTimestamp: episode.onsetTimestamp,
            hrTimestamp: episode.hrTimestamp,
            spo2Timestamp: episode.spo2Timestamp,
            meanHR: episode.meanHR,
            peakHR: episode.peakHR,
            symptoms: episode.symptoms,
            hasECG: episode.hasECG
        )
    }

    // MARK: - Emergency Call

    func callEmergency() {
        guard let url = URL(string: "tel://112") else { return }
        #if canImport(UIKit)
        UIApplication.shared.open(url)
        #endif
    }
}
