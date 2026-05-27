import SwiftUI
import WidgetKit

// Small (155×155 pt) — USD with all 5 sources, buy & sell columns
struct SmallWidgetView: View {
    let entry: RateEntry

    private var usd: CurrencySnapshot {
        entry.snapshot.currency("USD") ?? entry.snapshot.items[0]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            // Header
            HStack {
                Text(usd.currency)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                Spacer()
                Text("GEL Rates")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.secondary)
            }

            Divider()

            // Column header
            HStack(spacing: 0) {
                Text("SOURCE")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("BUY")
                    .frame(width: 44, alignment: .trailing)
                Text("SELL")
                    .frame(width: 44, alignment: .trailing)
            }
            .font(.system(size: 8, weight: .semibold))
            .foregroundStyle(.secondary)

            // Source rows
            ForEach(usd.sourceRates.sorted) { rate in
                SmallSourceRow(rate: rate)
            }

            Spacer(minLength: 0)

            Text(entry.date, style: .relative)
                .font(.system(size: 8))
                .foregroundStyle(.tertiary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

private struct SmallSourceRow: View {
    let rate: SourceRate

    var body: some View {
        HStack(spacing: 0) {
            Text(rate.source)
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Buy
            Text(rate.formattedBuy)
                .font(.system(size: 9, design: .monospaced).weight(rate.isBestBuy ? .bold : .regular))
                .foregroundStyle(rate.isBestBuy ? .green : .primary)
                .frame(width: 44, alignment: .trailing)

            // Sell (NBG has no sell)
            Text(rate.isNBG ? "ref" : rate.formattedSell)
                .font(.system(size: 9, design: .monospaced).weight(rate.isBestSell ? .bold : .regular))
                .foregroundStyle(rate.isNBG ? Color.secondary.opacity(0.5) : rate.isBestSell ? Color.orange : Color.primary)
                .frame(width: 44, alignment: .trailing)
        }
    }
}
