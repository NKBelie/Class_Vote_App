# ClassVote — Flutter Mobile Application

## Project Overview

ClassVote is a Flutter-based student election application designed to help students manage candidates, cast votes, and view election results through a simple mobile interface.

The application uses a deep-purple and white theme and includes four main screens: Dashboard, Candidates, Vote, and Results.

## Features

- Dashboard with election statistics and candidate previews
- Candidate registration, editing, and deletion
- Candidate selection and vote confirmation
- Election results with vote totals, percentages, and rankings
- Election reset with confirmation
- Local data persistence using `shared_preferences`
- Live Kigali weather using the Open-Meteo API
- Loading indicators, offline error handling, and Retry functionality

## Technologies Used

- Flutter and Dart
- Material Design
- `shared_preferences` for local persistence
- `http` for API requests
- Open-Meteo weather API
- Android Studio

## Local Data Persistence

ClassVote uses `shared_preferences` to save candidates, vote totals, and voting status on the device. Saved information remains available after the application is closed and reopened.

This is a single-device demonstration and is not a secure, multi-user election system.

### Before Closing the Application

![Before closing](screenshots/before.png)

### After Reopening the Application

![After running again](screenshots/after.png)

## Live API Integration

The Dashboard retrieves current Kigali weather information from the Open-Meteo API, including temperature, weather conditions, and wind speed.

### Live API Response

![Live data from an API](screenshots/api.png)

### No Internet and Retry

When the weather request fails, ClassVote displays an error message and a Retry button.

![No internet](screenshots/no-internet.png)

## How to Run

1. Install Flutter and configure Android Studio.
2. Clone the repository.
3. Open the project folder.
4. Run `flutter pub get`.
5. Connect an Android device or start an emulator.
6. Run `flutter run`.

## Project Purpose

This project demonstrates Flutter UI development, navigation, state management, local persistence, REST API integration, and error handling for a Mobile Programming assignment.