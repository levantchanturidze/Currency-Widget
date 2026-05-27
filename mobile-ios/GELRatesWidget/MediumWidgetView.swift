import SwiftUI
import WidgetKit

// Medium (322×155 pt) — buy-rate matrix: sources as rows, currencies as columns
struct MediumWidgetView: View {
    let entry: RateEntry
    private let codes = ["USD", "EUR", "GBP"]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Header ──────────────────────────────────────────────────
            WidgetHeaderView(
                title: "GEL Exchange Rates",
                date: entry.date,
                subtitle: "Best buy ↑ highlighted green"
            )
            .padding(.bottom, 6)

            ThinDivider()
                .padding(.bottom, 5)

            // ── Currency column headers ──────────────────────────────────
            HStack(spacing: 0) {
                Text("SOURCE")
                    .frame(width: 46, alignment: .leading)
                ForEach(codes, id: \.self) { code in
                    Text(code)
                        .frame(maxWidth: .infinity)
                }
            }
            .font(.system(size: 8, weight: .bold))
            .foregroundStyle(.secondary)
            .padding(.bottom, 4)

            // ── Source rows ──────────────────────────────────────────────
            VStack(spacing: 3) {
                ForEach(canonicalSourceOrder, id: \.self) { source in
                    MediumRow(source: source, codes: codes, snapshot: entry.snapshot)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct MediumRow: View {
    let source: String
    let codes: [String]
    let snapshot: RatesSnapshot

    var body: some View {
        HStack(spacing: 0) {
            SourceTag(name: source, width: 46, size: 9)

            ForEach(codes, id: \.self) { code in
                MediumCell(
                    rate: snapshot.currency(code)?.sourceRates.first { $0.source == source },
                    isNBG: source == "NBG"
                )
            }
        }
    }
}

private struct MediumCell: View {
    let rate: SourceRate?
    let isNBG: Bool

    var body: some View {
        HStack {
            Spacer(minLength: 0)
            RateChip(
                text:   isNBG ? (rate?.formattedBuy ?? "—") : (rate?.formattedBuy ?? "—"),
                isBest: rate?.isBestBuy == true,
                isRef:  isNBG,
                isBuy:  true
            )
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
    }
}
