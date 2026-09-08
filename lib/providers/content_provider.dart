import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/content_model.dart';
import '../services/content_repository.dart';

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepository();
});

final allContentStreamProvider = StreamProvider<List<ContentModel>>((ref) {
  final repo = ref.watch(contentRepositoryProvider);
  return repo.streamAllContent();
});

final contentByTypeStreamProvider =
    StreamProvider.family<List<ContentModel>, String>((ref, type) {
  final repo = ref.watch(contentRepositoryProvider);
  return repo.streamContentByType(type);
});

final contentDetailProvider =
    FutureProvider.family<ContentModel?, String>((ref, contentId) {
  final repo = ref.watch(contentRepositoryProvider);
  return repo.getContentById(contentId);
});
