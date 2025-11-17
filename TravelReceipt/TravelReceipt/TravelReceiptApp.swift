    //
    //  TravelReceiptApp.swift
    //  TravelReceipt
    //
    //  Created by YiJou  on 2025/11/12.
    //

import SwiftUI
import SwiftData
import CloudKit

@main
struct TravelReceiptApp: App {
    var modelContainer: ModelContainer = {
        let schema = Schema([
            Trip.self,
            Expense.self,
//            ExpenseCategory.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
//            groupContainer: .identifier("group.com.buildwithharry.TravelReceipt"),
//            cloudKitDatabase: .private("iCloud.com.buildwithharry.TravelReceipt")
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
                // 更詳細的錯誤訊息
            print("ModelContainer creation failed: \(error)")
            
                // 嘗試只用基本設定
            do {
                return try ModelContainer(for: Trip.self, Expense.self)
            } catch {
                fatalError("Could not create ModelContainer even with basic configuration:  \(error)")
            }
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}

