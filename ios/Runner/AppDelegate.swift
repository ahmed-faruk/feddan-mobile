import FirebaseAuth
import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // H1: Maps API key injected from SecretKeys.xcconfig → Info.plist at build time.
    let mapsKey = Bundle.main.object(forInfoDictionaryKey: "MAPS_API_KEY") as? String ?? ""
    GMSServices.provideAPIKey(mapsKey)
    // Register Flutter plugins early so Firebase Auth swizzling is active before
    // any UIApplicationDelegate notification/URL callbacks arrive.
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Firebase Phone Auth — reCAPTCHA redirect after simulator verification flow.
  // Firebase opens a SFSafariViewController, user completes CAPTCHA, Safari
  // returns to the app via the custom URL scheme registered in Info.plist.
  override func application(_ app: UIApplication,
                             open url: URL,
                             options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    if Auth.auth().canHandle(url) { return true }
    return super.application(app, open: url, options: options)
  }

  // Firebase Phone Auth — silent APNs token forwarding.
  // On a real device Firebase sends a silent push to verify APNs capability.
  // Must be forwarded even on simulator so the SDK can decide to fall back to reCAPTCHA.
  override func application(_ application: UIApplication,
                             didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                             fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    if Auth.auth().canHandleNotification(userInfo) {
      completionHandler(.noData)
      return
    }
    super.application(application,
                      didReceiveRemoteNotification: userInfo,
                      fetchCompletionHandler: completionHandler)
  }
}
