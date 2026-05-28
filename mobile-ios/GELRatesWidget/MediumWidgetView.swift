import SwiftUI
import WidgetKit

// Medium (322×155 pt) — USD & EUR with buy AND sell per source
struct MediumWidgetView: View {
    let entry: RateEntry
    private let codes = ["USD", "EUR"]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Header ──────────────────────────────────────────────────
            WidgetHeaderView(
                title: "GEL Exchange Rates",
                date: entry.date,
                subtitle: "USD · EUR  ·  Buy & Sell"
            )
            .padding(.bottom, 5)

            ThinDivider()
                .padding(.bottom, 4)

            // ── Column header ────────────────────────────────────────────
            HStack(spacing: 0) {
                Text("SOURCE")
                    .frame(width: 46, alignment: .leading)

                ForEach(codes, id: \.self) { code in
                    VStack(spacing: 1) {
                        Text(code)
                            .font(.system(size: 9, weight: .bold))
                        HStack(spacing: 0) {
                            Text("↑ Buy")
                                .foregroundStyle(WT.buy.opacity(0.8))
                                .frame(maxWidth: .infinity)
                            Text("↓ Sell")
                                .foregroundStyle(WT.sell.opacity(0.8))
                                .frame(maxWidth: .infinity)
                        }
                        .font(.system(size: 7, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
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

    var accentColor: Color? {
        let rates = codes.compactMap { snapshot.currency($0)?.sourceRates.first { $0.source == source } }
        if rates.contains(where: { $0.isBestBuy  }) { return WT.buy  }
        if rates.contains(where: { $0.isBestSell }) { return WT.sell }
        return nil
    }

    var body: some View {
        HStack(spacing: 0) {
            SourceTag(name: source, width: 46, accent: accentColor, size: 8)

            ForEach(codes, id: \.self) { code in
                MediumPair(
                    rate: snapshot.currency(code)?.sourceRates.first { $0.source == source },
                    isNBG: source == "NBG"
                )
            }
        }
    }
}

private struct MediumPair: View {
    let rate: SourceRate?
    let isNBG: Bool

    var body: some View {
        HStack(spacing: 0) {
            // Buy
            HStack {
                Spacer(minLength: 0)
                RateChip(
                    text:   rate?.formattedBuy ?? "—",
                    isBest: rate?.isBestBuy == true,
                    isRef:  isNBG,
                    isBuy:  true
                )
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)

            // Sell
            HStack {
                Spacer(minLength: 0)
                RateChip(
                    text:   isNBG ? "ref" : (rate?.formattedSell ?? "—"),
                    isBest: !isNBG && rate?.isBestSell == true,
                    isRef:  isNBG,
                    isBuy:  false
                )
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}
