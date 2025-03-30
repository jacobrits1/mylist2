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
- Category Management:
  - Create, edit, and delete categories
  - SQLite database integration for category persistence
  - Category-based note filtering
  - Category BLoC for state management
  - Category dialog for adding/editing categories
  - Visual feedback for category operations
  - Default categories (Personal, Work, Shopping, Ideas)
- Voice commands for note type selection and management
  - Switch between text and checklist modes
  - Add, remove, and check/uncheck checklist items
  - Change categories using voice
- Enhanced UI for note editing
  - Note type toggle in app bar
  - Voice command help dialog
  - Visual feedback for voice commands
  - Confidence indicator for speech recognition
- Improved checklist functionality
  - Persistent checklist states
  - Position tracking for reordering
  - Swipe-to-delete functionality
  - Proper cursor position management
- Reminder feature for notes
  - SQLite integration for storing reminders
  - Local notifications for reminder alerts
  - UI components for managing reminders
  - Ability to create, edit, and delete reminders
  - Mark reminders as completed
  - Swipe-to-delete functionality for reminders
  - DateTime picker for setting reminder times
  - Visual feedback for reminder status
- Data storage with SQLite:
  - Implemented Note model with proper fields and methods
  - Created NoteRepository for CRUD operations
  - Implemented complete database schema for Notes, Categories, Checklist Items, and Reminders
  - Added foreign key relationships with appropriate cascade actions
  - Implemented query methods for filtering and searching
  - Added date-based and type-based querying
- WhatsApp sharing functionality:
  - Created ShareService for handling different sharing methods
  - Added WhatsApp-specific sharing option in the note editor
  - Implemented proper text formatting for notes and checklists
  - Added bottom sheet dialog for sharing options
  - Added share button to the note edit screen
- Note Editing and Autosave functionality:
  - Created NoteBloc for state management of notes
  - Added ability to reopen and edit existing notes
  - Implemented autosave when exiting the edit screen
  - Added dirty state tracking to detect changes
  - Enhanced NoteRepository with support for checklist items
  - Improved note list to display actual note data
  - Added navigation between note list and edit screens
  - Integrated proper state updates when returning to the list

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
- Improved database structure:
  - Added more robust foreign key constraints
  - Enhanced model classes with immutability principles
  - Improved repository pattern implementation
- Improved navigation flow:
  - Added route parameter support for note editing
  - Enhanced state management during navigation
  - Added auto-refresh of lists after note operations

### Fixed
- Updated speech_to_text package to version ^7.0.0 for compatibility with Flutter 3.29.2
- Fixed ChecklistItem constructor to properly handle runtime DateTime values
- Fixed dependency injection setup for reminder feature
- Corrected NotificationService implementation with proper permission handling
- Updated ReminderRepository with proper database operations
- Fixed ReminderModel implementation with proper data conversion
- Improved error handling in reminder-related components
- Fixed ReminderBloc to use correct method names
- Added proper null safety handling in NotificationService
- Corrected reminder creation and notification scheduling flow
- Fixed notification scheduling by removing deprecated parameter

### Removed
- Removed unused code and dependencies 

### Changed
- Optimized reminder database schema
- Enhanced notification scheduling system
- Improved reminder state management 
- Updated note edit workflow with automatic saving instead of confirmation dialog 