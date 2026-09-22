/// Document comparison request DTO.
/// DESIGN DECISION — List of document IDs (not exactly 2):
/// While the UI might start with comparing 2 documents, the API
/// accepts a list. This makes it easy to support 3+ document
/// comparison later without changing the API contract.
/// DESIGN DECISION — optional focusAreas:
/// Users might want to compare specific aspects: "compare the
/// methodologies" or "compare the financial projections." If null,
/// the backend does a general comparison.
class CompareRequest {
  const CompareRequest({
    required this.documentIds,
    this.focusAreas,
  });

  /// IDs of documents to compare. Must contain at least 2.
  final List<String> documentIds;

  /// Optional specific areas to focus the comparison on.
  final List<String>? focusAreas;

  Map<String, dynamic> toJson() {
    return {
      'document_ids': documentIds,
      if (focusAreas != null) 'focus_areas': focusAreas,
    };
  }
}
