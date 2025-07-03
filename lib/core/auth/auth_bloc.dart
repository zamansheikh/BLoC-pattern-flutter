import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../network/api_clients.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthInitializeEvent extends AuthEvent {
  const AuthInitializeEvent();
}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? phone;

  const AuthRegisterEvent({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.phone,
  });

  @override
  List<Object?> get props => [email, password, firstName, lastName, phone];
}

class AuthLogoutEvent extends AuthEvent {
  const AuthLogoutEvent();
}

class AuthRefreshTokenEvent extends AuthEvent {
  const AuthRefreshTokenEvent();
}

class AuthCheckStatusEvent extends AuthEvent {
  const AuthCheckStatusEvent();
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthSplashLoading extends AuthState {
  const AuthSplashLoading();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final Map<String, dynamic> user;
  final String token;

  const AuthAuthenticated({required this.user, required this.token});

  @override
  List<Object?> get props => [user, token];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthTokenExpired extends AuthState {
  const AuthTokenExpired();
}

// BLoC
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthApiClient _authApiClient;
  final UserApiClient _userApiClient;

  String? _currentToken;
  Map<String, dynamic>? _currentUser;

  AuthBloc(this._authApiClient, this._userApiClient)
    : super(const AuthInitial()) {
    on<AuthInitializeEvent>(_onInitialize);
    on<AuthLoginEvent>(_onLogin);
    on<AuthRegisterEvent>(_onRegister);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthRefreshTokenEvent>(_onRefreshToken);
    on<AuthCheckStatusEvent>(_onCheckStatus);
  }

  // Getters for easy access to current auth state
  bool get isAuthenticated => state is AuthAuthenticated;
  String? get currentToken => _currentToken;
  Map<String, dynamic>? get currentUser => _currentUser;

  Future<void> _onInitialize(
    AuthInitializeEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthSplashLoading());

    try {
      // Initialize auth from stored token
      await _authApiClient.initializeAuth();

      // Check if user is logged in
      final isLoggedIn = await _authApiClient.isLoggedIn();

      if (isLoggedIn) {
        // Try to fetch user profile to validate token
        final profileResponse = await _userApiClient.getUserProfile();

        if (profileResponse.isSuccess && profileResponse.data != null) {
          _currentUser = profileResponse.data!;
          _currentToken = await _authApiClient.getStoredToken();

          emit(AuthAuthenticated(user: _currentUser!, token: _currentToken!));
        } else {
          // Token is invalid, clear it
          await _authApiClient.logout();
          emit(const AuthUnauthenticated());
        }
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError('Failed to initialize authentication: ${e.toString()}'));
    }
  }

  Future<void> _onLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      final response = await _authApiClient.login(event.email, event.password);

      if (response.isSuccess && response.data != null) {
        _currentToken = response.data!['token'] as String?;

        // Fetch user profile after successful login
        final profileResponse = await _userApiClient.getUserProfile();

        if (profileResponse.isSuccess && profileResponse.data != null) {
          _currentUser = profileResponse.data!;

          emit(AuthAuthenticated(user: _currentUser!, token: _currentToken!));
        } else {
          // Login successful but couldn't fetch profile
          _currentUser = response.data!['user'] as Map<String, dynamic>? ?? {};

          emit(AuthAuthenticated(user: _currentUser!, token: _currentToken!));
        }
      } else {
        emit(AuthError(response.message ?? 'Login failed'));
      }
    } catch (e) {
      emit(AuthError('Login error: ${e.toString()}'));
    }
  }

  Future<void> _onRegister(
    AuthRegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final response = await _authApiClient.register(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
      );

      if (response.isSuccess && response.data != null) {
        _currentToken = response.data!['token'] as String?;

        // Fetch user profile after successful registration
        final profileResponse = await _userApiClient.getUserProfile();

        if (profileResponse.isSuccess && profileResponse.data != null) {
          _currentUser = profileResponse.data!;

          emit(AuthAuthenticated(user: _currentUser!, token: _currentToken!));
        } else {
          // Registration successful but couldn't fetch profile
          _currentUser =
              response.data!['user'] as Map<String, dynamic>? ??
              {
                'email': event.email,
                'firstName': event.firstName,
                'lastName': event.lastName,
              };

          emit(AuthAuthenticated(user: _currentUser!, token: _currentToken!));
        }
      } else {
        emit(AuthError(response.message ?? 'Registration failed'));
      }
    } catch (e) {
      emit(AuthError('Registration error: ${e.toString()}'));
    }
  }

  Future<void> _onLogout(AuthLogoutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      await _authApiClient.logout();
      _currentToken = null;
      _currentUser = null;

      emit(const AuthUnauthenticated());
    } catch (e) {
      // Even if logout API fails, clear local state
      _currentToken = null;
      _currentUser = null;
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onRefreshToken(
    AuthRefreshTokenEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final response = await _authApiClient.refreshToken();

      if (response.isSuccess && response.data != null) {
        _currentToken = response.data!['token'] as String?;

        // Fetch updated user profile
        final profileResponse = await _userApiClient.getUserProfile();

        if (profileResponse.isSuccess && profileResponse.data != null) {
          _currentUser = profileResponse.data!;

          emit(AuthAuthenticated(user: _currentUser!, token: _currentToken!));
        }
      } else {
        // Token refresh failed, logout user
        await _authApiClient.logout();
        _currentToken = null;
        _currentUser = null;
        emit(const AuthTokenExpired());
      }
    } catch (e) {
      // Token refresh failed, logout user
      await _authApiClient.logout();
      _currentToken = null;
      _currentUser = null;
      emit(const AuthTokenExpired());
    }
  }

  Future<void> _onCheckStatus(
    AuthCheckStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final isLoggedIn = await _authApiClient.isLoggedIn();

      if (isLoggedIn && _currentUser != null && _currentToken != null) {
        // Try to fetch fresh user data
        final profileResponse = await _userApiClient.getUserProfile();

        if (profileResponse.isSuccess && profileResponse.data != null) {
          _currentUser = profileResponse.data!;

          emit(AuthAuthenticated(user: _currentUser!, token: _currentToken!));
        } else {
          // Profile fetch failed, but we still have a token
          emit(AuthAuthenticated(user: _currentUser!, token: _currentToken!));
        }
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError('Status check failed: ${e.toString()}'));
    }
  }
}
