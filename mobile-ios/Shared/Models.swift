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

struct CurrencySnapshot: Codable {
    let currency: String
    let bestBuy: Double?
    let bestBuySource: String?
    let bestSell: Double?
    let bestSellSource: String?
    let nbgRate: Double?

    var formattedBuy: String  { bestBuy.map  { String(format: "%.3f", $0) } ?? "—" }
    var formattedSell: String { bestSell.map { String(format: "%.3f", $0) } ?? "—" }
    var formattedNBG: String  { nbgRate.map  { String(format: "%.3f", $0) } ?? "—" }
}

struct RatesSnapshot: Codable {
    let items: [CurrencySnapshot]
    let fetchedAt: Date

    func currency(_ code: String) -> CurrencySnapshot? {
        items.first { $0.currency == code }
    }

    static var placeholder: RatesSnapshot {
        RatesSnapshot(
            items: [
                CurrencySnapshot(currency: "USD", bestBuy: 2.685, bestBuySource: "BOG",  bestSell: 2.705, bestSellSource: "TBC",   nbgRate: 2.700),
                CurrencySnapshot(currency: "EUR", bestBuy: 2.920, bestBuySource: "RICO", bestSell: 2.948, bestSellSource: "TBC",   nbgRate: 2.936),
                CurrencySnapshot(currency: "GBP", bestBuy: 3.380, bestBuySource: "BOG",  bestSell: 3.415, bestSellSource: "KURSI", nbgRate: 3.400),
            ],
            fetchedAt: Date()
        )
    }
}
