import 'package:go_router/go_router.dart';

import '../features/library/document_detail_screen.dart';
import '../features/library/home_screen.dart';
import '../features/scanner/edit_pages_screen.dart';
import '../data/document_repository.dart';

/// Central navigation graph. Kept flat and declarative so deep links and
/// future desktop/web routing come for free.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/doc/:id',
      builder: (context, state) =>
          DocumentDetailScreen(documentId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/edit',
      builder: (context, state) {
        final args = state.extra as EditPagesArgs;
        return EditPagesScreen(args: args);
      },
    ),
  ],
);

/// Arguments passed to the edit-pages screen after capture/import.
class EditPagesArgs {
  EditPagesArgs({
    required this.pageInputs,
    this.existingDocumentId,
  });

  /// Freshly captured/imported pages to review before saving.
  final List<PageInput> pageInputs;

  /// If set, append the pages to this document instead of creating a new one.
  final String? existingDocumentId;
}
