# DevJourney

DevJourney is a SwiftUI MVP for managing a personal iOS learning path in one place: learning goals, portfolio projects, and job applications.

The app is intentionally small and focused. It is built to show a clean portfolio-ready architecture without overengineering.

## Features

- Track learning goals with completion state and optional target date
- Manage portfolio projects with status, short description, and optional GitHub link
- Track job applications by company, position, status, and optional application date
- Dashboard with key metrics, application status overview, chart, and quick navigation
- Local persistence with SwiftData

## Tech Stack

- SwiftUI for the user interface
- SwiftData for local persistence
- MVVM-light structure for feature logic
- Swift Charts for dashboard visualization
- Swift Testing for focused ViewModel tests

## Architecture

The project follows a simple feature-first structure:

```text
DevJourney/
├── App/
├── Features/
│   ├── Applications/
│   ├── Dashboard/
│   ├── Goals/
│   └── Projects/
└── Models/
```

The MVP keeps the architecture deliberately lightweight:

- Views handle layout and navigation.
- ViewModels handle form state, validation, and user actions.
- SwiftData models represent persisted app data.
- Shared status values are centralized in the model layer.

This keeps each feature easy to understand, test, and extend.

## Current MVP Scope

DevJourney currently focuses on the core flow:

1. Create and edit learning goals.
2. Create and edit portfolio projects.
3. Create and edit job applications.
4. Review progress from the dashboard.

Advanced features such as cloud sync, authentication, reminders, and complex analytics are intentionally out of scope for the MVP.

## Tests

The test target currently covers basic ViewModel behavior:

- Learning goals require a non-empty title.
- Portfolio projects require a non-empty title and keep a default status.
- GitHub links are trimmed when a project is added.
- Job applications require company and position and keep a default status.

Run tests from Xcode or with:

```bash
xcodebuild -project DevJourney/DevJourney.xcodeproj \
  -scheme DevJourney \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:DevJourneyTests \
  test
```

## Next Steps

- Add more focused ViewModel tests as features grow
- Improve empty states with clearer calls to action
- Add lightweight project milestones or notes
- Add screenshots once the MVP visual direction is stable
