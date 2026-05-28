import WidgetKit
import SwiftUI

// MARK: - Entry View (router)

struct GELRatesEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: RateEntry

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallWidgetView(entry: entry)
            case .systemLarge, .systemExtraLarge:
                LargeWidgetView(entry: entry)
            default:
                MediumWidgetView(entry: entry)
            }
        }
        .overlay(alignment: .topTrailing) {
            if entry.hasError {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption2)
                    .foregroundStyle(.yellow)
                    .padding(8)
            }
        }
    }
}

// MARK: - Widget Configuration

struct GELRatesWidget: Widget {
    let kind = "GELRatesWidget"

    var supportedFamilies: [WidgetFamily] {
        #if os(macOS)
        return [.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge]
        #else
        return [.systemSmall, .systemMedium, .systemLarge]
        #endif
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RatesProvider()) { entry in
            GELRatesEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("GEL Exchange Rates")
        .description("Live USD, EUR, and GBP exchange rates against Georgian Lari.")
        .supportedFamilies(supportedFamilies)
        .contentMarginsDisabled()
    }
}

// MARK: - Bundle Entry Point

@main
struct GELRatesWidgetBundle: WidgetBundle {
    var body: some Widget {
        GELRatesWidget()
    }
}
