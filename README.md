# simplecalorietracker

AI calorie tracker Flutter app that:
- Captures a meal image from the device camera.
- Uses Google Gemini to identify foods and estimate grams.
- Uses FatSecret (`foods.search.v3`) to fetch calories and macros.

## Setup

```bash
flutter pub get
```

Run with API credentials:

```bash
flutter run \
  --dart-define=GEMINI_API_KEY=your_key \
  --dart-define=FATSECRET_CLIENT_ID=your_id \
  --dart-define=FATSECRET_CLIENT_SECRET=your_secret
```

## Architecture

Feature-first structure with Riverpod:
- `lib/features/camera` for camera capture
- `lib/features/recognition` for Gemini food recognition
- `lib/features/nutrition` for FatSecret nutrition lookup and state orchestration
