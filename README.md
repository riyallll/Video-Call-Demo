Video Call Demo App (Flutter/Agora)
This is a demonstration Flutter application that implements real-time video and screen sharing capabilities using the Agora RTC SDK.

Prerequisites
Before running the application, ensure you have the following installed:

Flutter SDK: Install Flutter (Ensure you are on the latest stable channel).

Dart SDK (comes bundled with Flutter).

Android Studio or VS Code with Flutter/Dart plugins.

An active Agora Account and an App ID/Token.

A physical iOS or Android Device or a functioning emulator/simulator.

1. Project Setup


Install dependencies:

flutter pub get

Configure Agora Credentials:

Open lib/core/constants.dart (or the file containing AppConstants) and replace the placeholder values with your actual Agora credentials.

NOTE: The provided token in the source code is temporary and will expire. For production, you must generate tokens on a secure server.

// Example in AppConstants (replace with your values):
static const String agoraAppId = "YOUR_AGORA_APP_ID";
static const String token = "YOUR_AGORA_TEMPORARY_TOKEN";

2. Platform Permissions Configuration
   The app requires Camera and Microphone access.

Android
Add permissions to android/app/src/main/AndroidManifest.xml:

<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
<uses-permission android:name="android.permission.BLUETOOTH"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" /> 

iOS
Add usage descriptions to ios/Runner/Info.plist:

<key>NSCameraUsageDescription</key>
<string>We need camera access to display your video during the call.</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access to transmit your audio during the call.</string>

3. Running the Application
   Connect a device or launch an emulator.

Run the app:

flutter run

Alternatively, use the "Run and Debug" feature in your IDE (VS Code or Android Studio).

Demo Credentials
The application uses sample credentials for the initial login screen:

Email: test@test.com

Password: password

You can also use the mock credentials provided by ReqRes for testing:

Email: eve.holt@reqres.in

Password: cityslicka