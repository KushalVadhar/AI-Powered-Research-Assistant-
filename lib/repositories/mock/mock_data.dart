import '../../models/data/user_model.dart';
import '../../models/data/document_model.dart';
import '../../models/data/conversation_model.dart';
import '../../models/data/chat_message_model.dart';
import '../../models/data/citation_model.dart';
import '../../models/enums/document_status.dart';
import '../../models/enums/file_type.dart';
import '../../models/enums/message_role.dart';

/// Realistic mock data for Phase 1 UI development.
class MockData {
  MockData._();

  // ── Timestamps ──────────────────────────────────────────────
  // Realistic timestamps relative to "now"
  static final DateTime _now = DateTime.now();
  static final DateTime _oneHourAgo = _now.subtract(const Duration(hours: 1));
  static final DateTime _threeHoursAgo = _now.subtract(const Duration(hours: 3));
  static final DateTime _oneDayAgo = _now.subtract(const Duration(days: 1));
  static final DateTime _twoDaysAgo = _now.subtract(const Duration(days: 2));
  static final DateTime _fiveDaysAgo = _now.subtract(const Duration(days: 5));
  static final DateTime _oneWeekAgo = _now.subtract(const Duration(days: 7));
  static final DateTime _twoWeeksAgo = _now.subtract(const Duration(days: 14));

  // ── User ────────────────────────────────────────────────────
  static final UserModel currentUser = UserModel(
    id: 'user-001',
    email: 'alex.chen@example.com',
    fullName: 'Alex Chen',
    avatarUrl: null,
    createdAt: _twoWeeksAgo,
  );

  // ── Documents ───────────────────────────────────────────────
  static final List<DocumentModel> documents = [
    DocumentModel(
      id: 'doc-001',
      userId: 'user-001',
      name: 'Attention Is All You Need.pdf',
      fileUrl: 'documents/user-001/attention-is-all-you-need.pdf',
      fileType: FileType.pdf,
      fileSize: 2 * 1024 * 1024 + 340 * 1024, // 2.3 MB
      pageCount: 15,
      status: DocumentStatus.ready,
      summary: 'This paper introduces the Transformer architecture, which '
          'relies entirely on self-attention mechanisms, dispensing with '
          'recurrence and convolutions entirely.',
      createdAt: _oneWeekAgo,
      updatedAt: _oneWeekAgo,
    ),
    DocumentModel(
      id: 'doc-002',
      userId: 'user-001',
      name: 'GPT-4 Technical Report.pdf',
      fileUrl: 'documents/user-001/gpt-4-technical-report.pdf',
      fileType: FileType.pdf,
      fileSize: 5 * 1024 * 1024 + 800 * 1024, // 5.8 MB
      pageCount: 98,
      status: DocumentStatus.ready,
      createdAt: _fiveDaysAgo,
      updatedAt: _fiveDaysAgo,
    ),
    DocumentModel(
      id: 'doc-003',
      userId: 'user-001',
      name: 'Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks.pdf',
      fileUrl: 'documents/user-001/rag-paper.pdf',
      fileType: FileType.pdf,
      fileSize: 1 * 1024 * 1024 + 200 * 1024, // 1.2 MB
      pageCount: 12,
      status: DocumentStatus.ready,
      createdAt: _twoDaysAgo,
      updatedAt: _twoDaysAgo,
    ),
    DocumentModel(
      id: 'doc-004',
      userId: 'user-001',
      name: 'Q3 2024 Financial Report.pdf',
      fileUrl: 'documents/user-001/q3-financial-report.pdf',
      fileType: FileType.pdf,
      fileSize: 3 * 1024 * 1024, // 3.0 MB
      pageCount: 42,
      status: DocumentStatus.processing,
      createdAt: _threeHoursAgo,
    ),
    DocumentModel(
      id: 'doc-005',
      userId: 'user-001',
      name: 'Project Requirements Specification.docx',
      fileUrl: 'documents/user-001/requirements-spec.docx',
      fileType: FileType.docx,
      fileSize: 450 * 1024, // 450 KB
      pageCount: 28,
      status: DocumentStatus.ready,
      createdAt: _oneDayAgo,
      updatedAt: _oneDayAgo,
    ),
    DocumentModel(
      id: 'doc-006',
      userId: 'user-001',
      name: 'Meeting Notes - AI Strategy Planning.txt',
      fileUrl: 'documents/user-001/meeting-notes.txt',
      fileType: FileType.txt,
      fileSize: 24 * 1024, // 24 KB
      pageCount: 5,
      status: DocumentStatus.ready,
      createdAt: _oneHourAgo,
      updatedAt: _oneHourAgo,
    ),
    DocumentModel(
      id: 'doc-007',
      userId: 'user-001',
      name: 'Corrupted Upload Test.pdf',
      fileUrl: 'documents/user-001/corrupted.pdf',
      fileType: FileType.pdf,
      fileSize: 100 * 1024,
      status: DocumentStatus.failed,
      createdAt: _twoDaysAgo,
    ),
    DocumentModel(
      id: 'doc-008',
      userId: 'user-001',
      name: 'New Research Paper Draft.pdf',
      fileUrl: 'documents/user-001/new-paper.pdf',
      fileType: FileType.pdf,
      fileSize: 1 * 1024 * 1024 + 800 * 1024, // 1.8 MB
      status: DocumentStatus.pending,
      createdAt: _now,
    ),
  ];

