import UIKit
import Flutter
import GoogleMaps   // ← wajib untuk google_maps_flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // GANTI dengan Google Maps API Key kamu
    GMSServices.provideAPIKey("AIzaSyBsPfZeUe8Jm5Shr3ToevC39SyzO8lAPvE")

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
