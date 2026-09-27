// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ArticlesTable extends Articles
    with TableInfo<$ArticlesTable, ArticleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArticlesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorNameMeta = const VerificationMeta(
    'authorName',
  );
  @override
  late final GeneratedColumn<String> authorName = GeneratedColumn<String>(
    'author_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorAvatarMeta = const VerificationMeta(
    'authorAvatar',
  );
  @override
  late final GeneratedColumn<String> authorAvatar = GeneratedColumn<String>(
    'author_avatar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _topicIdMeta = const VerificationMeta(
    'topicId',
  );
  @override
  late final GeneratedColumn<String> topicId = GeneratedColumn<String>(
    'topic_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _publishedAtMeta = const VerificationMeta(
    'publishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> publishedAt = GeneratedColumn<DateTime>(
    'published_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> tags =
      GeneratedColumn<String>(
        'tags',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($ArticlesTable.$convertertags);
  static const VerificationMeta _likesMeta = const VerificationMeta('likes');
  @override
  late final GeneratedColumn<int> likes = GeneratedColumn<int>(
    'likes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commentsMeta = const VerificationMeta(
    'comments',
  );
  @override
  late final GeneratedColumn<int> comments = GeneratedColumn<int>(
    'comments',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isLikedOnServerMeta = const VerificationMeta(
    'isLikedOnServer',
  );
  @override
  late final GeneratedColumn<bool> isLikedOnServer = GeneratedColumn<bool>(
    'is_liked_on_server',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_liked_on_server" IN (0, 1))',
    ),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    summary,
    source,
    authorName,
    authorAvatar,
    topicId,
    publishedAt,
    imageUrl,
    tags,
    likes,
    comments,
    isLikedOnServer,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'articles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArticleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('author_name')) {
      context.handle(
        _authorNameMeta,
        authorName.isAcceptableOrUnknown(data['author_name']!, _authorNameMeta),
      );
    } else if (isInserting) {
      context.missing(_authorNameMeta);
    }
    if (data.containsKey('author_avatar')) {
      context.handle(
        _authorAvatarMeta,
        authorAvatar.isAcceptableOrUnknown(
          data['author_avatar']!,
          _authorAvatarMeta,
        ),
      );
    }
    if (data.containsKey('topic_id')) {
      context.handle(
        _topicIdMeta,
        topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_topicIdMeta);
    }
    if (data.containsKey('published_at')) {
      context.handle(
        _publishedAtMeta,
        publishedAt.isAcceptableOrUnknown(
          data['published_at']!,
          _publishedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_publishedAtMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('likes')) {
      context.handle(
        _likesMeta,
        likes.isAcceptableOrUnknown(data['likes']!, _likesMeta),
      );
    } else if (isInserting) {
      context.missing(_likesMeta);
    }
    if (data.containsKey('comments')) {
      context.handle(
        _commentsMeta,
        comments.isAcceptableOrUnknown(data['comments']!, _commentsMeta),
      );
    } else if (isInserting) {
      context.missing(_commentsMeta);
    }
    if (data.containsKey('is_liked_on_server')) {
      context.handle(
        _isLikedOnServerMeta,
        isLikedOnServer.isAcceptableOrUnknown(
          data['is_liked_on_server']!,
          _isLikedOnServerMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isLikedOnServerMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ArticleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArticleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      authorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_name'],
      )!,
      authorAvatar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_avatar'],
      ),
      topicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic_id'],
      )!,
      publishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}published_at'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      tags: $ArticlesTable.$convertertags.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tags'],
        )!,
      ),
      likes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}likes'],
      )!,
      comments: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}comments'],
      )!,
      isLikedOnServer: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_liked_on_server'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $ArticlesTable createAlias(String alias) {
    return $ArticlesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertertags =
      const StringListConverter();
}

