//
//  AppDelegate.swift
//  MLScreenShot
//
//  Created by Trystan Rivers on 2020/10/06.
//  Copyright © 2020 Trystan Rivers. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

//    var statusItem: NSStatusItem?

//    override func awakeFromNib() {
//        super.awakeFromNib()
//
//        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
//        let itemImage = NSImage(named: "tick")
//        itemImage?.isTemplate = true
//        statusItem?.button?.image = itemImage
//    }
    
    @IBOutlet weak var statusItemManager: StatusItemManager!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}