  // ── Citations ───────────────────────────────────────────────
  static const List<CitationModel> _transformerCitations = [
    CitationModel(
      chunkId: 'chunk-001-03',
      documentId: 'doc-001',
      documentName: 'Attention Is All You Need.pdf',
      pageNumber: 3,
      contentPreview:
          'The Transformer follows an encoder-decoder structure using '
          'stacked self-attention and point-wise, fully connected layers '
          'for both the encoder and decoder...',
    ),
    CitationModel(
      chunkId: 'chunk-001-05',
      documentId: 'doc-001',
      documentName: 'Attention Is All You Need.pdf',
      pageNumber: 5,
      contentPreview:
          'An attention function can be described as mapping a query and '
          'a set of key-value pairs to an output, where the query, keys, '
          'values, and output are all vectors...',
    ),
  ];

  static const List<CitationModel> _ragCitations = [
    CitationModel(
      chunkId: 'chunk-003-02',
      documentId: 'doc-003',
      documentName:
          'Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks.pdf',
      pageNumber: 2,
      contentPreview:
          'We introduce RAG models where the parametric memory is a '
          'pre-trained seq2seq model and the non-parametric memory is a '
          'dense vector index of Wikipedia...',
    ),
  ];

  // ── Chat Messages ───────────────────────────────────────────
  static final List<ChatMessageModel> transformerChatMessages = [
    ChatMessageModel(
      id: 'msg-001',
      conversationId: 'conv-001',
      role: MessageRole.user,
      content: 'What is the main contribution of the Transformer paper?',
      createdAt: _oneWeekAgo,
    ),
    ChatMessageModel(
      id: 'msg-002',
      conversationId: 'conv-001',
      role: MessageRole.assistant,
      content:
          'The main contribution of "Attention Is All You Need" is the '
          'introduction of the **Transformer architecture**, which relies '
          'entirely on self-attention mechanisms. Unlike previous sequence '
          'models like RNNs and LSTMs, the Transformer:\n\n'
          '1. **Eliminates recurrence** — it processes all positions in '
          'parallel, making it significantly faster to train.\n\n'
          '2. **Uses multi-head attention** — allowing the model to attend '
          'to information from different representation subspaces at '
          'different positions.\n\n'
          '3. **Achieves state-of-the-art results** on machine translation '
          'benchmarks (WMT 2014 English-to-German and English-to-French) '
          'while requiring significantly less training time.\n\n'
          'The architecture has since become the foundation for most modern '
          'NLP models, including BERT, GPT, and their successors.',
      createdAt: _oneWeekAgo.add(const Duration(seconds: 5)),
      citations: _transformerCitations,
    ),
    ChatMessageModel(
      id: 'msg-003',
      conversationId: 'conv-001',
      role: MessageRole.user,
      content: 'How does self-attention differ from traditional attention?',
      createdAt: _oneWeekAgo.add(const Duration(minutes: 2)),
    ),
    ChatMessageModel(
      id: 'msg-004',
      conversationId: 'conv-001',
      role: MessageRole.assistant,
      content:
          'Traditional attention (as used in seq2seq models) computes '
          'attention between the **encoder output** and the **decoder '
          'input** — it looks at the source sequence to decide what to '
          'focus on when generating each output token.\n\n'
          'Self-attention, in contrast, computes attention of a sequence '
          '**with itself**. Each position in the sequence attends to all '
          'other positions in the same sequence. This allows the model to '
          'capture dependencies between any two positions regardless of '
          'distance, in a single step.\n\n'
          'Key differences:\n'
          '- **Scope**: Traditional = cross-sequence. Self = within-sequence.\n'
          '- **Parallelization**: Self-attention can process all positions '
          'simultaneously.\n'
          '- **Long-range dependencies**: Self-attention captures them in O(1) '
          'steps vs O(n) for RNNs.',
      createdAt: _oneWeekAgo.add(const Duration(minutes: 2, seconds: 8)),
      citations: _transformerCitations,
    ),
  ];

