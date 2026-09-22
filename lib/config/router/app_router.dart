import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/auth/auth_cubit.dart';
import '../../blocs/auth/auth_state.dart';
import 'route_names.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/documents/documents_screen.dart';
import '../../screens/document_details/document_details_screen.dart';
import '../../screens/upload_document/upload_document_screen.dart';
import '../../screens/chat/conversation_history_screen.dart';
import '../../screens/chat/chat_screen.dart';
import '../../screens/summary/summary_screen.dart';
import '../../screens/compare_documents/compare_documents_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/settings/settings_screen.dart';

/// Helper to convert a Stream into a Listenable for GoRouter refresh.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// GoRouter configuration wiring declarative routes to real application screens.
class AppRouter {
  AppRouter._();

  /// Pure routing policy determining whether a route transition should be redirected.
  static String? guardRedirect(AuthState? authState, String matchedLocation) {
    if (authState == null) return null;

    final isSplash = matchedLocation == RouteNames.splash;
    final isOnboarding = matchedLocation == RouteNames.onboarding;
    final isAuthRoute = matchedLocation == RouteNames.login ||
        matchedLocation == RouteNames.signup ||
        matchedLocation == RouteNames.forgotPassword;

    // Do not intercept splash or onboarding screens
    if (isSplash || isOnboarding) return null;

    final isAuthenticated = authState is Authenticated;

    // If authenticated and trying to view auth screens, redirect to /home
    if (isAuthenticated && isAuthRoute) {
      return RouteNames.home;
    }

    // If unauthenticated and trying to view private screens, redirect to /login
    if (!isAuthenticated && !isAuthRoute) {
      if (authState is AuthInitial || authState is AuthLoading) {
        return null;
      }
      return RouteNames.login;
    }

    return null;
  }

  /// Creates a GoRouter instance with optional auth cubit listening and route guards.
  static GoRouter createRouter({
    AuthCubit? authCubit,
    Listenable? refreshListenable,
    String initialLocation = RouteNames.splash,
  }) {
    return GoRouter(
      initialLocation: initialLocation,
      debugLogDiagnostics: false,
      refreshListenable: refreshListenable,
      redirect: (context, state) {
        AuthState? authState;
        try {
          authState = authCubit?.state ?? context.read<AuthCubit>().state;
        } catch (_) {
          authState = null;
        }

        return guardRedirect(authState, state.matchedLocation);
      },
      routes: [
      // ── Root / Splash ──────────────────────────────────────
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ── Onboarding ────────────────────────────────────────
      GoRoute(
        path: RouteNames.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ── Auth ──────────────────────────────────────────────
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ── Home ──────────────────────────────────────────────
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // ── Documents ─────────────────────────────────────────
      GoRoute(
        path: RouteNames.documents,
        name: 'documents',
        builder: (context, state) => const DocumentsScreen(),
      ),
      GoRoute(
        path: RouteNames.documentDetails,
        name: 'document-details',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return DocumentDetailsScreen(documentId: id);
        },
      ),
      GoRoute(
        path: RouteNames.uploadDocument,
        name: 'upload-document',
        builder: (context, state) => const UploadDocumentScreen(),
      ),

      // ── Chat ──────────────────────────────────────────────
      GoRoute(
        path: RouteNames.conversations,
        name: 'conversations',
        builder: (context, state) => const ConversationHistoryScreen(),
      ),
      GoRoute(
        path: RouteNames.chat,
        name: 'chat',
        builder: (context, state) {
          final conversationId = state.pathParameters['conversationId'] ?? 'conv-001';
          return ChatScreen(conversationId: conversationId);
        },
      ),

      // ── Summary ───────────────────────────────────────────
      GoRoute(
        path: RouteNames.summary,
        name: 'summary',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return SummaryScreen(documentId: id);
        },
      ),

      // ── Compare ───────────────────────────────────────────
      GoRoute(
        path: RouteNames.compareDocuments,
        name: 'compare',
        builder: (context, state) => const CompareDocumentsScreen(),
      ),

      // ── Profile & Settings ────────────────────────────────
      GoRoute(
        path: RouteNames.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}

  /// Default router singleton.
  static final GoRouter router = createRouter();
}
