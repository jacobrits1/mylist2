# New Knowledge Base

This document tracks new learnings and insights gained during the development of MyList2.

## Technical Insights

### Flutter 3.29.2 Features
- Material 3 design system implementation
- Performance optimizations with the latest Flutter version
- Widget lifecycle management best practices

### Clean Architecture in Flutter
- Separation of concerns using layers (presentation, domain, data)
- Dependency injection patterns with Get_it
- Repository pattern implementation for data management

### State Management
- BLoC pattern best practices
- State immutability principles
- Event-driven architecture implementation

### Performance Optimization
- Widget rebuilding optimization techniques
- Memory management best practices
- Lazy loading implementation strategies

### Material 3 Design
- Modern UI components and layouts
- Theme customization and dynamic theming
- Responsive design principles

### UI Implementation Insights
- Tab-based Navigation
  - Using TabController for smooth category switching
  - Implementing custom tab indicators
  - Handling tab state persistence

- Material 3 Components
  - SearchBar widget with modern design
  - Card-based list items
  - Dynamic form fields with Material design
  - Floating Action Button integration
  - Filter chips for enhanced search experience
  - Animated container transitions

- Voice Integration
  - Speech-to-text initialization and permissions
  - Real-time voice input handling
  - UI feedback during voice recording
  - Error handling and status management
  - Configurable recording parameters

- Dynamic Lists
  - Checklist implementation with state management
  - Efficient list item updates
  - Responsive list layouts
  - Dismissible widgets for item removal
  - State persistence during list modifications

- User Experience Enhancements
  - Confirmation dialogs for destructive actions
  - Unsaved changes detection
  - Visual feedback for user actions
  - Smooth animations and transitions
  - Error handling and recovery

- BottomNavigationBar Implementation
  - Material 3 BottomNavigationBar design
    - Persistent bottom navigation with labeled icons
    - Quick access to category filters and add functionality
    - State management for active navigation item
    - Smooth transitions between navigation states
    - Accessibility considerations for navigation items
  
  - Navigation Features
    - Quick add functionality for new items
    - Category filtering through bottom navigation
    - Visual feedback for active category
    - Animated icon transitions
    - Badge support for unread or important items
    
  - Best Practices
    - Proper state persistence during navigation
    - Handling of deep linking with bottom navigation
    - Save state handling during category switches
    - Proper elevation and theme integration
    - Platform-specific navigation patterns
    - Keyboard behavior management with bottom navigation

### Key Dependencies and Features
- Speech-to-Text Integration
  - Voice dictation capabilities using speech_to_text package
  - Platform-specific permission handling for microphone access
  - Error handling and feedback mechanisms

- Local Notifications
  - Scheduling and managing reminders with flutter_local_notifications
  - Platform-specific notification handling
  - Background notification processing

- Social Sharing
  - WhatsApp integration using share_plus package
  - Cross-platform sharing capabilities
  - Content formatting for sharing

## Voice Commands in Flutter
- Speech recognition can be used for both dictation and command processing
- Commands can be processed by checking for specific phrases in the recognized text
- Visual feedback is important for voice interactions (confidence indicators, status messages)
- Continuous mode vs. single recognition mode offers different user experiences
- Voice commands can be used to control UI state and perform actions

## Checklist Management
- Checklist items should be immutable for proper state management
- Position tracking helps with reordering and maintaining order
- Timestamps are important for tracking changes and syncing
- Swipe-to-delete provides a natural gesture for item removal
- Text selection and cursor position management improves text input UX 

## Dart Language Insights
- Const constructors cannot use runtime values like DateTime.now()
- Use const constructors only when all values are known at compile time
- For models with runtime values, use regular constructors
- Immutability can still be achieved without const by using final fields 

## Reminder Feature Implementation
### Database Structure
The reminder feature uses SQLite for persistent storage with the following schema:
```sql
CREATE TABLE IF NOT EXISTS reminders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  noteId INTEGER NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  reminderTime TEXT NOT NULL,
  isCompleted INTEGER DEFAULT 0,
  FOREIGN KEY (noteId) REFERENCES notes(id) ON DELETE CASCADE
)
```

