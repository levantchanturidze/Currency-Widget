import WidgetKit

struct RatesProvider: TimelineProvider {

    func placeholder(in context: Context) -> RateEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (RateEntry) -> Void) {
        guard !context.isPreview else {
            completion(.placeholder)
            return
        }
        Task { completion(await loadEntry()) }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RateEntry>) -> Void) {
        Task {
            let entry   = await loadEntry()
            let refresh = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
            completion(Timeline(entries: [entry], policy: .after(refresh)))
        }
    }

    private func loadEntry() async -> RateEntry {
        do {
            let snapshot = try await RatesAPI.shared.fetchSnapshot()
            return RateEntry(date: Date(), snapshot: snapshot, errorMessage: nil)
        } catch {
            return RateEntry(date: Date(), snapshot: .placeholder, errorMessage: error.localizedDescription)
        }
    }
}
