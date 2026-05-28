import SwiftUI
import WidgetKit

struct ContentView: View {
    var body: some View {
        VStack(spacing: 28) {
            Image(systemName: "rectangle.3.group.fill")
                .font(.system(size: 64))
                .foregroundStyle(.blue.gradient)

            VStack(spacing: 8) {
                Text("GEL Exchange Rates")
                    .font(.title)
                    .fontWeight(.bold)
                Text("USD · EUR · GBP")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text("Right-click your desktop or open Notification Centre to add the widget. Rates are fetched live every 15 minutes.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)

            Button {
                WidgetCenter.shared.reloadAllTimelines()
            } label: {
                Label("Refresh Widget Data", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(48)
        .frame(width: 420)
    }
}
