//
//  RootView.swift
//  TravelReceipt
//
//  App 根視圖 - 處理 Onboarding 與主畫面切換
//

import SwiftUI

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        if hasCompletedOnboarding {
            ContentView()
        } else {
            OnboardingView()
        }
    }
}

#Preview("首次啟動") {
    RootView()
        .onAppear {
            UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        }
}

#Preview("已完成引導") {
    RootView()
        .onAppear {
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        }
}