class ArticleRow extends DataClass implements Insertable<ArticleRow> {
  final String id;
  final String title;
  final String summary;
  final String source;
  final String authorName;
  final String? authorAvatar;
  final String topicId;
  final DateTime publishedAt;
  final String? imageUrl;
  final List<String> tags;
  final int likes;
  final int comments;
  final bool isLikedOnServer;
  final int version;
  const ArticleRow({
    required this.id,
    required this.title,
    required this.summary,
    required this.source,
    required this.authorName,
    this.authorAvatar,
    required this.topicId,
    required this.publishedAt,
    this.imageUrl,
    required this.tags,
    required this.likes,
    required this.comments,
    required this.isLikedOnServer,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['summary'] = Variable<String>(summary);
    map['source'] = Variable<String>(source);
    map['author_name'] = Variable<String>(authorName);
    if (!nullToAbsent || authorAvatar != null) {
      map['author_avatar'] = Variable<String>(authorAvatar);
    }
    map['topic_id'] = Variable<String>(topicId);
    map['published_at'] = Variable<DateTime>(publishedAt);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    {
      map['tags'] = Variable<String>($ArticlesTable.$convertertags.toSql(tags));
    }
    map['likes'] = Variable<int>(likes);
    map['comments'] = Variable<int>(comments);
    map['is_liked_on_server'] = Variable<bool>(isLikedOnServer);
    map['version'] = Variable<int>(version);
    return map;
  }

  ArticlesCompanion toCompanion(bool nullToAbsent) {
    return ArticlesCompanion(
      id: Value(id),
      title: Value(title),
      summary: Value(summary),
      source: Value(source),
      authorName: Value(authorName),
      authorAvatar: authorAvatar == null && nullToAbsent
          ? const Value.absent()
          : Value(authorAvatar),
      topicId: Value(topicId),
      publishedAt: Value(publishedAt),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      tags: Value(tags),
      likes: Value(likes),
      comments: Value(comments),
      isLikedOnServer: Value(isLikedOnServer),
      version: Value(version),
    );
  }

  factory ArticleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArticleRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      summary: serializer.fromJson<String>(json['summary']),
      source: serializer.fromJson<String>(json['source']),
      authorName: serializer.fromJson<String>(json['authorName']),
      authorAvatar: serializer.fromJson<String?>(json['authorAvatar']),
      topicId: serializer.fromJson<String>(json['topicId']),
      publishedAt: serializer.fromJson<DateTime>(json['publishedAt']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      tags: serializer.fromJson<List<String>>(json['tags']),
      likes: serializer.fromJson<int>(json['likes']),
      comments: serializer.fromJson<int>(json['comments']),
      isLikedOnServer: serializer.fromJson<bool>(json['isLikedOnServer']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'summary': serializer.toJson<String>(summary),
      'source': serializer.toJson<String>(source),
      'authorName': serializer.toJson<String>(authorName),
      'authorAvatar': serializer.toJson<String?>(authorAvatar),
      'topicId': serializer.toJson<String>(topicId),
      'publishedAt': serializer.toJson<DateTime>(publishedAt),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'tags': serializer.toJson<List<String>>(tags),
      'likes': serializer.toJson<int>(likes),
      'comments': serializer.toJson<int>(comments),
      'isLikedOnServer': serializer.toJson<bool>(isLikedOnServer),
      'version': serializer.toJson<int>(version),
    };
  }

  ArticleRow copyWith({
    String? id,
    String? title,
    String? summary,
    String? source,
    String? authorName,
    Value<String?> authorAvatar = const Value.absent(),
    String? topicId,
    DateTime? publishedAt,
    Value<String?> imageUrl = const Value.absent(),
    List<String>? tags,
    int? likes,
    int? comments,
    bool? isLikedOnServer,
    int? version,
  }) => ArticleRow(
    id: id ?? this.id,
    title: title ?? this.title,
    summary: summary ?? this.summary,
    source: source ?? this.source,
    authorName: authorName ?? this.authorName,
    authorAvatar: authorAvatar.present ? authorAvatar.value : this.authorAvatar,
    topicId: topicId ?? this.topicId,
    publishedAt: publishedAt ?? this.publishedAt,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    tags: tags ?? this.tags,
    likes: likes ?? this.likes,
    comments: comments ?? this.comments,
    isLikedOnServer: isLikedOnServer ?? this.isLikedOnServer,
    version: version ?? this.version,
  );
  ArticleRow copyWithCompanion(ArticlesCompanion data) {
    return ArticleRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      summary: data.summary.present ? data.summary.value : this.summary,
      source: data.source.present ? data.source.value : this.source,
      authorName: data.authorName.present
          ? data.authorName.value
          : this.authorName,
      authorAvatar: data.authorAvatar.present
          ? data.authorAvatar.value
          : this.authorAvatar,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      publishedAt: data.publishedAt.present
          ? data.publishedAt.value
          : this.publishedAt,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      tags: data.tags.present ? data.tags.value : this.tags,
      likes: data.likes.present ? data.likes.value : this.likes,
      comments: data.comments.present ? data.comments.value : this.comments,
      isLikedOnServer: data.isLikedOnServer.present
          ? data.isLikedOnServer.value
          : this.isLikedOnServer,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArticleRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('source: $source, ')
          ..write('authorName: $authorName, ')
          ..write('authorAvatar: $authorAvatar, ')
          ..write('topicId: $topicId, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('tags: $tags, ')
          ..write('likes: $likes, ')
          ..write('comments: $comments, ')
          ..write('isLikedOnServer: $isLikedOnServer, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    summary,
    source,
    authorName,
    authorAvatar,
    topicId,
    publishedAt,
    imageUrl,
    tags,
    likes,
    comments,
    isLikedOnServer,
    version,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArticleRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.summary == this.summary &&
          other.source == this.source &&
          other.authorName == this.authorName &&
          other.authorAvatar == this.authorAvatar &&
          other.topicId == this.topicId &&
          other.publishedAt == this.publishedAt &&
          other.imageUrl == this.imageUrl &&
          other.tags == this.tags &&
          other.likes == this.likes &&
          other.comments == this.comments &&
          other.isLikedOnServer == this.isLikedOnServer &&
          other.version == this.version);
}

class ArticlesCompanion extends UpdateCompanion<ArticleRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> summary;
  final Value<String> source;
  final Value<String> authorName;
  final Value<String?> authorAvatar;
  final Value<String> topicId;
  final Value<DateTime> publishedAt;
  final Value<String?> imageUrl;
  final Value<List<String>> tags;
  final Value<int> likes;
  final Value<int> comments;
  final Value<bool> isLikedOnServer;
  final Value<int> version;
  final Value<int> rowid;
  const ArticlesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.summary = const Value.absent(),
    this.source = const Value.absent(),
    this.authorName = const Value.absent(),
    this.authorAvatar = const Value.absent(),
    this.topicId = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.tags = const Value.absent(),
    this.likes = const Value.absent(),
    this.comments = const Value.absent(),
    this.isLikedOnServer = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArticlesCompanion.insert({
    required String id,
    required String title,
    required String summary,
    required String source,
    required String authorName,
    this.authorAvatar = const Value.absent(),
    required String topicId,
    required DateTime publishedAt,
    this.imageUrl = const Value.absent(),
    required List<String> tags,
    required int likes,
    required int comments,
    required bool isLikedOnServer,
    required int version,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       summary = Value(summary),
       source = Value(source),
       authorName = Value(authorName),
       topicId = Value(topicId),
       publishedAt = Value(publishedAt),
       tags = Value(tags),
       likes = Value(likes),
       comments = Value(comments),
       isLikedOnServer = Value(isLikedOnServer),
       version = Value(version);
  static Insertable<ArticleRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? summary,
    Expression<String>? source,
    Expression<String>? authorName,
    Expression<String>? authorAvatar,
    Expression<String>? topicId,
    Expression<DateTime>? publishedAt,
    Expression<String>? imageUrl,
    Expression<String>? tags,
    Expression<int>? likes,
    Expression<int>? comments,
    Expression<bool>? isLikedOnServer,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (summary != null) 'summary': summary,
      if (source != null) 'source': source,
      if (authorName != null) 'author_name': authorName,
      if (authorAvatar != null) 'author_avatar': authorAvatar,
      if (topicId != null) 'topic_id': topicId,
      if (publishedAt != null) 'published_at': publishedAt,
      if (imageUrl != null) 'image_url': imageUrl,
      if (tags != null) 'tags': tags,
      if (likes != null) 'likes': likes,
      if (comments != null) 'comments': comments,
      if (isLikedOnServer != null) 'is_liked_on_server': isLikedOnServer,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArticlesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? summary,
    Value<String>? source,
    Value<String>? authorName,
    Value<String?>? authorAvatar,
    Value<String>? topicId,
    Value<DateTime>? publishedAt,
    Value<String?>? imageUrl,
    Value<List<String>>? tags,
    Value<int>? likes,
    Value<int>? comments,
    Value<bool>? isLikedOnServer,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return ArticlesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      source: source ?? this.source,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      topicId: topicId ?? this.topicId,
      publishedAt: publishedAt ?? this.publishedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLikedOnServer: isLikedOnServer ?? this.isLikedOnServer,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (authorName.present) {
      map['author_name'] = Variable<String>(authorName.value);
    }
    if (authorAvatar.present) {
      map['author_avatar'] = Variable<String>(authorAvatar.value);
    }
    if (topicId.present) {
      map['topic_id'] = Variable<String>(topicId.value);
    }
    if (publishedAt.present) {
      map['published_at'] = Variable<DateTime>(publishedAt.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(
        $ArticlesTable.$convertertags.toSql(tags.value),
      );
    }
    if (likes.present) {
      map['likes'] = Variable<int>(likes.value);
    }
    if (comments.present) {
      map['comments'] = Variable<int>(comments.value);
    }
    if (isLikedOnServer.present) {
      map['is_liked_on_server'] = Variable<bool>(isLikedOnServer.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArticlesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('source: $source, ')
          ..write('authorName: $authorName, ')
          ..write('authorAvatar: $authorAvatar, ')
          ..write('topicId: $topicId, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('tags: $tags, ')
          ..write('likes: $likes, ')
          ..write('comments: $comments, ')
          ..write('isLikedOnServer: $isLikedOnServer, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ArticleDetailsTable extends ArticleDetails
    with TableInfo<$ArticleDetailsTable, ArticleDetailRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArticleDetailsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _articleIdMeta = const VerificationMeta(
    'articleId',
  );
  @override
  late final GeneratedColumn<String> articleId = GeneratedColumn<String>(
    'article_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES articles (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<ContentBlock>, String> body =
      GeneratedColumn<String>(
        'body',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<ContentBlock>>($ArticleDetailsTable.$converterbody);
  static const VerificationMeta _authorBioMeta = const VerificationMeta(
    'authorBio',
  );
  @override
  late final GeneratedColumn<String> authorBio = GeneratedColumn<String>(
    'author_bio',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _readTimeMinutesMeta = const VerificationMeta(
    'readTimeMinutes',
  );
  @override
  late final GeneratedColumn<int> readTimeMinutes = GeneratedColumn<int>(
    'read_time_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> relatedIds =
      GeneratedColumn<String>(
        'related_ids',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($ArticleDetailsTable.$converterrelatedIds);
  @override
  List<GeneratedColumn> get $columns => [
    articleId,
    body,
    authorBio,
    updatedAt,
    readTimeMinutes,
    relatedIds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'article_details';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArticleDetailRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('article_id')) {
      context.handle(
        _articleIdMeta,
        articleId.isAcceptableOrUnknown(data['article_id']!, _articleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_articleIdMeta);
    }
    if (data.containsKey('author_bio')) {
      context.handle(
        _authorBioMeta,
        authorBio.isAcceptableOrUnknown(data['author_bio']!, _authorBioMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('read_time_minutes')) {
      context.handle(
        _readTimeMinutesMeta,
        readTimeMinutes.isAcceptableOrUnknown(
          data['read_time_minutes']!,
          _readTimeMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {articleId};
  @override
  ArticleDetailRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArticleDetailRow(
      articleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}article_id'],
      )!,
      body: $ArticleDetailsTable.$converterbody.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}body'],
        )!,
      ),
      authorBio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_bio'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      readTimeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}read_time_minutes'],
      ),
      relatedIds: $ArticleDetailsTable.$converterrelatedIds.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}related_ids'],
        )!,
      ),
    );
  }

  @override
  $ArticleDetailsTable createAlias(String alias) {
    return $ArticleDetailsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<ContentBlock>, String> $converterbody =
      const ContentBlocksConverter();
  static TypeConverter<List<String>, String> $converterrelatedIds =
      const StringListConverter();
}

class ArticleDetailRow extends DataClass
    implements Insertable<ArticleDetailRow> {
  final String articleId;
  final List<ContentBlock> body;
  final String? authorBio;
  final DateTime? updatedAt;
  final int? readTimeMinutes;
  final List<String> relatedIds;
  const ArticleDetailRow({
    required this.articleId,
    required this.body,
    this.authorBio,
    this.updatedAt,
    this.readTimeMinutes,
    required this.relatedIds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['article_id'] = Variable<String>(articleId);
    {
      map['body'] = Variable<String>(
        $ArticleDetailsTable.$converterbody.toSql(body),
      );
    }
    if (!nullToAbsent || authorBio != null) {
      map['author_bio'] = Variable<String>(authorBio);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || readTimeMinutes != null) {
      map['read_time_minutes'] = Variable<int>(readTimeMinutes);
    }
    {
      map['related_ids'] = Variable<String>(
        $ArticleDetailsTable.$converterrelatedIds.toSql(relatedIds),
      );
    }
    return map;
  }

  ArticleDetailsCompanion toCompanion(bool nullToAbsent) {
    return ArticleDetailsCompanion(
      articleId: Value(articleId),
      body: Value(body),
      authorBio: authorBio == null && nullToAbsent
          ? const Value.absent()
          : Value(authorBio),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      readTimeMinutes: readTimeMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(readTimeMinutes),
      relatedIds: Value(relatedIds),
    );
  }

  factory ArticleDetailRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArticleDetailRow(
      articleId: serializer.fromJson<String>(json['articleId']),
      body: serializer.fromJson<List<ContentBlock>>(json['body']),
      authorBio: serializer.fromJson<String?>(json['authorBio']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      readTimeMinutes: serializer.fromJson<int?>(json['readTimeMinutes']),
      relatedIds: serializer.fromJson<List<String>>(json['relatedIds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'articleId': serializer.toJson<String>(articleId),
      'body': serializer.toJson<List<ContentBlock>>(body),
      'authorBio': serializer.toJson<String?>(authorBio),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'readTimeMinutes': serializer.toJson<int?>(readTimeMinutes),
      'relatedIds': serializer.toJson<List<String>>(relatedIds),
    };
  }

  ArticleDetailRow copyWith({
    String? articleId,
    List<ContentBlock>? body,
    Value<String?> authorBio = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<int?> readTimeMinutes = const Value.absent(),
    List<String>? relatedIds,
  }) => ArticleDetailRow(
    articleId: articleId ?? this.articleId,
    body: body ?? this.body,
    authorBio: authorBio.present ? authorBio.value : this.authorBio,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    readTimeMinutes: readTimeMinutes.present
        ? readTimeMinutes.value
        : this.readTimeMinutes,
    relatedIds: relatedIds ?? this.relatedIds,
  );
  ArticleDetailRow copyWithCompanion(ArticleDetailsCompanion data) {
    return ArticleDetailRow(
      articleId: data.articleId.present ? data.articleId.value : this.articleId,
      body: data.body.present ? data.body.value : this.body,
      authorBio: data.authorBio.present ? data.authorBio.value : this.authorBio,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      readTimeMinutes: data.readTimeMinutes.present
          ? data.readTimeMinutes.value
          : this.readTimeMinutes,
      relatedIds: data.relatedIds.present
          ? data.relatedIds.value
          : this.relatedIds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArticleDetailRow(')
          ..write('articleId: $articleId, ')
          ..write('body: $body, ')
          ..write('authorBio: $authorBio, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('readTimeMinutes: $readTimeMinutes, ')
          ..write('relatedIds: $relatedIds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    articleId,
    body,
    authorBio,
    updatedAt,
    readTimeMinutes,
    relatedIds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArticleDetailRow &&
          other.articleId == this.articleId &&
          other.body == this.body &&
          other.authorBio == this.authorBio &&
          other.updatedAt == this.updatedAt &&
          other.readTimeMinutes == this.readTimeMinutes &&
          other.relatedIds == this.relatedIds);
}

class ArticleDetailsCompanion extends UpdateCompanion<ArticleDetailRow> {
  final Value<String> articleId;
  final Value<List<ContentBlock>> body;
  final Value<String?> authorBio;
  final Value<DateTime?> updatedAt;
  final Value<int?> readTimeMinutes;
  final Value<List<String>> relatedIds;
  final Value<int> rowid;
  const ArticleDetailsCompanion({
    this.articleId = const Value.absent(),
    this.body = const Value.absent(),
    this.authorBio = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.readTimeMinutes = const Value.absent(),
    this.relatedIds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArticleDetailsCompanion.insert({
    required String articleId,
    required List<ContentBlock> body,
    this.authorBio = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.readTimeMinutes = const Value.absent(),
    required List<String> relatedIds,
    this.rowid = const Value.absent(),
  }) : articleId = Value(articleId),
       body = Value(body),
       relatedIds = Value(relatedIds);
  static Insertable<ArticleDetailRow> custom({
    Expression<String>? articleId,
    Expression<String>? body,
    Expression<String>? authorBio,
    Expression<DateTime>? updatedAt,
    Expression<int>? readTimeMinutes,
    Expression<String>? relatedIds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (articleId != null) 'article_id': articleId,
      if (body != null) 'body': body,
      if (authorBio != null) 'author_bio': authorBio,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (readTimeMinutes != null) 'read_time_minutes': readTimeMinutes,
      if (relatedIds != null) 'related_ids': relatedIds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArticleDetailsCompanion copyWith({
    Value<String>? articleId,
    Value<List<ContentBlock>>? body,
    Value<String?>? authorBio,
    Value<DateTime?>? updatedAt,
    Value<int?>? readTimeMinutes,
    Value<List<String>>? relatedIds,
    Value<int>? rowid,
  }) {
    return ArticleDetailsCompanion(
      articleId: articleId ?? this.articleId,
      body: body ?? this.body,
      authorBio: authorBio ?? this.authorBio,
      updatedAt: updatedAt ?? this.updatedAt,
      readTimeMinutes: readTimeMinutes ?? this.readTimeMinutes,
      relatedIds: relatedIds ?? this.relatedIds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (articleId.present) {
      map['article_id'] = Variable<String>(articleId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(
        $ArticleDetailsTable.$converterbody.toSql(body.value),
      );
    }
    if (authorBio.present) {
      map['author_bio'] = Variable<String>(authorBio.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (readTimeMinutes.present) {
      map['read_time_minutes'] = Variable<int>(readTimeMinutes.value);
    }
    if (relatedIds.present) {
      map['related_ids'] = Variable<String>(
        $ArticleDetailsTable.$converterrelatedIds.toSql(relatedIds.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArticleDetailsCompanion(')
          ..write('articleId: $articleId, ')
          ..write('body: $body, ')
          ..write('authorBio: $authorBio, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('readTimeMinutes: $readTimeMinutes, ')
          ..write('relatedIds: $relatedIds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, BookmarkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _articleIdMeta = const VerificationMeta(
    'articleId',
  );
  @override
  late final GeneratedColumn<String> articleId = GeneratedColumn<String>(
    'article_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES articles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [articleId, savedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookmarkRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('article_id')) {
      context.handle(
        _articleIdMeta,
        articleId.isAcceptableOrUnknown(data['article_id']!, _articleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_articleIdMeta);
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {articleId};
  @override
  BookmarkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarkRow(
      articleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}article_id'],
      )!,
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      )!,
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }
}

class BookmarkRow extends DataClass implements Insertable<BookmarkRow> {
  final String articleId;
  final DateTime savedAt;
  const BookmarkRow({required this.articleId, required this.savedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['article_id'] = Variable<String>(articleId);
    map['saved_at'] = Variable<DateTime>(savedAt);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      articleId: Value(articleId),
      savedAt: Value(savedAt),
    );
  }

  factory BookmarkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarkRow(
      articleId: serializer.fromJson<String>(json['articleId']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'articleId': serializer.toJson<String>(articleId),
      'savedAt': serializer.toJson<DateTime>(savedAt),
    };
  }

  BookmarkRow copyWith({String? articleId, DateTime? savedAt}) => BookmarkRow(
    articleId: articleId ?? this.articleId,
    savedAt: savedAt ?? this.savedAt,
  );
  BookmarkRow copyWithCompanion(BookmarksCompanion data) {
    return BookmarkRow(
      articleId: data.articleId.present ? data.articleId.value : this.articleId,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkRow(')
          ..write('articleId: $articleId, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(articleId, savedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarkRow &&
          other.articleId == this.articleId &&
          other.savedAt == this.savedAt);
}

class BookmarksCompanion extends UpdateCompanion<BookmarkRow> {
  final Value<String> articleId;
  final Value<DateTime> savedAt;
  final Value<int> rowid;
  const BookmarksCompanion({
    this.articleId = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookmarksCompanion.insert({
    required String articleId,
    required DateTime savedAt,
    this.rowid = const Value.absent(),
  }) : articleId = Value(articleId),
       savedAt = Value(savedAt);
  static Insertable<BookmarkRow> custom({
    Expression<String>? articleId,
    Expression<DateTime>? savedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (articleId != null) 'article_id': articleId,
      if (savedAt != null) 'saved_at': savedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookmarksCompanion copyWith({
    Value<String>? articleId,
    Value<DateTime>? savedAt,
    Value<int>? rowid,
  }) {
    return BookmarksCompanion(
      articleId: articleId ?? this.articleId,
      savedAt: savedAt ?? this.savedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (articleId.present) {
      map['article_id'] = Variable<String>(articleId.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('articleId: $articleId, ')
          ..write('savedAt: $savedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeedEntriesTable extends FeedEntries
    with TableInfo<$FeedEntriesTable, FeedEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _feedKeyMeta = const VerificationMeta(
    'feedKey',
  );
  @override
  late final GeneratedColumn<String> feedKey = GeneratedColumn<String>(
    'feed_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _articleIdMeta = const VerificationMeta(
    'articleId',
  );
  @override
  late final GeneratedColumn<String> articleId = GeneratedColumn<String>(
    'article_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES articles (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [feedKey, articleId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feed_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('feed_key')) {
      context.handle(
        _feedKeyMeta,
        feedKey.isAcceptableOrUnknown(data['feed_key']!, _feedKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_feedKeyMeta);
    }
    if (data.containsKey('article_id')) {
      context.handle(
        _articleIdMeta,
        articleId.isAcceptableOrUnknown(data['article_id']!, _articleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_articleIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {feedKey, articleId};
  @override
  FeedEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedEntryRow(
      feedKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_key'],
      )!,
      articleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}article_id'],
      )!,
    );
  }

  @override
  $FeedEntriesTable createAlias(String alias) {
    return $FeedEntriesTable(attachedDatabase, alias);
  }
}

class FeedEntryRow extends DataClass implements Insertable<FeedEntryRow> {
  final String feedKey;
  final String articleId;
  const FeedEntryRow({required this.feedKey, required this.articleId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['feed_key'] = Variable<String>(feedKey);
    map['article_id'] = Variable<String>(articleId);
    return map;
  }

  FeedEntriesCompanion toCompanion(bool nullToAbsent) {
    return FeedEntriesCompanion(
      feedKey: Value(feedKey),
      articleId: Value(articleId),
    );
  }

  factory FeedEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedEntryRow(
      feedKey: serializer.fromJson<String>(json['feedKey']),
      articleId: serializer.fromJson<String>(json['articleId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'feedKey': serializer.toJson<String>(feedKey),
      'articleId': serializer.toJson<String>(articleId),
    };
  }

  FeedEntryRow copyWith({String? feedKey, String? articleId}) => FeedEntryRow(
    feedKey: feedKey ?? this.feedKey,
    articleId: articleId ?? this.articleId,
  );
  FeedEntryRow copyWithCompanion(FeedEntriesCompanion data) {
    return FeedEntryRow(
      feedKey: data.feedKey.present ? data.feedKey.value : this.feedKey,
      articleId: data.articleId.present ? data.articleId.value : this.articleId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedEntryRow(')
          ..write('feedKey: $feedKey, ')
          ..write('articleId: $articleId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(feedKey, articleId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedEntryRow &&
          other.feedKey == this.feedKey &&
          other.articleId == this.articleId);
}

class FeedEntriesCompanion extends UpdateCompanion<FeedEntryRow> {
  final Value<String> feedKey;
  final Value<String> articleId;
  final Value<int> rowid;
  const FeedEntriesCompanion({
    this.feedKey = const Value.absent(),
    this.articleId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeedEntriesCompanion.insert({
    required String feedKey,
    required String articleId,
    this.rowid = const Value.absent(),
  }) : feedKey = Value(feedKey),
       articleId = Value(articleId);
  static Insertable<FeedEntryRow> custom({
    Expression<String>? feedKey,
    Expression<String>? articleId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (feedKey != null) 'feed_key': feedKey,
      if (articleId != null) 'article_id': articleId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeedEntriesCompanion copyWith({
    Value<String>? feedKey,
    Value<String>? articleId,
    Value<int>? rowid,
  }) {
    return FeedEntriesCompanion(
      feedKey: feedKey ?? this.feedKey,
      articleId: articleId ?? this.articleId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (feedKey.present) {
      map['feed_key'] = Variable<String>(feedKey.value);
    }
    if (articleId.present) {
      map['article_id'] = Variable<String>(articleId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedEntriesCompanion(')
          ..write('feedKey: $feedKey, ')
          ..write('articleId: $articleId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeedsTable extends Feeds with TableInfo<$FeedsTable, FeedRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _feedKeyMeta = const VerificationMeta(
    'feedKey',
  );
  @override
  late final GeneratedColumn<String> feedKey = GeneratedColumn<String>(
    'feed_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextCursorMeta = const VerificationMeta(
    'nextCursor',
  );
  @override
  late final GeneratedColumn<String> nextCursor = GeneratedColumn<String>(
    'next_cursor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [feedKey, nextCursor];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feeds';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('feed_key')) {
      context.handle(
        _feedKeyMeta,
        feedKey.isAcceptableOrUnknown(data['feed_key']!, _feedKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_feedKeyMeta);
    }
    if (data.containsKey('next_cursor')) {
      context.handle(
        _nextCursorMeta,
        nextCursor.isAcceptableOrUnknown(data['next_cursor']!, _nextCursorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {feedKey};
  @override
  FeedRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedRow(
      feedKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_key'],
      )!,
      nextCursor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_cursor'],
      ),
    );
  }

  @override
  $FeedsTable createAlias(String alias) {
    return $FeedsTable(attachedDatabase, alias);
  }
}

class FeedRow extends DataClass implements Insertable<FeedRow> {
  final String feedKey;
  final String? nextCursor;
  const FeedRow({required this.feedKey, this.nextCursor});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['feed_key'] = Variable<String>(feedKey);
    if (!nullToAbsent || nextCursor != null) {
      map['next_cursor'] = Variable<String>(nextCursor);
    }
    return map;
  }

  FeedsCompanion toCompanion(bool nullToAbsent) {
    return FeedsCompanion(
      feedKey: Value(feedKey),
      nextCursor: nextCursor == null && nullToAbsent
          ? const Value.absent()
          : Value(nextCursor),
    );
  }

  factory FeedRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedRow(
      feedKey: serializer.fromJson<String>(json['feedKey']),
      nextCursor: serializer.fromJson<String?>(json['nextCursor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'feedKey': serializer.toJson<String>(feedKey),
      'nextCursor': serializer.toJson<String?>(nextCursor),
    };
  }

  FeedRow copyWith({
    String? feedKey,
    Value<String?> nextCursor = const Value.absent(),
  }) => FeedRow(
    feedKey: feedKey ?? this.feedKey,
    nextCursor: nextCursor.present ? nextCursor.value : this.nextCursor,
  );
  FeedRow copyWithCompanion(FeedsCompanion data) {
    return FeedRow(
      feedKey: data.feedKey.present ? data.feedKey.value : this.feedKey,
      nextCursor: data.nextCursor.present
          ? data.nextCursor.value
          : this.nextCursor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedRow(')
          ..write('feedKey: $feedKey, ')
          ..write('nextCursor: $nextCursor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(feedKey, nextCursor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedRow &&
          other.feedKey == this.feedKey &&
          other.nextCursor == this.nextCursor);
}

class FeedsCompanion extends UpdateCompanion<FeedRow> {
  final Value<String> feedKey;
  final Value<String?> nextCursor;
  final Value<int> rowid;
  const FeedsCompanion({
    this.feedKey = const Value.absent(),
    this.nextCursor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeedsCompanion.insert({
    required String feedKey,
    this.nextCursor = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : feedKey = Value(feedKey);
  static Insertable<FeedRow> custom({
    Expression<String>? feedKey,
    Expression<String>? nextCursor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (feedKey != null) 'feed_key': feedKey,
      if (nextCursor != null) 'next_cursor': nextCursor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeedsCompanion copyWith({
    Value<String>? feedKey,
    Value<String?>? nextCursor,
    Value<int>? rowid,
  }) {
    return FeedsCompanion(
      feedKey: feedKey ?? this.feedKey,
      nextCursor: nextCursor ?? this.nextCursor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (feedKey.present) {
      map['feed_key'] = Variable<String>(feedKey.value);
    }
    if (nextCursor.present) {
      map['next_cursor'] = Variable<String>(nextCursor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedsCompanion(')
          ..write('feedKey: $feedKey, ')
          ..write('nextCursor: $nextCursor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingMutationsTable extends PendingMutations
    with TableInfo<$PendingMutationsTable, PendingMutation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingMutationsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<MutationKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MutationKind>($PendingMutationsTable.$converterkind);
  static const VerificationMeta _articleIdMeta = const VerificationMeta(
    'articleId',
  );
  @override
  late final GeneratedColumn<String> articleId = GeneratedColumn<String>(
    'article_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES articles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<bool> value = GeneratedColumn<bool>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("value" IN (0, 1))',
    ),
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _queuedAtMeta = const VerificationMeta(
    'queuedAt',
  );
  @override
  late final GeneratedColumn<DateTime> queuedAt = GeneratedColumn<DateTime>(
    'queued_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    kind,
    articleId,
    value,
    idempotencyKey,
    queuedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_mutations';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingMutation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('article_id')) {
      context.handle(
        _articleIdMeta,
        articleId.isAcceptableOrUnknown(data['article_id']!, _articleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_articleIdMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('queued_at')) {
      context.handle(
        _queuedAtMeta,
        queuedAt.isAcceptableOrUnknown(data['queued_at']!, _queuedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_queuedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {kind, articleId};
  @override
  PendingMutation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingMutation(
      kind: $PendingMutationsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      articleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}article_id'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}value'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      queuedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}queued_at'],
      )!,
    );
  }

  @override
  $PendingMutationsTable createAlias(String alias) {
    return $PendingMutationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MutationKind, String, String> $converterkind =
      const EnumNameConverter<MutationKind>(MutationKind.values);
}

class PendingMutation extends DataClass implements Insertable<PendingMutation> {
  final MutationKind kind;
  final String articleId;
  final bool value;
  final String idempotencyKey;
  final DateTime queuedAt;
  const PendingMutation({
    required this.kind,
    required this.articleId,
    required this.value,
    required this.idempotencyKey,
    required this.queuedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['kind'] = Variable<String>(
        $PendingMutationsTable.$converterkind.toSql(kind),
      );
    }
    map['article_id'] = Variable<String>(articleId);
    map['value'] = Variable<bool>(value);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['queued_at'] = Variable<DateTime>(queuedAt);
    return map;
  }

  PendingMutationsCompanion toCompanion(bool nullToAbsent) {
    return PendingMutationsCompanion(
      kind: Value(kind),
      articleId: Value(articleId),
      value: Value(value),
      idempotencyKey: Value(idempotencyKey),
      queuedAt: Value(queuedAt),
    );
  }

  factory PendingMutation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingMutation(
      kind: $PendingMutationsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      articleId: serializer.fromJson<String>(json['articleId']),
      value: serializer.fromJson<bool>(json['value']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      queuedAt: serializer.fromJson<DateTime>(json['queuedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'kind': serializer.toJson<String>(
        $PendingMutationsTable.$converterkind.toJson(kind),
      ),
      'articleId': serializer.toJson<String>(articleId),
      'value': serializer.toJson<bool>(value),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'queuedAt': serializer.toJson<DateTime>(queuedAt),
    };
  }

  PendingMutation copyWith({
    MutationKind? kind,
    String? articleId,
    bool? value,
    String? idempotencyKey,
    DateTime? queuedAt,
  }) => PendingMutation(
    kind: kind ?? this.kind,
    articleId: articleId ?? this.articleId,
    value: value ?? this.value,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    queuedAt: queuedAt ?? this.queuedAt,
  );
  PendingMutation copyWithCompanion(PendingMutationsCompanion data) {
    return PendingMutation(
      kind: data.kind.present ? data.kind.value : this.kind,
      articleId: data.articleId.present ? data.articleId.value : this.articleId,
      value: data.value.present ? data.value.value : this.value,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      queuedAt: data.queuedAt.present ? data.queuedAt.value : this.queuedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingMutation(')
          ..write('kind: $kind, ')
          ..write('articleId: $articleId, ')
          ..write('value: $value, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('queuedAt: $queuedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(kind, articleId, value, idempotencyKey, queuedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingMutation &&
          other.kind == this.kind &&
          other.articleId == this.articleId &&
          other.value == this.value &&
          other.idempotencyKey == this.idempotencyKey &&
          other.queuedAt == this.queuedAt);
}

class PendingMutationsCompanion extends UpdateCompanion<PendingMutation> {
  final Value<MutationKind> kind;
  final Value<String> articleId;
  final Value<bool> value;
  final Value<String> idempotencyKey;
  final Value<DateTime> queuedAt;
  final Value<int> rowid;
  const PendingMutationsCompanion({
    this.kind = const Value.absent(),
    this.articleId = const Value.absent(),
    this.value = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.queuedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingMutationsCompanion.insert({
    required MutationKind kind,
    required String articleId,
    required bool value,
    required String idempotencyKey,
    required DateTime queuedAt,
    this.rowid = const Value.absent(),
  }) : kind = Value(kind),
       articleId = Value(articleId),
       value = Value(value),
       idempotencyKey = Value(idempotencyKey),
       queuedAt = Value(queuedAt);
  static Insertable<PendingMutation> custom({
    Expression<String>? kind,
    Expression<String>? articleId,
    Expression<bool>? value,
    Expression<String>? idempotencyKey,
    Expression<DateTime>? queuedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (kind != null) 'kind': kind,
      if (articleId != null) 'article_id': articleId,
      if (value != null) 'value': value,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (queuedAt != null) 'queued_at': queuedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingMutationsCompanion copyWith({
    Value<MutationKind>? kind,
    Value<String>? articleId,
    Value<bool>? value,
    Value<String>? idempotencyKey,
    Value<DateTime>? queuedAt,
    Value<int>? rowid,
  }) {
    return PendingMutationsCompanion(
      kind: kind ?? this.kind,
      articleId: articleId ?? this.articleId,
      value: value ?? this.value,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      queuedAt: queuedAt ?? this.queuedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (kind.present) {
      map['kind'] = Variable<String>(
        $PendingMutationsTable.$converterkind.toSql(kind.value),
      );
    }
    if (articleId.present) {
      map['article_id'] = Variable<String>(articleId.value);
    }
    if (value.present) {
      map['value'] = Variable<bool>(value.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (queuedAt.present) {
      map['queued_at'] = Variable<DateTime>(queuedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingMutationsCompanion(')
          ..write('kind: $kind, ')
          ..write('articleId: $articleId, ')
          ..write('value: $value, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('queuedAt: $queuedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KeyValuesTable extends KeyValues
    with TableInfo<$KeyValuesTable, KeyValueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KeyValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'key_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<KeyValueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  KeyValueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KeyValueRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $KeyValuesTable createAlias(String alias) {
    return $KeyValuesTable(attachedDatabase, alias);
  }
}

class KeyValueRow extends DataClass implements Insertable<KeyValueRow> {
  final String key;
  final String value;
  const KeyValueRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  KeyValuesCompanion toCompanion(bool nullToAbsent) {
    return KeyValuesCompanion(key: Value(key), value: Value(value));
  }

  factory KeyValueRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KeyValueRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  KeyValueRow copyWith({String? key, String? value}) =>
      KeyValueRow(key: key ?? this.key, value: value ?? this.value);
  KeyValueRow copyWithCompanion(KeyValuesCompanion data) {
    return KeyValueRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KeyValueRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KeyValueRow &&
          other.key == this.key &&
          other.value == this.value);
}

class KeyValuesCompanion extends UpdateCompanion<KeyValueRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const KeyValuesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KeyValuesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<KeyValueRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KeyValuesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return KeyValuesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KeyValuesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ArticlesTable articles = $ArticlesTable(this);
  late final $ArticleDetailsTable articleDetails = $ArticleDetailsTable(this);
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $FeedEntriesTable feedEntries = $FeedEntriesTable(this);
  late final $FeedsTable feeds = $FeedsTable(this);
  late final $PendingMutationsTable pendingMutations = $PendingMutationsTable(
    this,
  );
  late final $KeyValuesTable keyValues = $KeyValuesTable(this);
  late final Index articlesPublishedAt = Index(
    'articles_published_at',
    'CREATE INDEX articles_published_at ON articles (published_at)',
  );
  late final ArticleDao articleDao = ArticleDao(this as AppDatabase);
  late final FeedDao feedDao = FeedDao(this as AppDatabase);
  late final OutboxDao outboxDao = OutboxDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    articles,
    articleDetails,
    bookmarks,
    feedEntries,
    feeds,
    pendingMutations,
    keyValues,
    articlesPublishedAt,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'articles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('article_details', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'articles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('bookmarks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'articles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('feed_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'articles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pending_mutations', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$ArticlesTableCreateCompanionBuilder =
    ArticlesCompanion Function({
      required String id,
      required String title,
      required String summary,
      required String source,
      required String authorName,
      Value<String?> authorAvatar,
      required String topicId,
      required DateTime publishedAt,
      Value<String?> imageUrl,
      required List<String> tags,
      required int likes,
      required int comments,
      required bool isLikedOnServer,
      required int version,
      Value<int> rowid,
    });
typedef $$ArticlesTableUpdateCompanionBuilder =
    ArticlesCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> summary,
      Value<String> source,
      Value<String> authorName,
      Value<String?> authorAvatar,
      Value<String> topicId,
      Value<DateTime> publishedAt,
      Value<String?> imageUrl,
      Value<List<String>> tags,
      Value<int> likes,
      Value<int> comments,
      Value<bool> isLikedOnServer,
      Value<int> version,
      Value<int> rowid,
    });

final class $$ArticlesTableReferences
    extends BaseReferences<_$AppDatabase, $ArticlesTable, ArticleRow> {
  $$ArticlesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ArticleDetailsTable, List<ArticleDetailRow>>
  _articleDetailsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.articleDetails,
    aliasName: $_aliasNameGenerator(
      db.articles.id,
      db.articleDetails.articleId,
    ),
  );

  $$ArticleDetailsTableProcessedTableManager get articleDetailsRefs {
    final manager = $$ArticleDetailsTableTableManager(
      $_db,
      $_db.articleDetails,
    ).filter((f) => f.articleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_articleDetailsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BookmarksTable, List<BookmarkRow>>
  _bookmarksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bookmarks,
    aliasName: $_aliasNameGenerator(db.articles.id, db.bookmarks.articleId),
  );

  $$BookmarksTableProcessedTableManager get bookmarksRefs {
    final manager = $$BookmarksTableTableManager(
      $_db,
      $_db.bookmarks,
    ).filter((f) => f.articleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookmarksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FeedEntriesTable, List<FeedEntryRow>>
  _feedEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.feedEntries,
    aliasName: $_aliasNameGenerator(db.articles.id, db.feedEntries.articleId),
  );

  $$FeedEntriesTableProcessedTableManager get feedEntriesRefs {
    final manager = $$FeedEntriesTableTableManager(
      $_db,
      $_db.feedEntries,
    ).filter((f) => f.articleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_feedEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PendingMutationsTable, List<PendingMutation>>
  _pendingMutationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pendingMutations,
    aliasName: $_aliasNameGenerator(
      db.articles.id,
      db.pendingMutations.articleId,
    ),
  );

  $$PendingMutationsTableProcessedTableManager get pendingMutationsRefs {
    final manager = $$PendingMutationsTableTableManager(
      $_db,
      $_db.pendingMutations,
    ).filter((f) => f.articleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _pendingMutationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ArticlesTableFilterComposer
    extends Composer<_$AppDatabase, $ArticlesTable> {
  $$ArticlesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorAvatar => $composableBuilder(
    column: $table.authorAvatar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topicId => $composableBuilder(
    column: $table.topicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String> get tags =>
      $composableBuilder(
        column: $table.tags,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get likes => $composableBuilder(
    column: $table.likes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get comments => $composableBuilder(
    column: $table.comments,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLikedOnServer => $composableBuilder(
    column: $table.isLikedOnServer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> articleDetailsRefs(
    Expression<bool> Function($$ArticleDetailsTableFilterComposer f) f,
  ) {
    final $$ArticleDetailsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.articleDetails,
      getReferencedColumn: (t) => t.articleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticleDetailsTableFilterComposer(
            $db: $db,
            $table: $db.articleDetails,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> bookmarksRefs(
    Expression<bool> Function($$BookmarksTableFilterComposer f) f,
  ) {
    final $$BookmarksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookmarks,
      getReferencedColumn: (t) => t.articleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarksTableFilterComposer(
            $db: $db,
            $table: $db.bookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> feedEntriesRefs(
    Expression<bool> Function($$FeedEntriesTableFilterComposer f) f,
  ) {
    final $$FeedEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.feedEntries,
      getReferencedColumn: (t) => t.articleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedEntriesTableFilterComposer(
            $db: $db,
            $table: $db.feedEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pendingMutationsRefs(
    Expression<bool> Function($$PendingMutationsTableFilterComposer f) f,
  ) {
    final $$PendingMutationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pendingMutations,
      getReferencedColumn: (t) => t.articleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PendingMutationsTableFilterComposer(
            $db: $db,
            $table: $db.pendingMutations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ArticlesTableOrderingComposer
    extends Composer<_$AppDatabase, $ArticlesTable> {
  $$ArticlesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorAvatar => $composableBuilder(
    column: $table.authorAvatar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topicId => $composableBuilder(
    column: $table.topicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get likes => $composableBuilder(
    column: $table.likes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get comments => $composableBuilder(
    column: $table.comments,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLikedOnServer => $composableBuilder(
    column: $table.isLikedOnServer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArticlesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArticlesTable> {
  $$ArticlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get authorAvatar => $composableBuilder(
    column: $table.authorAvatar,
    builder: (column) => column,
  );

  GeneratedColumn<String> get topicId =>
      $composableBuilder(column: $table.topicId, builder: (column) => column);

  GeneratedColumn<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<int> get likes =>
      $composableBuilder(column: $table.likes, builder: (column) => column);

  GeneratedColumn<int> get comments =>
      $composableBuilder(column: $table.comments, builder: (column) => column);

  GeneratedColumn<bool> get isLikedOnServer => $composableBuilder(
    column: $table.isLikedOnServer,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  Expression<T> articleDetailsRefs<T extends Object>(
    Expression<T> Function($$ArticleDetailsTableAnnotationComposer a) f,
  ) {
    final $$ArticleDetailsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.articleDetails,
      getReferencedColumn: (t) => t.articleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticleDetailsTableAnnotationComposer(
            $db: $db,
            $table: $db.articleDetails,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> bookmarksRefs<T extends Object>(
    Expression<T> Function($$BookmarksTableAnnotationComposer a) f,
  ) {
    final $$BookmarksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookmarks,
      getReferencedColumn: (t) => t.articleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarksTableAnnotationComposer(
            $db: $db,
            $table: $db.bookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> feedEntriesRefs<T extends Object>(
    Expression<T> Function($$FeedEntriesTableAnnotationComposer a) f,
  ) {
    final $$FeedEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.feedEntries,
      getReferencedColumn: (t) => t.articleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.feedEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pendingMutationsRefs<T extends Object>(
    Expression<T> Function($$PendingMutationsTableAnnotationComposer a) f,
  ) {
    final $$PendingMutationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pendingMutations,
      getReferencedColumn: (t) => t.articleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PendingMutationsTableAnnotationComposer(
            $db: $db,
            $table: $db.pendingMutations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ArticlesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ArticlesTable,
          ArticleRow,
          $$ArticlesTableFilterComposer,
          $$ArticlesTableOrderingComposer,
          $$ArticlesTableAnnotationComposer,
          $$ArticlesTableCreateCompanionBuilder,
          $$ArticlesTableUpdateCompanionBuilder,
          (ArticleRow, $$ArticlesTableReferences),
          ArticleRow,
          PrefetchHooks Function({
            bool articleDetailsRefs,
            bool bookmarksRefs,
            bool feedEntriesRefs,
            bool pendingMutationsRefs,
          })
        > {
  $$ArticlesTableTableManager(_$AppDatabase db, $ArticlesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArticlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArticlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArticlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> authorName = const Value.absent(),
                Value<String?> authorAvatar = const Value.absent(),
                Value<String> topicId = const Value.absent(),
                Value<DateTime> publishedAt = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<List<String>> tags = const Value.absent(),
                Value<int> likes = const Value.absent(),
                Value<int> comments = const Value.absent(),
                Value<bool> isLikedOnServer = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArticlesCompanion(
                id: id,
                title: title,
                summary: summary,
                source: source,
                authorName: authorName,
                authorAvatar: authorAvatar,
                topicId: topicId,
                publishedAt: publishedAt,
                imageUrl: imageUrl,
                tags: tags,
                likes: likes,
                comments: comments,
                isLikedOnServer: isLikedOnServer,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String summary,
                required String source,
                required String authorName,
                Value<String?> authorAvatar = const Value.absent(),
                required String topicId,
                required DateTime publishedAt,
                Value<String?> imageUrl = const Value.absent(),
                required List<String> tags,
                required int likes,
                required int comments,
                required bool isLikedOnServer,
                required int version,
                Value<int> rowid = const Value.absent(),
              }) => ArticlesCompanion.insert(
                id: id,
                title: title,
                summary: summary,
                source: source,
                authorName: authorName,
                authorAvatar: authorAvatar,
                topicId: topicId,
                publishedAt: publishedAt,
                imageUrl: imageUrl,
                tags: tags,
                likes: likes,
                comments: comments,
                isLikedOnServer: isLikedOnServer,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ArticlesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                articleDetailsRefs = false,
                bookmarksRefs = false,
                feedEntriesRefs = false,
                pendingMutationsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (articleDetailsRefs) db.articleDetails,
                    if (bookmarksRefs) db.bookmarks,
                    if (feedEntriesRefs) db.feedEntries,
                    if (pendingMutationsRefs) db.pendingMutations,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (articleDetailsRefs)
                        await $_getPrefetchedData<
                          ArticleRow,
                          $ArticlesTable,
                          ArticleDetailRow
                        >(
                          currentTable: table,
                          referencedTable: $$ArticlesTableReferences
                              ._articleDetailsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ArticlesTableReferences(
                                db,
                                table,
                                p0,
                              ).articleDetailsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.articleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (bookmarksRefs)
                        await $_getPrefetchedData<
                          ArticleRow,
                          $ArticlesTable,
                          BookmarkRow
                        >(
                          currentTable: table,
                          referencedTable: $$ArticlesTableReferences
                              ._bookmarksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ArticlesTableReferences(
                                db,
                                table,
                                p0,
                              ).bookmarksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.articleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (feedEntriesRefs)
                        await $_getPrefetchedData<
                          ArticleRow,
                          $ArticlesTable,
                          FeedEntryRow
                        >(
                          currentTable: table,
                          referencedTable: $$ArticlesTableReferences
                              ._feedEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ArticlesTableReferences(
                                db,
                                table,
                                p0,
                              ).feedEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.articleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (pendingMutationsRefs)
                        await $_getPrefetchedData<
                          ArticleRow,
                          $ArticlesTable,
                          PendingMutation
                        >(
                          currentTable: table,
                          referencedTable: $$ArticlesTableReferences
                              ._pendingMutationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ArticlesTableReferences(
                                db,
                                table,
                                p0,
                              ).pendingMutationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.articleId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ArticlesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ArticlesTable,
      ArticleRow,
      $$ArticlesTableFilterComposer,
      $$ArticlesTableOrderingComposer,
      $$ArticlesTableAnnotationComposer,
      $$ArticlesTableCreateCompanionBuilder,
      $$ArticlesTableUpdateCompanionBuilder,
      (ArticleRow, $$ArticlesTableReferences),
      ArticleRow,
      PrefetchHooks Function({
        bool articleDetailsRefs,
        bool bookmarksRefs,
        bool feedEntriesRefs,
        bool pendingMutationsRefs,
      })
    >;
typedef $$ArticleDetailsTableCreateCompanionBuilder =
    ArticleDetailsCompanion Function({
      required String articleId,
      required List<ContentBlock> body,
      Value<String?> authorBio,
      Value<DateTime?> updatedAt,
      Value<int?> readTimeMinutes,
      required List<String> relatedIds,
      Value<int> rowid,
    });
typedef $$ArticleDetailsTableUpdateCompanionBuilder =
    ArticleDetailsCompanion Function({
      Value<String> articleId,
      Value<List<ContentBlock>> body,
      Value<String?> authorBio,
      Value<DateTime?> updatedAt,
      Value<int?> readTimeMinutes,
      Value<List<String>> relatedIds,
      Value<int> rowid,
    });

final class $$ArticleDetailsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ArticleDetailsTable, ArticleDetailRow> {
  $$ArticleDetailsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ArticlesTable _articleIdTable(_$AppDatabase db) =>
      db.articles.createAlias(
        $_aliasNameGenerator(db.articleDetails.articleId, db.articles.id),
      );

  $$ArticlesTableProcessedTableManager get articleId {
    final $_column = $_itemColumn<String>('article_id')!;

    final manager = $$ArticlesTableTableManager(
      $_db,
      $_db.articles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_articleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ArticleDetailsTableFilterComposer
    extends Composer<_$AppDatabase, $ArticleDetailsTable> {
  $$ArticleDetailsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<List<ContentBlock>, List<ContentBlock>, String>
  get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get authorBio => $composableBuilder(
    column: $table.authorBio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get readTimeMinutes => $composableBuilder(
    column: $table.readTimeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get relatedIds => $composableBuilder(
    column: $table.relatedIds,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$ArticlesTableFilterComposer get articleId {
    final $$ArticlesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleId,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableFilterComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ArticleDetailsTableOrderingComposer
    extends Composer<_$AppDatabase, $ArticleDetailsTable> {
  $$ArticleDetailsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorBio => $composableBuilder(
    column: $table.authorBio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get readTimeMinutes => $composableBuilder(
    column: $table.readTimeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relatedIds => $composableBuilder(
    column: $table.relatedIds,
    builder: (column) => ColumnOrderings(column),
  );

  $$ArticlesTableOrderingComposer get articleId {
    final $$ArticlesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleId,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableOrderingComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ArticleDetailsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArticleDetailsTable> {
  $$ArticleDetailsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<List<ContentBlock>, String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get authorBio =>
      $composableBuilder(column: $table.authorBio, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get readTimeMinutes => $composableBuilder(
    column: $table.readTimeMinutes,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get relatedIds =>
      $composableBuilder(
        column: $table.relatedIds,
        builder: (column) => column,
      );

  $$ArticlesTableAnnotationComposer get articleId {
    final $$ArticlesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleId,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableAnnotationComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ArticleDetailsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ArticleDetailsTable,
          ArticleDetailRow,
          $$ArticleDetailsTableFilterComposer,
          $$ArticleDetailsTableOrderingComposer,
          $$ArticleDetailsTableAnnotationComposer,
          $$ArticleDetailsTableCreateCompanionBuilder,
          $$ArticleDetailsTableUpdateCompanionBuilder,
          (ArticleDetailRow, $$ArticleDetailsTableReferences),
          ArticleDetailRow,
          PrefetchHooks Function({bool articleId})
        > {
  $$ArticleDetailsTableTableManager(
    _$AppDatabase db,
    $ArticleDetailsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArticleDetailsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArticleDetailsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArticleDetailsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> articleId = const Value.absent(),
                Value<List<ContentBlock>> body = const Value.absent(),
                Value<String?> authorBio = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int?> readTimeMinutes = const Value.absent(),
                Value<List<String>> relatedIds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArticleDetailsCompanion(
                articleId: articleId,
                body: body,
                authorBio: authorBio,
                updatedAt: updatedAt,
                readTimeMinutes: readTimeMinutes,
                relatedIds: relatedIds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String articleId,
                required List<ContentBlock> body,
                Value<String?> authorBio = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int?> readTimeMinutes = const Value.absent(),
                required List<String> relatedIds,
                Value<int> rowid = const Value.absent(),
              }) => ArticleDetailsCompanion.insert(
                articleId: articleId,
                body: body,
                authorBio: authorBio,
                updatedAt: updatedAt,
                readTimeMinutes: readTimeMinutes,
                relatedIds: relatedIds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ArticleDetailsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({articleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (articleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.articleId,
                                referencedTable: $$ArticleDetailsTableReferences
                                    ._articleIdTable(db),
                                referencedColumn:
                                    $$ArticleDetailsTableReferences
                                        ._articleIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ArticleDetailsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ArticleDetailsTable,
      ArticleDetailRow,
      $$ArticleDetailsTableFilterComposer,
      $$ArticleDetailsTableOrderingComposer,
      $$ArticleDetailsTableAnnotationComposer,
      $$ArticleDetailsTableCreateCompanionBuilder,
      $$ArticleDetailsTableUpdateCompanionBuilder,
      (ArticleDetailRow, $$ArticleDetailsTableReferences),
      ArticleDetailRow,
      PrefetchHooks Function({bool articleId})
    >;
typedef $$BookmarksTableCreateCompanionBuilder =
    BookmarksCompanion Function({
      required String articleId,
      required DateTime savedAt,
      Value<int> rowid,
    });
typedef $$BookmarksTableUpdateCompanionBuilder =
    BookmarksCompanion Function({
      Value<String> articleId,
      Value<DateTime> savedAt,
      Value<int> rowid,
    });

final class $$BookmarksTableReferences
    extends BaseReferences<_$AppDatabase, $BookmarksTable, BookmarkRow> {
  $$BookmarksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ArticlesTable _articleIdTable(_$AppDatabase db) =>
      db.articles.createAlias(
        $_aliasNameGenerator(db.bookmarks.articleId, db.articles.id),
      );

  $$ArticlesTableProcessedTableManager get articleId {
    final $_column = $_itemColumn<String>('article_id')!;

    final manager = $$ArticlesTableTableManager(
      $_db,
      $_db.articles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_articleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ArticlesTableFilterComposer get articleId {
    final $$ArticlesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleId,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableFilterComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ArticlesTableOrderingComposer get articleId {
    final $$ArticlesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleId,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableOrderingComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);

  $$ArticlesTableAnnotationComposer get articleId {
    final $$ArticlesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleId,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableAnnotationComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookmarksTable,
          BookmarkRow,
          $$BookmarksTableFilterComposer,
          $$BookmarksTableOrderingComposer,
          $$BookmarksTableAnnotationComposer,
          $$BookmarksTableCreateCompanionBuilder,
          $$BookmarksTableUpdateCompanionBuilder,
          (BookmarkRow, $$BookmarksTableReferences),
          BookmarkRow,
          PrefetchHooks Function({bool articleId})
        > {
  $$BookmarksTableTableManager(_$AppDatabase db, $BookmarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> articleId = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookmarksCompanion(
                articleId: articleId,
                savedAt: savedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String articleId,
                required DateTime savedAt,
                Value<int> rowid = const Value.absent(),
              }) => BookmarksCompanion.insert(
                articleId: articleId,
                savedAt: savedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BookmarksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({articleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (articleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.articleId,
                                referencedTable: $$BookmarksTableReferences
                                    ._articleIdTable(db),
                                referencedColumn: $$BookmarksTableReferences
                                    ._articleIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookmarksTable,
      BookmarkRow,
      $$BookmarksTableFilterComposer,
      $$BookmarksTableOrderingComposer,
      $$BookmarksTableAnnotationComposer,
      $$BookmarksTableCreateCompanionBuilder,
      $$BookmarksTableUpdateCompanionBuilder,
      (BookmarkRow, $$BookmarksTableReferences),
      BookmarkRow,
      PrefetchHooks Function({bool articleId})
    >;
typedef $$FeedEntriesTableCreateCompanionBuilder =
    FeedEntriesCompanion Function({
      required String feedKey,
      required String articleId,
      Value<int> rowid,
    });
typedef $$FeedEntriesTableUpdateCompanionBuilder =
    FeedEntriesCompanion Function({
      Value<String> feedKey,
      Value<String> articleId,
      Value<int> rowid,
    });

final class $$FeedEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $FeedEntriesTable, FeedEntryRow> {
  $$FeedEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ArticlesTable _articleIdTable(_$AppDatabase db) =>
      db.articles.createAlias(
        $_aliasNameGenerator(db.feedEntries.articleId, db.articles.id),
      );

  $$ArticlesTableProcessedTableManager get articleId {
    final $_column = $_itemColumn<String>('article_id')!;

    final manager = $$ArticlesTableTableManager(
      $_db,
      $_db.articles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_articleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FeedEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $FeedEntriesTable> {
  $$FeedEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get feedKey => $composableBuilder(
    column: $table.feedKey,
    builder: (column) => ColumnFilters(column),
  );

  $$ArticlesTableFilterComposer get articleId {
    final $$ArticlesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleId,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableFilterComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FeedEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedEntriesTable> {
  $$FeedEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get feedKey => $composableBuilder(
    column: $table.feedKey,
    builder: (column) => ColumnOrderings(column),
  );

  $$ArticlesTableOrderingComposer get articleId {
    final $$ArticlesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleId,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableOrderingComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FeedEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedEntriesTable> {
  $$FeedEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get feedKey =>
      $composableBuilder(column: $table.feedKey, builder: (column) => column);

  $$ArticlesTableAnnotationComposer get articleId {
    final $$ArticlesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleId,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableAnnotationComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FeedEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeedEntriesTable,
          FeedEntryRow,
          $$FeedEntriesTableFilterComposer,
          $$FeedEntriesTableOrderingComposer,
          $$FeedEntriesTableAnnotationComposer,
          $$FeedEntriesTableCreateCompanionBuilder,
          $$FeedEntriesTableUpdateCompanionBuilder,
          (FeedEntryRow, $$FeedEntriesTableReferences),
          FeedEntryRow,
          PrefetchHooks Function({bool articleId})
        > {
  $$FeedEntriesTableTableManager(_$AppDatabase db, $FeedEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> feedKey = const Value.absent(),
                Value<String> articleId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedEntriesCompanion(
                feedKey: feedKey,
                articleId: articleId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String feedKey,
                required String articleId,
                Value<int> rowid = const Value.absent(),
              }) => FeedEntriesCompanion.insert(
                feedKey: feedKey,
                articleId: articleId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FeedEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({articleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (articleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.articleId,
                                referencedTable: $$FeedEntriesTableReferences
                                    ._articleIdTable(db),
                                referencedColumn: $$FeedEntriesTableReferences
                                    ._articleIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FeedEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeedEntriesTable,
      FeedEntryRow,
      $$FeedEntriesTableFilterComposer,
      $$FeedEntriesTableOrderingComposer,
      $$FeedEntriesTableAnnotationComposer,
      $$FeedEntriesTableCreateCompanionBuilder,
      $$FeedEntriesTableUpdateCompanionBuilder,
      (FeedEntryRow, $$FeedEntriesTableReferences),
      FeedEntryRow,
      PrefetchHooks Function({bool articleId})
    >;
typedef $$FeedsTableCreateCompanionBuilder =
    FeedsCompanion Function({
      required String feedKey,
      Value<String?> nextCursor,
      Value<int> rowid,
    });
typedef $$FeedsTableUpdateCompanionBuilder =
    FeedsCompanion Function({
      Value<String> feedKey,
      Value<String?> nextCursor,
      Value<int> rowid,
    });

class $$FeedsTableFilterComposer extends Composer<_$AppDatabase, $FeedsTable> {
  $$FeedsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get feedKey => $composableBuilder(
    column: $table.feedKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextCursor => $composableBuilder(
    column: $table.nextCursor,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeedsTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedsTable> {
  $$FeedsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get feedKey => $composableBuilder(
    column: $table.feedKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextCursor => $composableBuilder(
    column: $table.nextCursor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeedsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedsTable> {
  $$FeedsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get feedKey =>
      $composableBuilder(column: $table.feedKey, builder: (column) => column);

  GeneratedColumn<String> get nextCursor => $composableBuilder(
    column: $table.nextCursor,
    builder: (column) => column,
  );
}

class $$FeedsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeedsTable,
          FeedRow,
          $$FeedsTableFilterComposer,
          $$FeedsTableOrderingComposer,
          $$FeedsTableAnnotationComposer,
          $$FeedsTableCreateCompanionBuilder,
          $$FeedsTableUpdateCompanionBuilder,
          (FeedRow, BaseReferences<_$AppDatabase, $FeedsTable, FeedRow>),
          FeedRow,
          PrefetchHooks Function()
        > {
  $$FeedsTableTableManager(_$AppDatabase db, $FeedsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> feedKey = const Value.absent(),
                Value<String?> nextCursor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedsCompanion(
                feedKey: feedKey,
                nextCursor: nextCursor,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String feedKey,
                Value<String?> nextCursor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedsCompanion.insert(
                feedKey: feedKey,
                nextCursor: nextCursor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeedsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeedsTable,
      FeedRow,
      $$FeedsTableFilterComposer,
      $$FeedsTableOrderingComposer,
      $$FeedsTableAnnotationComposer,
      $$FeedsTableCreateCompanionBuilder,
      $$FeedsTableUpdateCompanionBuilder,
      (FeedRow, BaseReferences<_$AppDatabase, $FeedsTable, FeedRow>),
      FeedRow,
      PrefetchHooks Function()
    >;
typedef $$PendingMutationsTableCreateCompanionBuilder =
    PendingMutationsCompanion Function({
      required MutationKind kind,
      required String articleId,
      required bool value,
      required String idempotencyKey,
      required DateTime queuedAt,
      Value<int> rowid,
    });
typedef $$PendingMutationsTableUpdateCompanionBuilder =
    PendingMutationsCompanion Function({
      Value<MutationKind> kind,
      Value<String> articleId,
      Value<bool> value,
      Value<String> idempotencyKey,
      Value<DateTime> queuedAt,
      Value<int> rowid,
    });

final class $$PendingMutationsTableReferences
    extends
        BaseReferences<_$AppDatabase, $PendingMutationsTable, PendingMutation> {
  $$PendingMutationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ArticlesTable _articleIdTable(_$AppDatabase db) =>
      db.articles.createAlias(
        $_aliasNameGenerator(db.pendingMutations.articleId, db.articles.id),
      );

  $$ArticlesTableProcessedTableManager get articleId {
    final $_column = $_itemColumn<String>('article_id')!;

    final manager = $$ArticlesTableTableManager(
      $_db,
      $_db.articles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_articleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PendingMutationsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingMutationsTable> {
  $$PendingMutationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<MutationKind, MutationKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get queuedAt => $composableBuilder(
    column: $table.queuedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ArticlesTableFilterComposer get articleId {
    final $$ArticlesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleId,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableFilterComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PendingMutationsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingMutationsTable> {
  $$PendingMutationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get queuedAt => $composableBuilder(
    column: $table.queuedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ArticlesTableOrderingComposer get articleId {
    final $$ArticlesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleId,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableOrderingComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PendingMutationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingMutationsTable> {
  $$PendingMutationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<MutationKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<bool> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get queuedAt =>
      $composableBuilder(column: $table.queuedAt, builder: (column) => column);

  $$ArticlesTableAnnotationComposer get articleId {
    final $$ArticlesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleId,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableAnnotationComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PendingMutationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingMutationsTable,
          PendingMutation,
          $$PendingMutationsTableFilterComposer,
          $$PendingMutationsTableOrderingComposer,
          $$PendingMutationsTableAnnotationComposer,
          $$PendingMutationsTableCreateCompanionBuilder,
          $$PendingMutationsTableUpdateCompanionBuilder,
          (PendingMutation, $$PendingMutationsTableReferences),
          PendingMutation,
          PrefetchHooks Function({bool articleId})
        > {
  $$PendingMutationsTableTableManager(
    _$AppDatabase db,
    $PendingMutationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingMutationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingMutationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingMutationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<MutationKind> kind = const Value.absent(),
                Value<String> articleId = const Value.absent(),
                Value<bool> value = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<DateTime> queuedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingMutationsCompanion(
                kind: kind,
                articleId: articleId,
                value: value,
                idempotencyKey: idempotencyKey,
                queuedAt: queuedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required MutationKind kind,
                required String articleId,
                required bool value,
                required String idempotencyKey,
                required DateTime queuedAt,
                Value<int> rowid = const Value.absent(),
              }) => PendingMutationsCompanion.insert(
                kind: kind,
                articleId: articleId,
                value: value,
                idempotencyKey: idempotencyKey,
                queuedAt: queuedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PendingMutationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({articleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (articleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.articleId,
                                referencedTable:
                                    $$PendingMutationsTableReferences
                                        ._articleIdTable(db),
                                referencedColumn:
                                    $$PendingMutationsTableReferences
                                        ._articleIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PendingMutationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingMutationsTable,
      PendingMutation,
      $$PendingMutationsTableFilterComposer,
      $$PendingMutationsTableOrderingComposer,
      $$PendingMutationsTableAnnotationComposer,
      $$PendingMutationsTableCreateCompanionBuilder,
      $$PendingMutationsTableUpdateCompanionBuilder,
      (PendingMutation, $$PendingMutationsTableReferences),
      PendingMutation,
      PrefetchHooks Function({bool articleId})
    >;
typedef $$KeyValuesTableCreateCompanionBuilder =
    KeyValuesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$KeyValuesTableUpdateCompanionBuilder =
    KeyValuesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$KeyValuesTableFilterComposer
    extends Composer<_$AppDatabase, $KeyValuesTable> {
  $$KeyValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KeyValuesTableOrderingComposer
    extends Composer<_$AppDatabase, $KeyValuesTable> {
  $$KeyValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KeyValuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $KeyValuesTable> {
  $$KeyValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$KeyValuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KeyValuesTable,
          KeyValueRow,
          $$KeyValuesTableFilterComposer,
          $$KeyValuesTableOrderingComposer,
          $$KeyValuesTableAnnotationComposer,
          $$KeyValuesTableCreateCompanionBuilder,
          $$KeyValuesTableUpdateCompanionBuilder,
          (
            KeyValueRow,
            BaseReferences<_$AppDatabase, $KeyValuesTable, KeyValueRow>,
          ),
          KeyValueRow,
          PrefetchHooks Function()
        > {
  $$KeyValuesTableTableManager(_$AppDatabase db, $KeyValuesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KeyValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KeyValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KeyValuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KeyValuesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => KeyValuesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KeyValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KeyValuesTable,
      KeyValueRow,
      $$KeyValuesTableFilterComposer,
      $$KeyValuesTableOrderingComposer,
      $$KeyValuesTableAnnotationComposer,
      $$KeyValuesTableCreateCompanionBuilder,
      $$KeyValuesTableUpdateCompanionBuilder,
      (
        KeyValueRow,
        BaseReferences<_$AppDatabase, $KeyValuesTable, KeyValueRow>,
      ),
      KeyValueRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ArticlesTableTableManager get articles =>
      $$ArticlesTableTableManager(_db, _db.articles);
  $$ArticleDetailsTableTableManager get articleDetails =>
      $$ArticleDetailsTableTableManager(_db, _db.articleDetails);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$FeedEntriesTableTableManager get feedEntries =>
      $$FeedEntriesTableTableManager(_db, _db.feedEntries);
  $$FeedsTableTableManager get feeds =>
      $$FeedsTableTableManager(_db, _db.feeds);
  $$PendingMutationsTableTableManager get pendingMutations =>
      $$PendingMutationsTableTableManager(_db, _db.pendingMutations);
  $$KeyValuesTableTableManager get keyValues =>
      $$KeyValuesTableTableManager(_db, _db.keyValues);
}
