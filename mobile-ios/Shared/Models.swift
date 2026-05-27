import Foundation

// MARK: - Backend API Response

struct ExchangeRate: Codable, Identifiable {
    var id: String { "\(source)-\(currency)" }
    let source: String
    let currency: String
    let buy: Double?
    let sell: Double?
    let timestamp: String
    let isBestBuy: Bool
    let isBestSell: Bool
}

struct APIResponse: Codable {
    let currencies: [String]
    let sources: [String]
    let rates: [ExchangeRate]
    let lastUpdated: String
    let fromCache: Bool
}

// MARK: - Widget Data

struct SourceRate: Codable, Identifiable {
    var id: String { source }
    let source: String
    let buy: Double?
    let sell: Double?
    let isBestBuy: Bool
    let isBestSell: Bool

    var isNBG: Bool { source == "NBG" }
    var formattedBuy: String  { buy.map  { String(format: "%.4f", $0) } ?? "—" }
    var formattedSell: String { sell.map { String(format: "%.4f", $0) } ?? "—" }
}

struct CurrencySnapshot: Codable {
    let currency: String
    let sourceRates: [SourceRate]   // all 5 sources in canonical order
    let bestBuy: Double?
    let bestBuySource: String?
    let bestSell: Double?
    let bestSellSource: String?

    var nbgRate: Double? { sourceRates.first { $0.source == "NBG" }?.buy }
    var formattedBuy: String  { bestBuy.map  { String(format: "%.4f", $0) } ?? "—" }
    var formattedSell: String { bestSell.map { String(format: "%.4f", $0) } ?? "—" }
    var formattedNBG: String  { nbgRate.map  { String(format: "%.4f", $0) } ?? "—" }
}

struct RatesSnapshot: Codable {
    let items: [CurrencySnapshot]
    let fetchedAt: Date

    func currency(_ code: String) -> CurrencySnapshot? {
        items.first { $0.currency == code }
    }

    static var placeholder: RatesSnapshot {
        func src(_ s: String, buy: Double?, sell: Double?, bestBuy: Bool = false, bestSell: Bool = false) -> SourceRate {
            SourceRate(source: s, buy: buy, sell: sell, isBestBuy: bestBuy, isBestSell: bestSell)
        }
        return RatesSnapshot(
            items: [
                CurrencySnapshot(currency: "USD",
                    sourceRates: [
                        src("NBG",   buy: 2.700, sell: nil),
                        src("TBC",   buy: 2.685, sell: 2.705, bestBuy: true),
                        src("BOG",   buy: 2.680, sell: 2.710, bestSell: true),
                        src("RICO",  buy: 2.690, sell: 2.708),
                        src("KURSI", buy: 2.682, sell: 2.706),
                    ],
                    bestBuy: 2.685, bestBuySource: "TBC",
                    bestSell: 2.705, bestSellSource: "BOG"),
                CurrencySnapshot(currency: "EUR",
                    sourceRates: [
                        src("NBG",   buy: 2.936, sell: nil),
                        src("TBC",   buy: 2.920, sell: 2.948, bestSell: true),
                        src("BOG",   buy: 2.915, sell: 2.950),
                        src("RICO",  buy: 2.925, sell: 2.945, bestBuy: true),
                        src("KURSI", buy: 2.918, sell: 2.946),
                    ],
                    bestBuy: 2.925, bestBuySource: "RICO",
                    bestSell: 2.945, bestSellSource: "TBC"),
                CurrencySnapshot(currency: "GBP",
                    sourceRates: [
                        src("NBG",   buy: 3.400, sell: nil),
                        src("TBC",   buy: 3.380, sell: 3.415, bestBuy: true),
                        src("BOG",   buy: 3.375, sell: 3.420),
                        src("RICO",  buy: 3.385, sell: 3.412, bestSell: true),
                        src("KURSI", buy: 3.378, sell: 3.413),
                    ],
                    bestBuy: 3.380, bestBuySource: "TBC",
                    bestSell: 3.412, bestSellSource: "RICO"),
            ],
            fetchedAt: Date()
        )
    }
}

// MARK: - Helpers

let canonicalSourceOrder = ["NBG", "TBC", "BOG", "RICO", "KURSI"]

extension Array where Element == SourceRate {
    var sorted: [SourceRate] {
        sorted { (canonicalSourceOrder.firstIndex(of: $0.source) ?? 99) < (canonicalSourceOrder.firstIndex(of: $1.source) ?? 99) }
    }
}
