/// Application settings and configuration screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/theme/theme_cubit.dart';
import '../../blocs/theme/theme_state.dart';
import '../../config/app_constants.dart';
import '../../config/app_dimensions.dart';
import '../../config/app_strings.dart';
import '../../widgets/common/app_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const AppAppBar(title: AppStrings.settings),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPaddingH,
          vertical: AppDimensions.screenPaddingV,
        ),
        children: [
          Text(
            'Appearance',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              return SizedBox(
                width: double.infinity,
                child: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.system,
                      label: Text('System'),
                      icon: Icon(Icons.brightness_auto_rounded),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      label: Text('Light'),
                      icon: Icon(Icons.light_mode_rounded),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      label: Text('Dark'),
                      icon: Icon(Icons.dark_mode_rounded),
                    ),
                  ],
                  selected: {state.themeMode},
                  onSelectionChanged: (Set<ThemeMode> newSelection) {
                    context.read<ThemeCubit>().setThemeMode(newSelection.first);
                  },
                ),
              );
            },
          ),
          const SizedBox(height: AppDimensions.spacing2Xl),

          Text(
            'AI Engine & RAG Configuration',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Card(
            elevation: 0,
            color: theme.brightness == Brightness.light
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.psychology_rounded),
                  title: const Text('LLM Model'),
                  subtitle: const Text('Gemini 1.5 Flash / Pro (Google AI)'),
                  trailing: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.scatter_plot_rounded),
                  title: const Text('Embedding Model'),
                  subtitle: const Text('text-embedding-004 (768 dims)'),
                  trailing: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.storage_rounded),
                  title: const Text('Vector Store'),
                  subtitle: const Text('pgvector on Supabase PostgreSQL'),
                  trailing: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacing2Xl),

          Text(
            'About',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Card(
            elevation: 0,
            color: theme.brightness == Brightness.light
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                ListTile(
                  title: const Text(AppStrings.appName),
                  subtitle: const Text('Full-stack Document Intelligence & RAG Assistant'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text(AppStrings.version),
                  subtitle: const Text(AppConstants.appVersion),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
