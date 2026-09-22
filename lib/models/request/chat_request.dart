/// Chat message request DTO.
/// DESIGN DECISION — documentId is required:
/// Every chat question must be grounded in a document. The backend
/// uses documentId to know WHICH document's chunks to search.
/// Without it, the RAG pipeline doesn't know where to look.
/// DESIGN DECISION — conversationId is nullable:
/// First message in a new conversation has no conversationId yet.
/// The backend creates the conversation and returns its ID.
/// Subsequent messages include the conversationId to continue
/// the conversation.
/// Flow:
///   First message:
///     ChatRequest(documentId: "doc-1", message: "What is the main thesis?")
///     → Backend creates conversation, returns conversationId: "conv-1"
///   Follow-up:
///     ChatRequest(documentId: "doc-1", conversationId: "conv-1",
///                 message: "Can you elaborate on point 3?")
///     → Backend appends to existing conversation
class ChatRequest {
  const ChatRequest({
    required this.documentId,
    this.conversationId,
    required this.message,
  });

  final String documentId;
  final String? conversationId;
  final String message;

  Map<String, dynamic> toJson() {
    return {
      'document_id': documentId,
      if (conversationId != null) 'conversation_id': conversationId,
      'message': message,
    };
  }
}
