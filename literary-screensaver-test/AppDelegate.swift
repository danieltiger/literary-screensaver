//
//  AppDelegate.swift
//  literary-screensaver-test
//
//  Created by James Liu on 5/8/18.
//  Copyright © 2018 James Liu. All rights reserved.
//

import Cocoa

import Cocoa
import ScreenSaver

class ViewController: NSViewController {

    // MARK: - Properties
    private var saver: ScreenSaverView?
    private var timer: Timer?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        addScreensaver()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0/30,
                                     repeats: true) { [weak self] _ in
            self?.saver?.animateOneFrame()
        }
    }

    deinit {
        timer?.invalidate()
    }

    // MARK: - Helper Functions
    private func addScreensaver() {
        if let saver = Main(frame: view.frame, isPreview: false) {
            view.addSubview(saver)
            self.saver = saver
        }
    }

}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    private var timer: Timer?
    
    lazy var screenSaverView = Main(frame: NSZeroRect, isPreview: false)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let screenSaverView = screenSaverView {
            screenSaverView.frame = window.contentView!.bounds;
            window.contentView!.addSubview(screenSaverView);
//            screenSaverView.animateOneFrame()
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1.0/30,
                                     repeats: true) { [weak self] _ in
            self?.screenSaverView?.animateOneFrame()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    deinit {
        timer?.invalidate()
    }

}

