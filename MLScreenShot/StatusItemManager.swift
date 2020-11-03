//
//  StatusItemManager.swift
//  MLScreenShot
//
//  Created by Trystan Rivers on 2020/11/03.
//  Copyright © 2020 Trystan Rivers. All rights reserved.
//

import Cocoa

class StatusItemManager: NSObject {

    // MARK: - Properties
    
    var statusItem: NSStatusItem?
    var popover: NSPopover?

    var converterVC: FacesViewController?
    
    
    // MARK: - Init
    
    override init() {
        super.init()

        initStatusItem()
        initPopover()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        initStatusItem()
        initPopover()
    }
    
    
    
    // MARK: - Fileprivate Methods
    
    fileprivate func initStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let itemImage = NSImage(named: "tick")
        itemImage?.isTemplate = true
        statusItem?.button?.image = itemImage
        
        statusItem?.button?.target = self
        statusItem?.button?.action = #selector(showConverterVC)
    }
 
    
    fileprivate func initPopover() {
        popover = NSPopover()
        popover?.behavior = .transient
    }
    
        
    @objc fileprivate func showConverterVC() {
        guard let popover = popover, let button = statusItem?.button else { return }

        if converterVC == nil {
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            guard let vc = storyboard.instantiateController(withIdentifier: .init(stringLiteral: "converterID")) as? FacesViewController else { return }
            converterVC = vc
        }
        
        popover.contentViewController = converterVC
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
    }
    
    
    func hideAbout() {
        guard let popover = popover else { return }
        popover.contentViewController?.view.isHidden = true
        popover.contentViewController?.dismiss(nil)
        showConverterVC()
        popover.contentViewController?.view.isHidden = false
    }
}
