//
//  MeterView.swift
//  Car-Connect
//
//  SwiftUI rewrite of the parking-meter reminder feature.
//

import SwiftUI
import UserNotifications

// MARK: - Status enums

enum MeterStatus: Equatable {
    case notSet
    case running(remaining: TimeInterval)
    case expired

    var isActive: Bool {
        if case .running = self { return true }
        return false
    }
}

enum ReminderStatus: Equatable {
    case notSet
    case scheduled(remaining: TimeInterval)
    case sent
}

enum ReminderScheduleResult {
    case success
    case meterNotSet
    case leadTimeTooLong
    case permissionDenied
}

// MARK: - View model

@MainActor
final class MeterViewModel: ObservableObject {

    @Published private(set) var meterExpiration: Date?
    @Published private(set) var reminderFireDate: Date?
    @Published private(set) var notificationAuthorization: UNAuthorizationStatus = .notDetermined

    private let notificationCenter = UNUserNotificationCenter.current()
    private let notificationIdentifier = "MeterReminder"

    init() {
        meterExpiration = StorageHandler.getMeterExpiration()
        reminderFireDate = StorageHandler.getReminderFireDate()
        Task { await refreshAuthorizationStatus() }
    }

    var meterStatus: MeterStatus {
        guard let expiration = meterExpiration else { return .notSet }
        let remaining = expiration.timeIntervalSinceNow
        if remaining <= 0 { return .expired }
        return .running(remaining: remaining)
    }

    var reminderStatus: ReminderStatus {
        guard let fireDate = reminderFireDate else { return .notSet }
        let remaining = fireDate.timeIntervalSinceNow
        if remaining <= 0 { return .sent }
        return .scheduled(remaining: remaining)
    }

    /// Sets the meter to expire `interval` seconds from now.
    /// Any existing reminder is cleared since its lead time no longer applies.
    func setMeterExpiration(in interval: TimeInterval) {
        let expiration = Date().addingTimeInterval(interval)
        meterExpiration = expiration
        StorageHandler.setMeterExpiration(expiration)
        clearReminder()
    }

    /// Schedules a local notification for `leadTime` seconds before the meter expires.
    func setReminderLeadTime(_ leadTime: TimeInterval) async -> ReminderScheduleResult {
        guard let expiration = meterExpiration, expiration > Date() else {
            return .meterNotSet
        }
        let fireDate = expiration.addingTimeInterval(-leadTime)
        guard fireDate > Date() else {
            return .leadTimeTooLong
        }

        let granted = await requestNotificationAuthorization()
        guard granted else { return .permissionDenied }

        scheduleNotification(fireDate: fireDate)
        reminderFireDate = fireDate
        StorageHandler.setReminderFireDate(fireDate)
        return .success
    }

    func clearMeter() {
        meterExpiration = nil
        StorageHandler.clearMeterExpiration()
        clearReminder()
    }

    func clearReminder() {
        reminderFireDate = nil
        StorageHandler.clearReminderFireDate()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
    }

    /// Forces a view refresh so the countdown text updates. Called from a ticking timer.
    func tick() {
        objectWillChange.send()
    }

    // MARK: - Notifications

    private func requestNotificationAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound])
            await refreshAuthorizationStatus()
            return granted
        } catch {
            return false
        }
    }

    private func refreshAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        notificationAuthorization = settings.authorizationStatus
    }

    private func scheduleNotification(fireDate: Date) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])

        let content = UNMutableNotificationContent()
        content.title = "Don't forget!"
        content.body = "Your parking meter is about to expire."
        content.sound = .default

        let interval = max(1, fireDate.timeIntervalSinceNow)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error {
                print("Failed to schedule meter reminder: \(error)")
            }
        }
    }
}

// MARK: - View

struct MeterView: View {

