//
//  LegalView.swift
//  TravelReceipt
//
//  隱私政策與使用條款頁面
//

import SwiftUI

// MARK: - 隱私政策頁面
struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("最後更新：2025 年 1 月")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Group {
                    SectionHeader(title: "資料收集")
                    Text("""
                    TravelReceipt 僅在您的裝置上儲存以下資料：
                    • 行程資訊（名稱、日期、目的地）
                    • 支出記錄（金額、分類、商家名稱）
                    • 收據照片（儲存於本機）
                    
                    我們不會收集您的個人身份資訊。
                    """)
                }
                
                Group {
                    SectionHeader(title: "iCloud 同步")
                    Text("""
                    如果您啟用 iCloud 同步功能，您的資料將透過 Apple 的 iCloud 服務在您的裝置間同步。此資料受 Apple 隱私政策保護。
                    
                    您可以隨時在設定中關閉 iCloud 同步。
                    """)
                }
                
                Group {
                    SectionHeader(title: "相機與相簿")
                    Text("""
                    本 App 會請求存取您的相機和相簿權限，僅用於：
                    • 拍攝收據照片
                    • 選擇已有的收據圖片
                    
                    這些照片僅儲存在您的裝置和 iCloud（若啟用）中。
                    """)
                }
                
                Group {
                    SectionHeader(title: "OCR 文字辨識")
                    Text("""
                    本 App 使用 iOS 內建的 Vision 框架進行文字辨識，所有處理均在您的裝置上本地完成，不會將圖片傳送至外部伺服器。
                    """)
                }
                
                Group {
                    SectionHeader(title: "第三方服務")
                    Text("""
                    本 App 不包含任何第三方追蹤或分析工具。我們不會與任何第三方分享您的資料。
                    """)
                }
                
                Group {
                    SectionHeader(title: "聯絡我們")
                    Text("""
                    如有任何隱私相關問題，請聯繫：
                    travelreceipt.app@gmail.com
                    """)
                }
            }
            .padding()
        }
        .navigationTitle("隱私政策")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 使用條款頁面
struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("最後更新：2025 年 1 月")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Group {
                    SectionHeader(title: "服務說明")
                    Text("""
                    TravelReceipt 是一款旅遊記帳應用程式，協助您記錄旅途中的支出。本服務按「現況」提供，不提供任何明示或暗示的保證。
                    """)
                }
                
                Group {
                    SectionHeader(title: "使用者責任")
                    Text("""
                    • 您應確保輸入的資料正確無誤
                    • 您應定期備份重要資料
                    • 您不得將本 App 用於任何非法用途
                    """)
                }
                
                Group {
                    SectionHeader(title: "資料準確性")
                    Text("""
                    OCR 文字辨識功能可能無法 100% 準確辨識所有發票內容。請在儲存前確認辨識結果是否正確。
                    
                    匯率換算功能使用您手動設定的匯率，不代表實際市場匯率。
                    """)
                }
                
                Group {
                    SectionHeader(title: "免責聲明")
                    Text("""
                    • 我們不對資料遺失或損壞負責
                    • 我們不對因使用本 App 造成的任何損失負責
                    • 我們保留隨時修改服務條款的權利
                    """)
                }
                
                Group {
                    SectionHeader(title: "智慧財產權")
                    Text("""
                    TravelReceipt 及其相關標誌、設計為本開發者所有。未經許可不得複製或修改。
                    """)
                }
                
                Group {
                    SectionHeader(title: "條款變更")
                    Text("""
                    我們可能會不定期更新這些條款。繼續使用本 App 即表示您同意更新後的條款。
                    """)
                }
            }
            .padding()
        }
        .navigationTitle("使用條款")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 關於頁面
struct AboutView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "airplane.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.blue)
                        
                        Text("TravelReceipt")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("旅行記帳")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text("版本 1.0.0")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
            }
            
            Section("開發資訊") {
                LabeledContent("開發者", value: "YiJou Chen")
                LabeledContent("聯絡信箱", value: "travelreceipt.app@gmail.com")
            }
            
            Section("法律資訊") {
                NavigationLink {
                    PrivacyPolicyView()
                } label: {
                    Label("隱私政策", systemImage: "hand.raised")
                }
                
                NavigationLink {
                    TermsOfServiceView()
                } label: {
                    Label("使用條款", systemImage: "doc.text")
                }
            }
            
            Section {
                HStack {
                    Spacer()
                    Text("Made with ❤️ in Taiwan")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
        }
        .navigationTitle("關於")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Helper Components
private struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(.primary)
    }
}

// MARK: - Previews
#Preview("隱私政策") {
    NavigationStack {
        PrivacyPolicyView()
    }
}

#Preview("使用條款") {
    NavigationStack {
        TermsOfServiceView()
    }
}

#Preview("關於") {
    NavigationStack {
        AboutView()
    }
}
