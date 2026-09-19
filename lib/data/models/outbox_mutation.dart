class OutboxMutation {
  const OutboxMutation({
    required this.idempotencyKey,
    required this.op,
    required this.articleId,
    required this.payload,
    required this.queuedAt,
  });

  static const opSetReaction = 'set_reaction';
  static const opSetBookmark = 'set_bookmark';

  final String idempotencyKey;
  final String op;
  final String articleId;
  final Map<String, dynamic> payload;
  final DateTime queuedAt;

  Map<String, dynamic> toJson() => {
    'idempotencyKey': idempotencyKey,
    'op': op,
    'articleId': articleId,
    'payload': payload,
    'queuedAt': queuedAt.toUtc().toIso8601String(),
  };

  static OutboxMutation fromJson(Map<String, dynamic> json) => OutboxMutation(
    idempotencyKey: json['idempotencyKey'] as String,
    op: json['op'] as String,
    articleId: json['articleId'] as String,
    payload: (json['payload'] as Map).cast<String, dynamic>(),
    queuedAt:
        DateTime.tryParse(json['queuedAt'] as String? ?? '') ?? DateTime.now(),
  );
}
