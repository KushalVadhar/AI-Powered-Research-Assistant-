import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'blocs/auth/auth_cubit.dart';
import 'blocs/chat/chat_bloc.dart';
import 'blocs/chat/chat_event.dart';
import 'blocs/documents/document_bloc.dart';
import 'blocs/documents/document_event.dart';
import 'blocs/theme/theme_cubit.dart';
import 'config/app_constants.dart';
import 'network/http_service.dart';
import 'repositories/auth_repository.dart';
import 'repositories/chat_repository.dart';
import 'repositories/document_repository.dart';
import 'repositories/mock/mock_auth_repository.dart';
import 'repositories/mock/mock_chat_repository.dart';
import 'repositories/mock/mock_document_repository.dart';
import 'repositories/supabase_auth_repository.dart';
import 'repositories/supabase_chat_repository.dart';
import 'repositories/supabase_document_repository.dart';
import 'services/auth_service.dart';
import 'services/supabase_database_service.dart';
import 'services/supabase_storage_service.dart';

/// Application entry point.
void main() async {
  // Step 1: Ensure Flutter engine is ready for async calls
  WidgetsFlutterBinding.ensureInitialized();

  // Step 2: Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Step 3: Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Step 4: Initialize Supabase (or fallback to Mock repositories)
  late final AuthRepository authRepository;
  late final DocumentRepository documentRepository;
  late final ChatRepository chatRepository;

  final httpService = HttpService();

  if (AppConstants.isSupabaseConfigured) {
    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: AppConstants.supabaseAnonKey,
      );
      final authService = AuthService();
      final databaseService = SupabaseDatabaseService();
      final storageService = SupabaseStorageService();

      authRepository = SupabaseAuthRepository(
        authService: authService,
        authInterceptor: httpService.authInterceptor,
      );
      documentRepository = SupabaseDocumentRepository(
        databaseService: databaseService,
        storageService: storageService,
        authService: authService,
        httpService: httpService,
      );
      chatRepository = SupabaseChatRepository(
        databaseService: databaseService,
        authService: authService,
        httpService: httpService,
      );
    } catch (e) {
      debugPrint('Supabase initialization failed: $e. Falling back to Mock repositories.');
      authRepository = MockAuthRepository();
      documentRepository = MockDocumentRepository();
      chatRepository = MockChatRepository();
    }
  } else {
    authRepository = MockAuthRepository();
    documentRepository = MockDocumentRepository();
    chatRepository = MockChatRepository();
  }

  // Step 5: Run app with dependency injection
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<DocumentRepository>.value(value: documentRepository),
        RepositoryProvider<ChatRepository>.value(value: chatRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          // Theme management
          BlocProvider<ThemeCubit>(
            create: (_) => ThemeCubit(),
          ),

          // Authentication state
          BlocProvider<AuthCubit>(
            create: (_) => AuthCubit(authRepository: authRepository)..checkAuthStatus(),
            lazy: false,
          ),

          // Document library state
          BlocProvider<DocumentBloc>(
            create: (_) => DocumentBloc(documentRepository: documentRepository)..add(const LoadDocuments()),
          ),

          // Chat and conversation state
          BlocProvider<ChatBloc>(
            create: (_) => ChatBloc(chatRepository: chatRepository)..add(const LoadConversations()),
          ),
        ],
        child: const App(),
      ),
    ),
  );
}
