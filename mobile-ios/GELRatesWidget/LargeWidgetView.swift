import SwiftUI
import WidgetKit

// Large (322×345 pt) — all 3 currencies with source labels and NBG reference
struct LargeWidgetView: View {
    let entry: RateEntry

    private let codes = ["USD", "EUR", "GBP"]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(alignment: .lastTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Georgian Exchange Rates")
                        .font(.system(size: 14, weight: .bold))
                    Text("Best buy & sell vs. GEL")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Updated")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                    Text(entry.date, style: .relative)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: 72, alignment: .trailing)
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider().padding(.horizontal, 14)

            // Currency sections
            ForEach(Array(codes.enumerated()), id: \.element) { idx, code in
                if let snap = entry.snapshot.currency(code) {
                    LargeCurrencySection(snapshot: snap)
                    if idx < codes.count - 1 {
                        Divider().padding(.horizontal, 14)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct LargeCurrencySection: View {
    let snapshot: CurrencySnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Row 1: currency code + NBG badge
            HStack {
                Text(snapshot.currency)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Spacer()
                if let nbg = snapshot.nbgRate {
                    HStack(spacing: 3) {
                        Text("NBG")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Text(String(format: "%.3f", nbg))
                            .font(.system(size: 10, design: .monospaced).weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
                }
            }

            // Row 2: buy and sell cards side by side
            HStack(spacing: 12) {
                LargeRateCard(
                    label: "Best Buy",
                    value: snapshot.formattedBuy,
                    source: snapshot.bestBuySource ?? "—",
                    color: .green,
                    icon: "arrow.up.circle.fill"
                )
                LargeRateCard(
                    label: "Best Sell",
                    value: snapshot.formattedSell,
                    source: snapshot.bestSellSource ?? "—",
                    color: .orange,
                    icon: "arrow.down.circle.fill"
                )
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

private struct LargeRateCard: View {
    let label: String
    let value: String
    let source: String
    let color: Color
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.system(size: 18, design: .monospaced).weight(.bold))
                    .foregroundStyle(color)
                Text(source)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