    @StateObject private var viewModel = MeterViewModel()
    @State private var presentedPicker: PickerKind?
    @State private var showPermissionAlert = false
    @State private var scheduleErrorMessage: String?

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    enum PickerKind: Identifiable {
        case meter
        case reminder

        var id: Self { self }

        var title: String {
            switch self {
            case .meter: return "Meter Expires In"
            case .reminder: return "Remind Me Before"
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    meterRow
                    reminderRow
                } footer: {
                    Text("Set how long until your meter expires, then choose how soon before expiration you want a reminder notification.")
                }

                if viewModel.meterExpiration != nil {
                    Section {
                        Button(role: .destructive) {
                            withAnimation {
                                viewModel.clearMeter()
                            }
                        } label: {
                            Label("Clear Meter", systemImage: "trash")
                        }
                        .accessibilityIdentifier("ClearMeterButton")
                    }
                }
            }
            .navigationTitle("Meter")
            .sheet(item: $presentedPicker) { kind in
                DurationPickerSheet(kind: kind) { interval in
                    handlePickerResult(kind: kind, interval: interval)
                }
            }
            .onReceive(timer) { _ in
                viewModel.tick()
            }
            .alert("Notifications Disabled",
                   isPresented: $showPermissionAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Enable notifications in Settings to get reminded before your meter expires.")
            }
            .alert("Can't Schedule Reminder",
                   isPresented: Binding(
                    get: { scheduleErrorMessage != nil },
                    set: { if !$0 { scheduleErrorMessage = nil } }
                   )) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(scheduleErrorMessage ?? "")
            }
        }
    }

    // MARK: Rows

    private var meterRow: some View {
        Button {
            presentedPicker = .meter
        } label: {
            StatusRow(
                title: "Meter Expires In",
                status: meterStatusText,
                statusTint: meterStatusTint,
                icon: "timer"
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("MeterRow")
    }

    private var reminderRow: some View {
        Button {
            presentedPicker = .reminder
        } label: {
            StatusRow(
                title: "Remind Me Before",
                status: reminderStatusText,
                statusTint: reminderStatusTint,
                icon: "bell"
            )
        }
        .buttonStyle(.plain)
        .disabled(!viewModel.meterStatus.isActive)
        .accessibilityIdentifier("ReminderRow")
    }

    // MARK: Status text + tint

    private var meterStatusText: String {
        switch viewModel.meterStatus {
        case .notSet: return "Not set"
        case .expired: return "Expired"
        case .running(let remaining): return format(remaining)
        }
    }

    private var meterStatusTint: Color {
        switch viewModel.meterStatus {
        case .notSet: return .secondary
        case .expired: return .red
        case .running(let remaining): return remaining < 300 ? .orange : .primary
        }
    }

    private var reminderStatusText: String {
        switch viewModel.reminderStatus {
        case .notSet: return "No reminder"
        case .sent: return "Notification sent"
        case .scheduled(let remaining): return "In \(format(remaining))"
        }
    }

    private var reminderStatusTint: Color {
        switch viewModel.reminderStatus {
        case .notSet: return .secondary
        case .sent: return .green
        case .scheduled: return .primary
        }
    }

    // MARK: Formatting

    private func format(_ interval: TimeInterval) -> String {
        let total = Int(interval.rounded(.down))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm %02ds", minutes, seconds)
        } else {
            return "\(seconds)s"
        }
    }

    // MARK: Actions

    private func handlePickerResult(kind: PickerKind, interval: TimeInterval) {
        switch kind {
        case .meter:
            withAnimation {
                viewModel.setMeterExpiration(in: interval)
            }
        case .reminder:
            Task {
                let result = await viewModel.setReminderLeadTime(interval)
                switch result {
                case .success:
                    break
                case .meterNotSet:
                    scheduleErrorMessage = "Set a meter expiration first."
                case .leadTimeTooLong:
                    scheduleErrorMessage = "The reminder lead time is longer than the time remaining on the meter."
                case .permissionDenied:
                    showPermissionAlert = true
                }
            }
        }
    }
}

// MARK: - Row component

private struct StatusRow: View {
    let title: String
    let status: String
    let statusTint: Color
    let icon: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)
                Text(status)
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(statusTint)
                    .contentTransition(.numericText())
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .contentShape(Rectangle())
        .padding(.vertical, 4)
    }
}

// MARK: - Duration picker sheet

private struct DurationPickerSheet: View {
    let kind: MeterView.PickerKind
    let onSelect: (TimeInterval) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var hours: Int = 0
    @State private var minutes: Int = 15

    var body: some View {
        NavigationStack {
            VStack {
                HStack(spacing: 0) {
                    labeledPicker(title: "hours", selection: $hours, range: 0..<24)
                    labeledPicker(title: "min",   selection: $minutes, range: 0..<60)
                }
                .frame(maxHeight: 220)

                Spacer()
            }
            .padding(.top, 16)
            .navigationTitle(kind.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Set") {
                        let interval = TimeInterval(hours * 3600 + minutes * 60)
                        onSelect(interval)
                        dismiss()
                    }
                    .disabled(hours == 0 && minutes == 0)
                    .accessibilityIdentifier("SetDurationButton")
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func labeledPicker(title: String, selection: Binding<Int>, range: Range<Int>) -> some View {
        Picker(title, selection: selection) {
            ForEach(range, id: \.self) { value in
                Text("\(value) \(title)").tag(value)
            }
        }
        .pickerStyle(.wheel)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MeterView()
}
