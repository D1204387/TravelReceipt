//
//  OCRService.swift
//  TravelReceipt
//
//  OCR 服務 - 使用 Vision 框架辨識圖片文字
//

import Foundation
import Vision
import UIKit

// MARK: - OCR 結果
struct OCRResult {
    var amount: Double?
    var date: Date?
    var storeName: String?
    var rawText: String
    var items: [ParsedItem] = []
    
    init(rawText: String = "") {
        self.rawText = rawText
    }
    
    /// 從 ParseResult 轉換
    init(from parseResult: ParseResult) {
        self.amount = parseResult.totalAmount.map { NSDecimalNumber(decimal: $0).doubleValue }
        self.date = parseResult.date
        self.storeName = parseResult.merchantName
        self.rawText = parseResult.rawText
        self.items = parseResult.items
    }
}

// MARK: - OCR 服務
class OCRService {
    
    /// 從圖片辨識文字並解析
    static func recognizeText(from image: UIImage, completion: @escaping (OCRResult) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(OCRResult())
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                DispatchQueue.main.async {
                    completion(OCRResult())
                }
                return
            }
            
            // 收集所有辨識到的文字（按 Y 座標排序）
            var allTexts: [(text: String, y: CGFloat)] = []
            
            for observation in observations {
                if let topCandidate = observation.topCandidates(1).first {
                    allTexts.append((topCandidate.string, observation.boundingBox.origin.y))
                }
            }
            
            // 按 Y 座標排序（Vision 座標是從下往上，所以要反轉）
            allTexts.sort { $0.y > $1.y }
            
            let rawText = allTexts.map { $0.text }.joined(separator: "\n")
            
            // 使用統一的 ReceiptTextParser 解析
            let parseResult = ReceiptTextParser.parse(rawText: rawText)
            let ocrResult = OCRResult(from: parseResult)
            
            DispatchQueue.main.async {
                completion(ocrResult)
            }
        }
        
        // 設定辨識語言
        request.recognitionLanguages = ["zh-Hant", "zh-Hans", "en-US"]
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("❌ OCR 錯誤: \(error)")
                DispatchQueue.main.async {
                    completion(OCRResult())
                }
            }
        }
    }
}
