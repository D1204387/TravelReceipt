    //
    //  TravelReceiptApp.swift
    //  TravelReceipt
    //
    //  Created by YiJou on 2025/11/12.
    //

import SwiftUI
import SwiftData
import UserNotifications
import WidgetKit

@main
struct TravelReceiptApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    var modelContainer: ModelContainer = {
        do {
            return try ModelContainer(for: Trip.self, Expense.self)
        } catch {
            print("❌ ModelContainer creation failed: \(error)")
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        requestNotificationPermission()
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("通知權限已開啟")
            } else {
                print("通知權限被拒絕")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // 初次啟動時同步資料
                    syncWidgetData()
                }
        }
        .modelContainer(modelContainer)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                // 進入背景時同步資料給 Widget
                syncWidgetData()
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
    
    /// 同步資料到 Widget 共享容器
    @MainActor
    private func syncWidgetData() {
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<Trip>(sortBy: [SortDescriptor(\.startDate, order: .reverse)])
        
        do {
            let trips = try context.fetch(descriptor)
            let sharedData = trips.map { trip -> SharedTripData in
                // 計算分類統計
                var categoryBreakdown: [String: Double] = [:]
                if let expenses = trip.expenses {
                    for expense in expenses {
                        let convertedAmount = trip.convertToPrimaryCurrency(amount: expense.amount, from: expense.currency)
                        categoryBreakdown[expense.category.displayName, default: 0] += convertedAmount
                    }
                }
                
                return SharedTripData(
                    id: trip.id,
                    name: trip.name,
                    destination: trip.destination,
                    startDate: trip.startDate,
                    endDate: trip.endDate,
                    totalExpenses: trip.totalExpensesInPrimaryCurrency,
                    expenseCount: trip.expenses?.count ?? 0,
                    primaryCurrency: trip.primaryCurrency,
                    categoryBreakdown: categoryBreakdown
                )
            }
            
            SharedDataManager.saveTripData(sharedData)
        } catch {
            print("❌ 同步 Widget 資料失敗：\(error)")
        }
    }
}

    // ✅ 新增 AppDelegate 處理前景通知
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
        // ✅ 這個方法讓 App 在前景時也能顯示通知
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
