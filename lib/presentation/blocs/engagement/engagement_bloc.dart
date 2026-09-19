import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/app_exception.dart';
import '../../../domain/entities/article.dart';
import '../../../domain/repositories/bookmark_repository.dart';
import '../../../domain/repositories/reaction_repository.dart';

part 'engagement_event.dart';
part 'engagement_state.dart';

class EngagementBloc extends Bloc<EngagementEvent, EngagementState> {
  EngagementBloc({
    required ReactionRepository reactionRepository,
    required BookmarkRepository bookmarkRepository,
  }) : _reactions = reactionRepository,
       _bookmarks = bookmarkRepository,
       super(const EngagementState()) {
    on<EngagementLikeToggled>(_onLikeToggled, transformer: concurrent());
    on<EngagementBookmarkToggled>(
      _onBookmarkToggled,
      transformer: concurrent(),
    );
  }

  final ReactionRepository _reactions;
  final BookmarkRepository _bookmarks;

  Future<void> _onLikeToggled(
    EngagementLikeToggled event,
    Emitter<EngagementState> emit,
  ) async {
    try {
      await _reactions.toggleLike(event.article);
    } on AppException catch (e) {
      emit(state.notify(e.message));
    }
  }

  Future<void> _onBookmarkToggled(
    EngagementBookmarkToggled event,
    Emitter<EngagementState> emit,
  ) async {
    await _bookmarks.toggle(event.article);
    emit(
      state.notify(
        event.article.isBookmarked
            ? 'Removed from bookmarks'
            : 'Saved to bookmarks',
      ),
    );
  }
}
