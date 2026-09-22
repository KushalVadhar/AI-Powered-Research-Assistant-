import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_research_assistant/models/data/citation_model.dart';
import 'package:ai_research_assistant/models/data/chat_message_model.dart';
import 'package:ai_research_assistant/models/data/document_model.dart';
import 'package:ai_research_assistant/models/enums/document_status.dart';
import 'package:ai_research_assistant/models/enums/file_type.dart';
import 'package:ai_research_assistant/models/enums/message_role.dart';
import 'package:ai_research_assistant/utils/date_formatter.dart';
import 'package:ai_research_assistant/utils/file_utils.dart';
import 'package:ai_research_assistant/widgets/cards/document_card.dart';
import 'package:ai_research_assistant/widgets/chat/chat_message_bubble.dart';
import 'package:ai_research_assistant/widgets/common/app_button.dart';
import 'package:ai_research_assistant/widgets/common/app_empty_state.dart';
import 'package:ai_research_assistant/widgets/common/app_error_widget.dart';
import 'package:ai_research_assistant/widgets/common/app_text_field.dart';
import 'package:ai_research_assistant/widgets/dialogs/confirm_dialog.dart';
import 'package:ai_research_assistant/widgets/document/document_status_badge.dart';

void main() {
  group('FileUtils Unit Tests', () {
    test('formatBytes formats properly', () {
      expect(FileUtils.formatBytes(0), '0 B');
      expect(FileUtils.formatBytes(1024), '1.0 KB');
      expect(FileUtils.formatBytes(1048576), '1.0 MB');
      expect(FileUtils.formatBytes(5242880), '5.0 MB');
    });

    test('getExtension extracts correctly', () {
      expect(FileUtils.getExtension('test.pdf'), 'pdf');
      expect(FileUtils.getExtension('document.DOCX'), 'docx');
      expect(FileUtils.getExtension('no_ext'), '');
    });
  });

  group('DateFormatter Unit Tests', () {
    test('formatRelative produces friendly string', () {
      final now = DateTime.now();
      expect(DateFormatter.formatRelative(now), 'Just now');
      final tenMinAgo = now.subtract(const Duration(minutes: 10));
      expect(DateFormatter.formatRelative(tenMinAgo), '10m ago');
    });
  });

  group('AppButton Widget Tests', () {
    testWidgets('renders text and handles tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Click Me',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
      await tester.tap(find.byType(AppButton));
      expect(tapped, isTrue);
    });

    testWidgets('shows spinner and ignores tap when isLoading', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Submit',
              isLoading: true,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit'), findsNothing);
      await tester.tap(find.byType(AppButton));
      expect(tapped, isFalse);
    });
  });

  group('AppTextField Widget Tests', () {
    testWidgets('renders label and toggles password visibility', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              label: 'Password',
              hint: 'Enter your password',
              isPassword: true,
            ),
          ),
        ),
      );

      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
      final iconButton = find.byType(IconButton);
      expect(iconButton, findsOneWidget);
      await tester.tap(iconButton);
      await tester.pumpAndSettle();
    });
  });

  group('DocumentStatusBadge Widget Tests', () {
    testWidgets('renders Ready status badge correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DocumentStatusBadge(status: DocumentStatus.ready),
          ),
        ),
      );

      expect(find.text('Ready'), findsOneWidget);
    });
  });

  group('DocumentCard Widget Tests', () {
    testWidgets('renders document card details', (tester) async {
      final doc = DocumentModel(
        id: 'doc-1',
        userId: 'user-1',
        name: 'quantum_computing.pdf',
        fileUrl: 'https://example.com/doc.pdf',
        fileType: FileType.pdf,
        fileSize: 2097152, // 2 MB
        pageCount: 15,
        status: DocumentStatus.ready,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DocumentCard(document: doc),
          ),
        ),
      );

      expect(find.text('quantum_computing.pdf'), findsOneWidget);
      expect(find.text('2.0 MB'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
    });
  });

  group('ChatMessageBubble Widget Tests', () {
    testWidgets('renders assistant message and citations', (tester) async {
      final message = ChatMessageModel(
        id: 'msg-1',
        conversationId: 'conv-1',
        role: MessageRole.assistant,
        content: 'This is the AI response with citations.',
        createdAt: DateTime.now(),
        citations: const [
          CitationModel(
            chunkId: 'chunk-1',
            documentId: 'doc-1',
            documentName: 'paper.pdf',
            pageNumber: 3,
            contentPreview: 'This is the cited snippet.',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatMessageBubble(message: message),
          ),
        ),
      );

      expect(find.text('This is the AI response with citations.'), findsOneWidget);
      expect(find.text('1 Sources'), findsOneWidget);
      expect(find.text('paper.pdf'), findsOneWidget);
    });
  });

  group('Empty & Error States Widget Tests', () {
    testWidgets('AppEmptyState renders title and button', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppEmptyState(
              icon: Icons.folder_open,
              title: 'No Documents',
              subtitle: 'Upload your first document',
              buttonText: 'Upload',
              onButtonPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('No Documents'), findsOneWidget);
      expect(find.text('Upload'), findsOneWidget);
      await tester.tap(find.text('Upload'));
      expect(pressed, isTrue);
    });

    testWidgets('AppErrorWidget renders error and triggers retry', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorWidget(
              message: 'Failed to load documents',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Failed to load documents'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });
  });

  group('ConfirmDialog Widget Tests', () {
    testWidgets('renders dialog and dismisses on cancel', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => ConfirmDialog.show(
                  context: context,
                  title: 'Delete Document',
                  message: 'Are you sure?',
                  isDestructive: true,
                ),
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Document'), findsOneWidget);
      expect(find.text('Are you sure?'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Document'), findsNothing);
    });
  });
}
