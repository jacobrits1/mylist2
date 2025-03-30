# MyList2

A modern todo list mobile application built with Flutter 3.29.2

## Features

- Modern and responsive UI using Material 3 Design
- Clean Architecture with BLoC pattern
- Local data persistence with SQLite
  - Notes with text and checklist support
  - Categories for organization
  - Reminders with local notifications
- Voice commands and dictation
- Social Sharing
  - WhatsApp integration
  - Cross-platform sharing capabilities
  - Formatted note sharing
- Smooth animations and transitions
- Cross-platform support (Android/iOS)

## Tech Stack

- Flutter 3.29.2
- Dart
- BLoC for state management
- SQLite for local storage
- Get_it for dependency injection

## Getting Started

### Prerequisites

- Flutter 3.29.2 or higher
- Android Studio / VS Code with Flutter extensions
- Android Emulator or physical device

### Installation

1. Clone the repository:
```bash
git clone https://github.com/jacobrits1/mylist2.git
```

2. Navigate to project directory:
```bash
cd mylist2
```

3. Get dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── core/                 # Core functionality and utilities
│   ├── constants/        # App constants
│   ├── errors/           # Error handling
│   ├── themes/           # App themes
│   └── utils/            # Utility functions
├── data/                 # Data layer
│   ├── models/           # Data models
│   ├── repositories/     # Repository implementations
│   └── sources/          # Data sources
├── domain/               # Domain layer
│   ├── entities/         # Business entities
│   ├── repositories/     # Repository interfaces
│   └── usecases/        # Business logic
├── presentation/         # Presentation layer
│   ├── blocs/            # BLoC state management
│   ├── pages/            # App screens
│   └── widgets/          # Reusable widgets
└── main.dart            # App entry point
```

## Development Guidelines

- Follow clean architecture principles
- Use BLoC pattern for state management
- Implement proper error handling
- Write clear documentation and comments
- Use code splitting and lazy loading where appropriate
- Follow Material 3 design guidelines

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Data Storage

MyList2 uses SQLite for persistent local storage with the following features:

- **Notes**: Store text notes and checklists with titles, content, categories, and due dates
- **Categories**: Organize notes with customizable categories
- **Checklists**: Create and manage checklist items within notes
- **Reminders**: Set and manage reminders for notes with local notifications

The database schema follows best practices:
- Proper foreign key relationships
- Cascade deletion where appropriate
- Timestamps for tracking changes
- Query optimization for filtering and searching
