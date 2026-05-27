import SwiftUI
import WidgetKit

// Small (155×155 pt) — USD comparison across all 5 sources
struct SmallWidgetView: View {
    let entry: RateEntry

    private var usd: CurrencySnapshot {
        entry.snapshot.currency("USD") ?? entry.snapshot.items[0]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Header ──────────────────────────────────────────────────
            HStack(alignment: .firstTextBaseline) {
                HStack(spacing: 3) {
                    Text("₾")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(.blue)
                    Text("USD")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                }
                Spacer()
                Text(entry.date, style: .relative)
                    .font(.system(size: 7))
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: 48, alignment: .trailing)
            }
            .padding(.bottom, 5)

            ThinDivider()
                .padding(.bottom, 4)

            // ── Column labels ────────────────────────────────────────────
            HStack(spacing: 0) {
                Text("SRC")
                    .frame(width: 36, alignment: .leading)
                Text("↑ BUY")
                    .foregroundStyle(WT.buy.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Text("↓ SELL")
                    .foregroundStyle(WT.sell.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .font(.system(size: 7, weight: .bold))
            .padding(.bottom, 3)

            // ── Source rows ──────────────────────────────────────────────
            VStack(spacing: 4) {
                ForEach(usd.sourceRates.sorted) { rate in
                    SmallRow(rate: rate)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

private struct SmallRow: View {
    let rate: SourceRate

    var accentColor: Color? {
        if rate.isBestBuy  { return WT.buy  }
        if rate.isBestSell { return WT.sell }
        return nil
    }

    var body: some View {
        HStack(spacing: 0) {
            SourceTag(name: rate.source, width: 36, accent: accentColor, size: 8)

            Spacer()

            RateChip(
                text:   rate.formattedBuy,
                isBest: rate.isBestBuy,
                isRef:  rate.isNBG,
                isBuy:  true
            )
            .frame(maxWidth: .infinity, alignment: .trailing)

            RateChip(
                text:   rate.isNBG ? "ref" : rate.formattedSell,
                isBest: !rate.isNBG && rate.isBestSell,
                isRef:  rate.isNBG,
                isBuy:  false
            )
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}
