// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "cloud_firestore", path: "../.packages/cloud_firestore-6.8.0"),
        .package(name: "device_info_plus", path: "../.packages/device_info_plus-13.2.0"),
        .package(name: "file_picker_darwin", path: "../.packages/file_picker_darwin-1.0.1"),
        .package(name: "firebase_auth", path: "../.packages/firebase_auth-6.5.7"),
        .package(name: "firebase_core", path: "../.packages/firebase_core-4.13.0"),
        .package(name: "firebase_database", path: "../.packages/firebase_database-12.4.7"),
        .package(name: "firebase_storage", path: "../.packages/firebase_storage-13.4.6"),
        .package(name: "flutter_image_compress_common", path: "../.packages/flutter_image_compress_common-1.1.1"),
        .package(name: "flutter_local_notifications", path: "../.packages/flutter_local_notifications-22.3.0"),
        .package(name: "flutter_secure_storage_darwin", path: "../.packages/flutter_secure_storage_darwin-0.4.0"),
        .package(name: "google_sign_in_ios", path: "../.packages/google_sign_in_ios-6.3.0"),
        .package(name: "image_picker_ios", path: "../.packages/image_picker_ios-0.8.13+6"),
        .package(name: "native_file_preview", path: "../.packages/native_file_preview-1.1.0"),
        .package(name: "pasteboard", path: "../.packages/pasteboard-0.5.0"),
        .package(name: "pdfx", path: "../.packages/pdfx-2.11.0"),
        .package(name: "receive_sharing_intent", path: "../.packages/receive_sharing_intent-1.9.0"),
        .package(name: "share_plus", path: "../.packages/share_plus-13.3.0"),
        .package(name: "shared_preferences_foundation", path: "../.packages/shared_preferences_foundation-2.5.6"),
        .package(name: "sqflite_darwin", path: "../.packages/sqflite_darwin-2.4.3+1"),
        .package(name: "syncfusion_flutter_pdfviewer", path: "../.packages/syncfusion_flutter_pdfviewer-33.2.15"),
        .package(name: "url_launcher_ios", path: "../.packages/url_launcher_ios-6.4.1"),
        .package(name: "FlutterFramework", path: "../.packages/FlutterFramework")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "cloud-firestore", package: "cloud_firestore"),
                .product(name: "device-info-plus", package: "device_info_plus"),
                .product(name: "file-picker-darwin", package: "file_picker_darwin"),
                .product(name: "firebase-auth", package: "firebase_auth"),
                .product(name: "firebase-core", package: "firebase_core"),
                .product(name: "firebase-database", package: "firebase_database"),
                .product(name: "firebase-storage", package: "firebase_storage"),
                .product(name: "flutter-image-compress-common", package: "flutter_image_compress_common"),
                .product(name: "flutter-local-notifications", package: "flutter_local_notifications"),
                .product(name: "flutter-secure-storage-darwin", package: "flutter_secure_storage_darwin"),
                .product(name: "google-sign-in-ios", package: "google_sign_in_ios"),
                .product(name: "image-picker-ios", package: "image_picker_ios"),
                .product(name: "native-file-preview", package: "native_file_preview"),
                .product(name: "pasteboard", package: "pasteboard"),
                .product(name: "pdfx", package: "pdfx"),
                .product(name: "receive-sharing-intent", package: "receive_sharing_intent"),
                .product(name: "share-plus", package: "share_plus"),
                .product(name: "shared-preferences-foundation", package: "shared_preferences_foundation"),
                .product(name: "sqflite-darwin", package: "sqflite_darwin"),
                .product(name: "syncfusion-flutter-pdfviewer", package: "syncfusion_flutter_pdfviewer"),
                .product(name: "url-launcher-ios", package: "url_launcher_ios"),
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