### Key Components
1. **NotificationService**
   - Handles local notifications using flutter_local_notifications
   - Manages notification permissions for Android and iOS
   - Schedules notifications based on reminder times
   - Handles notification tap actions

2. **ReminderRepository**
   - Manages CRUD operations for reminders in SQLite
   - Provides methods for querying and filtering reminders
   - Handles cascade deletion with notes

3. **ReminderModel**
   - Represents reminder data structure
   - Handles data conversion between app and database
   - Implements proper equality and hash code

### Best Practices
- Use proper dependency injection for services
- Implement proper error handling
- Follow clean architecture principles
- Use BLoC pattern for state management
- Handle platform-specific notification requirements

### Integration Points
- Note editing screen for setting reminders
- Reminder list view for managing reminders
- Notification handling for reminder alerts

### Local Notifications for Reminders
- Integration with flutter_local_notifications package
- Platform-specific notification channels setup
- Notification scheduling and management:
  - One-time reminders
  - Recurring reminders
  - Reminder modification and cancellation
- Background notification handling
- Deep linking from notifications to specific notes
- Custom notification sounds and vibration patterns

### Reminder UI/UX Implementation
- DateTime picker for setting reminder time
- Reminder status indicators in note list
- Reminder management interface:
  - Create/Edit reminder modal
  - Reminder list view
  - Quick actions (snooze, dismiss, mark complete)
- Visual and auditory feedback for reminder actions
- Accessibility considerations for reminder interfaces

### Best Practices
- Proper timezone handling for reminders
- Battery optimization considerations
- Data backup and restoration
- Error handling and recovery
- User preference management for notifications
- Permission handling for notifications
- State management for reminder updates 

## Project Structure
### Clean Architecture Implementation
```
lib/
├── core/                     # Core functionality and utilities
│   ├── di/                  # Dependency injection setup
│   │   └── dependency_injection.dart
│   ├── themes/             # App theming
│   │   └── app_theme.dart
│   └── utils/              # Utility functions and constants
│
├── data/                    # Data layer
│   ├── models/             # Data models
│   │   ├── category.dart
│   │   ├── checklist_item.dart
│   │   └── reminder_model.dart
│   ├── repositories/       # Repository implementations
│   │   ├── category_repository.dart
│   │   └── reminder_repository.dart
│   └── sources/           # Data sources
│       └── local/        # Local database
│           └── database_helper.dart
│
├── presentation/           # Presentation layer
│   ├── blocs/             # BLoC state management
│   │   ├── category/     # Category-related blocs
│   │   │   ├── category_bloc.dart
│   │   │   ├── category_event.dart
│   │   │   └── category_state.dart
│   │   └── reminder/     # Reminder-related blocs
│   │       ├── reminder_bloc.dart
│   │       ├── reminder_event.dart
│   │       └── reminder_state.dart
│   ├── pages/            # Screen implementations
│   │   ├── home/        # Home screen
│   │   │   └── home_page.dart
│   │   └── note/        # Note editing screen
│   │       └── note_edit_page.dart
│   └── widgets/          # Reusable widgets
│       ├── reminder_dialog.dart
│       └── reminder_list.dart
│
├── services/              # Service implementations
│   └── notification_service.dart
│
└── main.dart             # Application entry point
```

### Key Architectural Components
1. **Core Layer**
   - Dependency injection setup using Get_it
   - Theme configuration with Material 3
   - Common utilities and constants

2. **Data Layer**
   - Models representing data structures
   - Repositories for data operations
   - Local database implementation with SQLite

3. **Presentation Layer**
   - BLoC pattern for state management
   - Screen implementations
   - Reusable widgets
   - Material 3 design components

4. **Services Layer**
   - Platform-specific service implementations
   - Background processing
   - External integrations

