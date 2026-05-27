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
                    .font(.title2)
                    .fontWeight(.bold)

                Text("USD · EUR · GBP")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text("Add the widget to your Home Screen for live Georgian Lari exchange rates at a glance.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                WidgetCenter.shared.reloadAllTimelines()
            } label: {
                Label("Refresh Widget Data", systemImage: "arrow.clockwise")
                    .font(.callout)
                    .fontWeight(.medium)
            }
            .buttonStyle(.bordered)
            .tint(.blue)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}
