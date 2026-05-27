import SwiftUI

// MARK: - Design tokens

enum WT {
    // Colors
    static let buy:      Color = .green
    static let sell:     Color = .orange
    static let ref:      Color = .blue

    static var buyBg:    Color { .green.opacity(0.13)  }
    static var sellBg:   Color { .orange.opacity(0.13) }
    static var refBg:    Color { .blue.opacity(0.09)   }

    // Typography
    static let widgetTitle: Font = .system(size: 13, weight: .bold)
    static let subtitle:    Font = .system(size: 9)
    static let colHeader:   Font = .system(size: 7, weight: .bold)
    static let srcLabel:    Font = .system(size: 9,  weight: .bold,   design: .monospaced)
    static let rateNormal:  Font = .system(size: 10, design: .monospaced)
    static let rateBold:    Font = .system(size: 10, design: .monospaced).weight(.bold)
    static let rateLg:      Font = .system(size: 11, design: .monospaced)
    static let rateLgBold:  Font = .system(size: 11, design: .monospaced).weight(.bold)
    static let timestamp:   Font = .system(size: 8)
    static let legend:      Font = .system(size: 8, weight: .medium)
}

// MARK: - RateChip
// A rate value that highlights itself with a coloured pill when it's the best rate.

struct RateChip: View {
    let text:   String
    let isBest: Bool
    let isRef:  Bool    // NBG reference (shown in blue, no pill)
    let isBuy:  Bool
    var large:  Bool = false

    var fgColor: Color {
        if isRef  { return WT.ref  }
        if isBest { return isBuy ? WT.buy : WT.sell }
        return .primary
    }

    var bgColor: Color {
        guard isBest else { return .clear }
        return isBuy ? WT.buyBg : WT.sellBg
    }

    var body: some View {
        Text(text)
            .font(large
                ? (isBest ? WT.rateLgBold : WT.rateLg)
                : (isBest ? WT.rateBold   : WT.rateNormal))
            .foregroundStyle(fgColor)
            .padding(.horizontal, isBest ? 4 : 0)
            .padding(.vertical,   isBest ? 2 : 0)
            .background(bgColor)
            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
    }
}

// MARK: - SourceTag
// Uppercase monospaced label. Optional coloured left accent bar.

struct SourceTag: View {
    let name:    String
    var width:   CGFloat = 40
    var accent:  Color?  = nil
    var size:    CGFloat = 9

    var body: some View {
        HStack(spacing: 4) {
            if let c = accent {
                RoundedRectangle(cornerRadius: 1)
                    .fill(c)
                    .frame(width: 2, height: 10)
            }
            Text(name)
                .font(.system(size: size, weight: .bold, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .frame(width: width, alignment: .leading)
    }
}

// MARK: - WidgetHeaderView

struct WidgetHeaderView: View {
    let title:    String
    let date:     Date
    var subtitle: String? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text("₾")
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(WT.widgetTitle)
                if let sub = subtitle {
                    Text(sub)
                        .font(WT.subtitle)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            HStack(spacing: 2) {
                Image(systemName: "clock")
                    .font(.system(size: 7))
                    .foregroundStyle(.tertiary)
                Text(date, style: .relative)
                    .font(WT.timestamp)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: 55, alignment: .trailing)
            }
        }
    }
}

// MARK: - Thin divider

struct ThinDivider: View {
    var opacity: Double = 0.15
    var body: some View {
        Rectangle()
            .fill(Color.primary.opacity(opacity))
            .frame(height: 0.5)
    }
}
