import SwiftUI

@main
struct SleepPathApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
                    .preferredColorScheme(.dark)
            } else {
                OnboardingContainerView(onComplete: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        hasCompletedOnboarding = true
                    }
                })
                .preferredColorScheme(.dark)
            }
        }
    }
}
