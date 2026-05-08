# Disconime

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev/)
[![API](https://img.shields.io/badge/API-Jikan%20v4-blue)](https://jikan.moe/)

Disconime is an anime discovery app built with Flutter. It uses the [Jikan](https://jikan.moe/) REST API (unofficial MyAnimeList API) for listings, details, schedules, genres, and character data—without scraping MAL itself.

Package name / repository folder: **`anime_discovery`**.

---

## Showcase

<div align="center">
<img width="590" height="1280" alt="disconimeCover" src="https://github.com/user-attachments/assets/90af3ba1-6642-4597-b75f-404ec36d5c5e" />
</div>

---

## Features

- Rankings and filtering for highly rated anime
- Search with persisted history
- Seasonal anime browser
- Weekly broadcast schedule
- Genre browsing and genre detail flows
- Character discovery and profiles (voice actor info where available)
- Personal favorites and viewing statistics dashboard
- Local response caching with offline-friendly fallbacks when data was previously fetched
- Light and dark themes
- Share anime via the platform share sheet

---

## Stack

| Area | Choice |
|------|--------|
| UI | Flutter (Material), `google_fonts` |
| State | `provider` |
| Routing | `go_router` |
| HTTP | `http` |
| Images | `cached_network_image` |
| Persistence | `shared_preferences` |
| Connectivity | `connectivity_plus`, `internet_connection_checker_plus` |
| Audio | `just_audio` (where used in-app) |

---

## Project layout

```text
lib/
├── models/       # JSON models (anime, characters, schedule, filters, …)
├── providers/    # ChangeNotifier providers
├── screens/      # Full-screen routes
├── services/     # API, cache, connectivity
├── theme/        # App theming
├── utils/        # Helpers
├── widgets/      # Shared widgets
└── router/       # GoRouter setup
```

---

## Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) satisfying **Dart SDK ^3.10.4** (see `pubspec.yaml`)
- Xcode / Android SDK / Chrome as needed for your target platforms

---

## Setup

1. Clone the repository and enter the project directory (folder name may match your fork).

   ```bash
   git clone <repository-url>
   cd anime_discovery
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Optional — environment file at the **repository root**:

   Create a `.env` file if you want to override the API base URL. If `.env` is missing, the app falls back to `https://api.jikan.moe/v4`.

   ```text
   JIKAN_API_URL=https://api.jikan.moe/v4
   ```

   Respect Jikan rate limits and [their usage guidelines](https://docs.api.jikan.moe/).

4. Run checks and tests:

   ```bash
   flutter analyze
   flutter test
   ```

5. Run the app:

   ```bash
   flutter run
   ```

---

## Third-party data

Anime metadata and images are sourced from third parties (MAL via Jikan, CDNs linked in API responses). This app does not claim ownership of that material. Usage is subject to the policies of MyAnimeList, Jikan, and other linked services.

---

## License

This project is released under the [MIT License](LICENSE).

---

## Credits

Developed by **Srun Sochettra** / **© 2026 Disconime Team** (see in-app About screen).
