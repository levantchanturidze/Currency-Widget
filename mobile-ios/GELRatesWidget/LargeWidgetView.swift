import SwiftUI
import WidgetKit

// Large (322×345 pt) — full comparison table: 5 sources × 3 currencies × buy + sell
struct LargeWidgetView: View {
    let entry: RateEntry
    private let codes = ["USD", "EUR", "GBP"]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Header ──────────────────────────────────────────────────
            WidgetHeaderView(
                title: "Georgian Exchange Rates",
                date: entry.date,
                subtitle: "USD · EUR · GBP  ·  All 5 sources"
            )
            .padding(.horizontal, 14)
            .padding(.top, 13)
            .padding(.bottom, 9)

            ThinDivider().padding(.horizontal, 14)

            // ── Column header ────────────────────────────────────────────
            LargeColumnHeader(codes: codes)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)

            ThinDivider().padding(.horizontal, 14)

            // ── Source rows ──────────────────────────────────────────────
            ForEach(Array(canonicalSourceOrder.enumerated()), id: \.element) { idx, source in
                LargeSourceRow(source: source, codes: codes, snapshot: entry.snapshot)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(
                        idx % 2 == 0
                            ? Color(.systemGray6).opacity(0.5)
                            : Color.clear
                    )
            }

            Spacer(minLength: 0)

            // ── Legend ───────────────────────────────────────────────────
            ThinDivider(opacity: 0.1).padding(.horizontal, 14)
            HStack(spacing: 10) {
                HStack(spacing: 3) {
                    Circle().fill(WT.buy).frame(width: 5, height: 5)
                    Text("Best buy")
                }
                HStack(spacing: 3) {
                    Circle().fill(WT.sell).frame(width: 5, height: 5)
                    Text("Best sell")
                }
                Spacer()
                HStack(spacing: 3) {
                    Circle().fill(WT.ref).frame(width: 5, height: 5)
                    Text("NBG reference")
                }
            }
            .font(WT.legend)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Column header

private struct LargeColumnHeader: View {
    let codes: [String]

    var body: some View {
        HStack(spacing: 0) {
            Text("SOURCE")
                .frame(width: 44, alignment: .leading)

            ForEach(codes, id: \.self) { code in
                VStack(spacing: 2) {
                    Text(code)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.primary)
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
        .font(.system(size: 7, weight: .bold))
        .foregroundStyle(.secondary)
    }
}

// MARK: - Source row

private struct LargeSourceRow: View {
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
            SourceTag(name: source, width: 44, accent: accentColor, size: 9)

            ForEach(codes, id: \.self) { code in
                LargePair(
                    rate: snapshot.currency(code)?.sourceRates.first { $0.source == source },
                    isNBG: source == "NBG"
                )
            }
        }
    }
}

// MARK: - Buy/Sell pair cell

private struct LargePair: View {
    let rate: SourceRate?
    let isNBG: Bool

    var body: some View {
        HStack(spacing: 0) {
            // Buy
            Group {
                Spacer(minLength: 0)
                RateChip(
                    text:   rate?.formattedBuy ?? "—",
                    isBest: rate?.isBestBuy == true,
                    isRef:  isNBG,
                    isBuy:  true,
                    large:  true
                )
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)

            // Sell
            Group {
                Spacer(minLength: 0)
                RateChip(
                    text:   isNBG ? "ref" : (rate?.formattedSell ?? "—"),
                    isBest: !isNBG && rate?.isBestSell == true,
                    isRef:  isNBG,
                    isBuy:  false,
                    large:  true
                )
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}
