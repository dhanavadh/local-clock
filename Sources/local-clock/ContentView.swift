import SwiftUI

struct ContentView: View {
    @State private var currentTime = Date()

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }

    var body: some View {
        Text(dateFormatter.string(from: currentTime))
            .font(.system(size: 80, weight: .bold, design: .monospaced))
            .foregroundColor(.init(white: 0.9)) // Off-white color
            .padding()
            .onReceive(timer) { input in
                self.currentTime = input
            }
            .background(WindowAccessor { window in
                if let window = window {
                    window.isOpaque = false
                    window.backgroundColor = .clear
                    window.titlebarAppearsTransparent = true
                    window.styleMask = .borderless
                    window.hasShadow = false
                    window.level = .floating
                    window.collectionBehavior = .canJoinAllSpaces
                    if let screen = NSScreen.main {
                        let screenRect = screen.visibleFrame
                        let newOrigin = CGPoint(x: screenRect.origin.x, y: screenRect.origin.y)
                        window.setFrameOrigin(newOrigin)
                    }
                }
            })
    }
}
