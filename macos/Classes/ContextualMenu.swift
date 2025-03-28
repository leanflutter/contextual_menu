//
//  ContextualMenu.swift
//  platform_context_menu
//
//  Created by Lijy91 on 2022/5/6.
//

import AppKit

public class ContextualMenu: NSMenu, NSMenuDelegate {
    public var onMenuItemClick:((NSMenuItem) -> Void)?
    public var onMenuItemHighlight:((NSMenuItem?) -> Void)?
    
    public override init(title: String) {
        super.init(title: title)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public init(_ args: [String: Any]) {
        super.init(title: "")
        
        let items: [NSDictionary] = args["items"] as! [NSDictionary];
        for item in items {
            let menuItem: NSMenuItem
            
            let itemDict = item as! [String: Any]
            let id: Int = itemDict["id"] as! Int
            let type: String = itemDict["type"] as! String
            let label: String = itemDict["label"] as? String ?? ""
            let toolTip: String = itemDict["toolTip"] as? String ?? ""
            let checked: Bool? = itemDict["checked"] as? Bool
            let disabled: Bool = itemDict["disabled"] as? Bool ?? true
            let shortcutKey: String = itemDict["shortcutKey"] as? String ?? ""
            let shortcutModifiers: [String] = itemDict["shortcutModifiers"] as? [String] ?? []
            
            if (type == "separator") {
                menuItem = NSMenuItem.separator()
            } else {
                menuItem = NSMenuItem()
            }
            
            menuItem.tag = id
            menuItem.title = label
            menuItem.toolTip = toolTip
            menuItem.isEnabled = !disabled
            menuItem.action = !disabled ? #selector(statusItemMenuButtonClicked) : nil
            menuItem.target = self

            menuItem.keyEquivalent = shortcutKey
            menuItem.keyEquivalentModifierMask = []
            for modifier in shortcutModifiers {
                if (modifier == "ctrl") {
                    menuItem.keyEquivalentModifierMask = menuItem.keyEquivalentModifierMask.union(.control)
                } else if (modifier == "shift") {
                    menuItem.keyEquivalentModifierMask = menuItem.keyEquivalentModifierMask.union(.shift)
                } else if (modifier == "alt" || modifier == "option") {
                    menuItem.keyEquivalentModifierMask = menuItem.keyEquivalentModifierMask.union(.option)
                } else if (modifier == "cmd") {
                    menuItem.keyEquivalentModifierMask = menuItem.keyEquivalentModifierMask.union(.command)
                }
            }
            
            switch (type) {
            case "separator":
                break
            case "submenu":
                if let submenuDict = itemDict["submenu"] as? NSDictionary {
                    let submenu = ContextualMenu(submenuDict as! [String : Any])
                    submenu.onMenuItemClick = {
                        (menuItem: NSMenuItem) in
                        self.statusItemMenuButtonClicked(menuItem)
                    }
                    self.setSubmenu(submenu, for: menuItem)
                }
                break
            case "checkbox":
                if (checked == nil) {
                    menuItem.state = .mixed
                } else {
                    menuItem.state = checked! ? .on : .off
                }
                break
            default:
                break
            }
            self.addItem(menuItem)
        }
        self.delegate = self
    }
    
    @objc func statusItemMenuButtonClicked(_ sender: Any?) {
        if (sender is NSMenuItem && onMenuItemClick != nil) {
            let menuItem = sender as! NSMenuItem
            self.onMenuItemClick!(menuItem)
        }
    }
    
    // MARK: NSMenuDelegate
    
    public func menuDidClose(_ menu: NSMenu) {
        
    }

    public func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
        if (onMenuItemHighlight != nil) {
            self.onMenuItemHighlight!(item)
        }
    }
}
