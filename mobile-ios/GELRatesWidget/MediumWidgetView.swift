import SwiftUI
import WidgetKit

// Medium (322×155 pt) — all 3 currencies side by side
struct MediumWidgetView: View {
    let entry: RateEntry

    private let codes = ["USD", "EUR", "GBP"]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 11, weight: .semibold))
                    Text("GEL Exchange Rates")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(.secondary)

                Spacer()

                // Auto-updating relative timestamp
                Text(entry.date, style: .relative)
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: 70, alignment: .trailing)
            }

            Divider()

            // Three columns
            HStack(spacing: 0) {
                ForEach(Array(codes.enumerated()), id: \.element) { idx, code in
                    if let snap = entry.snapshot.currency(code) {
                        MediumCurrencyColumn(snapshot: snap)
                    }
                    if idx < codes.count - 1 {
                        Divider().padding(.vertical, 2)
                    }
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct MediumCurrencyColumn: View {
    let snapshot: CurrencySnapshot

    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            Text(snapshot.currency)
                .font(.system(size: 20, weight: .bold, design: .rounded))

            VStack(alignment: .leading, spacing: 4) {
                MediumRateRow(
                    icon: "arrow.up",
                    value: snapshot.formattedBuy,
                    source: snapshot.bestBuySource ?? "",
                    color: .green
                )
                MediumRateRow(
                    icon: "arrow.down",
                    value: snapshot.formattedSell,
                    source: snapshot.bestSellSource ?? "",
                    color: .orange
                )
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct MediumRateRow: View {
    let icon: String
    let value: String
    let source: String
    let color: Color

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 13, design: .monospaced).weight(.semibold))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
