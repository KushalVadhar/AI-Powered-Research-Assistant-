/// Centralized UI strings.
class AppStrings {
  AppStrings._();

  // ── App ───────────────────────────────────────────────────────
  static const String appName = 'AI Research Assistant';
  static const String appTagline = 'Your intelligent document companion';

  // ── Onboarding ────────────────────────────────────────────────
  static const String onboardingTitle1 = 'Upload Documents';
  static const String onboardingSubtitle1 =
      'Upload PDFs and documents to build your research library.';
  static const String onboardingTitle2 = 'Ask Questions';
  static const String onboardingSubtitle2 =
      'Get AI-powered answers grounded in your documents.';
  static const String onboardingTitle3 = 'Get Insights';
  static const String onboardingSubtitle3 =
      'Summarize, compare, and extract key findings effortlessly.';
  static const String getStarted = 'Get Started';
  static const String skip = 'Skip';
  static const String next = 'Next';

  // ── Auth ──────────────────────────────────────────────────────
  static const String loginTitle = 'Welcome Back';
  static const String loginSubtitle = 'Sign in to continue your research';
  static const String signupTitle = 'Create Account';
  static const String signupSubtitle = 'Start your research journey';
  static const String forgotPasswordTitle = 'Reset Password';
  static const String forgotPasswordSubtitle =
      'Enter your email and we\'ll send you a reset link';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String login = 'Sign In';
  static const String signup = 'Create Account';
  static const String forgotPassword = 'Forgot Password?';
  static const String resetPassword = 'Send Reset Link';
  static const String dontHaveAccount = 'Don\'t have an account? ';
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String or = 'OR';

  // ── Home ──────────────────────────────────────────────────────
  static const String homeGreeting = 'Hello';
  static const String recentDocuments = 'Recent Documents';
  static const String quickActions = 'Quick Actions';
  static const String recentConversations = 'Recent Conversations';
  static const String viewAll = 'View All';
  static const String uploadDocument = 'Upload Document';
  static const String askQuestion = 'Ask a Question';
  static const String summarize = 'Summarize';
  static const String compare = 'Compare';

  // ── Documents ─────────────────────────────────────────────────
  static const String documents = 'Documents';
  static const String noDocuments = 'No documents yet';
  static const String noDocumentsSubtitle =
      'Upload your first document to get started';
  static const String searchDocuments = 'Search documents...';
  static const String uploadYourFirst = 'Upload Your First Document';
  static const String documentDetails = 'Document Details';
  static const String deleteDocument = 'Delete Document';
  static const String processDocument = 'Process Document';
  static const String pages = 'pages';

  // ── Upload ────────────────────────────────────────────────────
  static const String selectFile = 'Select File';
  static const String dragAndDrop = 'Tap to select or drag & drop';
  static const String supportedFormats = 'Supported: PDF, DOCX, TXT';
  static const String maxFileSize = 'Max file size: 20 MB';
  static const String uploading = 'Uploading...';
  static const String processing = 'Processing...';

  // ── Chat ──────────────────────────────────────────────────────
  static const String chat = 'Chat';
  static const String conversations = 'Conversations';
  static const String noConversations = 'No conversations yet';
  static const String noConversationsSubtitle =
      'Start a conversation about your documents';
  static const String typeMessage = 'Ask a question about this document...';
  static const String regenerate = 'Regenerate';
  static const String copy = 'Copy';
  static const String copied = 'Copied to clipboard';
  static const String sources = 'Sources';
  static const String suggestedQuestions = 'Suggested Questions';
  static const String newConversation = 'New Conversation';

  // ── Summary ───────────────────────────────────────────────────
  static const String documentSummary = 'Document Summary';
  static const String generating = 'Generating summary...';
  static const String executiveSummary = 'Executive Summary';
  static const String keyPoints = 'Key Points';
  static const String importantFindings = 'Important Findings';

  // ── Compare ───────────────────────────────────────────────────
  static const String compareDocuments = 'Compare Documents';
  static const String selectDocuments = 'Select documents to compare';
  static const String similarities = 'Similarities';
  static const String differences = 'Differences';
  static const String startComparison = 'Start Comparison';

  // ── Profile ───────────────────────────────────────────────────
  static const String profile = 'Profile';
  static const String settings = 'Settings';
  static const String darkMode = 'Dark Mode';
  static const String logout = 'Logout';
  static const String logoutConfirm = 'Are you sure you want to log out?';
  static const String editProfile = 'Edit Profile';
  static const String about = 'About';
  static const String version = 'Version';

  // ── Validation Messages ───────────────────────────────────────
  static const String requiredField = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String passwordTooShort =
      'Password must be at least 8 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String invalidFileType = 'File type not supported';
  static const String fileTooLarge = 'File size exceeds the maximum limit';

  // ── Error Messages ────────────────────────────────────────────
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError =
      'No internet connection. Please check your network.';
  static const String timeoutError =
      'Request timed out. Please try again later.';
  static const String unauthorizedError = 'Session expired. Please log in again.';
  static const String serverError =
      'Server error. Our team has been notified.';
  static const String uploadError = 'Failed to upload document. Please try again.';
  static const String processingError =
      'Document processing failed. Please try again.';

  // ── Success Messages ──────────────────────────────────────────
  static const String documentUploaded = 'Document uploaded successfully';
  static const String documentDeleted = 'Document deleted';
  static const String passwordResetSent = 'Password reset email sent';
  static const String profileUpdated = 'Profile updated successfully';

  // ── Buttons ───────────────────────────────────────────────────
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String retry = 'Retry';
  static const String done = 'Done';
}
