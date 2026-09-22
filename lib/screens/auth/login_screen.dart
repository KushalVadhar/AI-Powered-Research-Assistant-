/// User login authentication screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/auth/auth_cubit.dart';
import '../../blocs/auth/auth_state.dart';
import '../../config/app_dimensions.dart';
import '../../config/app_strings.dart';
import '../../config/router/route_names.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'alex.chen@example.com');
  final _passwordController = TextEditingController(text: 'password123');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.go(RouteNames.home);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.screenPaddingH,
                  vertical: AppDimensions.screenPaddingV,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        ),
                        child: Icon(
                          Icons.auto_stories_rounded,
                          color: colorScheme.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXl),
                      Text(
                        AppStrings.loginTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingSm),
                      Text(
                        AppStrings.loginSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacing2Xl),
                      AppTextField(
                        controller: _emailController,
                        label: AppStrings.email,
                        hint: 'name@example.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppStrings.requiredField;
                          }
                          if (!value.contains('@')) {
                            return AppStrings.invalidEmail;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.spacingLg),
                      AppTextField(
                        controller: _passwordController,
                        label: AppStrings.password,
                        hint: '••••••••',
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        onSubmitted: (_) => _onLogin(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.requiredField;
                          }
                          if (value.length < 6) {
                            return AppStrings.passwordTooShort;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.spacingSm),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.push(RouteNames.forgotPassword),
                          child: Text(
                            AppStrings.forgotPassword,
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingLg),
                      AppButton.primary(
                        text: AppStrings.login,
                        isLoading: isLoading,
                        onPressed: _onLogin,
                      ),
                      const SizedBox(height: AppDimensions.spacing2Xl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.dontHaveAccount,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push(RouteNames.signup),
                            child: Text(
                              AppStrings.signup,
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
