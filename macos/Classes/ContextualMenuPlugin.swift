import Cocoa
import FlutterMacOS

public class ContextualMenuPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "contextual_menu", binaryMessenger: registrar.messenger)
        let instance = ContextualMenuPlugin()
        instance.registrar = registrar
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    private var registrar: FlutterPluginRegistrar!;
    private var channel: FlutterMethodChannel!
    
    private var menu: ContextualMenu?
    
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
        menu = ContextualMenu(args["menu"] as! [String: Any])
        menu!.onMenuItemClick = {
            (menuItem: NSMenuItem) in
            let args: NSDictionary = [
                "id": menuItem.tag,
            ]
            self.channel.invokeMethod("onMenuItemClick", arguments: args, result: nil)
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
        
        if (placement == "topRight") {
            x -= menu?.size.width ?? 0
        }
        
        menu?.popUp(
            positioning: nil,
            at: NSPoint(x: x, y: y),
            in: mainWindow.contentView
        )
        
        result(nil)
    }
}
