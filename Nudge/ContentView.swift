//
//  ContentView.swift
//  Nudge
//
//  Created by Erik Gomez on 2/2/21.
//

import SwiftUI

// https://stackoverflow.com/a/66039864
// https://gist.github.com/steve228uk/c960b4880480c6ed186d

struct ContentView: View {
    @EnvironmentObject var manager: PolicyManager
    var body: some View {
        HostingWindowFinder {window in
            window?.standardWindowButton(.closeButton)?.isHidden = true //hides the red close button
            window?.standardWindowButton(.miniaturizeButton)?.isHidden = true //hides the yellow miniaturize button
            window?.standardWindowButton(.zoomButton)?.isHidden = true //this removes the green zoom button
            window?.center() // center
            window?.isMovable = false // not movable
            NSApp.activate(ignoringOtherApps: true) // bring to forefront upon launch
        }
        Nudge()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(PolicyManager(withVersion:  try! OSVersion("11.2") ))
    }
}

struct HostingWindowFinder: NSViewRepresentable {
    var callback: (NSWindow?) -> ()

    func runSoftwareUpdate(delay: Int) {
        if asyncronousSoftwareUpdate {
            DispatchQueue(label: "nudge-su", attributes: .concurrent).asyncAfter(deadline: .now() + Double(delay), execute: {
                SoftwareUpdate().Download()
            })
        } else {
            SoftwareUpdate().Download()
        }
    }

    func makeNSView(context: Self.Context) -> NSView {
        let view = NSView()
        if Utils().versionArgumentPassed() {
            print(Utils().getNudgeVersion())
            AppKit.NSApp.terminate(nil)
        }

        if randomDelay {
            let randomDelaySeconds = Int.random(in: 1...maxRandomDelayInSeconds)
            uiLog.info("Delaying initial run (in seconds) by: \(String(randomDelaySeconds), privacy: .public)")
            runSoftwareUpdate(delay: randomDelaySeconds)
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(randomDelaySeconds)) { [weak view] in
                self.callback(view?.window)
            }
        } else {
            runSoftwareUpdate(delay: 0)
            DispatchQueue.main.async { [weak view] in
                self.callback(view?.window)
            }
        }
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}
