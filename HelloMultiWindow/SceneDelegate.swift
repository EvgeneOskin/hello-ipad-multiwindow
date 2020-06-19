import UIKit
import SwiftUI

var windowsCount = 0
func hideOtherScreen(_ session: UISceneSession) {
    if (windowsCount > 0) {
        UIApplication.shared.requestSceneSessionDestruction(session, options: nil, errorHandler: nil)
        return
    }
    windowsCount += 1
}

class ExternalWindow: UIWindow {
  var shadowWindow: UIWindow? = nil
}


@objc class ShadowWindow: UIWindow {
  private let _refWindow: UIWindow

  @objc var refWindow: UIWindow { _refWindow }

  init(windowScene: UIWindowScene, refWindow: UIWindow) {
    _refWindow = refWindow

    super.init(windowScene: windowScene)

    frame = _refWindow.frame
    self.clipsToBounds = false
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var frame: CGRect {
    get { _refWindow.frame }
    set { super.frame = _refWindow.frame }
  }


  @objc static var shared: ShadowWindow? = nil
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var externalWindow: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Create the SwiftUI view that provides the window contents.
        // hideOtherScreen(session)
        
        let contentView = ContentView()

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()

            NotificationCenter.default.addObserver(forName: UIScreen.didConnectNotification, object: nil, queue: nil) { (connectNotice) in
                let extScreen = connectNotice.object as! UIScreen
                self.setupExternalScreen(screen: extScreen)

//                self.addExternalDisplay(session, windowScene)
            }
            NotificationCenter.default.addObserver(forName: UIScreen.didDisconnectNotification, object: nil, queue: nil) { (disconnectNotice) in
               let extScreen = disconnectNotice.object as! UIScreen

               if let extWindow = self.externalWindow, extScreen == extWindow.screen
               {
                    self.externalWindow?.isHidden = true
                    self.externalWindow = nil
               }
            }
        }
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    private func setupExternalScreen(screen: UIScreen, shouldRecurse: Bool = true) {
        // For iOS13 find matching UIWindowScene
        var matchingWindowScene: UIWindowScene? = nil
        if #available(iOS 13.0, *) {
            let scenes = UIApplication.shared.connectedScenes
            matchingWindowScene = scenes.first { (scene) -> Bool in
                return (scene as? UIWindowScene)?.screen == screen
            } as? UIWindowScene
            if matchingWindowScene == nil {
                // UIWindowScene has not been created by iOS rendered yet
                // Lets recall self after delay of two seconds
                if shouldRecurse {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                        self.setupExternalScreen(screen:screen, shouldRecurse: false)
                    }
                }
                // Dont proceed furthure in iOS13
                return
            }
        }

        guard externalWindow == nil else {
          return
        }

        externalWindow = UIWindow(frame: screen.bounds)
        externalWindow!.rootViewController = externaScreenController()
        if #available(iOS 13.0, *) {
            externalWindow!.windowScene = matchingWindowScene
        } else {
            externalWindow!.screen = screen
        }
        externalWindow!.isHidden = false
    }

    func externaScreenController() -> UIViewController {
        return UIHostingController(rootView: ContentView())
    }
}


func applyExternalScreenCompensation() {
 if (UIScreen.screens.count <= 1) {
   return;
 }

    if let screen = UIScreen.screens.last {
        //   case BKBKOverscanCompensationScale:
        //     screen.overscanCompensation = UIScreen.OverscanCompensation.scale;
        //   case BKBKOverscanCompensationInsetBounds:
        screen.overscanCompensation = UIScreen.OverscanCompensation.insetBounds;
    }
}
