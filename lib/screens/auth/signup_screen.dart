/// User registration authentication screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/auth/auth_cubit.dart';
import '../../blocs/auth/auth_state.dart';
import '../../config/app_dimensions.dart';
import '../../config/app_strings.dart';
import '../../config/router/route_names.dart';
import '../../widgets/common/app_app_bar.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSignup() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().signup(
            fullName: _nameController.text.trim(),
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
          appBar: const AppAppBar(
            title: '',
            showBackButton: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
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
                      AppStrings.signupTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingSm),
                    Text(
                      AppStrings.signupSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing2Xl),
                    AppTextField(
                      controller: _nameController,
                      label: AppStrings.fullName,
                      hint: 'Dr. Jane Doe',
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? AppStrings.requiredField : null,
                    ),
                    const SizedBox(height: AppDimensions.spacingLg),
                    AppTextField(
                      controller: _emailController,
                      label: AppStrings.email,
                      hint: 'jane.doe@example.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return AppStrings.requiredField;
                        if (!v.contains('@')) return AppStrings.invalidEmail;
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.spacingLg),
                    AppTextField(
                      controller: _passwordController,
                      label: AppStrings.password,
                      hint: '••••••••',
                      isPassword: true,
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      validator: (v) {
                        if (v == null || v.isEmpty) return AppStrings.requiredField;
                        if (v.length < 6) return AppStrings.passwordTooShort;
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.spacingLg),
                    AppTextField(
                      controller: _confirmPasswordController,
                      label: AppStrings.confirmPassword,
                      hint: '••••••••',
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      onSubmitted: (_) => _onSignup(),
                      validator: (v) {
                        if (v != _passwordController.text) {
                          return AppStrings.passwordsDoNotMatch;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.spacing2Xl),
                    AppButton.primary(
                      text: AppStrings.signup,
                      isLoading: isLoading,
                      onPressed: _onSignup,
                    ),
                    const SizedBox(height: AppDimensions.spacingLg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.alreadyHaveAccount,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            AppStrings.login,
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
        );
      },
    );
  }
}
