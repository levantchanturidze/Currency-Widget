import SwiftUI
import WidgetKit

// Medium (322×155 pt) — matrix: sources as rows, currencies as columns, buy rates
struct MediumWidgetView: View {
    let entry: RateEntry

    private let codes = ["USD", "EUR", "GBP"]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 10, weight: .semibold))
                    Text("GEL Exchange Rates")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundStyle(.secondary)
                Spacer()
                Text(entry.date, style: .relative)
                    .font(.system(size: 9))
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: 60, alignment: .trailing)
            }

            Divider()

            // Currency header row
            HStack(spacing: 0) {
                Text("SOURCE")
                    .frame(width: 46, alignment: .leading)
                ForEach(codes, id: \.self) { code in
                    Text(code)
                        .frame(maxWidth: .infinity)
                }
            }
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(.secondary)

            // Source rows (buy rates)
            ForEach(canonicalSourceOrder, id: \.self) { source in
                MediumSourceRow(source: source, codes: codes, snapshot: entry.snapshot)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct MediumSourceRow: View {
    let source: String
    let codes: [String]
    let snapshot: RatesSnapshot

    var body: some View {
        HStack(spacing: 0) {
            // Source label
            Text(source)
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 46, alignment: .leading)

            // Buy rate per currency
            ForEach(codes, id: \.self) { code in
                let rate = snapshot.currency(code)?.sourceRates.first { $0.source == source }
                let isBest = rate?.isBestBuy ?? false
                let isNBG = source == "NBG"

                Text(rate?.formattedBuy ?? "—")
                    .font(.system(size: 10, design: .monospaced).weight(isBest ? .bold : .regular))
                    .foregroundStyle(isNBG ? Color.secondary : isBest ? Color.green : Color.primary)
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .topTrailing) {
                        if isBest {
                            Image(systemName: "star.fill")
                                .font(.system(size: 5))
                                .foregroundStyle(.green)
                                .offset(x: 1, y: -1)
                        }
                    }
            }
        }
    }
}
