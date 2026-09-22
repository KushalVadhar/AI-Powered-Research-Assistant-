import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ai_research_assistant/app.dart';
import 'package:ai_research_assistant/blocs/auth/auth_cubit.dart';
import 'package:ai_research_assistant/blocs/chat/chat_bloc.dart';
import 'package:ai_research_assistant/blocs/documents/document_bloc.dart';
import 'package:ai_research_assistant/blocs/theme/theme_cubit.dart';
import 'package:ai_research_assistant/config/app_strings.dart';
import 'package:ai_research_assistant/repositories/auth_repository.dart';
import 'package:ai_research_assistant/repositories/chat_repository.dart';
import 'package:ai_research_assistant/repositories/document_repository.dart';
import 'package:ai_research_assistant/repositories/mock/mock_auth_repository.dart';
import 'package:ai_research_assistant/repositories/mock/mock_chat_repository.dart';
import 'package:ai_research_assistant/repositories/mock/mock_document_repository.dart';

void main() {
  testWidgets('App renders splash screen and brand on boot', (WidgetTester tester) async {
    final authRepo = MockAuthRepository();
    final docRepo = MockDocumentRepository();
    final chatRepo = MockChatRepository();

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AuthRepository>.value(value: authRepo),
          RepositoryProvider<DocumentRepository>.value(value: docRepo),
          RepositoryProvider<ChatRepository>.value(value: chatRepo),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
            BlocProvider<AuthCubit>(create: (_) => AuthCubit(authRepository: authRepo)),
            BlocProvider<DocumentBloc>(create: (_) => DocumentBloc(documentRepository: docRepo)),
            BlocProvider<ChatBloc>(create: (_) => ChatBloc(chatRepository: chatRepo)),
          ],
          child: const App(),
        ),
      ),
    );

    await tester.pump();
    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.appTagline), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
  });
}
