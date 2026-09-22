/// User profile and account preferences screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/auth/auth_cubit.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/documents/document_bloc.dart';
import '../../blocs/documents/document_state.dart';
import '../../blocs/theme/theme_cubit.dart';
import '../../blocs/theme/theme_state.dart';
import '../../config/app_dimensions.dart';
import '../../config/app_strings.dart';
import '../../config/router/route_names.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/common/app_app_bar.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/dialogs/confirm_dialog.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const AppAppBar(title: AppStrings.profile),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            context.go(RouteNames.login);
          }
        },
        builder: (context, authState) {
          final user = authState is Authenticated ? authState.user : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPaddingH,
              vertical: AppDimensions.screenPaddingV,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── User Avatar & Name ─────────────────────────────────────
                CircleAvatar(
                  radius: AppDimensions.avatarLg / 2,
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                  child: Text(
                    user != null && user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'R',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                Text(
                  user?.fullName ?? 'Researcher',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  user?.email ?? 'researcher@example.com',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (user != null) ...[
                  const SizedBox(height: 4.0),
                  Text(
                    'Member since ${DateFormatter.formatDate(user.createdAt)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ],
                const SizedBox(height: AppDimensions.spacing2Xl),

                // ── Library Stats ──────────────────────────────────────────
                BlocBuilder<DocumentBloc, DocumentState>(
                  builder: (context, docState) {
                    final count = docState is DocumentLoaded ? docState.documents.length : 0;
                    return Container(
                      padding: const EdgeInsets.all(AppDimensions.spacingLg),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.light
                            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
                            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Documents', '$count', context),
                          Container(width: 1, height: 32, color: colorScheme.outlineVariant),
                          _buildStatItem('Chats', '3', context),
                          Container(width: 1, height: 32, color: colorScheme.outlineVariant),
                          _buildStatItem('Indexed', '64 Pages', context),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppDimensions.spacing2Xl),

                // ── Preferences List ───────────────────────────────────────
                BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, themeState) {
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      ),
                      leading: Icon(
                        themeState.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: colorScheme.primary,
                      ),
                      title: const Text(AppStrings.darkMode),
                      trailing: Switch(
                        value: themeState.isDarkMode,
                        onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
                      ),
                    );
                  },
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  leading: Icon(Icons.settings_outlined, color: colorScheme.primary),
                  title: const Text(AppStrings.settings),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(RouteNames.settings),
                ),
                const SizedBox(height: AppDimensions.spacing2Xl),

                // ── Logout Button ──────────────────────────────────────────
                AppButton.danger(
                  text: AppStrings.logout,
                  leadingIcon: Icons.logout_rounded,
                  onPressed: () async {
                    final confirmed = await ConfirmDialog.show(
                      context: context,
                      title: AppStrings.logout,
                      message: AppStrings.logoutConfirm,
                      confirmText: AppStrings.logout,
                      isDestructive: true,
                    );
                    if (confirmed && context.mounted) {
                      context.read<AuthCubit>().logout();
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
