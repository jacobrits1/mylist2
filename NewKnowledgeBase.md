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