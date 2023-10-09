import Cocoa
import FlutterMacOS

public class FlutterDesktopContextMenuPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_desktop_context_menu", binaryMessenger: registrar.messenger)
        let instance = FlutterDesktopContextMenuPlugin()
        instance.registrar = registrar
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    private var registrar: FlutterPluginRegistrar!;
    private var channel: FlutterMethodChannel!
    
    private var menu: FlutterDesktopContextMenu?
    
    private var mainWindow: NSWindow {
        get {
            return (self.registrar.view?.window)!;
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "popUp":
            popUp(call, result: result)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func popUp(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args:[String: Any] = call.arguments as! [String: Any]
        menu = FlutterDesktopContextMenu(args["menu"] as! [String: Any])
        menu!.onMenuItemClick = {
            (menuItem: NSMenuItem) in
            let args: NSDictionary = [
                "id": menuItem.tag,
            ]
            self.channel.invokeMethod("onMenuItemClick", arguments: args, result: nil)
        }
        menu!.onMenuItemHighlight = { (menuItem: NSMenuItem?) in
            let args: NSDictionary = [
                "id": menuItem?.tag as Any,
            ]
            self.channel.invokeMethod("onMenuItemHighlight", arguments: args, result: nil)
        }
        
        let position = args["position"]  as? [String: Any]
        let placement = args["placement"]  as! String
        
        let contentView = mainWindow.contentView
        let mouseLocation = mainWindow.mouseLocationOutsideOfEventStream
        
        var x = mouseLocation.x
        var y = mouseLocation.y
        
        if (position != nil) {
            x = position?["x"] as! CGFloat
            y = position?["y"] as! CGFloat
            
            if !contentView!.isFlipped {
                let frameHeight = Double(contentView!.frame.height)
                y = frameHeight - y
            }
        }
        
        if (placement == "topLeft") {
            x -= menu?.size.width ?? 0
            y += menu?.size.height ?? 0
        } else if (placement == "topRight") {
            y += menu?.size.height ?? 0
        } else if (placement == "bottomLeft") {
            x -= menu?.size.width ?? 0
        } else if (placement == "bottomRight") {
            // skip
        }
        
        let action = Action({ [self] in
            menu?.popUp(
                positioning: nil,
                at: NSPoint(x: x, y: y),
                in: mainWindow.contentView
            )
        })
        RunLoop.current.perform(
            #selector(action.action),
            target: action,
            argument: nil,
            order: 0,
            modes: [RunLoop.Mode.default]
        )

        result(nil)
    }
}

// Wrapper class to pass closures to Objective-C APIs that take selectors taken
// from https://stackoverflow.com/a/36983811/1988017
final class Action: NSObject {
    private let _action: () -> ()

    init(_ action: @escaping () -> ()) {
        _action = action
        super.init()
    }

    @objc func action() {
        _action()
    }
}
