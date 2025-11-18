import AppKit
import SwiftUI

@MainActor
class StatusBarController {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    private var menu: NSMenu
    private var window: NSWindow

    let colors = ["White", "Red", "Green", "Blue", "Yellow", "Black"]

    init(window: NSWindow) {
        self.window = window
        statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "clock", accessibilityDescription: "Clock")
        }

        menu = NSMenu()
        statusItem.menu = menu
        
        let corners = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"]
        for corner in corners {
            let menuItem = NSMenuItem(title: corner, action: #selector(cornerSelected), keyEquivalent: "")
            menuItem.target = self
            menu.addItem(menuItem)
        }

        menu.addItem(NSMenuItem.separator())

        let colorMenuItem = NSMenuItem(title: "Color", action: nil, keyEquivalent: "")
        let colorMenu = NSMenu()
        for colorName in colors {
            let menuItem = NSMenuItem(title: colorName, action: #selector(colorSelected), keyEquivalent: "")
            menuItem.target = self
            colorMenu.addItem(menuItem)
        }
        colorMenuItem.submenu = colorMenu
        menu.addItem(colorMenuItem)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        updateMenu()
        updateWindowPosition()
    }

    func updateMenu() {
        let selectedCorner = UserDefaults.standard.string(forKey: "selectedCorner") ?? "Bottom Left"
        let selectedColor = UserDefaults.standard.string(forKey: "selectedColor") ?? "White"
        
        for item in menu.items {
            if item.action == #selector(cornerSelected) {
                item.state = (item.title == selectedCorner) ? .on : .off
            }
        }

        if let colorMenuItem = menu.item(withTitle: "Color"), let colorMenu = colorMenuItem.submenu {
            for item in colorMenu.items {
                item.state = (item.title == selectedColor) ? .on : .off
            }
        }
    }

    @objc func cornerSelected(sender: NSMenuItem) {
        UserDefaults.standard.set(sender.title, forKey: "selectedCorner")
        updateMenu()
        updateWindowPosition()
    }

    @objc func colorSelected(sender: NSMenuItem) {
        UserDefaults.standard.set(sender.title, forKey: "selectedColor")
        updateMenu()
        NotificationCenter.default.post(name: .colorDidChange, object: nil)
    }

    func updateWindowPosition() {
        guard let screen = NSScreen.main else { return }

        let selectedCorner = UserDefaults.standard.string(forKey: "selectedCorner") ?? "Bottom Left"
        let screenRect = screen.visibleFrame
        
        if let contentView = window.contentView {
            let size = contentView.fittingSize
            window.setContentSize(size)
        }
        
        let windowSize = window.frame.size
        var newOrigin = CGPoint.zero

        switch selectedCorner {
        case "Top Left":
            newOrigin = CGPoint(x: screenRect.origin.x, y: screenRect.origin.y + screenRect.height - windowSize.height)
        case "Top Right":
            newOrigin = CGPoint(x: screenRect.origin.x + screenRect.width - windowSize.width, y: screenRect.origin.y + screenRect.height - windowSize.height)
        case "Bottom Right":
            newOrigin = CGPoint(x: screenRect.origin.x + screenRect.width - windowSize.width, y: screenRect.origin.y)
        default: // Bottom Left
            newOrigin = CGPoint(x: screenRect.origin.x, y: screenRect.origin.y)
        }

        window.setFrameOrigin(newOrigin)
    }
}

extension NSNotification.Name {
    static let colorDidChange = NSNotification.Name("colorDidChange")
}
