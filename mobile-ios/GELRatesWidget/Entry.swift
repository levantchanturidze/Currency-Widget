import WidgetKit

struct RateEntry: TimelineEntry {
    let date: Date
    let snapshot: RatesSnapshot
    let errorMessage: String?

    var hasError: Bool { errorMessage != nil }

    static var placeholder: RateEntry {
        RateEntry(date: Date(), snapshot: .placeholder, errorMessage: nil)
    }
}
