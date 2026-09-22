import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'package:ai_research_assistant/blocs/auth/auth_state.dart';
import 'package:ai_research_assistant/models/data/user_model.dart';
import 'package:ai_research_assistant/config/router/app_router.dart';
import 'package:ai_research_assistant/config/router/route_names.dart';
import 'package:ai_research_assistant/network/api_result.dart';
import 'package:ai_research_assistant/network/interceptors/auth_interceptor.dart';
import 'package:ai_research_assistant/repositories/supabase_auth_repository.dart';
import 'package:ai_research_assistant/services/auth_service.dart';

/// Test double simulating Supabase AuthService without connecting to live backend.
class FakeAuthService extends AuthService {
  bool shouldFail = false;
  String? failMessage;
  String? failCode;
  supabase.User? mockUser;
  supabase.Session? mockSession;

  FakeAuthService({
    this.shouldFail = false,
    this.failMessage,
    this.failCode,
    this.mockUser,
    this.mockSession,
  });

  @override
  supabase.User? get currentUser => mockUser;

  @override
  supabase.Session? get currentSession => mockSession;

  @override
  String? get currentAccessToken => mockSession?.accessToken;

  @override
  Future<supabase.AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    if (shouldFail) {
      throw supabase.AuthException(
        failMessage ?? 'Invalid login credentials',
        statusCode: failCode ?? '400',
      );
    }
    return supabase.AuthResponse(
      user: mockUser,
      session: mockSession,
    );
  }

  @override
  Future<supabase.AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    if (shouldFail) {
      throw supabase.AuthException(
        failMessage ?? 'User already registered',
        statusCode: failCode ?? '422',
      );
    }
    return supabase.AuthResponse(
      user: mockUser,
      session: mockSession,
    );
  }

  @override
  Future<void> resetPasswordForEmail({required String email}) async {
    if (shouldFail) {
      throw supabase.AuthException(
        failMessage ?? 'Email not found',
        statusCode: failCode ?? '404',
      );
    }
  }

  @override
  Future<void> signOut() async {
    if (shouldFail) {
      throw Exception('Network error during sign out');
    }
    mockUser = null;
    mockSession = null;
  }
}

