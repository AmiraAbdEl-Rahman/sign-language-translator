# Platform setup for the Flutter app

Create the platform folders once, then copy the files in `lib/`, `test/` and `pubspec.yaml`:

    flutter create --org com.example --project-name sign_language_translator mobile_app_tmp
    # copy mobile_app_tmp/android, ios (and other platform folders) into mobile_app/

## Android — android/app/src/main/AndroidManifest.xml
Inside `<manifest>` add:

    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.INTERNET"/>

Inside `<application>` add (only needed while the server uses http://, not https://):

    android:usesCleartextTraffic="true"

In `android/app/build.gradle` set `minSdkVersion 21` (the camera plugin needs it).

## iOS — ios/Runner/Info.plist

    <key>NSCameraUsageDescription</key>
    <string>The camera is used to read sign language gestures.</string>

For plain http servers on iOS also add an App Transport Security exception for your server.

## Server address
- Android emulator: `http://10.0.2.2:5000` (default)
- Real phone: use your computer's LAN address, e.g. `http://192.168.1.20:5000`
  (phone and computer must be on the same Wi-Fi). Change it in Settings > Server address.
