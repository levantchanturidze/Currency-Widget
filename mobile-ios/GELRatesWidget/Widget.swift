import WidgetKit
import SwiftUI

// MARK: - Entry View (router)

struct GELRatesEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: RateEntry

    var body: some View {
        Group {
            switch family {
            case .systemSmall:  SmallWidgetView(entry: entry)
            case .systemLarge:  LargeWidgetView(entry: entry)
            default:            MediumWidgetView(entry: entry)
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

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RatesProvider()) { entry in
            GELRatesEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("GEL Exchange Rates")
        .description("Live USD, EUR, and GBP exchange rates against Georgian Lari.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
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
