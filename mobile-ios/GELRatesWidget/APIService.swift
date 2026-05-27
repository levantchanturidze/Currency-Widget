import Foundation

enum APIError: LocalizedError {
    case badURL
    case network(Error)
    case badStatus(Int)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .badURL:           return "Invalid backend URL"
        case .network(let e):   return "Network: \(e.localizedDescription)"
        case .badStatus(let c): return "Server returned \(c)"
        case .decoding:         return "Failed to parse response"
        }
    }
}

actor RatesAPI {
    static let shared = RatesAPI()

    private let backendURL = "https://currency-widget-qtso.onrender.com"
    private let targetCurrencies = ["USD", "EUR", "GBP"]

    func fetchSnapshot() async throws -> RatesSnapshot {
        guard let url = URL(string: "\(backendURL)/api/rates") else {
            throw APIError.badURL
        }

        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 10
        let session = URLSession(configuration: config)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw APIError.network(error)
        }

        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw APIError.badStatus(http.statusCode)
        }

        do {
            return transform(try JSONDecoder().decode(APIResponse.self, from: data))
        } catch {
            throw APIError.decoding(error)
        }
    }

    private func transform(_ response: APIResponse) -> RatesSnapshot {
        let items = targetCurrencies.map { code -> CurrencySnapshot in
            let rates    = response.rates.filter { $0.currency == code }
            let bestBuy  = rates.first { $0.isBestBuy }
            let bestSell = rates.first { $0.isBestSell }

            let sourceRates = rates.map { r in
                SourceRate(
                    source:     r.source,
                    buy:        r.buy,
                    sell:       r.sell,
                    isBestBuy:  r.isBestBuy,
                    isBestSell: r.isBestSell
                )
            }

            return CurrencySnapshot(
                currency:       code,
                sourceRates:    sourceRates.sorted,
                bestBuy:        bestBuy?.buy,
                bestBuySource:  bestBuy?.source,
                bestSell:       bestSell?.sell,
                bestSellSource: bestSell?.source
            )
        }

        return RatesSnapshot(items: items, fetchedAt: Date())
    }
}
