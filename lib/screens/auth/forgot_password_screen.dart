/// Password reset request screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_cubit.dart';
import '../../config/app_dimensions.dart';
import '../../config/app_strings.dart';
import '../../widgets/common/app_app_bar.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onResetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      final success = await context.read<AuthCubit>().resetPassword(
            _emailController.text.trim(),
          );
      setState(() {
        _isLoading = false;
        _isSent = success;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const AppAppBar(
        title: '',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH,
            vertical: AppDimensions.screenPaddingV,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.forgotPasswordTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Text(
                  AppStrings.forgotPasswordSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing2Xl),
                if (_isSent) ...[
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spacingLg),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.mark_email_read_rounded,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: AppDimensions.spacingMd),
                        Expanded(
                          child: Text(
                            AppStrings.passwordResetSent,
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXxl),
                ] else ...[
                  AppTextField(
                    controller: _emailController,
                    label: AppStrings.email,
                    hint: 'name@example.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return AppStrings.requiredField;
                      if (!v.contains('@')) return AppStrings.invalidEmail;
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacing2Xl),
                  AppButton.primary(
                    text: AppStrings.resetPassword,
                    isLoading: _isLoading,
                    onPressed: _onResetPassword,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
