Lost-Found App



An intuitive and easy-to-use Flutter application designed to help users post and find lost or found items within a community. Whether you've misplaced an important document or found someone's watch, this app connects you with others to facilitate the return of items.
✨ Features

User Authentication: Secure login and account creation with password reset functionality.
Post Management:
    Create new posts for lost or found items.
    Add item name, description, category, and an image.
    View and manage your own posts (edit/delete).
Browse Posts: View all active posts.
Search Functionality: Easily search for specific items by name.
User Profile: View(Full Name, Contact Phone, Account Created date).
Settings: Customize app experience with features like Dark Mode and Font Size adjustment.
Image Support: Attach images to posts for better identification.

📱 Screenshots

![photo_1_2025-06-01_14-58-58](https://github.com/user-attachments/assets/f6be1f13-404f-4d01-a244-11d79dfa37dc)
![photo_4_2025-06-01_14-58-58](https://github.com/user-attachments/assets/40969ff9-91e5-458d-9385-4499c298bde1)

![photo_13_2025-06-01_14-58-58](https://github.com/user-attachments/assets/10211dca-478a-44d8-a67f-9739b39c4c35)
![photo_6_2025-06-01_14-58-58](https://github.com/user-attachments/assets/4d18eec2-04df-4c25-8046-ee2a14905ea8)

![photo_10_2025-06-01_14-58-58](https://github.com/user-attachments/assets/74578a21-451c-418d-b911-5c33fd0010a4)
![photo_7_2025-06-01_14-58-58](https://github.com/user-attachments/assets/e704447f-7f0e-4ff2-8904-b8df4d5b2ffa)



🛠️ Technologies Used

Flutter: UI framework for building natively compiled applications for mobile, web, and desktop from a single codebase.
Dart: The programming language used by Flutter.
Supabase: For the backend, including:
    PostgreSQL Database: For storing application data.
    Supabase Auth: For user authentication.
    Supabase Storage: For storing images associated with posts.
YAML: For managing project dependencies (pubspec.yaml).
Gradle: For Android-specific build configurations (managed by Flutter).

🚀 Getting Started (Using the Pre-built APK)


Go to the Releases section of this GitHub repository .
Look for the app-release.apk (or similar name).
Download the latest APK file to your Android device.

Enable "Install from Unknown Sources":
On your Android device, you might need to enable the "Install from unknown sources" or "Allow apps from unknown sources" option in your device's security settings to install APKs not from the Google Play Store. The exact path varies by Android version and manufacturer:
    Android 8.0 (Oreo) and higher: Go to Settings > Apps & notifications > Special app access > Install unknown apps. Select your browser (or file manager app) and toggle "Allow from this source" on.
    Older Android versions: Go to Settings > Security and check the "Unknown sources" box.

Install the APK:
Locate the downloaded APK file using your device's file manager or the "Downloads" section in your browser.
Tap the APK file to begin the installation process.
Follow the on-screen prompts to install the application.

💻 Building from Source (For Developers)

If you wish to modify the application, contribute, or connect it to your own Supabase project, follow these steps:
Prerequisites

  Flutter SDK: Make sure you have Flutter installed and configured. Follow the official Flutter installation guide: https://flutter.dev/docs/get-started/install
  Android Studio / VS Code: An IDE with Flutter and Dart plugins installed.
  Git: For cloning the repository.
  Supabase Account: You'll need a Supabase project set up for your backend.

Setup & Run

    Clone the repository:
    Bash

git clone https://github.com/Erga1/Lost-Found.git
cd Lost-Found

Get Flutter dependencies:
Bash

    flutter pub get

Set up Supabase Environment Variables:
  Create a .env file in the root of your project to store your Supabase project URL and anonymous public key:

  SUPABASE_URL=YOUR_SUPABASE_PROJECT_URL
  SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY

  (If you use a package like flutter_dotenv, follow its specific setup instructions to load these variables into your app.)
  Database Schema: Ensure your Supabase database tables (e.g., posts, users), authentication, and storage buckets (post_images) are correctly configured in your Supabase project.
  RLS Policies: Verify your Row Level Security (RLS) policies are correctly configured on your Supabase tables.

Run the app from your IDE:
  Open the project in Android Studio or VS Code.
  Select your target device/emulator/simulator.
  Click the "Run" button (or use flutter run in the terminal).
  The app will build and install on your selected device/emulator/simulator.

🤝 Contributor(group memeber)

1. NEGASA RETA                             UGR/31072/15
2. ERGABUS HIRPHA                      UGR/30475/15
3. ABDISA GEBI                                UGR/30019/15 
4. BEKAM BIRHANU                        UGR/30252/15
5. LELISA WAKTOLA                        UGR/30816/15
6. MAHFUZ REDWAN                     UGR/30846/15
7. SEGNI MERGA                             UGR/31202/15

  Fork the Project
  Create your Feature Branch (git checkout -b feature/AmazingFeature)
  Commit your Changes (git commit -m 'Add some AmazingFeature')
  Push to the Branch (git push origin feature/AmazingFeature)
  Open a Pull Request

📄 License

Distributed under the MIT License. See LICENSE for more information.

!!!!disclaimer
        The Forgot Password is not working
