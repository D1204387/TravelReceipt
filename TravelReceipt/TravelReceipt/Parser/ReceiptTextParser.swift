//
//  ReceiptTextParser.swift
//  TravelReceipt
//
//  統一的發票文字解析器
//

import Foundation

// MARK: - 解析結果
struct ParseResult {
    var date: Date?
    var totalAmount: Decimal?
    var merchantName: String?
    var items: [ParsedItem] = []
    var currencyCode: String = "TWD"
    var rawText: String = ""
}

// MARK: - 發票文字解析器
struct ReceiptTextParser {
    
    /// 主要解析入口
    static func parse(rawText: String) -> ParseResult {
        var result = ParseResult()
        result.rawText = rawText
        
        let lines = rawText.components(separatedBy: .newlines)
        
        // 1. 解析商家名稱
        result.merchantName = parseStoreName(from: lines)
        
        // 2. 解析日期
        result.date = parseDate(from: rawText)
        
        // 3. 解析金額
        result.totalAmount = parseAmount(from: rawText)
        
        return result
    }
    
    // MARK: - 解析金額
    static func parseAmount(from text: String) -> Decimal? {
        // 🔴 第一層：嚴格匹配特定關鍵詞
        let strictPatterns = [
            #"車資[（(]Total[，,]\s*\$\s*[）)]\s*[：:]\s*[\n\r]*\s*(\d+)"#,
            #"跳表金額[（(]Fare[，,]\s*\$\s*[）)]\s*[：:]\s*[\n\r]*\s*(\d+)"#,
        ]
        
        for pattern in strictPatterns {
            if let amount = matchFirstAmount(pattern: pattern, in: text, min: 50, max: 10000) {
                return Decimal(amount)
            }
        }
        
        // 🟡 第二層：通用關鍵詞匹配
        let generalPatterns = [
            #"總[計額]\s*[:：]?\s*\$?\s*([\d,]+\.?\d*)"#,
            #"合\s*計\s*[:：]?\s*\$?\s*([\d,]+\.?\d*)"#,
            #"金\s*額\s*[:：]?\s*\$?\s*([\d,]+\.?\d*)"#,
            #"實付\s*[:：]?\s*\$?\s*([\d,]+\.?\d*)"#,
            #"應付\s*[:：]?\s*\$?\s*([\d,]+\.?\d*)"#,
            #"小\s*計\s*[:：]?\s*\$?\s*([\d,]+\.?\d*)"#,
            #"NT\$?\s*([\d,]+\.?\d*)"#,
            #"TWD\s*([\d,]+\.?\d*)"#,
            #"\$\s*([\d,]+\.?\d*)"#,
            #"([\d,]+)\s*元"#,
        ]
        
        for pattern in generalPatterns {
            if let amount = matchFirstAmount(pattern: pattern, in: text, min: 10, max: 100000) {
                return Decimal(amount)
            }
        }
        
        // 🟢 第三層：寬泛匹配（找所有數字取最合理的）
        return findLargestReasonableAmount(in: text)
    }
    
    // MARK: - 解析日期
    static func parseDate(from text: String) -> Date? {
        let patterns: [(pattern: String, handler: ([Int]) -> DateComponents?)] = [
            // yyyy-MM-dd 或 yyyy/MM/dd
            (#"(\d{4})[/\-.](d{1,2})[/\-.](d{1,2})"#, { comps in
                guard comps.count == 3 else { return nil }
                return DateComponents(year: comps[0], month: comps[1], day: comps[2])
            }),
            // 民國年 yyy/MM/dd
            (#"(\d{3})[/\-.](d{1,2})[/\-.](d{1,2})"#, { comps in
                guard comps.count == 3 else { return nil }
                return DateComponents(year: comps[0] + 1911, month: comps[1], day: comps[2])
            }),
        ]
        
        for (pattern, handler) in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let range = NSRange(text.startIndex..., in: text)
                if let match = regex.firstMatch(in: text, range: range) {
                    var components: [Int] = []
                    for i in 1...3 {
                        if let r = Range(match.range(at: i), in: text),
                           let num = Int(text[r]) {
                            components.append(num)
                        }
                    }
                    if let dateComps = handler(components),
                       let date = Calendar.current.date(from: dateComps) {
                        return date
                    }
                }
            }
        }
        
        return nil
    }
    
    // MARK: - 解析商家名稱
    static func parseStoreName(from lines: [String]) -> String? {
        let excludeKeywords = [
            "統一編號", "發票", "日期", "時間", "金額", "總計",
            "合計", "小計", "找零", "現金", "信用卡", "收據"
        ]
        
        let filtered = lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // 長度檢查
            guard trimmed.count >= 2 && trimmed.count <= 30 else { return false }
            
            // 排除關鍵詞
            for keyword in excludeKeywords {
                if trimmed.contains(keyword) { return false }
            }
            
            // 排除純數字
            if trimmed.allSatisfy({ $0.isNumber || $0 == "." || $0 == "," || $0 == "-" }) {
                return false
            }
            
            return true
        }
        
        return filtered.first?.trimmingCharacters(in: .whitespaces)
    }
    
    // MARK: - Helper Functions
    
    private static func matchFirstAmount(pattern: String, in text: String, min: Double, max: Double) -> Double? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }
        
        let range = NSRange(text.startIndex..., in: text)
        if let match = regex.firstMatch(in: text, range: range),
           let amountRange = Range(match.range(at: 1), in: text) {
            let amountStr = String(text[amountRange]).replacingOccurrences(of: ",", with: "")
            if let amount = Double(amountStr), amount > min && amount < max {
                return amount
            }
        }
        return nil
    }
    
    private static func findLargestReasonableAmount(in text: String) -> Decimal? {
        let pattern = #"([\d,]+\.?\d*)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return nil
        }
        
        let range = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, options: [], range: range)
        
        var amounts: [Double] = []
        for match in matches {
            if let numRange = Range(match.range(at: 1), in: text) {
                let numStr = String(text[numRange]).replacingOccurrences(of: ",", with: "")
                if let num = Double(numStr), num > 10 && num < 100000 {
                    amounts.append(num)
                }
            }
        }
        
        // 返回最大值（通常是總額）
        if let maxAmount = amounts.max() {
            return Decimal(maxAmount)
        }
        return nil
    }
}
