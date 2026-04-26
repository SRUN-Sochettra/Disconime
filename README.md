# Disconime

A high-end anime discovery platform built with Flutter and the Jikan API.

---

## Features

- 🏆 Top anime rankings with advanced filters
- 🔍 Instant search with history
- 🌸 Seasonal anime browser
- 📅 Weekly broadcast schedule
- 🎭 Genre exploration
- 👤 Character profiles & voice actors
- 📊 Personal statistics dashboard
- 🔖 Offline-first with smart caching
- 🌙 Dark / Light mode
- 📤 Share anime cards

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x |
| Language | Dart |
| State Management | Provider |
| Navigation | GoRouter |
| API | Jikan REST API v4 |
| Caching | SharedPreferences |
| Image Loading | CachedNetworkImage |

---

## Architecture

```
lib/
├── models/        # Data models
├── providers/     # State management
├── screens/       # UI screens
├── services/      # API + Cache + Connectivity
├── theme/         # App theme + colors
├── utils/         # Error utilities
├── widgets/       # Reusable widgets
└── router/        # GoRouter navigation
```

---

## Getting Started

### Prerequisites
- Flutter SDK 3.x
- Dart 3.x
- Android Studio / VS Code

### Installation

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/anime_discovery.git

# Navigate to project
cd anime_discovery

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Environment
This app uses the Jikan public API — no API key required.

If you have a `.env` file, create one at the root:
```
JIKAN_API_URL=https://api.jikan.moe/v4
```

---

## Data Source

Powered by [Jikan API v4](https://jikan.moe/) —
an unofficial MyAnimeList REST API.

---

## Developer

**SRUN-Sochettra**

---

## License

This project is for educational purposes.
