import SwiftUI
import WidgetKit

// Small (155×155 pt) — shows USD with buy / sell / NBG
struct SmallWidgetView: View {
    let entry: RateEntry

    private var usd: CurrencySnapshot {
        entry.snapshot.currency("USD") ?? entry.snapshot.items[0]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 4) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 10, weight: .semibold))
                Text("GEL Rates")
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundStyle(.secondary)

            Spacer()

            // Currency code
            Text(usd.currency)
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.7)

            Spacer()

            // Buy / Sell
            VStack(alignment: .leading, spacing: 5) {
                SmallRateRow(arrow: "arrow.up.circle.fill",   value: usd.formattedBuy,  color: .green)
                SmallRateRow(arrow: "arrow.down.circle.fill", value: usd.formattedSell, color: .orange)
            }

            Spacer()

            // NBG reference
            if let nbg = usd.nbgRate {
                Text("NBG \(String(format: "%.3f", nbg))")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

private struct SmallRateRow: View {
    let arrow: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: arrow)
                .font(.system(size: 12))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 15, design: .monospaced).weight(.semibold))
                .foregroundStyle(color)
        }
    }
}
