//
//  ReceiptScannerView.swift
//  TravelReceipt
//
//  相機掃描視圖 - 使用 VisionKit 掃描發票
//

import SwiftUI
import VisionKit
import Vision

struct ReceiptScannerView: UIViewControllerRepresentable {
    typealias Completion = (ScanResult) -> Void
    let onComplete: Completion
    let onCancel: () -> Void
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let vc = VNDocumentCameraViewController()
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete, onCancel: onCancel)
    }
    
    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let onComplete: Completion
        let onCancel: () -> Void
        
        init(onComplete: @escaping Completion, onCancel: @escaping () -> Void) {
            self.onComplete = onComplete
            self.onCancel = onCancel
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            guard scan.pageCount > 0 else {
                controller.dismiss(animated: true) { self.onCancel() }
                return
            }
            
            // 取第一頁影像進行 OCR
            let image = scan.imageOfPage(at: 0)
            performOCR(image: image) { result in
                controller.dismiss(animated: true) { self.onComplete(result) }
            }
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true) { self.onCancel() }
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("❌ 掃描失敗: \(error)")
            controller.dismiss(animated: true) { self.onCancel() }
        }
        
        // MARK: - OCR 處理
        private func performOCR(image: UIImage, completion: @escaping (ScanResult) -> Void) {
            guard let cgImage = image.cgImage else {
                completion(ScanResult())
                return
            }
            
            let request = VNRecognizeTextRequest { req, error in
                var scanResult = ScanResult()
                
                guard let observations = req.results as? [VNRecognizedTextObservation] else {
                    completion(scanResult)
                    return
                }
                
                // 收集辨識文字
                let lines: [String] = observations.compactMap { $0.topCandidates(1).first?.string }
                let rawText = lines.joined(separator: "\n")
                
                // 使用統一的 ReceiptTextParser 解析
                let parsed = ReceiptTextParser.parse(rawText: rawText)
                
                scanResult.date = parsed.date
                scanResult.amount = parsed.totalAmount
                scanResult.merchantName = parsed.merchantName
                scanResult.rawText = rawText
                scanResult.items = parsed.items
                
                completion(scanResult)
            }
            
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = ["zh-Hant", "zh-Hans", "en-US"]
            request.customWords = ["發票", "統編", "金額", "總計", "收據", "公司", "店名", "小計", "付款"]
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    print("❌ OCR 錯誤: \(error)")
                    DispatchQueue.main.async {
                        completion(ScanResult())
                    }
                }
            }
        }
    }
}

#Preview {
    ReceiptScannerView(
        onComplete: { result in
            print("掃描完成: \(result)")
        },
        onCancel: {
            print("取消掃描")
        }
    )
}
