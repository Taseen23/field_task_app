# field_task_app

A new Flutter project.

## Overview

The **Field Task App** is designed to help field agents efficiently manage their daily assignments. The app provides:

- **Task Management**: View, create, and manage daily field tasks
- **Location-Based Check-In**: GPS-based proximity verification (within 100 meters) for task check-ins
- **Offline Support**: Full offline capability with automatic data synchronization when connectivity is restored
- **Real-Time Sync**: Seamless synchronization with Firebase Firestore backend
- **Clean Architecture**: Well-organized project structure following MVVM pattern with GetX state management


## Architecture

The project follows **Clean Architecture** principles with the following layers:

### 1. **Presentation Layer** (`lib/presentation/`)
- **Controllers**: GetX controllers managing state and business logic
  - `TaskController`: Manages task operations and state
  - `LocationController`: Manages GPS and location services
- **Pages**: Full-screen UI components
  - `HomeScreen`: Task list and overview
  - `TaskDetailScreen`: Detailed task information and actions
  - `CreateTaskScreen`: Task creation interface
  - `CheckInScreen`: Location verification and check-in
- **Widgets**: Reusable UI components
  - `TaskCard`: Task list item widget
  - `CustomTextField`: Customized text input field

### 2. **Domain Layer** (`lib/domain/`)
- **Entities**: Core business objects
  - `Task`: Task entity with properties and methods
- **Repositories**: Abstract repository interfaces
  - `TaskRepository`: Interface for task data operations

### 3. **Data Layer** (`lib/data/`)
- **Models**: Data transfer objects with serialization
  - `TaskModel`: Task model with JSON serialization and Hive adapter
- **Repositories**: Concrete repository implementations
  - `TaskRepositoryImpl`: Implementation of TaskRepository with Firebase and Hive
- **Local Storage**: Hive database service
  - `HiveService`: Local data persistence and offline support

### 4. **Configuration** (`lib/config/`)
- **AppRoutes**: Route definitions and navigation
- **AppTheme**: Theme configuration and styling


## Key Features


### 1. **Task Management**
- Create new tasks with title, description, due date, and location
- View all tasks with filtering options (All, Pending, Completed)
- Update task status (Pending → Checked In → Completed)
- Delete tasks
- Real-time task statistics and progress tracking

### 2. **Location-Based Features**
- GPS location tracking with high accuracy
- Proximity verification (100-meter radius)
- Distance calculation to task locations
- Location permission handling
- Manual location selection for task creation

### 3. **Offline-First Architecture**
- Local storage with Hive database
- Automatic synchronization when online
- Sync queue for pending operations
- Seamless transition between online and offline modes

### 4. **State Management**
- GetX for reactive state management
- Unidirectional data flow
- Efficient rebuilds with Obx widgets
- Persistent controllers for app-wide state