  static final List<ChatMessageModel> ragChatMessages = [
    ChatMessageModel(
      id: 'msg-005',
      conversationId: 'conv-002',
      role: MessageRole.user,
      content: 'What is Retrieval-Augmented Generation?',
      createdAt: _twoDaysAgo,
    ),
    ChatMessageModel(
      id: 'msg-006',
      conversationId: 'conv-002',
      role: MessageRole.assistant,
      content:
          'Retrieval-Augmented Generation (RAG) is a technique that combines '
          'the strengths of retrieval-based and generative models. Instead '
          'of relying solely on what the model has learned during training, '
          'RAG **retrieves relevant documents** from an external knowledge '
          'source and uses them as additional context for generating responses.\n\n'
          'The key components are:\n\n'
          '1. **Retriever**: Finds relevant documents/passages based on the '
          'input query using dense vector similarity search.\n\n'
          '2. **Generator**: A seq2seq model (like BART or T5) that generates '
          'the final answer conditioned on both the query and retrieved documents.\n\n'
          'This approach is particularly powerful because it allows the model '
          'to access up-to-date information without retraining, and the '
          'retrieved passages serve as verifiable sources for the generated answer.',
      createdAt: _twoDaysAgo.add(const Duration(seconds: 6)),
      citations: _ragCitations,
    ),
  ];

  // ── Conversations ───────────────────────────────────────────
  static final List<ConversationModel> conversations = [
    ConversationModel(
      id: 'conv-001',
      userId: 'user-001',
      documentId: 'doc-001',
      title: 'Understanding the Transformer Architecture',
      documentName: 'Attention Is All You Need.pdf',
      createdAt: _oneWeekAgo,
      updatedAt: _oneWeekAgo.add(const Duration(minutes: 2)),
      lastMessage: transformerChatMessages.last,
    ),
    ConversationModel(
      id: 'conv-002',
      userId: 'user-001',
      documentId: 'doc-003',
      title: 'RAG Paper Key Concepts',
      documentName:
          'Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks.pdf',
      createdAt: _twoDaysAgo,
      updatedAt: _twoDaysAgo.add(const Duration(minutes: 1)),
      lastMessage: ragChatMessages.last,
    ),
    ConversationModel(
      id: 'conv-003',
      userId: 'user-001',
      documentId: 'doc-002',
      title: 'GPT-4 Capabilities and Limitations',
      documentName: 'GPT-4 Technical Report.pdf',
      createdAt: _fiveDaysAgo,
      updatedAt: _fiveDaysAgo,
    ),
  ];

  // ── Suggested Questions ─────────────────────────────────────
  /// Suggested questions shown to the user before they start chatting.
  static const List<String> suggestedQuestions = [
    'What are the main findings of this document?',
    'Summarize the key points in simple terms.',
    'What methodology was used in this research?',
    'Are there any limitations mentioned?',
    'What are the implications of these findings?',
  ];
}