### Best Practices
- Clear separation of concerns
- Dependency injection for loose coupling
- Repository pattern for data abstraction
- BLoC pattern for state management
- Single responsibility principle
- Clean and maintainable folder structure
- Modular component design
- Consistent naming conventions 

## SQLite Database Implementation
### Database Schema
The application uses SQLite for persistent storage with the following tables:

1. **Notes Table**
   ```sql
   CREATE TABLE notes(
     id INTEGER PRIMARY KEY AUTOINCREMENT,
     title TEXT NOT NULL,
     content TEXT,
     category_id INTEGER,
     note_type TEXT NOT NULL DEFAULT 'text',
     created_at TEXT NOT NULL,
     updated_at TEXT NOT NULL,
     due_date TEXT,
     FOREIGN KEY (category_id) REFERENCES categories (id)
       ON DELETE SET NULL
   )
   ```

2. **Categories Table**
   ```sql
   CREATE TABLE categories(
     id INTEGER PRIMARY KEY AUTOINCREMENT,
     name TEXT NOT NULL,
     description TEXT,
     created_at TEXT NOT NULL,
     updated_at TEXT NOT NULL
   )
   ```

3. **Checklist Items Table**
   ```sql
   CREATE TABLE checklist_items(
     id INTEGER PRIMARY KEY AUTOINCREMENT,
     note_id INTEGER NOT NULL,
     text TEXT NOT NULL,
     is_checked INTEGER NOT NULL DEFAULT 0,
     position INTEGER NOT NULL,
     created_at TEXT NOT NULL,
     updated_at TEXT NOT NULL,
     FOREIGN KEY (note_id) REFERENCES notes (id)
       ON DELETE CASCADE
   )
   ```

4. **Reminders Table**
   ```sql
   CREATE TABLE reminders(
     id INTEGER PRIMARY KEY AUTOINCREMENT,
     noteId INTEGER NOT NULL,
     title TEXT NOT NULL,
     description TEXT,
     reminderTime TEXT NOT NULL,
     isCompleted INTEGER DEFAULT 0,
     FOREIGN KEY (noteId) REFERENCES notes(id) ON DELETE CASCADE
   )
   ```

### Model Classes
- Each database table has a corresponding model class (Note, Category, ChecklistItem, ReminderModel)
- Models follow immutability principles with copyWith methods
- Proper serialization/deserialization methods (toMap/fromMap)
- Appropriate data validation and type safety

### Repository Pattern
- Each model has a dedicated repository class for CRUD operations
- Clean separation of database logic from business logic
- Repositories handle specific query operations:
  - Filtering by category
  - Text search capabilities
  - Date-based queries
  - Type-specific queries

### Foreign Key Relationships
- Categories can have many notes (one-to-many)
- Notes can have many checklist items (one-to-many)
- Notes can have many reminders (one-to-many)
- ON DELETE CASCADE ensures data integrity
  - When a note is deleted, its checklist items and reminders are also deleted
  - When a category is deleted, associated notes are preserved (category set to null) 

## Sharing Notes via WhatsApp
### Implementation
- Used share_plus package for cross-platform sharing capabilities
- Created a dedicated ShareService with the following features:
  - Content formatting for different note types (text vs checklist)
  - WhatsApp-specific sharing method
  - Generic sharing method for other apps
  - Error handling and user feedback

### Share Content Formatting
- Title formatted with underline for clarity
- Checklist items rendered with checkboxes (✓/☐)
- Text formatting with proper line breaks
- Custom footer attribution

### Share UI/UX Implementation
- Share button in the note editor app bar
- Bottom sheet dialog with sharing options
- WhatsApp-specific option with icon
- General sharing option for other apps
- Visual feedback after sharing

### Best Practices
- Proper error handling for share operations
- Graceful degradation when WhatsApp isn't installed
- Consistent sharing format across platforms
- Share position context for proper UI placement
- State preservation during sharing operations 