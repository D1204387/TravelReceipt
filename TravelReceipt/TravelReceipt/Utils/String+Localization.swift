//
//  String+Localization.swift
//  TravelReceipt
//
//  字串在地化擴展
//

import Foundation

extension String {
    /// 取得在地化字串
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    /// 取得帶參數的在地化字串
    func localized(with arguments: CVarArg...) -> String {
        String(format: self.localized, arguments: arguments)
    }
}

// MARK: - Localization Keys
/// 定義所有在地化鍵值，提供型別安全的存取方式
enum L10n {
    
    // MARK: Tab Bar
    enum Tab {
        static let trips = "tab.trips".localized
        static let statistics = "tab.statistics".localized
        static let settings = "tab.settings".localized
    }
    
    // MARK: Trips
    enum Trips {
        static let title = "trips.title".localized
        static let emptyTitle = "trips.empty.title".localized
        static let emptySubtitle = "trips.empty.subtitle".localized
        static let ongoing = "trips.section.ongoing".localized
        static let upcoming = "trips.section.upcoming".localized
        static let completed = "trips.section.completed".localized
    }
    
    // MARK: Add Trip
    enum AddTrip {
        static let title = "addTrip.title".localized
        static let name = "addTrip.name".localized
        static let destination = "addTrip.destination".localized
        static let startDate = "addTrip.startDate".localized
        static let endDate = "addTrip.endDate".localized
        static let budget = "addTrip.budget".localized
        static let currency = "addTrip.currency".localized
    }
    
    // MARK: Add Expense
    enum AddExpense {
        static let title = "addExpense.title".localized
        static let amount = "addExpense.amount".localized
        static let currency = "addExpense.currency".localized
        static let category = "addExpense.category".localized
        static let date = "addExpense.date".localized
        static let store = "addExpense.store".localized
        static let notes = "addExpense.notes".localized
        static let photo = "addExpense.photo".localized
        static let scan = "addExpense.scan".localized
        static let scanning = "addExpense.scanning".localized
    }
    
    // MARK: Categories
    enum Category {
        static let transport = "category.transport".localized
        static let lodging = "category.lodging".localized
        static let food = "category.food".localized
        static let telecom = "category.telecom".localized
        static let shopping = "category.shopping".localized
        static let entertainment = "category.entertainment".localized
        static let attraction = "category.attraction".localized
        static let miscellaneous = "category.miscellaneous".localized
    }
    
    // MARK: Statistics
    enum Stats {
        static let title = "stats.title".localized
        static let totalExpense = "stats.totalExpense".localized
        static let dailyAverage = "stats.dailyAverage".localized
        static let expenseCount = "stats.expenseCount".localized
        static let categoryBreakdown = "stats.categoryBreakdown".localized
    }
    
    // MARK: Settings
    enum Settings {
        static let title = "settings.title".localized
        static let sync = "settings.sync".localized
        static let syncNow = "settings.syncNow".localized
        static let lastSync = "settings.lastSync".localized
        static let defaultCurrency = "settings.defaultCurrency".localized
        static let dataStats = "settings.dataStats".localized
        static let tripCount = "settings.tripCount".localized
        static let expenseCount = "settings.expenseCount".localized
        static let dataManagement = "settings.dataManagement".localized
        static let export = "settings.export".localized
        static let sampleData = "settings.sampleData".localized
        static let deleteAll = "settings.deleteAll".localized
        static let about = "settings.about".localized
        static let privacy = "settings.privacy".localized
        static let terms = "settings.terms".localized
    }
    
    // MARK: Common
    enum Common {
        static let save = "common.save".localized
        static let cancel = "common.cancel".localized
        static let delete = "common.delete".localized
        static let edit = "common.edit".localized
        static let done = "common.done".localized
        static let confirm = "common.confirm".localized
        static let enabled = "common.enabled".localized
        static let disabled = "common.disabled".localized
    }
    
    // MARK: Onboarding
    enum Onboarding {
        static let start = "onboarding.start".localized
        static let skip = "onboarding.skip".localized
        static let next = "onboarding.next".localized
    }
}
