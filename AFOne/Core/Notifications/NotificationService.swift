import Foundation
import UserNotifications
import HealthKit

@MainActor
final class NotificationService {
    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()
    private var lastCheckedEpisodeDate: Date?

    private init() {}

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            if granted {
                await setupNotificationCategories()
            }
            return granted
        } catch {
            return false
        }
    }

    private func setupNotificationCategories() async {
        let viewAction = UNNotificationAction(
            identifier: "VIEW_EPISODE",
            title: "View Details",
            options: [.foreground]
        )

        let dismissAction = UNNotificationAction(
            identifier: "DISMISS",
            title: "Dismiss",
            options: []
        )

        let afCategory = UNNotificationCategory(
            identifier: "AF_ALERT",
            actions: [viewAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )

        center.setNotificationCategories([afCategory])
    }

    func checkForNewEpisodes() async {
        let now = Date()
        let dayAgo = Calendar.current.date(byAdding: .day, value: -1, to: now)!

        do {
            let episodes = try await HealthKitService.shared.fetchEpisodes(from: dayAgo, to: now)

            guard let latestEpisode = episodes.first else { return }

            if let lastDate = lastCheckedEpisodeDate {
                if latestEpisode.startDate > lastDate {
                    await scheduleNotification(for: latestEpisode)
                }
            }

            if let latest = episodes.first {
                lastCheckedEpisodeDate = latest.startDate
            }
        } catch {
            // Silently fail - notifications are not critical
        }
    }

    private func scheduleNotification(for episode: RhythmEpisode) async {
        let content = UNMutableNotificationContent()
        content.title = "AF Episode Detected"
        content.body = "Your Apple Watch detected an irregular rhythm. Tap for details."
        content.sound = .default
        content.categoryIdentifier = "AF_ALERT"
        content.userInfo = ["episodeId": episode.id.uuidString]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(
            identifier: "af-episode-\(episode.id.uuidString)",
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            // Silently fail
        }
    }

    func scheduleEpisodeDurationAlert(episode: RhythmEpisode, duration: TimeInterval) async {
        let hours = Int(duration / 3600)

        guard hours >= 1 else { return }

        let content = UNMutableNotificationContent()
        content.title = "Long AF Episode"
        content.body = "You have been in AF for \(hours) hour\(hours > 1 ? "s" : ""). Consider contacting your doctor."
        content.sound = .default
        content.categoryIdentifier = "AF_ALERT"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(
            identifier: "af-duration-\(episode.id.uuidString)",
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            // Silently fail
        }
    }
}
