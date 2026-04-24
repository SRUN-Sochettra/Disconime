# Disconime

Disconime is an enterprise-grade, state-managed, cyber-minimalist terminal-themed anime discovery application built with Flutter.

## Architecture
The application employs an enterprise-layered architecture:
- **Models**: Robust Dart models (`Anime`, `Synopsis`, `Score`) with JSON serialization handle data integrity.
- **Services**: A dedicated `ApiService` encapsulates HTTP interactions with the Jikan API v4.
- **Providers**: Centralized state management using `Provider` for API calls, pagination, and application-wide states (Loading, Loaded, Error).
- **Screens**: A cyber-minimalist UI layered over the state providers to present data interactively.

## Features
- **Top Anime**: Browse the current top-rated anime, powered by infinite scroll pagination.
- **Search**: Real-time terminal-style search capability.
- **Details & Recommendations**: Deep dive into anime synopses and discover similar recommendations.
- **Cyber-Minimalist Theme**: A strict dark mode theme with Space Mono typography and cyber-cyan accents.

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK

### Installation
1. Clone the repository:
   ```bash
   git clone <repository-url>
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Create a `.env` file in the root directory and add the Jikan API URL:
   ```env
   JIKAN_API_URL=https://api.jikan.moe/v4
   ```
4. Run the application:
   ```bash
   flutter run
   ```

## Dependencies
- `provider`: State management.
- `http`: API network requests.
- `google_fonts`: Space Mono typography.
- `flutter_dotenv`: Environment variable configuration.
