import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .today
    @State private var todayViewModel = TodayViewModel()
    @State private var patternsViewModel = PatternsViewModel()
    @State private var settingsViewModel = SettingsViewModel()

    enum Tab: String, CaseIterable {
        case today = "Today"
        case patterns = "Patterns"
        case settings = "Settings"

        var icon: String {
            switch self {
            case .today: return "sun.max.fill"
            case .patterns: return "chart.xyaxis.line"
            case .settings: return "gearshape.fill"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView(viewModel: todayViewModel)
                .tabItem {
                    Label(Tab.today.rawValue, systemImage: Tab.today.icon)
                }
                .tag(Tab.today)

            PatternsView(viewModel: patternsViewModel)
                .tabItem {
                    Label(Tab.patterns.rawValue, systemImage: Tab.patterns.icon)
                }
                .tag(Tab.patterns)

            SettingsView(viewModel: settingsViewModel)
                .tabItem {
                    Label(Tab.settings.rawValue, systemImage: Tab.settings.icon)
                }
                .tag(Tab.settings)
        }
        .tint(Color.appAccent)
        .onAppear {
            configureTabBarAppearance()
            todayViewModel.loadToday()
            patternsViewModel.loadData()
            settingsViewModel.loadSettings()
        }
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.appBackground)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    MainTabView()
        .preferredColorScheme(.dark)
}
