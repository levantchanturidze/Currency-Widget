import SwiftUI
import WidgetKit

// Large (322×345 pt) — full table: sources × currencies, both buy and sell
struct LargeWidgetView: View {
    let entry: RateEntry

    private let codes = ["USD", "EUR", "GBP"]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Georgian Exchange Rates")
                        .font(.system(size: 13, weight: .bold))
                    Text("GEL · All sources · Buy & Sell")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 1) {
                    Text("Updated")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                    Text(entry.date, style: .relative)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: 60, alignment: .trailing)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 8)

            Divider().padding(.horizontal, 12)

            // Column header: SOURCE | USD Buy Sell | EUR Buy Sell | GBP Buy Sell
            LargeHeaderRow(codes: codes)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)

            Divider().padding(.horizontal, 12)

            // Source rows
            ForEach(Array(canonicalSourceOrder.enumerated()), id: \.element) { idx, source in
                LargeSourceRow(source: source, codes: codes, snapshot: entry.snapshot)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(idx % 2 == 0 ? Color(.systemGray6).opacity(0.4) : Color.clear)
            }

            Spacer(minLength: 0)

            // Legend
            HStack(spacing: 12) {
                Label("Best buy", systemImage: "arrow.up.circle.fill")
                    .foregroundStyle(.green)
                Label("Best sell", systemImage: "arrow.down.circle.fill")
                    .foregroundStyle(.orange)
                Spacer()
                Text("NBG = reference rate")
                    .foregroundStyle(.tertiary)
            }
            .font(.system(size: 8))
            .padding(.horizontal, 12)
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Header row

private struct LargeHeaderRow: View {
    let codes: [String]

    var body: some View {
        HStack(spacing: 0) {
            Text("SOURCE")
                .frame(width: 42, alignment: .leading)
            ForEach(codes, id: \.self) { code in
                VStack(spacing: 0) {
                    Text(code)
                        .font(.system(size: 10, weight: .bold))
                    HStack(spacing: 0) {
                        Text("Buy")
                            .frame(maxWidth: .infinity)
                        Text("Sell")
                            .frame(maxWidth: .infinity)
                    }
                    .font(.system(size: 8))
                    .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .font(.system(size: 9, weight: .semibold))
        .foregroundStyle(.secondary)
    }
}

// MARK: - Currency cell

private struct LargeCurrencyCell: View {
    let rate: SourceRate?
    let isNBG: Bool

    var body: some View {
        HStack(spacing: 0) {
            Text(rate?.formattedBuy ?? "—")
                .font(.system(size: 9, design: .monospaced).weight(rate?.isBestBuy == true ? .bold : .regular))
                .foregroundStyle(isNBG ? Color.secondary : rate?.isBestBuy == true ? Color.green : Color.primary)
                .frame(maxWidth: .infinity)

            Text(isNBG ? "ref" : (rate?.formattedSell ?? "—"))
                .font(.system(size: 9, design: .monospaced).weight(rate?.isBestSell == true ? .bold : .regular))
                .foregroundStyle(isNBG ? Color.secondary.opacity(0.5) : rate?.isBestSell == true ? Color.orange : Color.primary)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Source row

private struct LargeSourceRow: View {
    let source: String
    let codes: [String]
    let snapshot: RatesSnapshot

    var body: some View {
        HStack(spacing: 0) {
            // Source label
            Text(source)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 42, alignment: .leading)

            // Buy + Sell per currency
            ForEach(codes, id: \.self) { code in
                LargeCurrencyCell(
                    rate: snapshot.currency(code)?.sourceRates.first { $0.source == source },
                    isNBG: source == "NBG"
                )
            }
        }
    }
}
