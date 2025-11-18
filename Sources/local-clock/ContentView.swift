import SwiftUI

struct ContentView: View {
    @State private var currentTime = Date()
    @State private var textColor = Color.white

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }

    var body: some View {
        Text(dateFormatter.string(from: currentTime))
            .font(.system(size: 80, weight: .bold, design: .monospaced))
            .foregroundColor(textColor)
            .padding(5) // Add a small padding
            .onReceive(timer) { input in
                self.currentTime = input
            }
            .onAppear(perform: updateColor)
            .onReceive(NotificationCenter.default.publisher(for: .colorDidChange)) { _ in
                updateColor()
            }
    }

    private func updateColor() {
        let colorName = UserDefaults.standard.string(forKey: "selectedColor") ?? "White"
        switch colorName {
        case "Red":
            textColor = .red
        case "Green":
            textColor = .green
        case "Blue":
            textColor = .blue
        case "Yellow":
            textColor = .yellow
        case "Black":
            textColor = .black
        default:
            textColor = .white
        }
    }
}
