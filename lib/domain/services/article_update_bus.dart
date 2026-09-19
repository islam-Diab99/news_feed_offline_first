import 'dart:async';

import '../entities/article_update.dart';

class ArticleUpdateBus {
  final _controller = StreamController<ArticleUpdate>.broadcast();

  Stream<ArticleUpdate> get stream => _controller.stream;

  void publish(ArticleUpdate update) {
    if (!_controller.isClosed) _controller.add(update);
  }

  Future<void> dispose() => _controller.close();
}
