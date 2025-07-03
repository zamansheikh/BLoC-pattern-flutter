import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import 'api_service.dart';

/// Authentication API client
@lazySingleton
class AuthApiClient {
  final ApiService _apiService;
  final SharedPreferences _prefs;

  AuthApiClient(this._apiService, this._prefs);

  /// Login with email and password
  Future<ApiResponse<Map<String, dynamic>>> login(
    String email,
    String password,
  ) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      ApiConstants.loginEndpoint,
      data: {'email': email, 'password': password},
      parser: (data) => data as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      final token = response.data!['token'] as String?;
      if (token != null) {
        await _saveToken(token);
        _apiService.setAuthToken(token);
      }
    }

    return response;
  }

  /// Register new user
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      ApiConstants.registerEndpoint,
      data: {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        if (phone != null) 'phone': phone,
      },
      parser: (data) => data as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      final token = response.data!['token'] as String?;
      if (token != null) {
        await _saveToken(token);
        _apiService.setAuthToken(token);
      }
    }

    return response;
  }

  /// Refresh authentication token
  Future<ApiResponse<Map<String, dynamic>>> refreshToken() async {
    final response = await _apiService.post<Map<String, dynamic>>(
      ApiConstants.refreshTokenEndpoint,
      requiresAuth: true,
      parser: (data) => data as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      final token = response.data!['token'] as String?;
      if (token != null) {
        await _saveToken(token);
        _apiService.setAuthToken(token);
      }
    }

    return response;
  }

  /// Logout
  Future<ApiResponse<bool>> logout() async {
    final response = await _apiService.post<bool>(
      ApiConstants.logoutEndpoint,
      requiresAuth: true,
      parser: (data) => true,
    );

    await _clearToken();
    _apiService.clearAuthToken();

    return response;
  }

  /// Initialize authentication state
  Future<void> initializeAuth() async {
    final token = await _getStoredToken();
    if (token != null) {
      _apiService.setAuthToken(token);
    }
  }

  /// Save token to local storage
  Future<void> _saveToken(String token) async {
    await _prefs.setString(DataConstants.tokenKey, token);
  }

  /// Get stored token
  Future<String?> _getStoredToken() async {
    return _prefs.getString(DataConstants.tokenKey);
  }

  /// Clear stored token
  Future<void> _clearToken() async {
    await _prefs.remove(DataConstants.tokenKey);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _getStoredToken();
    return token != null;
  }
}

/// User API client
@lazySingleton
class UserApiClient {
  final ApiService _apiService;

  UserApiClient(this._apiService);

