//
//  OnboardingView.swift
//  TravelReceipt
//
//  首次啟動引導頁面
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "airplane.circle.fill",
            iconColor: .blue,
            title: "歡迎使用 TravelReceipt",
            subtitle: "您的旅途財務小幫手",
            description: "輕鬆記錄每一筆旅行支出，讓您專注享受旅程"
        ),
        OnboardingPage(
            icon: "list.bullet.clipboard.fill",
            iconColor: .purple,
            title: "行程管理",
            subtitle: "一目了然的行程規劃",
            description: "建立多個行程，分別追蹤不同旅途的支出，隨時掌握預算"
        ),
        OnboardingPage(
            icon: "text.viewfinder",
            iconColor: .orange,
            title: "智能掃描",
            subtitle: "AI 自動辨識發票",
            description: "拍攝發票照片，自動識別金額、日期、商家，並智慧分類"
        ),
        OnboardingPage(
            icon: "dollarsign.circle.fill",
            iconColor: .green,
            title: "多幣別支援",
            subtitle: "跨國旅遊無煩惱",
            description: "支援多種貨幣，自訂匯率，自動換算統計總支出"
        ),
        OnboardingPage(
            icon: "chart.pie.fill",
            iconColor: .teal,
            title: "視覺化統計",
            subtitle: "掌握每一筆支出",
            description: "圓餅圖分析支出分佈，了解消費習慣，還可匯出 CSV"
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 頁面內容
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            
            // 底部控制區
            VStack(spacing: 20) {
                // 頁面指示器
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut, value: currentPage)
                    }
                }
                
                // 按鈕
                if currentPage == pages.count - 1 {
                    Button(action: completeOnboarding) {
                        Text("開始使用")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                } else {
                    HStack {
                        Button(action: { completeOnboarding() }) {
                            Text("跳過")
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: { withAnimation { currentPage += 1 } }) {
                            HStack {
                                Text("下一步")
                                Image(systemName: "arrow.right")
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(.blue)
                            .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
        .background(Color(.systemBackground))
    }
    
    private func completeOnboarding() {
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
}

// MARK: - 單頁內容
struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: page.icon)
                .font(.system(size: 100))
                .foregroundStyle(page.iconColor)
                .padding(.bottom, 20)
            
            VStack(spacing: 12) {
                Text(page.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Text(page.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
    }
}

// MARK: - 資料模型
struct OnboardingPage {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let description: String
}

// MARK: - Preview
#Preview {
    OnboardingView()
}
