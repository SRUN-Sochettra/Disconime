# Disconime

[![Flutter Version](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev/)
[![Dart Version](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev/)
[![API: Jikan](https://img.shields.io/badge/API-Jikan_v4-blue)](https://jikan.moe/)

A high-end anime discovery platform built with Flutter and the Jikan API.

---

## Visuals

<div align="center">
  <img width="584" height="1280" alt="mainscreen" src="https://github.com/user-attachments/assets/5c749abf-e936-4e29-88fb-5b932aa9040c" />
<img width="585" height="1280" alt="mainscreen_light" src="https://github.com/user-attachments/assets/eb3ae508-adbe-4e2f-8cbe-817f33c5e3ff" />
<img width="586" height="1280" alt="searchscreen" src="https://github.com/user-attachments/assets/4b345d7d-0fc9-46b1-8433-8305519ec7b1" />
<img width="584" height="1280" alt="detailscreen" src="https://github.com/user-attachments/assets/a4c0ebc4-7a96-4cfc-b339-49fe72509ca8" />
<img width="585" height="1280" alt="dashboard" src="https://github.com/user-attachments/assets/844e6fd6-0d61-4214-8e95-4c7089258e71" />
</div>

---

## Features

- 🏆 **Top Rankings:** Advanced filtering for highest-rated series.
- 🔍 **Instant Search:** Real-time querying with persistent search history.
- 🌸 **Seasonal Browser:** Explore current and upcoming anime seasons.
- 📅 **Broadcast Schedule:** Track weekly episode releases.
- 🎭 **Genre Exploration:** Categorized discovery system.
- 👤 **Comprehensive Profiles:** Detailed character data and voice actor information.
- 📊 **Dashboard:** Personal viewing statistics.
- 🔖 **Offline-First:** Smart caching mechanisms for network resilience.
- 🌙 **Theming:** Seamless Dark and Light mode transitions.
- 📤 **Native Sharing:** Integrated anime card distribution.

---

## Technical Architecture

### Core Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x |
| Language | Dart 3.x |
| State Management | Provider |
| Routing | GoRouter |
| Data Source | Jikan REST API v4 |
| Local Storage | SharedPreferences |
| Network | http, internet_connection_checker_plus |

### Directory Structure

```text
lib/
├── models/        # Data serialization and domain models
├── providers/     # State management and business logic
├── screens/       # Primary UI views
├── services/      # API, Cache, and Connectivity interfaces
├── theme/         # Application styling and color palettes
├── utils/         # Error handling and utility functions
├── widgets/       # Reusable UI components
└── router/        # GoRouter configuration
```

---

## Getting Started

### Prerequisites
- Flutter SDK ^3.10.4
- Dart SDK
- Target deployment device or emulator

### Installation

1. Clone the repository:
```bash
git clone [https://github.com/SRUN-Sochettra/disconime.git](https://github.com/SRUN-Sochettra/disconime.git)
cd disconime
```

2. Install dependencies:
```bash
flutter pub get
```

3. Environment Configuration:
Create a `.env` file at the project root matching the provided `.env.example` structure:
```text
JIKAN_API_URL=[https://api.jikan.moe/v4](https://api.jikan.moe/v4)
```

4. Execute static analysis and tests to verify environment integrity:
```bash
flutter analyze
flutter test
```

5. Run the application:
```bash
flutter run
```

---

## Quality Assurance
This repository enforces strict static analysis. Ensure all modifications pass the `flutter analyze` pipeline and meet coverage requirements in `flutter test` before issuing pull requests.

---

## Developer

**Srun Sochettra**
*Professional NullPointerException Hunter*

---

## License

This project is maintained for educational purposes.