void main() {
  final testSupabaseUser = supabase.User(
    id: 'user-uuid-1234',
    appMetadata: {},
    userMetadata: {'full_name': 'Dr. Alan Turing'},
    aud: 'authenticated',
    createdAt: '2026-01-01T00:00:00.000Z',
    email: 'alan.turing@research.org',
  );

  final testSupabaseSession = supabase.Session(
    accessToken: 'jwt-access-token-xyz',
    tokenType: 'bearer',
    user: testSupabaseUser,
  );

  group('SupabaseAuthRepository Unit Tests', () {
    late AuthInterceptor interceptor;

    setUp(() {
      interceptor = AuthInterceptor();
    });

    test('login success maps UserModel and synchronizes AuthInterceptor', () async {
      final fakeService = FakeAuthService(
        mockUser: testSupabaseUser,
        mockSession: testSupabaseSession,
      );

      final repo = SupabaseAuthRepository(
        authService: fakeService,
        authInterceptor: interceptor,
      );

      final result = await repo.login(
        email: 'alan.turing@research.org',
        password: 'password123',
      );

      expect(result, isA<ApiSuccess>());
      if (result case ApiSuccess(:final data)) {
        expect(data.user.id, equals('user-uuid-1234'));
        expect(data.user.email, equals('alan.turing@research.org'));
        expect(data.user.fullName, equals('Dr. Alan Turing'));
        expect(data.accessToken, equals('jwt-access-token-xyz'));
      }

      expect(interceptor.hasToken, isTrue);
    });

    test('login failure returns ApiFailure with mapped error message', () async {
      final fakeService = FakeAuthService(
        shouldFail: true,
        failMessage: 'Invalid login credentials',
        failCode: '400',
      );

      final repo = SupabaseAuthRepository(
        authService: fakeService,
        authInterceptor: interceptor,
      );

      final result = await repo.login(
        email: 'wrong@example.com',
        password: 'wrongpassword',
      );

      expect(result, isA<ApiFailure>());
      if (result case ApiFailure(:final exception)) {
        expect(exception.message, contains('Invalid login credentials'));
        expect(exception.statusCode, equals(400));
      }
      expect(interceptor.hasToken, isFalse);
    });

    test('signup success returns ApiSuccess with mapped user', () async {
      final fakeService = FakeAuthService(
        mockUser: testSupabaseUser,
        mockSession: testSupabaseSession,
      );

      final repo = SupabaseAuthRepository(
        authService: fakeService,
        authInterceptor: interceptor,
      );

      final result = await repo.signup(
        email: 'alan.turing@research.org',
        password: 'password123',
        fullName: 'Dr. Alan Turing',
      );

      expect(result, isA<ApiSuccess>());
      if (result case ApiSuccess(:final data)) {
        expect(data.user.fullName, equals('Dr. Alan Turing'));
      }
      expect(interceptor.hasToken, isTrue);
    });

    test('signup failure returns ApiFailure', () async {
      final fakeService = FakeAuthService(
        shouldFail: true,
        failMessage: 'User already exists',
        failCode: '422',
      );

      final repo = SupabaseAuthRepository(
        authService: fakeService,
        authInterceptor: interceptor,
      );

      final result = await repo.signup(
        email: 'existing@example.com',
        password: 'password123',
        fullName: 'Existing User',
      );

      expect(result, isA<ApiFailure>());
      if (result case ApiFailure(:final exception)) {
        expect(exception.message, contains('User already exists'));
      }
    });

    test('sendPasswordResetEmail success returns ApiSuccess', () async {
      final fakeService = FakeAuthService();
      final repo = SupabaseAuthRepository(authService: fakeService);

      final result = await repo.sendPasswordResetEmail(email: 'test@example.com');
      expect(result, isA<ApiSuccess>());
    });

    test('sendPasswordResetEmail failure returns ApiFailure', () async {
      final fakeService = FakeAuthService(shouldFail: true, failMessage: 'User not found');
      final repo = SupabaseAuthRepository(authService: fakeService);

      final result = await repo.sendPasswordResetEmail(email: 'notfound@example.com');
      expect(result, isA<ApiFailure>());
    });

    test('logout clears interceptor and returns ApiSuccess', () async {
      interceptor.setToken('existing-token');
      expect(interceptor.hasToken, isTrue);

      final fakeService = FakeAuthService(
        mockUser: testSupabaseUser,
        mockSession: testSupabaseSession,
      );

      final repo = SupabaseAuthRepository(
        authService: fakeService,
        authInterceptor: interceptor,
      );

      final result = await repo.logout();
      expect(result, isA<ApiSuccess>());
      expect(interceptor.hasToken, isFalse);
    });

    test('getCurrentUser returns UserModel when user is logged in', () async {
      final fakeService = FakeAuthService(
        mockUser: testSupabaseUser,
        mockSession: testSupabaseSession,
      );

      final repo = SupabaseAuthRepository(
        authService: fakeService,
        authInterceptor: interceptor,
      );

      final user = await repo.getCurrentUser();
      expect(user, isNotNull);
      expect(user?.email, equals('alan.turing@research.org'));
      expect(interceptor.hasToken, isTrue);
    });

    test('isAuthenticated returns true when session exists, false when null', () async {
      final loggedInService = FakeAuthService(mockSession: testSupabaseSession);
      final loggedInRepo = SupabaseAuthRepository(authService: loggedInService);
      expect(await loggedInRepo.isAuthenticated(), isTrue);

      final loggedOutService = FakeAuthService(mockSession: null);
      final loggedOutRepo = SupabaseAuthRepository(authService: loggedOutService);
      expect(await loggedOutRepo.isAuthenticated(), isFalse);
    });
  });

  group('AuthInterceptor Dynamic Token Tests', () {
    test('dynamic tokenProvider retrieves token and sets Authorization header', () {
      String? dynamicToken = 'dynamic-jwt-999';
      final interceptor = AuthInterceptor(tokenProvider: () => dynamicToken);

      expect(interceptor.hasToken, isTrue);

      final options = RequestOptions(path: '/api/v1/documents');
      interceptor.onRequest(options, RequestInterceptorHandler());

      expect(options.headers['Authorization'], equals('Bearer dynamic-jwt-999'));

      // Dynamic token change
      dynamicToken = null;
      expect(interceptor.hasToken, isFalse);
    });
  });

  group('AppRouter Auth Guard Policy Tests', () {
    final testUser = UserModel(
      id: 'test-user',
      email: 'test@example.com',
      fullName: 'Test User',
      createdAt: DateTime.now(),
    );

    test('unauthenticated users are redirected from protected routes to /login', () {
      const unauthenticatedState = Unauthenticated();

      expect(
        AppRouter.guardRedirect(unauthenticatedState, RouteNames.home),
        equals(RouteNames.login),
      );
      expect(
        AppRouter.guardRedirect(unauthenticatedState, RouteNames.documents),
        equals(RouteNames.login),
      );
      expect(
        AppRouter.guardRedirect(unauthenticatedState, RouteNames.chat),
        equals(RouteNames.login),
      );
      expect(
        AppRouter.guardRedirect(unauthenticatedState, RouteNames.profile),
        equals(RouteNames.login),
      );
    });

    test('public routes (splash, onboarding, auth) are not blocked for unauthenticated users', () {
      const unauthenticatedState = Unauthenticated();

      expect(AppRouter.guardRedirect(unauthenticatedState, RouteNames.splash), isNull);
      expect(AppRouter.guardRedirect(unauthenticatedState, RouteNames.onboarding), isNull);
      expect(AppRouter.guardRedirect(unauthenticatedState, RouteNames.login), isNull);
      expect(AppRouter.guardRedirect(unauthenticatedState, RouteNames.signup), isNull);
      expect(AppRouter.guardRedirect(unauthenticatedState, RouteNames.forgotPassword), isNull);
    });

    test('authenticated users are redirected away from login/signup to /home', () {
      final authenticatedState = Authenticated(testUser);

      expect(
        AppRouter.guardRedirect(authenticatedState, RouteNames.login),
        equals(RouteNames.home),
      );
      expect(
        AppRouter.guardRedirect(authenticatedState, RouteNames.signup),
        equals(RouteNames.home),
      );
      expect(
        AppRouter.guardRedirect(authenticatedState, RouteNames.forgotPassword),
        equals(RouteNames.home),
      );
    });

    test('authenticated users can access protected routes without redirection', () {
      final authenticatedState = Authenticated(testUser);

      expect(AppRouter.guardRedirect(authenticatedState, RouteNames.home), isNull);
      expect(AppRouter.guardRedirect(authenticatedState, RouteNames.documents), isNull);
      expect(AppRouter.guardRedirect(authenticatedState, RouteNames.chat), isNull);
    });

    test('initial or loading auth states do not prematurely redirect to login', () {
      expect(AppRouter.guardRedirect(const AuthInitial(), RouteNames.home), isNull);
      expect(AppRouter.guardRedirect(const AuthLoading(), RouteNames.home), isNull);
    });
  });
}
