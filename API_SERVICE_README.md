# API Service Documentation

This document provides comprehensive information about using the API service in this Flutter application built with Clean Architecture, BLoC pattern, and dependency injection.

## Table of Contents

1. [Overview](#overview)
2. [Setup](#setup)
3. [API Service Features](#api-service-features)
4. [Usage Examples](#usage-examples)
5. [API Constants](#api-constants)
6. [Error Handling](#error-handling)
7. [File Upload](#file-upload)
8. [Authentication](#authentication)
9. [Best Practices](#best-practices)

## Overview

The API service provides a comprehensive solution for making HTTP requests with the following features:

- **All HTTP Methods**: GET, POST, PUT, PATCH, DELETE
- **File Upload**: Single and multiple file uploads
- **Form Data**: URL-encoded and multipart form data
- **Authentication**: Token-based authentication with automatic header injection
- **Error Handling**: Comprehensive error handling with custom exceptions
- **Progress Tracking**: Upload and download progress callbacks
- **Type Safety**: Generic response handling with custom parsers

## Setup

### 1. Dependencies

The following dependencies are already included in `pubspec.yaml`:

```yaml
dependencies:
  dio: ^5.8.0+1
  injectable: ^2.5.0
  get_it: ^8.0.3
  shared_preferences: ^2.5.3
  flutter_bloc: ^9.1.1
  equatable: ^2.0.7
  dartz: ^0.10.1
```

### 2. Dependency Injection

The API service is automatically registered with GetIt through Injectable. Make sure to run:

```bash
flutter packages pub run build_runner build
```

### 3. Initialization

Initialize the API service in your main.dart:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  
  // Initialize authentication state
  final authApiClient = getIt<AuthApiClient>();
  await authApiClient.initializeAuth();
  
  runApp(MyApp());
}
```

## API Service Features

### Core API Service

The `ApiService` class provides the foundation for all HTTP operations:

```dart
@lazySingleton
class ApiService {
  // Generic request method
  Future<ApiResponse<T>> request<T>(ApiRequest request, {T Function(dynamic)? parser})
  
  // HTTP Methods
  Future<ApiResponse<T>> get<T>(String endpoint, {...})
  Future<ApiResponse<T>> post<T>(String endpoint, {...})
  Future<ApiResponse<T>> put<T>(String endpoint, {...})
  Future<ApiResponse<T>> patch<T>(String endpoint, {...})
  Future<ApiResponse<T>> delete<T>(String endpoint, {...})
  
  // File Operations
  Future<ApiResponse<T>> uploadFile<T>(FileUploadRequest request, {...})
  Future<ApiResponse<T>> uploadFiles<T>(MultiFileUploadRequest request, {...})
  Future<ApiResponse<String>> downloadFile(String endpoint, String savePath, {...})
  
  // Form Data
  Future<ApiResponse<T>> sendFormData<T>(String endpoint, {...})
  Future<ApiResponse<T>> sendMultipartFormData<T>(String endpoint, {...})
}
```

### Specialized API Clients

1. **AuthApiClient**: Handles authentication operations
2. **UserApiClient**: Manages user profile operations
3. **FileUploadApiClient**: Specialized for file uploads
4. **GenericApiClient**: Generic operations for custom endpoints

## Usage Examples

### 1. Basic GET Request

```dart
final apiClient = getIt<GenericApiClient>();

final response = await apiClient.get<Map<String, dynamic>>(
  '/users/123',
  requiresAuth: true,
  parser: (data) => data as Map<String, dynamic>,
);

if (response.isSuccess) {
  print('User data: ${response.data}');
} else {
  print('Error: ${response.message}');
}
```

### 2. POST Request with JSON Data

```dart
final response = await apiClient.post<Map<String, dynamic>>(
  '/users',
  data: {
    'name': 'John Doe',
    'email': 'john@example.com',
    'age': 30,
  },
  requiresAuth: true,
  parser: (data) => data as Map<String, dynamic>,
);
```

### 3. File Upload

```dart
final fileUploadClient = getIt<FileUploadApiClient>();

final response = await fileUploadClient.uploadFile(
  file: File('/path/to/file.jpg'),
  fieldName: 'profile_picture',
  additionalFields: {
    'user_id': '123',
    'category': 'profile',
  },
  onProgress: (sent, total) {
    print('Upload progress: ${(sent / total * 100).toStringAsFixed(1)}%');
  },
);
```

### 4. Multiple File Upload

```dart
final files = [
  File('/path/to/file1.jpg'),
  File('/path/to/file2.pdf'),
  File('/path/to/file3.png'),
];

final response = await fileUploadClient.uploadFiles(
  files: files,
  fieldName: 'documents',
  additionalFields: {
    'folder': 'user_documents',
  },
  onProgress: (sent, total) {
    print('Upload progress: ${(sent / total * 100).toStringAsFixed(1)}%');
  },
);
```

### 5. Form Data Submission

```dart
final response = await apiClient.sendFormData<Map<String, dynamic>>(
  '/contact',
  data: {
    'name': 'John Doe',
    'email': 'john@example.com',
    'message': 'Hello, World!',
    'subject': 'Contact Form',
  },
  parser: (data) => data as Map<String, dynamic>,
);
```

### 6. File Download

```dart
final response = await apiClient.downloadFile(
  '/files/document.pdf',
  '/local/path/document.pdf',
  requiresAuth: true,
  onProgress: (received, total) {
    print('Download progress: ${(received / total * 100).toStringAsFixed(1)}%');
  },
);

if (response.isSuccess) {
  print('File downloaded to: ${response.data}');
}
```

### 7. Authentication

```dart
final authClient = getIt<AuthApiClient>();

// Login
final loginResponse = await authClient.login('user@example.com', 'password123');

if (loginResponse.isSuccess) {
  print('Login successful');
  // Token is automatically saved and set for future requests
} else {
  print('Login failed: ${loginResponse.message}');
}

// Register
final registerResponse = await authClient.register(
  email: 'newuser@example.com',
  password: 'password123',
  firstName: 'John',
  lastName: 'Doe',
  phone: '+1234567890',
);

// Logout
await authClient.logout();
```

## API Constants

All API-related constants are defined in `ApiConstants`:

```dart
class ApiConstants {
  // HTTP Methods
  static const String get = 'GET';
  static const String post = 'POST';
  static const String put = 'PUT';
  static const String patch = 'PATCH';
  static const String delete = 'DELETE';

  // Content Types
  static const String contentTypeJson = 'application/json';
  static const String contentTypeFormData = 'multipart/form-data';
  static const String contentTypeUrlEncoded = 'application/x-www-form-urlencoded';

  // Headers
  static const String headerContentType = 'Content-Type';
  static const String headerAccept = 'Accept';
  static const String headerAuthorization = 'Authorization';
  static const String headerBearerPrefix = 'Bearer ';

  // File Upload Constraints
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx', 'txt'];
  static const List<String> allowedVideoTypes = ['mp4', 'mov', 'avi', 'mkv'];

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';
  static const String userProfileEndpoint = '/user/profile';
  static const String uploadFileEndpoint = '/upload';
}
```

## Error Handling

The API service provides comprehensive error handling:

### ApiResponse Wrapper

```dart
class ApiResponse<T> {
  final T? data;
  final String? message;
  final int? statusCode;
  final bool isSuccess;
  final Map<String, dynamic>? headers;
}
```

### Error Types

1. **Network Errors**: Connection timeout, network unavailable
2. **HTTP Errors**: 400, 401, 403, 404, 500, etc.
3. **Parse Errors**: JSON parsing failures
4. **Custom Errors**: Business logic errors

### Usage in BLoC

```dart
Future<void> _onApiCall(ApiCallEvent event, Emitter<ApiState> emit) async {
  emit(const ApiLoading());
  
  try {
    final response = await apiClient.get<Map<String, dynamic>>(
      event.endpoint,
      parser: (data) => data as Map<String, dynamic>,
    );
    
    if (response.isSuccess) {
      emit(ApiSuccess(response.data!));
    } else {
      emit(ApiError(response.message ?? 'Unknown error'));
    }
  } catch (e) {
    emit(ApiError(e.toString()));
  }
}
```

## File Upload

### Validation

Files are automatically validated for:
- File existence
- File size (max 10MB by default)
- File type (configurable allowed types)

### Progress Tracking

```dart
onProgress: (sent, total) {
  final progress = sent / total;
  emit(FileUploadProgress(progress));
}
```

### Supported File Types

- **Images**: jpg, jpeg, png, gif, webp
- **Documents**: pdf, doc, docx, txt
- **Videos**: mp4, mov, avi, mkv

## Authentication

### Token Management

The `AuthApiClient` automatically handles:
- Token storage in SharedPreferences
- Token injection in authenticated requests
- Token refresh
- Logout cleanup

### Usage

```dart
// Initialize auth state on app startup
await authClient.initializeAuth();

// Check if user is logged in
final isLoggedIn = await authClient.isLoggedIn();

// Set token manually (if needed)
apiService.setAuthToken('your-token-here');

// Clear token
apiService.clearAuthToken();
```

## Best Practices

### 1. Use Dependency Injection

Always use GetIt to access API clients:

```dart
final apiClient = getIt<GenericApiClient>();
```

### 2. Handle Errors Properly

Always check `isSuccess` before accessing data:

```dart
if (response.isSuccess && response.data != null) {
  // Use response.data
} else {
  // Handle error with response.message
}
```

### 3. Use Typed Responses

Provide parsers for type safety:

```dart
parser: (data) => UserModel.fromJson(data as Map<String, dynamic>)
```

### 4. Use Progress Callbacks

For file operations, always provide progress callbacks:

```dart
onProgress: (sent, total) {
  // Update UI with progress
}
```

### 5. Configure Timeouts

Set appropriate timeouts for different operations:

```dart
timeout: const Duration(minutes: 2), // For large file uploads
```

### 6. Validate Files Before Upload

```dart
if (!file.existsSync()) {
  throw Exception('File does not exist');
}

final fileSize = await file.length();
if (fileSize > ApiConstants.maxFileSize) {
  throw Exception('File too large');
}
```

### 7. Use BLoC for State Management

Integrate API calls with BLoC pattern:

```dart
class MyBloc extends Bloc<MyEvent, MyState> {
  final ApiClient _apiClient;
  
  MyBloc(this._apiClient) : super(MyInitial()) {
    on<FetchDataEvent>(_onFetchData);
  }
  
  Future<void> _onFetchData(FetchDataEvent event, Emitter<MyState> emit) async {
    emit(MyLoading());
    // API call logic
  }
}
```

## Configuration

### Base URL

Update the base URL in `DataConstants`:

```dart
static const String baseUrl = 'https://your-api.com/api/v1/';
```

### Timeouts

Configure timeouts in `DataConstants`:

```dart
static const Duration connectionTimeout = Duration(seconds: 30);
static const Duration receiveTimeout = Duration(seconds: 30);
```

### File Upload Limits

Modify file upload constraints in `ApiConstants`:

```dart
static const int maxFileSize = 20 * 1024 * 1024; // 20MB
static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'];
```

This API service provides a robust, type-safe, and feature-rich solution for all your HTTP communication needs in a Flutter application following clean architecture principles.
