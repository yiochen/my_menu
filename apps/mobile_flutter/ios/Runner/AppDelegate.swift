import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "com.myaimenu.mymenu/data-protection",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { [weak self] call, result in
        guard call.method == "hardenLocalMenuStorage" else {
          result(FlutterMethodNotImplemented)
          return
        }
        do {
          try self?.hardenLocalMenuStorage()
          result(nil)
        } catch {
          result(FlutterError(
            code: "data_protection_failed",
            message: "Could not protect local menu storage.",
            details: error.localizedDescription
          ))
        }
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func hardenLocalMenuStorage() throws {
    let fileManager = FileManager.default
    let documents = try fileManager.url(
      for: .documentDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true
    )
    let support = try fileManager.url(
      for: .applicationSupportDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true
    )
    let protectedDirectories = [
      documents,
      support.appendingPathComponent("menu_media", isDirectory: true),
      support.appendingPathComponent("generated-covers", isDirectory: true),
      support.appendingPathComponent("processing", isDirectory: true),
      support.appendingPathComponent("dish_image_cache", isDirectory: true),
    ]
    for directory in protectedDirectories {
      try protectRecursively(directory, fileManager: fileManager)
    }
  }

  private func protectRecursively(
    _ directory: URL,
    fileManager: FileManager
  ) throws {
    try fileManager.createDirectory(
      at: directory,
      withIntermediateDirectories: true,
      attributes: [.protectionKey: FileProtectionType.complete]
    )
    try protect(directory, fileManager: fileManager)
    if let enumerator = fileManager.enumerator(
      at: directory,
      includingPropertiesForKeys: nil
    ) {
      for case let child as URL in enumerator {
        try protect(child, fileManager: fileManager)
      }
    }
  }

  private func protect(_ url: URL, fileManager: FileManager) throws {
    try fileManager.setAttributes(
      [.protectionKey: FileProtectionType.complete],
      atPath: url.path
    )
    try (url as NSURL).setResourceValue(
      true,
      forKey: URLResourceKey.isExcludedFromBackupKey
    )
  }
}
