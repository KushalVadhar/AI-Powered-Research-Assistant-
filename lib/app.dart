import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';

import 'blocs/auth/auth_cubit.dart';
import 'config/app_theme.dart';
import 'config/router/app_router.dart';
import 'blocs/theme/theme_cubit.dart';
import 'blocs/theme/theme_state.dart';

/// Root widget of the application.
class App extends StatefulWidget {
  final GoRouter? router;

  const App({super.key, this.router});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  GoRouter? _router;
  GoRouterRefreshStream? _refreshStream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.router != null) {
      _router = widget.router;
    } else if (_router == null) {
      try {
        final authCubit = context.read<AuthCubit>();
        _refreshStream = GoRouterRefreshStream(authCubit.stream);
        _router = AppRouter.createRouter(
          authCubit: authCubit,
          refreshListenable: _refreshStream,
        );
      } catch (_) {
        _router = AppRouter.router;
      }
    }
  }

  @override
  void dispose() {
    _refreshStream?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp.router(
          // ── Identity ───────────────────────────────────────
          title: 'AI Research Assistant',
          debugShowCheckedModeBanner: false,

          // ── Theming ────────────────────────────────────────
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeState.themeMode,

          // ── Navigation ─────────────────────────────────────
          routerConfig: _router ?? AppRouter.router,
        );
      },
    );
  }
}
