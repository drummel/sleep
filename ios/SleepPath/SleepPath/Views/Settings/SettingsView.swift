import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: SettingsViewModel

    var body: some View {
        NavigationStack {
            List {
                profileSection
                connectionsSection
                notificationsSection
                preferencesSection
                dataSection
                aboutSection
            }
            .scrollContentBackground(.hidden)
            .background(SleepTheme.background.ignoresSafeArea())
            .navigationTitle("Settings")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Delete All Data", isPresented: $viewModel.showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete Everything", role: .destructive) {
                    viewModel.confirmDeleteAllData()
                }
            } message: {
                Text("This will permanently delete all your sleep data, patterns, and preferences. This action cannot be undone.")
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Profile Section

    private var profileSection: some View {
        Section {
            HStack {
                Label {
                    Text("Chronotype")
                        .foregroundStyle(.white)
                } icon: {
                    Image(systemName: "moon.stars.fill")
                        .foregroundStyle(SleepTheme.accent)
                }

                Spacer()

                Text("\(viewModel.chronotype.displayName) \(viewModel.chronotype.emoji)")
                    .foregroundStyle(.white.opacity(0.6))

                Button("Retake Quiz") {
                    viewModel.retakeQuiz()
                }
                .font(.caption)
                .foregroundStyle(SleepTheme.accent)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .stroke(SleepTheme.accent, lineWidth: 1)
                )
            }
            .listRowBackground(SleepTheme.card)

            Picker(selection: $viewModel.goal) {
                ForEach(UserGoal.allCases, id: \.self) { goal in
                    Text(goal.displayName).tag(goal)
                }
            } label: {
                Label {
                    Text("Goal")
                        .foregroundStyle(.white)
                } icon: {
                    Image(systemName: "target")
                        .foregroundStyle(SleepTheme.accent)
                }
            }
            .tint(.white.opacity(0.6))
            .listRowBackground(SleepTheme.card)

            Picker(selection: $viewModel.ageRange) {
                ForEach(AgeRange.allCases, id: \.self) { range in
                    Text(range.displayName).tag(range)
                }
            } label: {
                Label {
                    Text("Age Range")
                        .foregroundStyle(.white)
                } icon: {
                    Image(systemName: "person.fill")
                        .foregroundStyle(SleepTheme.accent)
                }
            }
            .tint(.white.opacity(0.6))
            .listRowBackground(SleepTheme.card)

            Toggle(isOn: $viewModel.isNightShift) {
                Label {
                    Text("Night Shift Mode")
                        .foregroundStyle(.white)
                } icon: {
                    Image(systemName: "moon.fill")
                        .foregroundStyle(SleepTheme.accent)
                }
            }
            .tint(SleepTheme.accent)
            .listRowBackground(SleepTheme.card)
        } header: {
            Text("Profile")
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    // MARK: - Connections Section

    private var connectionsSection: some View {
        Section {
            Toggle(isOn: $viewModel.healthKitConnected) {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Apple Health")
                            .foregroundStyle(.white)
                        Text(viewModel.healthKitConnected ? "Connected" : "Disconnected")
                            .font(.caption)
                            .foregroundStyle(viewModel.healthKitConnected ? .green : .white.opacity(0.4))
                    }
                } icon: {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                }
            }
            .tint(SleepTheme.accent)
            .listRowBackground(SleepTheme.card)

            Toggle(isOn: $viewModel.calendarExportEnabled) {
                Label {
                    Text("Calendar Export")
                        .foregroundStyle(.white)
                } icon: {
                    Image(systemName: "calendar")
                        .foregroundStyle(SleepTheme.accent)
                }
            }
            .tint(SleepTheme.accent)
            .listRowBackground(SleepTheme.card)
        } header: {
            Text("Connections")
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    // MARK: - Notifications Section

    private var notificationsSection: some View {
        Section {
            notificationToggle(
                isOn: $viewModel.notificationPreferences.sunlightEnabled,
                icon: "sun.max.fill",
                iconColor: .yellow,
                title: "Sunlight Reminder",
                subtitle: "Morning light exposure window"
            )
            notificationToggle(
                isOn: $viewModel.notificationPreferences.caffeineCutoffEnabled,
                icon: "cup.and.saucer.fill",
                iconColor: .brown,
                title: "Caffeine Cutoff",
                subtitle: "Stop caffeine before it affects sleep"
            )
            notificationToggle(
                isOn: $viewModel.notificationPreferences.peakFocusEnabled,
                icon: "brain.head.profile",
                iconColor: .cyan,
                title: "Peak Focus",
                subtitle: "Your optimal cognitive window"
            )
            notificationToggle(
                isOn: $viewModel.notificationPreferences.digitalSunsetEnabled,
                icon: "iphone.slash",
                iconColor: .orange,
                title: "Digital Sunset",
                subtitle: "Time to reduce screen exposure"
            )
            notificationToggle(
                isOn: $viewModel.notificationPreferences.windDownEnabled,
                icon: "wind",
                iconColor: .mint,
                title: "Wind-Down Routine",
                subtitle: "Start your pre-sleep routine"
            )
            notificationToggle(
                isOn: $viewModel.notificationPreferences.weeklySummaryEnabled,
                icon: "doc.text.fill",
                iconColor: SleepTheme.accent,
                title: "Weekly Summary",
                subtitle: "Your sleep patterns overview"
            )
        } header: {
            Text("Notifications")
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    private func notificationToggle(
        isOn: Binding<Bool>,
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String
    ) -> some View {
        Toggle(isOn: isOn) {
            Label {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))
                }
            } icon: {
                Image(systemName: icon)
                    .foregroundStyle(iconColor)
            }
        }
        .tint(SleepTheme.accent)
        .listRowBackground(SleepTheme.card)
    }

    // MARK: - Preferences Section

    private var preferencesSection: some View {
        Section {
            Toggle(isOn: $viewModel.scienceMode) {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Science Mode")
                            .foregroundStyle(.white)
                        Text(viewModel.scienceMode ? "Detailed scientific language" : "Plain, friendly language")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                } icon: {
                    Image(systemName: "flask.fill")
                        .foregroundStyle(SleepTheme.accent)
                }
            }
            .tint(SleepTheme.accent)
            .listRowBackground(SleepTheme.card)

            Picker(selection: $viewModel.caffeineSensitivity) {
                ForEach(CaffeineSensitivity.allCases, id: \.self) { sensitivity in
                    Text(sensitivity.displayName).tag(sensitivity)
                }
            } label: {
                Label {
                    Text("Caffeine Sensitivity")
                        .foregroundStyle(.white)
                } icon: {
                    Image(systemName: "bolt.fill")
                        .foregroundStyle(SleepTheme.accent)
                }
            }
            .tint(.white.opacity(0.6))
            .listRowBackground(SleepTheme.card)

            Toggle(isOn: $viewModel.use24HourTime) {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Time Format")
                            .foregroundStyle(.white)
                        Text(viewModel.use24HourTime ? "24-hour" : "12-hour")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                } icon: {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(SleepTheme.accent)
                }
            }
            .tint(SleepTheme.accent)
            .listRowBackground(SleepTheme.card)
        } header: {
            Text("Preferences")
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    // MARK: - Data Section

    private var dataSection: some View {
        Section {
            Button {
                viewModel.exportData()
            } label: {
                Label {
                    Text("Export My Data")
                        .foregroundStyle(.white)
                } icon: {
                    Image(systemName: "square.and.arrow.up.fill")
                        .foregroundStyle(SleepTheme.accent)
                }
            }
            .listRowBackground(SleepTheme.card)

            Button {
                viewModel.deleteAllData()
            } label: {
                Label {
                    Text("Delete All Data")
                        .foregroundStyle(.red)
                } icon: {
                    Image(systemName: "trash.fill")
                        .foregroundStyle(.red)
                }
            }
            .listRowBackground(SleepTheme.card)
        } header: {
            Text("Data")
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section {
            HStack {
                Label {
                    Text("Subscription")
                        .foregroundStyle(.white)
                } icon: {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(SleepTheme.accent)
                }
                Spacer()
                Text(viewModel.subscriptionStatusText)
                    .font(.subheadline)
                    .foregroundStyle(.green)
            }
            .listRowBackground(SleepTheme.card)

            Link(destination: URL(string: "https://sleeppath.app/privacy")!) {
                Label {
                    Text("Privacy Policy")
                        .foregroundStyle(.white)
                } icon: {
                    Image(systemName: "hand.raised.fill")
                        .foregroundStyle(SleepTheme.accent)
                }
            }
            .listRowBackground(SleepTheme.card)

            Link(destination: URL(string: "https://sleeppath.app/terms")!) {
                Label {
                    Text("Terms of Service")
                        .foregroundStyle(.white)
                } icon: {
                    Image(systemName: "doc.text.fill")
                        .foregroundStyle(SleepTheme.accent)
                }
            }
            .listRowBackground(SleepTheme.card)

            HStack {
                Label {
                    Text("Version")
                        .foregroundStyle(.white)
                } icon: {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(SleepTheme.accent)
                }
                Spacer()
                Text(viewModel.versionString)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.4))
            }
            .listRowBackground(SleepTheme.card)

            HStack {
                Spacer()
                Text("Made with \u{2764}\u{FE0F} by Fibonacci Labs")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.3))
                Spacer()
            }
            .listRowBackground(Color.clear)
        } header: {
            Text("About")
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}

#Preview {
    @Previewable @State var vm = SettingsViewModel()

    SettingsView(viewModel: vm)
        .onAppear { vm.loadSettings() }
}