  /// Get user profile
  Future<ApiResponse<Map<String, dynamic>>> getUserProfile() async {
    return await _apiService.get<Map<String, dynamic>>(
      ApiConstants.userProfileEndpoint,
      requiresAuth: true,
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  /// Update user profile
  Future<ApiResponse<Map<String, dynamic>>> updateUserProfile(
    Map<String, dynamic> userData,
  ) async {
    return await _apiService.put<Map<String, dynamic>>(
      ApiConstants.userProfileEndpoint,
      data: userData,
      requiresAuth: true,
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  /// Upload profile picture
  Future<ApiResponse<Map<String, dynamic>>> uploadProfilePicture(
    File imageFile,
  ) async {
    final request = FileUploadRequest(
      endpoint: '${ApiConstants.userProfileEndpoint}/picture',
      file: imageFile,
      fieldName: 'profile_picture',
      requiresAuth: true,
    );

    return await _apiService.uploadFile<Map<String, dynamic>>(
      request,
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  /// Delete user account
  Future<ApiResponse<bool>> deleteAccount() async {
    return await _apiService.delete<bool>(
      ApiConstants.userProfileEndpoint,
      requiresAuth: true,
      parser: (data) => true,
    );
  }
}

/// File upload API client
@lazySingleton
class FileUploadApiClient {
  final ApiService _apiService;

  FileUploadApiClient(this._apiService);

  /// Upload single file
  Future<ApiResponse<Map<String, dynamic>>> uploadFile({
    required File file,
    String? customEndpoint,
    String fieldName = 'file',
    Map<String, dynamic>? additionalFields,
    bool requiresAuth = true,
    ProgressCallback? onProgress,
  }) async {
    if (!_isValidFile(file)) {
      return ApiResponse.failure(
        message: 'Invalid file type or size',
        statusCode: 400,
      );
    }

    final request = FileUploadRequest(
      endpoint: customEndpoint ?? ApiConstants.uploadFileEndpoint,
      file: file,
      fieldName: fieldName,
      additionalFields: additionalFields,
      requiresAuth: requiresAuth,
      onProgress: onProgress,
    );

    return await _apiService.uploadFile<Map<String, dynamic>>(
      request,
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  /// Upload multiple files
  Future<ApiResponse<Map<String, dynamic>>> uploadFiles({
    required List<File> files,
    String? customEndpoint,
    String fieldName = 'files',
    Map<String, dynamic>? additionalFields,
    bool requiresAuth = true,
    ProgressCallback? onProgress,
  }) async {
    for (final file in files) {
      if (!_isValidFile(file)) {
        return ApiResponse.failure(
          message: 'One or more files are invalid',
          statusCode: 400,
        );
      }
    }

    final request = MultiFileUploadRequest(
      endpoint: customEndpoint ?? ApiConstants.uploadFileEndpoint,
      files: files,
      fieldName: fieldName,
      additionalFields: additionalFields,
      requiresAuth: requiresAuth,
      onProgress: onProgress,
    );

    return await _apiService.uploadFiles<Map<String, dynamic>>(
      request,
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  /// Validate file
  bool _isValidFile(File file) {
    if (!file.existsSync()) return false;

    final fileName = file.path.split('/').last.toLowerCase();
    final extension = fileName.split('.').last;

    // Check file size
    final fileSize = file.lengthSync();
    if (fileSize > ApiConstants.maxFileSize) return false;

    // Check file type
    final allowedTypes = [
      ...ApiConstants.allowedImageTypes,
      ...ApiConstants.allowedDocumentTypes,
      ...ApiConstants.allowedVideoTypes,
    ];

    return allowedTypes.contains(extension);
  }
}

/// Generic API client for custom endpoints
@lazySingleton
class GenericApiClient {
  final ApiService _apiService;

  GenericApiClient(this._apiService);

  /// Generic GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = false,
    T Function(dynamic)? parser,
  }) async {
    return await _apiService.get<T>(
      endpoint,
      queryParameters: queryParameters,
      headers: headers,
      requiresAuth: requiresAuth,
      parser: parser,
    );
  }

  /// Generic POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = false,
    T Function(dynamic)? parser,
  }) async {
    return await _apiService.post<T>(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      requiresAuth: requiresAuth,
      parser: parser,
    );
  }

  /// Generic PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = false,
    T Function(dynamic)? parser,
  }) async {
    return await _apiService.put<T>(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      requiresAuth: requiresAuth,
      parser: parser,
    );
  }

  /// Generic PATCH request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = false,
    T Function(dynamic)? parser,
  }) async {
    return await _apiService.patch<T>(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      requiresAuth: requiresAuth,
      parser: parser,
    );
  }

  /// Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = false,
    T Function(dynamic)? parser,
  }) async {
    return await _apiService.delete<T>(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      requiresAuth: requiresAuth,
      parser: parser,
    );
  }

  /// Send form data
  Future<ApiResponse<T>> sendFormData<T>(
    String endpoint, {
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = false,
    T Function(dynamic)? parser,
  }) async {
    return await _apiService.sendFormData<T>(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      requiresAuth: requiresAuth,
      parser: parser,
    );
  }

  /// Send multipart form data
  Future<ApiResponse<T>> sendMultipartFormData<T>(
    String endpoint, {
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = false,
    T Function(dynamic)? parser,
  }) async {
    return await _apiService.sendMultipartFormData<T>(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      requiresAuth: requiresAuth,
      parser: parser,
    );
  }

  /// Download file
  Future<ApiResponse<String>> downloadFile(
    String endpoint,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = false,
    ProgressCallback? onProgress,
  }) async {
    return await _apiService.downloadFile(
      endpoint,
      savePath,
      queryParameters: queryParameters,
      headers: headers,
      requiresAuth: requiresAuth,
      onProgress: onProgress,
    );
  }
}
