# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- Initial project setup with Flutter 3.29.2
- Project structure following clean architecture
- Basic Material 3 theme implementation
- Home page with basic UI elements
- Documentation (README.md, CHANGELOG.md)
- Development guidelines and project structure
- Basic dependency setup (BLoC, Get_it, SQLite)
- Added new dependencies:
  - speech_to_text for voice dictation feature
  - flutter_local_notifications for reminder functionality
  - share_plus for WhatsApp sharing capability
- Implemented Home Screen UI:
  - Category-based note filtering with tabs
  - Material 3 search bar
  - Note list with preview cards
- Implemented Note Editing Screen:
  - Rich text editing with voice dictation
  - Checklist support with dynamic items
  - Category assignment
  - Save and delete functionality

### Enhanced
- Improved speech recognition:
  - Added visual feedback during recording
  - Error handling and status messages
  - Configurable recording duration
- Enhanced checklist functionality:
  - Swipe-to-delete checklist items
  - Improved item management
- Added confirmation dialogs:
  - Note deletion confirmation
  - Unsaved changes warning
- Enhanced search functionality:
  - Added filter chips for search categories
  - Animated filter transitions
  - Multi-select filter options

### Fixed
- Updated speech_to_text package to version ^7.0.0 for compatibility with Flutter 3.29.2 