//
//  CategoryClassifier.swift
//  TravelReceipt
//
//  智慧分類服務 - 根據商家名稱與發票內容自動推薦支出類別
//

import Foundation

/// 分類結果
struct ClassificationResult {
    let category: ExpenseCategory
    let confidence: Double  // 0.0 ~ 1.0
    let matchedKeyword: String?
}

/// 智慧分類服務
struct CategoryClassifier {
    
    // MARK: - 關鍵字字典
    
    /// 各分類的關鍵字對照表
    private static let categoryKeywords: [ExpenseCategory: [String]] = [
        .food: [
            // 餐廳類型
            "餐廳", "餐館", "飯館", "小吃", "熱炒", "火鍋", "燒烤", "燒肉",
            "拉麵", "壽司", "居酒屋", "定食", "丼飯", "咖哩",
            // 速食/連鎖
            "麥當勞", "肯德基", "摩斯", "漢堡王", "Subway", "必勝客",
            "星巴克", "Starbucks", "路易莎", "Louisa", "cama", "85度C",
            // 便利商店/超市
            "7-11", "7-ELEVEN", "全家", "FamilyMart", "萊爾富", "OK超商",
            "全聯", "家樂福", "Costco", "好市多", "大潤發",
            // 一般關鍵詞
            "飲料", "咖啡", "茶", "麵", "飯", "便當", "早餐", "午餐", "晚餐",
            "甜點", "蛋糕", "麵包", "烘焙", "鮮奶", "果汁"
        ],
        
        .transport: [
            // 計程車/網約車
            "計程車", "TAXI", "Taxi", "Uber", "小黃",
            "LINE TAXI", "yoxi", "台灣大車隊", "大都會",
            // 大眾運輸
            "捷運", "MRT", "高鐵", "THSR", "台鐵", "火車",
            "客運", "公車", "巴士", "Bus",
            // 其他交通
            "加油站", "中油", "台塑", "停車場", "停車費",
            "租車", "iRent", "GoShare", "WeMo", "YouBike", "機車",
            "機場", "航空", "EVA", "長榮", "華航", "星宇", "虎航"
        ],
        
        .lodging: [
            // 飯店類型
            "飯店", "酒店", "旅館", "民宿", "青年旅館", "背包客棧",
            "Hotel", "Inn", "Hostel", "Resort", "Villa",
            // 連鎖品牌
            "Marriott", "萬豪", "Hilton", "希爾頓", "IHG", "Hyatt", "凱悅",
            "晶華", "寒舍", "老爺", "福華", "圓山", "國賓",
            "Airbnb", "Agoda", "Booking"
        ],
        
        .telecom: [
            // 電信公司
            "電信", "中華電信", "遠傳", "台灣大", "台灣之星", "亞太",
            "Chunghwa", "FETnet", "T-Star",
            // SIM卡/eSIM
            "SIM卡", "eSIM", "網卡", "WiFi", "行動上網",
            // 國際漫遊
            "漫遊", "Roaming"
        ],
        
        .shopping: [
            // 購物中心/百貨
            "百貨", "購物中心", "Mall", "Outlet",
            "SOGO", "新光三越", "遠東", "微風", "誠品",
            // 賣場類型
            "藥妝", "屈臣氏", "康是美", "寶雅", "松本清", "唐吉訶德",
            "Donki", "大創", "DAISO", "無印良品", "MUJI",
            // 一般購物
            "紀念品", "伴手禮", "名產", "土產", "特產",
            "服飾", "服裝", "鞋", "包", "配件"
        ],
        
        .entertainment: [
            // 娛樂場所
            "KTV", "卡拉OK", "電影院", "影城", "威秀", "國賓影城",
            "遊樂園", "樂園", "迪士尼", "環球影城", "USJ",
            // 活動類型
            "演唱會", "音樂會", "表演", "展覽", "展場",
            "SPA", "按摩", "溫泉", "泡湯"
        ],
        
        .attraction: [
            // 景點類型
            "博物館", "美術館", "紀念館", "故宮", "科博館",
            "動物園", "水族館", "植物園",
            // 門票關鍵詞
            "門票", "入場", "入園", "參觀", "Ticket",
            // 知名景點
            "東京鐵塔", "晴空塔", "101", "阿里山", "日月潭"
        ]
    ]
    
    // MARK: - 主要分類方法
    
    /// 根據商家名稱和原始文字推薦分類
    /// - Parameters:
    ///   - storeName: 商家名稱（可選）
    ///   - rawText: 發票原始文字（可選）
    /// - Returns: 分類結果，包含類別、信心度和匹配的關鍵字
    static func classify(storeName: String?, rawText: String?) -> ClassificationResult {
        let combinedText = [storeName, rawText]
            .compactMap { $0 }
            .joined(separator: " ")
            .lowercased()
        
        guard !combinedText.isEmpty else {
            return ClassificationResult(category: .miscellaneous, confidence: 0.0, matchedKeyword: nil)
        }
        
        // 遍歷所有分類尋找匹配
        for (category, keywords) in categoryKeywords {
            for keyword in keywords {
                if combinedText.contains(keyword.lowercased()) {
                    // 計算信心度：關鍵字越長越可信
                    let confidence = min(1.0, Double(keyword.count) / 10.0 + 0.5)
                    return ClassificationResult(
                        category: category,
                        confidence: confidence,
                        matchedKeyword: keyword
                    )
                }
            }
        }
        
        // 無匹配則返回雜支
        return ClassificationResult(category: .miscellaneous, confidence: 0.3, matchedKeyword: nil)
    }
    
    /// 快速分類（僅返回類別）
    static func suggestCategory(storeName: String?, rawText: String?) -> ExpenseCategory {
        return classify(storeName: storeName, rawText: rawText).category
    }
}
