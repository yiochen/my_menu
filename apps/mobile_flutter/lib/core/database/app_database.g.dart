// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DishesTable extends Dishes with TableInfo<$DishesTable, DishRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DishesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _heroImageUrlMeta =
      const VerificationMeta('heroImageUrl');
  @override
  late final GeneratedColumn<String> heroImageUrl = GeneratedColumn<String>(
      'hero_image_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _heroPreviewUrlMeta =
      const VerificationMeta('heroPreviewUrl');
  @override
  late final GeneratedColumn<String> heroPreviewUrl = GeneratedColumn<String>(
      'hero_preview_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _heroThumbnailUrlMeta =
      const VerificationMeta('heroThumbnailUrl');
  @override
  late final GeneratedColumn<String> heroThumbnailUrl = GeneratedColumn<String>(
      'hero_thumbnail_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _heroPlaceholderUrlMeta =
      const VerificationMeta('heroPlaceholderUrl');
  @override
  late final GeneratedColumn<String> heroPlaceholderUrl =
      GeneratedColumn<String>('hero_placeholder_url', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _prepMinutesMeta =
      const VerificationMeta('prepMinutes');
  @override
  late final GeneratedColumn<int> prepMinutes = GeneratedColumn<int>(
      'prep_minutes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _difficultyMeta =
      const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
      'difficulty', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _madeCountMeta =
      const VerificationMeta('madeCount');
  @override
  late final GeneratedColumn<int> madeCount = GeneratedColumn<int>(
      'made_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastMadeLabelMeta =
      const VerificationMeta('lastMadeLabel');
  @override
  late final GeneratedColumn<String> lastMadeLabel = GeneratedColumn<String>(
      'last_made_label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ingredientsJsonMeta =
      const VerificationMeta('ingredientsJson');
  @override
  late final GeneratedColumn<String> ingredientsJson = GeneratedColumn<String>(
      'ingredients_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recipeStepsJsonMeta =
      const VerificationMeta('recipeStepsJson');
  @override
  late final GeneratedColumn<String> recipeStepsJson = GeneratedColumn<String>(
      'recipe_steps_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesJsonMeta =
      const VerificationMeta('notesJson');
  @override
  late final GeneratedColumn<String> notesJson = GeneratedColumn<String>(
      'notes_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _openedAtMeta =
      const VerificationMeta('openedAt');
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
      'opened_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        description,
        heroImageUrl,
        heroPreviewUrl,
        heroThumbnailUrl,
        heroPlaceholderUrl,
        category,
        prepMinutes,
        difficulty,
        madeCount,
        lastMadeLabel,
        ingredientsJson,
        recipeStepsJson,
        notesJson,
        isFavorite,
        createdAt,
        openedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dishes';
  @override
  VerificationContext validateIntegrity(Insertable<DishRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('hero_image_url')) {
      context.handle(
          _heroImageUrlMeta,
          heroImageUrl.isAcceptableOrUnknown(
              data['hero_image_url']!, _heroImageUrlMeta));
    } else if (isInserting) {
      context.missing(_heroImageUrlMeta);
    }
    if (data.containsKey('hero_preview_url')) {
      context.handle(
          _heroPreviewUrlMeta,
          heroPreviewUrl.isAcceptableOrUnknown(
              data['hero_preview_url']!, _heroPreviewUrlMeta));
    }
    if (data.containsKey('hero_thumbnail_url')) {
      context.handle(
          _heroThumbnailUrlMeta,
          heroThumbnailUrl.isAcceptableOrUnknown(
              data['hero_thumbnail_url']!, _heroThumbnailUrlMeta));
    }
    if (data.containsKey('hero_placeholder_url')) {
      context.handle(
          _heroPlaceholderUrlMeta,
          heroPlaceholderUrl.isAcceptableOrUnknown(
              data['hero_placeholder_url']!, _heroPlaceholderUrlMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('prep_minutes')) {
      context.handle(
          _prepMinutesMeta,
          prepMinutes.isAcceptableOrUnknown(
              data['prep_minutes']!, _prepMinutesMeta));
    } else if (isInserting) {
      context.missing(_prepMinutesMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
          _difficultyMeta,
          difficulty.isAcceptableOrUnknown(
              data['difficulty']!, _difficultyMeta));
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('made_count')) {
      context.handle(_madeCountMeta,
          madeCount.isAcceptableOrUnknown(data['made_count']!, _madeCountMeta));
    } else if (isInserting) {
      context.missing(_madeCountMeta);
    }
    if (data.containsKey('last_made_label')) {
      context.handle(
          _lastMadeLabelMeta,
          lastMadeLabel.isAcceptableOrUnknown(
              data['last_made_label']!, _lastMadeLabelMeta));
    } else if (isInserting) {
      context.missing(_lastMadeLabelMeta);
    }
    if (data.containsKey('ingredients_json')) {
      context.handle(
          _ingredientsJsonMeta,
          ingredientsJson.isAcceptableOrUnknown(
              data['ingredients_json']!, _ingredientsJsonMeta));
    } else if (isInserting) {
      context.missing(_ingredientsJsonMeta);
    }
    if (data.containsKey('recipe_steps_json')) {
      context.handle(
          _recipeStepsJsonMeta,
          recipeStepsJson.isAcceptableOrUnknown(
              data['recipe_steps_json']!, _recipeStepsJsonMeta));
    } else if (isInserting) {
      context.missing(_recipeStepsJsonMeta);
    }
    if (data.containsKey('notes_json')) {
      context.handle(_notesJsonMeta,
          notesJson.isAcceptableOrUnknown(data['notes_json']!, _notesJsonMeta));
    } else if (isInserting) {
      context.missing(_notesJsonMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('opened_at')) {
      context.handle(_openedAtMeta,
          openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DishRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DishRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      heroImageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hero_image_url'])!,
      heroPreviewUrl: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}hero_preview_url']),
      heroThumbnailUrl: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}hero_thumbnail_url']),
      heroPlaceholderUrl: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}hero_placeholder_url']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      prepMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}prep_minutes'])!,
      difficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}difficulty'])!,
      madeCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}made_count'])!,
      lastMadeLabel: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_made_label'])!,
      ingredientsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}ingredients_json'])!,
      recipeStepsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}recipe_steps_json'])!,
      notesJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes_json'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      openedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}opened_at']),
    );
  }

  @override
  $DishesTable createAlias(String alias) {
    return $DishesTable(attachedDatabase, alias);
  }
}

class DishRow extends DataClass implements Insertable<DishRow> {
  final String id;
  final String title;
  final String description;
  final String heroImageUrl;
  final String? heroPreviewUrl;
  final String? heroThumbnailUrl;
  final String? heroPlaceholderUrl;
  final String category;
  final int prepMinutes;
  final String difficulty;
  final int madeCount;
  final String lastMadeLabel;
  final String ingredientsJson;
  final String recipeStepsJson;
  final String notesJson;
  final bool isFavorite;
  final DateTime? createdAt;
  final DateTime? openedAt;
  const DishRow(
      {required this.id,
      required this.title,
      required this.description,
      required this.heroImageUrl,
      this.heroPreviewUrl,
      this.heroThumbnailUrl,
      this.heroPlaceholderUrl,
      required this.category,
      required this.prepMinutes,
      required this.difficulty,
      required this.madeCount,
      required this.lastMadeLabel,
      required this.ingredientsJson,
      required this.recipeStepsJson,
      required this.notesJson,
      required this.isFavorite,
      this.createdAt,
      this.openedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['hero_image_url'] = Variable<String>(heroImageUrl);
    if (!nullToAbsent || heroPreviewUrl != null) {
      map['hero_preview_url'] = Variable<String>(heroPreviewUrl);
    }
    if (!nullToAbsent || heroThumbnailUrl != null) {
      map['hero_thumbnail_url'] = Variable<String>(heroThumbnailUrl);
    }
    if (!nullToAbsent || heroPlaceholderUrl != null) {
      map['hero_placeholder_url'] = Variable<String>(heroPlaceholderUrl);
    }
    map['category'] = Variable<String>(category);
    map['prep_minutes'] = Variable<int>(prepMinutes);
    map['difficulty'] = Variable<String>(difficulty);
    map['made_count'] = Variable<int>(madeCount);
    map['last_made_label'] = Variable<String>(lastMadeLabel);
    map['ingredients_json'] = Variable<String>(ingredientsJson);
    map['recipe_steps_json'] = Variable<String>(recipeStepsJson);
    map['notes_json'] = Variable<String>(notesJson);
    map['is_favorite'] = Variable<bool>(isFavorite);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || openedAt != null) {
      map['opened_at'] = Variable<DateTime>(openedAt);
    }
    return map;
  }

  DishesCompanion toCompanion(bool nullToAbsent) {
    return DishesCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      heroImageUrl: Value(heroImageUrl),
      heroPreviewUrl: heroPreviewUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(heroPreviewUrl),
      heroThumbnailUrl: heroThumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(heroThumbnailUrl),
      heroPlaceholderUrl: heroPlaceholderUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(heroPlaceholderUrl),
      category: Value(category),
      prepMinutes: Value(prepMinutes),
      difficulty: Value(difficulty),
      madeCount: Value(madeCount),
      lastMadeLabel: Value(lastMadeLabel),
      ingredientsJson: Value(ingredientsJson),
      recipeStepsJson: Value(recipeStepsJson),
      notesJson: Value(notesJson),
      isFavorite: Value(isFavorite),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      openedAt: openedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(openedAt),
    );
  }

  factory DishRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DishRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      heroImageUrl: serializer.fromJson<String>(json['heroImageUrl']),
      heroPreviewUrl: serializer.fromJson<String?>(json['heroPreviewUrl']),
      heroThumbnailUrl: serializer.fromJson<String?>(json['heroThumbnailUrl']),
      heroPlaceholderUrl:
          serializer.fromJson<String?>(json['heroPlaceholderUrl']),
      category: serializer.fromJson<String>(json['category']),
      prepMinutes: serializer.fromJson<int>(json['prepMinutes']),
      difficulty: serializer.fromJson<String>(json['difficulty']),
      madeCount: serializer.fromJson<int>(json['madeCount']),
      lastMadeLabel: serializer.fromJson<String>(json['lastMadeLabel']),
      ingredientsJson: serializer.fromJson<String>(json['ingredientsJson']),
      recipeStepsJson: serializer.fromJson<String>(json['recipeStepsJson']),
      notesJson: serializer.fromJson<String>(json['notesJson']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      openedAt: serializer.fromJson<DateTime?>(json['openedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'heroImageUrl': serializer.toJson<String>(heroImageUrl),
      'heroPreviewUrl': serializer.toJson<String?>(heroPreviewUrl),
      'heroThumbnailUrl': serializer.toJson<String?>(heroThumbnailUrl),
      'heroPlaceholderUrl': serializer.toJson<String?>(heroPlaceholderUrl),
      'category': serializer.toJson<String>(category),
      'prepMinutes': serializer.toJson<int>(prepMinutes),
      'difficulty': serializer.toJson<String>(difficulty),
      'madeCount': serializer.toJson<int>(madeCount),
      'lastMadeLabel': serializer.toJson<String>(lastMadeLabel),
      'ingredientsJson': serializer.toJson<String>(ingredientsJson),
      'recipeStepsJson': serializer.toJson<String>(recipeStepsJson),
      'notesJson': serializer.toJson<String>(notesJson),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'openedAt': serializer.toJson<DateTime?>(openedAt),
    };
  }

  DishRow copyWith(
          {String? id,
          String? title,
          String? description,
          String? heroImageUrl,
          Value<String?> heroPreviewUrl = const Value.absent(),
          Value<String?> heroThumbnailUrl = const Value.absent(),
          Value<String?> heroPlaceholderUrl = const Value.absent(),
          String? category,
          int? prepMinutes,
          String? difficulty,
          int? madeCount,
          String? lastMadeLabel,
          String? ingredientsJson,
          String? recipeStepsJson,
          String? notesJson,
          bool? isFavorite,
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> openedAt = const Value.absent()}) =>
      DishRow(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        heroImageUrl: heroImageUrl ?? this.heroImageUrl,
        heroPreviewUrl:
            heroPreviewUrl.present ? heroPreviewUrl.value : this.heroPreviewUrl,
        heroThumbnailUrl: heroThumbnailUrl.present
            ? heroThumbnailUrl.value
            : this.heroThumbnailUrl,
        heroPlaceholderUrl: heroPlaceholderUrl.present
            ? heroPlaceholderUrl.value
            : this.heroPlaceholderUrl,
        category: category ?? this.category,
        prepMinutes: prepMinutes ?? this.prepMinutes,
        difficulty: difficulty ?? this.difficulty,
        madeCount: madeCount ?? this.madeCount,
        lastMadeLabel: lastMadeLabel ?? this.lastMadeLabel,
        ingredientsJson: ingredientsJson ?? this.ingredientsJson,
        recipeStepsJson: recipeStepsJson ?? this.recipeStepsJson,
        notesJson: notesJson ?? this.notesJson,
        isFavorite: isFavorite ?? this.isFavorite,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        openedAt: openedAt.present ? openedAt.value : this.openedAt,
      );
  DishRow copyWithCompanion(DishesCompanion data) {
    return DishRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      heroImageUrl: data.heroImageUrl.present
          ? data.heroImageUrl.value
          : this.heroImageUrl,
      heroPreviewUrl: data.heroPreviewUrl.present
          ? data.heroPreviewUrl.value
          : this.heroPreviewUrl,
      heroThumbnailUrl: data.heroThumbnailUrl.present
          ? data.heroThumbnailUrl.value
          : this.heroThumbnailUrl,
      heroPlaceholderUrl: data.heroPlaceholderUrl.present
          ? data.heroPlaceholderUrl.value
          : this.heroPlaceholderUrl,
      category: data.category.present ? data.category.value : this.category,
      prepMinutes:
          data.prepMinutes.present ? data.prepMinutes.value : this.prepMinutes,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      madeCount: data.madeCount.present ? data.madeCount.value : this.madeCount,
      lastMadeLabel: data.lastMadeLabel.present
          ? data.lastMadeLabel.value
          : this.lastMadeLabel,
      ingredientsJson: data.ingredientsJson.present
          ? data.ingredientsJson.value
          : this.ingredientsJson,
      recipeStepsJson: data.recipeStepsJson.present
          ? data.recipeStepsJson.value
          : this.recipeStepsJson,
      notesJson: data.notesJson.present ? data.notesJson.value : this.notesJson,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DishRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('heroImageUrl: $heroImageUrl, ')
          ..write('heroPreviewUrl: $heroPreviewUrl, ')
          ..write('heroThumbnailUrl: $heroThumbnailUrl, ')
          ..write('heroPlaceholderUrl: $heroPlaceholderUrl, ')
          ..write('category: $category, ')
          ..write('prepMinutes: $prepMinutes, ')
          ..write('difficulty: $difficulty, ')
          ..write('madeCount: $madeCount, ')
          ..write('lastMadeLabel: $lastMadeLabel, ')
          ..write('ingredientsJson: $ingredientsJson, ')
          ..write('recipeStepsJson: $recipeStepsJson, ')
          ..write('notesJson: $notesJson, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt, ')
          ..write('openedAt: $openedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      description,
      heroImageUrl,
      heroPreviewUrl,
      heroThumbnailUrl,
      heroPlaceholderUrl,
      category,
      prepMinutes,
      difficulty,
      madeCount,
      lastMadeLabel,
      ingredientsJson,
      recipeStepsJson,
      notesJson,
      isFavorite,
      createdAt,
      openedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DishRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.heroImageUrl == this.heroImageUrl &&
          other.heroPreviewUrl == this.heroPreviewUrl &&
          other.heroThumbnailUrl == this.heroThumbnailUrl &&
          other.heroPlaceholderUrl == this.heroPlaceholderUrl &&
          other.category == this.category &&
          other.prepMinutes == this.prepMinutes &&
          other.difficulty == this.difficulty &&
          other.madeCount == this.madeCount &&
          other.lastMadeLabel == this.lastMadeLabel &&
          other.ingredientsJson == this.ingredientsJson &&
          other.recipeStepsJson == this.recipeStepsJson &&
          other.notesJson == this.notesJson &&
          other.isFavorite == this.isFavorite &&
          other.createdAt == this.createdAt &&
          other.openedAt == this.openedAt);
}

class DishesCompanion extends UpdateCompanion<DishRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<String> heroImageUrl;
  final Value<String?> heroPreviewUrl;
  final Value<String?> heroThumbnailUrl;
  final Value<String?> heroPlaceholderUrl;
  final Value<String> category;
  final Value<int> prepMinutes;
  final Value<String> difficulty;
  final Value<int> madeCount;
  final Value<String> lastMadeLabel;
  final Value<String> ingredientsJson;
  final Value<String> recipeStepsJson;
  final Value<String> notesJson;
  final Value<bool> isFavorite;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> openedAt;
  final Value<int> rowid;
  const DishesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.heroImageUrl = const Value.absent(),
    this.heroPreviewUrl = const Value.absent(),
    this.heroThumbnailUrl = const Value.absent(),
    this.heroPlaceholderUrl = const Value.absent(),
    this.category = const Value.absent(),
    this.prepMinutes = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.madeCount = const Value.absent(),
    this.lastMadeLabel = const Value.absent(),
    this.ingredientsJson = const Value.absent(),
    this.recipeStepsJson = const Value.absent(),
    this.notesJson = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DishesCompanion.insert({
    required String id,
    required String title,
    required String description,
    required String heroImageUrl,
    this.heroPreviewUrl = const Value.absent(),
    this.heroThumbnailUrl = const Value.absent(),
    this.heroPlaceholderUrl = const Value.absent(),
    required String category,
    required int prepMinutes,
    required String difficulty,
    required int madeCount,
    required String lastMadeLabel,
    required String ingredientsJson,
    required String recipeStepsJson,
    required String notesJson,
    this.isFavorite = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        description = Value(description),
        heroImageUrl = Value(heroImageUrl),
        category = Value(category),
        prepMinutes = Value(prepMinutes),
        difficulty = Value(difficulty),
        madeCount = Value(madeCount),
        lastMadeLabel = Value(lastMadeLabel),
        ingredientsJson = Value(ingredientsJson),
        recipeStepsJson = Value(recipeStepsJson),
        notesJson = Value(notesJson);
  static Insertable<DishRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? heroImageUrl,
    Expression<String>? heroPreviewUrl,
    Expression<String>? heroThumbnailUrl,
    Expression<String>? heroPlaceholderUrl,
    Expression<String>? category,
    Expression<int>? prepMinutes,
    Expression<String>? difficulty,
    Expression<int>? madeCount,
    Expression<String>? lastMadeLabel,
    Expression<String>? ingredientsJson,
    Expression<String>? recipeStepsJson,
    Expression<String>? notesJson,
    Expression<bool>? isFavorite,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? openedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (heroImageUrl != null) 'hero_image_url': heroImageUrl,
      if (heroPreviewUrl != null) 'hero_preview_url': heroPreviewUrl,
      if (heroThumbnailUrl != null) 'hero_thumbnail_url': heroThumbnailUrl,
      if (heroPlaceholderUrl != null)
        'hero_placeholder_url': heroPlaceholderUrl,
      if (category != null) 'category': category,
      if (prepMinutes != null) 'prep_minutes': prepMinutes,
      if (difficulty != null) 'difficulty': difficulty,
      if (madeCount != null) 'made_count': madeCount,
      if (lastMadeLabel != null) 'last_made_label': lastMadeLabel,
      if (ingredientsJson != null) 'ingredients_json': ingredientsJson,
      if (recipeStepsJson != null) 'recipe_steps_json': recipeStepsJson,
      if (notesJson != null) 'notes_json': notesJson,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (createdAt != null) 'created_at': createdAt,
      if (openedAt != null) 'opened_at': openedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DishesCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? description,
      Value<String>? heroImageUrl,
      Value<String?>? heroPreviewUrl,
      Value<String?>? heroThumbnailUrl,
      Value<String?>? heroPlaceholderUrl,
      Value<String>? category,
      Value<int>? prepMinutes,
      Value<String>? difficulty,
      Value<int>? madeCount,
      Value<String>? lastMadeLabel,
      Value<String>? ingredientsJson,
      Value<String>? recipeStepsJson,
      Value<String>? notesJson,
      Value<bool>? isFavorite,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? openedAt,
      Value<int>? rowid}) {
    return DishesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      heroImageUrl: heroImageUrl ?? this.heroImageUrl,
      heroPreviewUrl: heroPreviewUrl ?? this.heroPreviewUrl,
      heroThumbnailUrl: heroThumbnailUrl ?? this.heroThumbnailUrl,
      heroPlaceholderUrl: heroPlaceholderUrl ?? this.heroPlaceholderUrl,
      category: category ?? this.category,
      prepMinutes: prepMinutes ?? this.prepMinutes,
      difficulty: difficulty ?? this.difficulty,
      madeCount: madeCount ?? this.madeCount,
      lastMadeLabel: lastMadeLabel ?? this.lastMadeLabel,
      ingredientsJson: ingredientsJson ?? this.ingredientsJson,
      recipeStepsJson: recipeStepsJson ?? this.recipeStepsJson,
      notesJson: notesJson ?? this.notesJson,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      openedAt: openedAt ?? this.openedAt,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (heroImageUrl.present) {
      map['hero_image_url'] = Variable<String>(heroImageUrl.value);
    }
    if (heroPreviewUrl.present) {
      map['hero_preview_url'] = Variable<String>(heroPreviewUrl.value);
    }
    if (heroThumbnailUrl.present) {
      map['hero_thumbnail_url'] = Variable<String>(heroThumbnailUrl.value);
    }
    if (heroPlaceholderUrl.present) {
      map['hero_placeholder_url'] = Variable<String>(heroPlaceholderUrl.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (prepMinutes.present) {
      map['prep_minutes'] = Variable<int>(prepMinutes.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (madeCount.present) {
      map['made_count'] = Variable<int>(madeCount.value);
    }
    if (lastMadeLabel.present) {
      map['last_made_label'] = Variable<String>(lastMadeLabel.value);
    }
    if (ingredientsJson.present) {
      map['ingredients_json'] = Variable<String>(ingredientsJson.value);
    }
    if (recipeStepsJson.present) {
      map['recipe_steps_json'] = Variable<String>(recipeStepsJson.value);
    }
    if (notesJson.present) {
      map['notes_json'] = Variable<String>(notesJson.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DishesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('heroImageUrl: $heroImageUrl, ')
          ..write('heroPreviewUrl: $heroPreviewUrl, ')
          ..write('heroThumbnailUrl: $heroThumbnailUrl, ')
          ..write('heroPlaceholderUrl: $heroPlaceholderUrl, ')
          ..write('category: $category, ')
          ..write('prepMinutes: $prepMinutes, ')
          ..write('difficulty: $difficulty, ')
          ..write('madeCount: $madeCount, ')
          ..write('lastMadeLabel: $lastMadeLabel, ')
          ..write('ingredientsJson: $ingredientsJson, ')
          ..write('recipeStepsJson: $recipeStepsJson, ')
          ..write('notesJson: $notesJson, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt, ')
          ..write('openedAt: $openedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DishNotesTable extends DishNotes
    with TableInfo<$DishNotesTable, DishNoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DishNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dishIdMeta = const VerificationMeta('dishId');
  @override
  late final GeneratedColumn<String> dishId = GeneratedColumn<String>(
      'dish_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, dishId, body, position, createdAt, updatedAt, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dish_notes';
  @override
  VerificationContext validateIntegrity(Insertable<DishNoteRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('dish_id')) {
      context.handle(_dishIdMeta,
          dishId.isAcceptableOrUnknown(data['dish_id']!, _dishIdMeta));
    } else if (isInserting) {
      context.missing(_dishIdMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DishNoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DishNoteRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      dishId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dish_id'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $DishNotesTable createAlias(String alias) {
    return $DishNotesTable(attachedDatabase, alias);
  }
}

class DishNoteRow extends DataClass implements Insertable<DishNoteRow> {
  final String id;
  final String dishId;
  final String body;
  final int position;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const DishNoteRow(
      {required this.id,
      required this.dishId,
      required this.body,
      required this.position,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['dish_id'] = Variable<String>(dishId);
    map['body'] = Variable<String>(body);
    map['position'] = Variable<int>(position);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  DishNotesCompanion toCompanion(bool nullToAbsent) {
    return DishNotesCompanion(
      id: Value(id),
      dishId: Value(dishId),
      body: Value(body),
      position: Value(position),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory DishNoteRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DishNoteRow(
      id: serializer.fromJson<String>(json['id']),
      dishId: serializer.fromJson<String>(json['dishId']),
      body: serializer.fromJson<String>(json['body']),
      position: serializer.fromJson<int>(json['position']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dishId': serializer.toJson<String>(dishId),
      'body': serializer.toJson<String>(body),
      'position': serializer.toJson<int>(position),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  DishNoteRow copyWith(
          {String? id,
          String? dishId,
          String? body,
          int? position,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      DishNoteRow(
        id: id ?? this.id,
        dishId: dishId ?? this.dishId,
        body: body ?? this.body,
        position: position ?? this.position,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  DishNoteRow copyWithCompanion(DishNotesCompanion data) {
    return DishNoteRow(
      id: data.id.present ? data.id.value : this.id,
      dishId: data.dishId.present ? data.dishId.value : this.dishId,
      body: data.body.present ? data.body.value : this.body,
      position: data.position.present ? data.position.value : this.position,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DishNoteRow(')
          ..write('id: $id, ')
          ..write('dishId: $dishId, ')
          ..write('body: $body, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, dishId, body, position, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DishNoteRow &&
          other.id == this.id &&
          other.dishId == this.dishId &&
          other.body == this.body &&
          other.position == this.position &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class DishNotesCompanion extends UpdateCompanion<DishNoteRow> {
  final Value<String> id;
  final Value<String> dishId;
  final Value<String> body;
  final Value<int> position;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const DishNotesCompanion({
    this.id = const Value.absent(),
    this.dishId = const Value.absent(),
    this.body = const Value.absent(),
    this.position = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DishNotesCompanion.insert({
    required String id,
    required String dishId,
    required String body,
    required int position,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        dishId = Value(dishId),
        body = Value(body),
        position = Value(position),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<DishNoteRow> custom({
    Expression<String>? id,
    Expression<String>? dishId,
    Expression<String>? body,
    Expression<int>? position,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dishId != null) 'dish_id': dishId,
      if (body != null) 'body': body,
      if (position != null) 'position': position,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DishNotesCompanion copyWith(
      {Value<String>? id,
      Value<String>? dishId,
      Value<String>? body,
      Value<int>? position,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return DishNotesCompanion(
      id: id ?? this.id,
      dishId: dishId ?? this.dishId,
      body: body ?? this.body,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dishId.present) {
      map['dish_id'] = Variable<String>(dishId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DishNotesCompanion(')
          ..write('id: $id, ')
          ..write('dishId: $dishId, ')
          ..write('body: $body, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SourcePhotosTable extends SourcePhotos
    with TableInfo<$SourcePhotosTable, SourcePhotoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SourcePhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dishIdMeta = const VerificationMeta('dishId');
  @override
  late final GeneratedColumn<String> dishId = GeneratedColumn<String>(
      'dish_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _previewUrlMeta =
      const VerificationMeta('previewUrl');
  @override
  late final GeneratedColumn<String> previewUrl = GeneratedColumn<String>(
      'preview_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _thumbnailUrlMeta =
      const VerificationMeta('thumbnailUrl');
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
      'thumbnail_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _placeholderUrlMeta =
      const VerificationMeta('placeholderUrl');
  @override
  late final GeneratedColumn<String> placeholderUrl = GeneratedColumn<String>(
      'placeholder_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _capturedLabelMeta =
      const VerificationMeta('capturedLabel');
  @override
  late final GeneratedColumn<String> capturedLabel = GeneratedColumn<String>(
      'captured_label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _confidenceLabelMeta =
      const VerificationMeta('confidenceLabel');
  @override
  late final GeneratedColumn<String> confidenceLabel = GeneratedColumn<String>(
      'confidence_label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _captureIdMeta =
      const VerificationMeta('captureId');
  @override
  late final GeneratedColumn<String> captureId = GeneratedColumn<String>(
      'capture_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cookingOccasionIdMeta =
      const VerificationMeta('cookingOccasionId');
  @override
  late final GeneratedColumn<String> cookingOccasionId =
      GeneratedColumn<String>('cooking_occasion_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _capturedAtMeta =
      const VerificationMeta('capturedAt');
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
      'captured_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        dishId,
        url,
        previewUrl,
        thumbnailUrl,
        placeholderUrl,
        capturedLabel,
        confidenceLabel,
        captureId,
        cookingOccasionId,
        capturedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'source_photos';
  @override
  VerificationContext validateIntegrity(Insertable<SourcePhotoRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('dish_id')) {
      context.handle(_dishIdMeta,
          dishId.isAcceptableOrUnknown(data['dish_id']!, _dishIdMeta));
    } else if (isInserting) {
      context.missing(_dishIdMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('preview_url')) {
      context.handle(
          _previewUrlMeta,
          previewUrl.isAcceptableOrUnknown(
              data['preview_url']!, _previewUrlMeta));
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
          _thumbnailUrlMeta,
          thumbnailUrl.isAcceptableOrUnknown(
              data['thumbnail_url']!, _thumbnailUrlMeta));
    }
    if (data.containsKey('placeholder_url')) {
      context.handle(
          _placeholderUrlMeta,
          placeholderUrl.isAcceptableOrUnknown(
              data['placeholder_url']!, _placeholderUrlMeta));
    }
    if (data.containsKey('captured_label')) {
      context.handle(
          _capturedLabelMeta,
          capturedLabel.isAcceptableOrUnknown(
              data['captured_label']!, _capturedLabelMeta));
    } else if (isInserting) {
      context.missing(_capturedLabelMeta);
    }
    if (data.containsKey('confidence_label')) {
      context.handle(
          _confidenceLabelMeta,
          confidenceLabel.isAcceptableOrUnknown(
              data['confidence_label']!, _confidenceLabelMeta));
    }
    if (data.containsKey('capture_id')) {
      context.handle(_captureIdMeta,
          captureId.isAcceptableOrUnknown(data['capture_id']!, _captureIdMeta));
    }
    if (data.containsKey('cooking_occasion_id')) {
      context.handle(
          _cookingOccasionIdMeta,
          cookingOccasionId.isAcceptableOrUnknown(
              data['cooking_occasion_id']!, _cookingOccasionIdMeta));
    }
    if (data.containsKey('captured_at')) {
      context.handle(
          _capturedAtMeta,
          capturedAt.isAcceptableOrUnknown(
              data['captured_at']!, _capturedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SourcePhotoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SourcePhotoRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      dishId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dish_id'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      previewUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}preview_url']),
      thumbnailUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thumbnail_url']),
      placeholderUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}placeholder_url']),
      capturedLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}captured_label'])!,
      confidenceLabel: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}confidence_label']),
      captureId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}capture_id']),
      cookingOccasionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}cooking_occasion_id']),
      capturedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}captured_at']),
    );
  }

  @override
  $SourcePhotosTable createAlias(String alias) {
    return $SourcePhotosTable(attachedDatabase, alias);
  }
}

class SourcePhotoRow extends DataClass implements Insertable<SourcePhotoRow> {
  final String id;
  final String dishId;
  final String url;
  final String? previewUrl;
  final String? thumbnailUrl;
  final String? placeholderUrl;
  final String capturedLabel;
  final String? confidenceLabel;
  final String? captureId;
  final String? cookingOccasionId;
  final DateTime? capturedAt;
  const SourcePhotoRow(
      {required this.id,
      required this.dishId,
      required this.url,
      this.previewUrl,
      this.thumbnailUrl,
      this.placeholderUrl,
      required this.capturedLabel,
      this.confidenceLabel,
      this.captureId,
      this.cookingOccasionId,
      this.capturedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['dish_id'] = Variable<String>(dishId);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || previewUrl != null) {
      map['preview_url'] = Variable<String>(previewUrl);
    }
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    if (!nullToAbsent || placeholderUrl != null) {
      map['placeholder_url'] = Variable<String>(placeholderUrl);
    }
    map['captured_label'] = Variable<String>(capturedLabel);
    if (!nullToAbsent || confidenceLabel != null) {
      map['confidence_label'] = Variable<String>(confidenceLabel);
    }
    if (!nullToAbsent || captureId != null) {
      map['capture_id'] = Variable<String>(captureId);
    }
    if (!nullToAbsent || cookingOccasionId != null) {
      map['cooking_occasion_id'] = Variable<String>(cookingOccasionId);
    }
    if (!nullToAbsent || capturedAt != null) {
      map['captured_at'] = Variable<DateTime>(capturedAt);
    }
    return map;
  }

  SourcePhotosCompanion toCompanion(bool nullToAbsent) {
    return SourcePhotosCompanion(
      id: Value(id),
      dishId: Value(dishId),
      url: Value(url),
      previewUrl: previewUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(previewUrl),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      placeholderUrl: placeholderUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(placeholderUrl),
      capturedLabel: Value(capturedLabel),
      confidenceLabel: confidenceLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(confidenceLabel),
      captureId: captureId == null && nullToAbsent
          ? const Value.absent()
          : Value(captureId),
      cookingOccasionId: cookingOccasionId == null && nullToAbsent
          ? const Value.absent()
          : Value(cookingOccasionId),
      capturedAt: capturedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(capturedAt),
    );
  }

  factory SourcePhotoRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SourcePhotoRow(
      id: serializer.fromJson<String>(json['id']),
      dishId: serializer.fromJson<String>(json['dishId']),
      url: serializer.fromJson<String>(json['url']),
      previewUrl: serializer.fromJson<String?>(json['previewUrl']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      placeholderUrl: serializer.fromJson<String?>(json['placeholderUrl']),
      capturedLabel: serializer.fromJson<String>(json['capturedLabel']),
      confidenceLabel: serializer.fromJson<String?>(json['confidenceLabel']),
      captureId: serializer.fromJson<String?>(json['captureId']),
      cookingOccasionId:
          serializer.fromJson<String?>(json['cookingOccasionId']),
      capturedAt: serializer.fromJson<DateTime?>(json['capturedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dishId': serializer.toJson<String>(dishId),
      'url': serializer.toJson<String>(url),
      'previewUrl': serializer.toJson<String?>(previewUrl),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'placeholderUrl': serializer.toJson<String?>(placeholderUrl),
      'capturedLabel': serializer.toJson<String>(capturedLabel),
      'confidenceLabel': serializer.toJson<String?>(confidenceLabel),
      'captureId': serializer.toJson<String?>(captureId),
      'cookingOccasionId': serializer.toJson<String?>(cookingOccasionId),
      'capturedAt': serializer.toJson<DateTime?>(capturedAt),
    };
  }

  SourcePhotoRow copyWith(
          {String? id,
          String? dishId,
          String? url,
          Value<String?> previewUrl = const Value.absent(),
          Value<String?> thumbnailUrl = const Value.absent(),
          Value<String?> placeholderUrl = const Value.absent(),
          String? capturedLabel,
          Value<String?> confidenceLabel = const Value.absent(),
          Value<String?> captureId = const Value.absent(),
          Value<String?> cookingOccasionId = const Value.absent(),
          Value<DateTime?> capturedAt = const Value.absent()}) =>
      SourcePhotoRow(
        id: id ?? this.id,
        dishId: dishId ?? this.dishId,
        url: url ?? this.url,
        previewUrl: previewUrl.present ? previewUrl.value : this.previewUrl,
        thumbnailUrl:
            thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
        placeholderUrl:
            placeholderUrl.present ? placeholderUrl.value : this.placeholderUrl,
        capturedLabel: capturedLabel ?? this.capturedLabel,
        confidenceLabel: confidenceLabel.present
            ? confidenceLabel.value
            : this.confidenceLabel,
        captureId: captureId.present ? captureId.value : this.captureId,
        cookingOccasionId: cookingOccasionId.present
            ? cookingOccasionId.value
            : this.cookingOccasionId,
        capturedAt: capturedAt.present ? capturedAt.value : this.capturedAt,
      );
  SourcePhotoRow copyWithCompanion(SourcePhotosCompanion data) {
    return SourcePhotoRow(
      id: data.id.present ? data.id.value : this.id,
      dishId: data.dishId.present ? data.dishId.value : this.dishId,
      url: data.url.present ? data.url.value : this.url,
      previewUrl:
          data.previewUrl.present ? data.previewUrl.value : this.previewUrl,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      placeholderUrl: data.placeholderUrl.present
          ? data.placeholderUrl.value
          : this.placeholderUrl,
      capturedLabel: data.capturedLabel.present
          ? data.capturedLabel.value
          : this.capturedLabel,
      confidenceLabel: data.confidenceLabel.present
          ? data.confidenceLabel.value
          : this.confidenceLabel,
      captureId: data.captureId.present ? data.captureId.value : this.captureId,
      cookingOccasionId: data.cookingOccasionId.present
          ? data.cookingOccasionId.value
          : this.cookingOccasionId,
      capturedAt:
          data.capturedAt.present ? data.capturedAt.value : this.capturedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SourcePhotoRow(')
          ..write('id: $id, ')
          ..write('dishId: $dishId, ')
          ..write('url: $url, ')
          ..write('previewUrl: $previewUrl, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('placeholderUrl: $placeholderUrl, ')
          ..write('capturedLabel: $capturedLabel, ')
          ..write('confidenceLabel: $confidenceLabel, ')
          ..write('captureId: $captureId, ')
          ..write('cookingOccasionId: $cookingOccasionId, ')
          ..write('capturedAt: $capturedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      dishId,
      url,
      previewUrl,
      thumbnailUrl,
      placeholderUrl,
      capturedLabel,
      confidenceLabel,
      captureId,
      cookingOccasionId,
      capturedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SourcePhotoRow &&
          other.id == this.id &&
          other.dishId == this.dishId &&
          other.url == this.url &&
          other.previewUrl == this.previewUrl &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.placeholderUrl == this.placeholderUrl &&
          other.capturedLabel == this.capturedLabel &&
          other.confidenceLabel == this.confidenceLabel &&
          other.captureId == this.captureId &&
          other.cookingOccasionId == this.cookingOccasionId &&
          other.capturedAt == this.capturedAt);
}

class SourcePhotosCompanion extends UpdateCompanion<SourcePhotoRow> {
  final Value<String> id;
  final Value<String> dishId;
  final Value<String> url;
  final Value<String?> previewUrl;
  final Value<String?> thumbnailUrl;
  final Value<String?> placeholderUrl;
  final Value<String> capturedLabel;
  final Value<String?> confidenceLabel;
  final Value<String?> captureId;
  final Value<String?> cookingOccasionId;
  final Value<DateTime?> capturedAt;
  final Value<int> rowid;
  const SourcePhotosCompanion({
    this.id = const Value.absent(),
    this.dishId = const Value.absent(),
    this.url = const Value.absent(),
    this.previewUrl = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.placeholderUrl = const Value.absent(),
    this.capturedLabel = const Value.absent(),
    this.confidenceLabel = const Value.absent(),
    this.captureId = const Value.absent(),
    this.cookingOccasionId = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SourcePhotosCompanion.insert({
    required String id,
    required String dishId,
    required String url,
    this.previewUrl = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.placeholderUrl = const Value.absent(),
    required String capturedLabel,
    this.confidenceLabel = const Value.absent(),
    this.captureId = const Value.absent(),
    this.cookingOccasionId = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        dishId = Value(dishId),
        url = Value(url),
        capturedLabel = Value(capturedLabel);
  static Insertable<SourcePhotoRow> custom({
    Expression<String>? id,
    Expression<String>? dishId,
    Expression<String>? url,
    Expression<String>? previewUrl,
    Expression<String>? thumbnailUrl,
    Expression<String>? placeholderUrl,
    Expression<String>? capturedLabel,
    Expression<String>? confidenceLabel,
    Expression<String>? captureId,
    Expression<String>? cookingOccasionId,
    Expression<DateTime>? capturedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dishId != null) 'dish_id': dishId,
      if (url != null) 'url': url,
      if (previewUrl != null) 'preview_url': previewUrl,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (placeholderUrl != null) 'placeholder_url': placeholderUrl,
      if (capturedLabel != null) 'captured_label': capturedLabel,
      if (confidenceLabel != null) 'confidence_label': confidenceLabel,
      if (captureId != null) 'capture_id': captureId,
      if (cookingOccasionId != null) 'cooking_occasion_id': cookingOccasionId,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SourcePhotosCompanion copyWith(
      {Value<String>? id,
      Value<String>? dishId,
      Value<String>? url,
      Value<String?>? previewUrl,
      Value<String?>? thumbnailUrl,
      Value<String?>? placeholderUrl,
      Value<String>? capturedLabel,
      Value<String?>? confidenceLabel,
      Value<String?>? captureId,
      Value<String?>? cookingOccasionId,
      Value<DateTime?>? capturedAt,
      Value<int>? rowid}) {
    return SourcePhotosCompanion(
      id: id ?? this.id,
      dishId: dishId ?? this.dishId,
      url: url ?? this.url,
      previewUrl: previewUrl ?? this.previewUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      placeholderUrl: placeholderUrl ?? this.placeholderUrl,
      capturedLabel: capturedLabel ?? this.capturedLabel,
      confidenceLabel: confidenceLabel ?? this.confidenceLabel,
      captureId: captureId ?? this.captureId,
      cookingOccasionId: cookingOccasionId ?? this.cookingOccasionId,
      capturedAt: capturedAt ?? this.capturedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dishId.present) {
      map['dish_id'] = Variable<String>(dishId.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (previewUrl.present) {
      map['preview_url'] = Variable<String>(previewUrl.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (placeholderUrl.present) {
      map['placeholder_url'] = Variable<String>(placeholderUrl.value);
    }
    if (capturedLabel.present) {
      map['captured_label'] = Variable<String>(capturedLabel.value);
    }
    if (confidenceLabel.present) {
      map['confidence_label'] = Variable<String>(confidenceLabel.value);
    }
    if (captureId.present) {
      map['capture_id'] = Variable<String>(captureId.value);
    }
    if (cookingOccasionId.present) {
      map['cooking_occasion_id'] = Variable<String>(cookingOccasionId.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SourcePhotosCompanion(')
          ..write('id: $id, ')
          ..write('dishId: $dishId, ')
          ..write('url: $url, ')
          ..write('previewUrl: $previewUrl, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('placeholderUrl: $placeholderUrl, ')
          ..write('capturedLabel: $capturedLabel, ')
          ..write('confidenceLabel: $confidenceLabel, ')
          ..write('captureId: $captureId, ')
          ..write('cookingOccasionId: $cookingOccasionId, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GeneratedCoversTable extends GeneratedCovers
    with TableInfo<$GeneratedCoversTable, GeneratedCoverRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GeneratedCoversTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dishIdMeta = const VerificationMeta('dishId');
  @override
  late final GeneratedColumn<String> dishId = GeneratedColumn<String>(
      'dish_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _previewPathMeta =
      const VerificationMeta('previewPath');
  @override
  late final GeneratedColumn<String> previewPath = GeneratedColumn<String>(
      'preview_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _thumbnailPathMeta =
      const VerificationMeta('thumbnailPath');
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
      'thumbnail_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _placeholderPathMeta =
      const VerificationMeta('placeholderPath');
  @override
  late final GeneratedColumn<String> placeholderPath = GeneratedColumn<String>(
      'placeholder_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
      'origin', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _groundingMeta =
      const VerificationMeta('grounding');
  @override
  late final GeneratedColumn<String> grounding = GeneratedColumn<String>(
      'grounding', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _selectedSourceIdsJsonMeta =
      const VerificationMeta('selectedSourceIdsJson');
  @override
  late final GeneratedColumn<String> selectedSourceIdsJson =
      GeneratedColumn<String>('selected_source_ids_json', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lookMeta = const VerificationMeta('look');
  @override
  late final GeneratedColumn<String> look = GeneratedColumn<String>(
      'look', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _viewMeta = const VerificationMeta('view');
  @override
  late final GeneratedColumn<String> view = GeneratedColumn<String>(
      'view', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _finishMeta = const VerificationMeta('finish');
  @override
  late final GeneratedColumn<String> finish = GeneratedColumn<String>(
      'finish', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contractVersionMeta =
      const VerificationMeta('contractVersion');
  @override
  late final GeneratedColumn<String> contractVersion = GeneratedColumn<String>(
      'contract_version', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _proposalIdMeta =
      const VerificationMeta('proposalId');
  @override
  late final GeneratedColumn<String> proposalId = GeneratedColumn<String>(
      'proposal_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
      'state', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _automaticAcknowledgedMeta =
      const VerificationMeta('automaticAcknowledged');
  @override
  late final GeneratedColumn<bool> automaticAcknowledged =
      GeneratedColumn<bool>('automatic_acknowledged', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("automatic_acknowledged" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _automaticUndoAvailableMeta =
      const VerificationMeta('automaticUndoAvailable');
  @override
  late final GeneratedColumn<bool> automaticUndoAvailable =
      GeneratedColumn<bool>('automatic_undo_available', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("automatic_undo_available" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _previousCoverJsonMeta =
      const VerificationMeta('previousCoverJson');
  @override
  late final GeneratedColumn<String> previousCoverJson =
      GeneratedColumn<String>('previous_cover_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        dishId,
        localPath,
        previewPath,
        thumbnailPath,
        placeholderPath,
        origin,
        grounding,
        selectedSourceIdsJson,
        look,
        view,
        finish,
        contractVersion,
        proposalId,
        state,
        automaticAcknowledged,
        automaticUndoAvailable,
        previousCoverJson,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'generated_covers';
  @override
  VerificationContext validateIntegrity(Insertable<GeneratedCoverRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('dish_id')) {
      context.handle(_dishIdMeta,
          dishId.isAcceptableOrUnknown(data['dish_id']!, _dishIdMeta));
    } else if (isInserting) {
      context.missing(_dishIdMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('preview_path')) {
      context.handle(
          _previewPathMeta,
          previewPath.isAcceptableOrUnknown(
              data['preview_path']!, _previewPathMeta));
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
          _thumbnailPathMeta,
          thumbnailPath.isAcceptableOrUnknown(
              data['thumbnail_path']!, _thumbnailPathMeta));
    }
    if (data.containsKey('placeholder_path')) {
      context.handle(
          _placeholderPathMeta,
          placeholderPath.isAcceptableOrUnknown(
              data['placeholder_path']!, _placeholderPathMeta));
    }
    if (data.containsKey('origin')) {
      context.handle(_originMeta,
          origin.isAcceptableOrUnknown(data['origin']!, _originMeta));
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    if (data.containsKey('grounding')) {
      context.handle(_groundingMeta,
          grounding.isAcceptableOrUnknown(data['grounding']!, _groundingMeta));
    } else if (isInserting) {
      context.missing(_groundingMeta);
    }
    if (data.containsKey('selected_source_ids_json')) {
      context.handle(
          _selectedSourceIdsJsonMeta,
          selectedSourceIdsJson.isAcceptableOrUnknown(
              data['selected_source_ids_json']!, _selectedSourceIdsJsonMeta));
    } else if (isInserting) {
      context.missing(_selectedSourceIdsJsonMeta);
    }
    if (data.containsKey('look')) {
      context.handle(
          _lookMeta, look.isAcceptableOrUnknown(data['look']!, _lookMeta));
    } else if (isInserting) {
      context.missing(_lookMeta);
    }
    if (data.containsKey('view')) {
      context.handle(
          _viewMeta, view.isAcceptableOrUnknown(data['view']!, _viewMeta));
    } else if (isInserting) {
      context.missing(_viewMeta);
    }
    if (data.containsKey('finish')) {
      context.handle(_finishMeta,
          finish.isAcceptableOrUnknown(data['finish']!, _finishMeta));
    } else if (isInserting) {
      context.missing(_finishMeta);
    }
    if (data.containsKey('contract_version')) {
      context.handle(
          _contractVersionMeta,
          contractVersion.isAcceptableOrUnknown(
              data['contract_version']!, _contractVersionMeta));
    } else if (isInserting) {
      context.missing(_contractVersionMeta);
    }
    if (data.containsKey('proposal_id')) {
      context.handle(
          _proposalIdMeta,
          proposalId.isAcceptableOrUnknown(
              data['proposal_id']!, _proposalIdMeta));
    } else if (isInserting) {
      context.missing(_proposalIdMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
          _stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('automatic_acknowledged')) {
      context.handle(
          _automaticAcknowledgedMeta,
          automaticAcknowledged.isAcceptableOrUnknown(
              data['automatic_acknowledged']!, _automaticAcknowledgedMeta));
    }
    if (data.containsKey('automatic_undo_available')) {
      context.handle(
          _automaticUndoAvailableMeta,
          automaticUndoAvailable.isAcceptableOrUnknown(
              data['automatic_undo_available']!, _automaticUndoAvailableMeta));
    }
    if (data.containsKey('previous_cover_json')) {
      context.handle(
          _previousCoverJsonMeta,
          previousCoverJson.isAcceptableOrUnknown(
              data['previous_cover_json']!, _previousCoverJsonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GeneratedCoverRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GeneratedCoverRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      dishId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dish_id'])!,
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path'])!,
      previewPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}preview_path']),
      thumbnailPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thumbnail_path']),
      placeholderPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}placeholder_path']),
      origin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}origin'])!,
      grounding: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}grounding'])!,
      selectedSourceIdsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}selected_source_ids_json'])!,
      look: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}look'])!,
      view: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}view'])!,
      finish: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}finish'])!,
      contractVersion: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}contract_version'])!,
      proposalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}proposal_id'])!,
      state: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state'])!,
      automaticAcknowledged: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}automatic_acknowledged'])!,
      automaticUndoAvailable: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}automatic_undo_available'])!,
      previousCoverJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}previous_cover_json']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $GeneratedCoversTable createAlias(String alias) {
    return $GeneratedCoversTable(attachedDatabase, alias);
  }
}

class GeneratedCoverRow extends DataClass
    implements Insertable<GeneratedCoverRow> {
  final String id;
  final String dishId;
  final String localPath;
  final String? previewPath;
  final String? thumbnailPath;
  final String? placeholderPath;
  final String origin;
  final String grounding;
  final String selectedSourceIdsJson;
  final String look;
  final String view;
  final String finish;
  final String contractVersion;
  final String proposalId;
  final String state;
  final bool automaticAcknowledged;
  final bool automaticUndoAvailable;
  final String? previousCoverJson;
  final DateTime createdAt;
  const GeneratedCoverRow(
      {required this.id,
      required this.dishId,
      required this.localPath,
      this.previewPath,
      this.thumbnailPath,
      this.placeholderPath,
      required this.origin,
      required this.grounding,
      required this.selectedSourceIdsJson,
      required this.look,
      required this.view,
      required this.finish,
      required this.contractVersion,
      required this.proposalId,
      required this.state,
      required this.automaticAcknowledged,
      required this.automaticUndoAvailable,
      this.previousCoverJson,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['dish_id'] = Variable<String>(dishId);
    map['local_path'] = Variable<String>(localPath);
    if (!nullToAbsent || previewPath != null) {
      map['preview_path'] = Variable<String>(previewPath);
    }
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    if (!nullToAbsent || placeholderPath != null) {
      map['placeholder_path'] = Variable<String>(placeholderPath);
    }
    map['origin'] = Variable<String>(origin);
    map['grounding'] = Variable<String>(grounding);
    map['selected_source_ids_json'] = Variable<String>(selectedSourceIdsJson);
    map['look'] = Variable<String>(look);
    map['view'] = Variable<String>(view);
    map['finish'] = Variable<String>(finish);
    map['contract_version'] = Variable<String>(contractVersion);
    map['proposal_id'] = Variable<String>(proposalId);
    map['state'] = Variable<String>(state);
    map['automatic_acknowledged'] = Variable<bool>(automaticAcknowledged);
    map['automatic_undo_available'] = Variable<bool>(automaticUndoAvailable);
    if (!nullToAbsent || previousCoverJson != null) {
      map['previous_cover_json'] = Variable<String>(previousCoverJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GeneratedCoversCompanion toCompanion(bool nullToAbsent) {
    return GeneratedCoversCompanion(
      id: Value(id),
      dishId: Value(dishId),
      localPath: Value(localPath),
      previewPath: previewPath == null && nullToAbsent
          ? const Value.absent()
          : Value(previewPath),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      placeholderPath: placeholderPath == null && nullToAbsent
          ? const Value.absent()
          : Value(placeholderPath),
      origin: Value(origin),
      grounding: Value(grounding),
      selectedSourceIdsJson: Value(selectedSourceIdsJson),
      look: Value(look),
      view: Value(view),
      finish: Value(finish),
      contractVersion: Value(contractVersion),
      proposalId: Value(proposalId),
      state: Value(state),
      automaticAcknowledged: Value(automaticAcknowledged),
      automaticUndoAvailable: Value(automaticUndoAvailable),
      previousCoverJson: previousCoverJson == null && nullToAbsent
          ? const Value.absent()
          : Value(previousCoverJson),
      createdAt: Value(createdAt),
    );
  }

  factory GeneratedCoverRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GeneratedCoverRow(
      id: serializer.fromJson<String>(json['id']),
      dishId: serializer.fromJson<String>(json['dishId']),
      localPath: serializer.fromJson<String>(json['localPath']),
      previewPath: serializer.fromJson<String?>(json['previewPath']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      placeholderPath: serializer.fromJson<String?>(json['placeholderPath']),
      origin: serializer.fromJson<String>(json['origin']),
      grounding: serializer.fromJson<String>(json['grounding']),
      selectedSourceIdsJson:
          serializer.fromJson<String>(json['selectedSourceIdsJson']),
      look: serializer.fromJson<String>(json['look']),
      view: serializer.fromJson<String>(json['view']),
      finish: serializer.fromJson<String>(json['finish']),
      contractVersion: serializer.fromJson<String>(json['contractVersion']),
      proposalId: serializer.fromJson<String>(json['proposalId']),
      state: serializer.fromJson<String>(json['state']),
      automaticAcknowledged:
          serializer.fromJson<bool>(json['automaticAcknowledged']),
      automaticUndoAvailable:
          serializer.fromJson<bool>(json['automaticUndoAvailable']),
      previousCoverJson:
          serializer.fromJson<String?>(json['previousCoverJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dishId': serializer.toJson<String>(dishId),
      'localPath': serializer.toJson<String>(localPath),
      'previewPath': serializer.toJson<String?>(previewPath),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'placeholderPath': serializer.toJson<String?>(placeholderPath),
      'origin': serializer.toJson<String>(origin),
      'grounding': serializer.toJson<String>(grounding),
      'selectedSourceIdsJson': serializer.toJson<String>(selectedSourceIdsJson),
      'look': serializer.toJson<String>(look),
      'view': serializer.toJson<String>(view),
      'finish': serializer.toJson<String>(finish),
      'contractVersion': serializer.toJson<String>(contractVersion),
      'proposalId': serializer.toJson<String>(proposalId),
      'state': serializer.toJson<String>(state),
      'automaticAcknowledged': serializer.toJson<bool>(automaticAcknowledged),
      'automaticUndoAvailable': serializer.toJson<bool>(automaticUndoAvailable),
      'previousCoverJson': serializer.toJson<String?>(previousCoverJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GeneratedCoverRow copyWith(
          {String? id,
          String? dishId,
          String? localPath,
          Value<String?> previewPath = const Value.absent(),
          Value<String?> thumbnailPath = const Value.absent(),
          Value<String?> placeholderPath = const Value.absent(),
          String? origin,
          String? grounding,
          String? selectedSourceIdsJson,
          String? look,
          String? view,
          String? finish,
          String? contractVersion,
          String? proposalId,
          String? state,
          bool? automaticAcknowledged,
          bool? automaticUndoAvailable,
          Value<String?> previousCoverJson = const Value.absent(),
          DateTime? createdAt}) =>
      GeneratedCoverRow(
        id: id ?? this.id,
        dishId: dishId ?? this.dishId,
        localPath: localPath ?? this.localPath,
        previewPath: previewPath.present ? previewPath.value : this.previewPath,
        thumbnailPath:
            thumbnailPath.present ? thumbnailPath.value : this.thumbnailPath,
        placeholderPath: placeholderPath.present
            ? placeholderPath.value
            : this.placeholderPath,
        origin: origin ?? this.origin,
        grounding: grounding ?? this.grounding,
        selectedSourceIdsJson:
            selectedSourceIdsJson ?? this.selectedSourceIdsJson,
        look: look ?? this.look,
        view: view ?? this.view,
        finish: finish ?? this.finish,
        contractVersion: contractVersion ?? this.contractVersion,
        proposalId: proposalId ?? this.proposalId,
        state: state ?? this.state,
        automaticAcknowledged:
            automaticAcknowledged ?? this.automaticAcknowledged,
        automaticUndoAvailable:
            automaticUndoAvailable ?? this.automaticUndoAvailable,
        previousCoverJson: previousCoverJson.present
            ? previousCoverJson.value
            : this.previousCoverJson,
        createdAt: createdAt ?? this.createdAt,
      );
  GeneratedCoverRow copyWithCompanion(GeneratedCoversCompanion data) {
    return GeneratedCoverRow(
      id: data.id.present ? data.id.value : this.id,
      dishId: data.dishId.present ? data.dishId.value : this.dishId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      previewPath:
          data.previewPath.present ? data.previewPath.value : this.previewPath,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      placeholderPath: data.placeholderPath.present
          ? data.placeholderPath.value
          : this.placeholderPath,
      origin: data.origin.present ? data.origin.value : this.origin,
      grounding: data.grounding.present ? data.grounding.value : this.grounding,
      selectedSourceIdsJson: data.selectedSourceIdsJson.present
          ? data.selectedSourceIdsJson.value
          : this.selectedSourceIdsJson,
      look: data.look.present ? data.look.value : this.look,
      view: data.view.present ? data.view.value : this.view,
      finish: data.finish.present ? data.finish.value : this.finish,
      contractVersion: data.contractVersion.present
          ? data.contractVersion.value
          : this.contractVersion,
      proposalId:
          data.proposalId.present ? data.proposalId.value : this.proposalId,
      state: data.state.present ? data.state.value : this.state,
      automaticAcknowledged: data.automaticAcknowledged.present
          ? data.automaticAcknowledged.value
          : this.automaticAcknowledged,
      automaticUndoAvailable: data.automaticUndoAvailable.present
          ? data.automaticUndoAvailable.value
          : this.automaticUndoAvailable,
      previousCoverJson: data.previousCoverJson.present
          ? data.previousCoverJson.value
          : this.previousCoverJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GeneratedCoverRow(')
          ..write('id: $id, ')
          ..write('dishId: $dishId, ')
          ..write('localPath: $localPath, ')
          ..write('previewPath: $previewPath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('placeholderPath: $placeholderPath, ')
          ..write('origin: $origin, ')
          ..write('grounding: $grounding, ')
          ..write('selectedSourceIdsJson: $selectedSourceIdsJson, ')
          ..write('look: $look, ')
          ..write('view: $view, ')
          ..write('finish: $finish, ')
          ..write('contractVersion: $contractVersion, ')
          ..write('proposalId: $proposalId, ')
          ..write('state: $state, ')
          ..write('automaticAcknowledged: $automaticAcknowledged, ')
          ..write('automaticUndoAvailable: $automaticUndoAvailable, ')
          ..write('previousCoverJson: $previousCoverJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      dishId,
      localPath,
      previewPath,
      thumbnailPath,
      placeholderPath,
      origin,
      grounding,
      selectedSourceIdsJson,
      look,
      view,
      finish,
      contractVersion,
      proposalId,
      state,
      automaticAcknowledged,
      automaticUndoAvailable,
      previousCoverJson,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeneratedCoverRow &&
          other.id == this.id &&
          other.dishId == this.dishId &&
          other.localPath == this.localPath &&
          other.previewPath == this.previewPath &&
          other.thumbnailPath == this.thumbnailPath &&
          other.placeholderPath == this.placeholderPath &&
          other.origin == this.origin &&
          other.grounding == this.grounding &&
          other.selectedSourceIdsJson == this.selectedSourceIdsJson &&
          other.look == this.look &&
          other.view == this.view &&
          other.finish == this.finish &&
          other.contractVersion == this.contractVersion &&
          other.proposalId == this.proposalId &&
          other.state == this.state &&
          other.automaticAcknowledged == this.automaticAcknowledged &&
          other.automaticUndoAvailable == this.automaticUndoAvailable &&
          other.previousCoverJson == this.previousCoverJson &&
          other.createdAt == this.createdAt);
}

class GeneratedCoversCompanion extends UpdateCompanion<GeneratedCoverRow> {
  final Value<String> id;
  final Value<String> dishId;
  final Value<String> localPath;
  final Value<String?> previewPath;
  final Value<String?> thumbnailPath;
  final Value<String?> placeholderPath;
  final Value<String> origin;
  final Value<String> grounding;
  final Value<String> selectedSourceIdsJson;
  final Value<String> look;
  final Value<String> view;
  final Value<String> finish;
  final Value<String> contractVersion;
  final Value<String> proposalId;
  final Value<String> state;
  final Value<bool> automaticAcknowledged;
  final Value<bool> automaticUndoAvailable;
  final Value<String?> previousCoverJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const GeneratedCoversCompanion({
    this.id = const Value.absent(),
    this.dishId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.previewPath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.placeholderPath = const Value.absent(),
    this.origin = const Value.absent(),
    this.grounding = const Value.absent(),
    this.selectedSourceIdsJson = const Value.absent(),
    this.look = const Value.absent(),
    this.view = const Value.absent(),
    this.finish = const Value.absent(),
    this.contractVersion = const Value.absent(),
    this.proposalId = const Value.absent(),
    this.state = const Value.absent(),
    this.automaticAcknowledged = const Value.absent(),
    this.automaticUndoAvailable = const Value.absent(),
    this.previousCoverJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GeneratedCoversCompanion.insert({
    required String id,
    required String dishId,
    required String localPath,
    this.previewPath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.placeholderPath = const Value.absent(),
    required String origin,
    required String grounding,
    required String selectedSourceIdsJson,
    required String look,
    required String view,
    required String finish,
    required String contractVersion,
    required String proposalId,
    required String state,
    this.automaticAcknowledged = const Value.absent(),
    this.automaticUndoAvailable = const Value.absent(),
    this.previousCoverJson = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        dishId = Value(dishId),
        localPath = Value(localPath),
        origin = Value(origin),
        grounding = Value(grounding),
        selectedSourceIdsJson = Value(selectedSourceIdsJson),
        look = Value(look),
        view = Value(view),
        finish = Value(finish),
        contractVersion = Value(contractVersion),
        proposalId = Value(proposalId),
        state = Value(state),
        createdAt = Value(createdAt);
  static Insertable<GeneratedCoverRow> custom({
    Expression<String>? id,
    Expression<String>? dishId,
    Expression<String>? localPath,
    Expression<String>? previewPath,
    Expression<String>? thumbnailPath,
    Expression<String>? placeholderPath,
    Expression<String>? origin,
    Expression<String>? grounding,
    Expression<String>? selectedSourceIdsJson,
    Expression<String>? look,
    Expression<String>? view,
    Expression<String>? finish,
    Expression<String>? contractVersion,
    Expression<String>? proposalId,
    Expression<String>? state,
    Expression<bool>? automaticAcknowledged,
    Expression<bool>? automaticUndoAvailable,
    Expression<String>? previousCoverJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dishId != null) 'dish_id': dishId,
      if (localPath != null) 'local_path': localPath,
      if (previewPath != null) 'preview_path': previewPath,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (placeholderPath != null) 'placeholder_path': placeholderPath,
      if (origin != null) 'origin': origin,
      if (grounding != null) 'grounding': grounding,
      if (selectedSourceIdsJson != null)
        'selected_source_ids_json': selectedSourceIdsJson,
      if (look != null) 'look': look,
      if (view != null) 'view': view,
      if (finish != null) 'finish': finish,
      if (contractVersion != null) 'contract_version': contractVersion,
      if (proposalId != null) 'proposal_id': proposalId,
      if (state != null) 'state': state,
      if (automaticAcknowledged != null)
        'automatic_acknowledged': automaticAcknowledged,
      if (automaticUndoAvailable != null)
        'automatic_undo_available': automaticUndoAvailable,
      if (previousCoverJson != null) 'previous_cover_json': previousCoverJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GeneratedCoversCompanion copyWith(
      {Value<String>? id,
      Value<String>? dishId,
      Value<String>? localPath,
      Value<String?>? previewPath,
      Value<String?>? thumbnailPath,
      Value<String?>? placeholderPath,
      Value<String>? origin,
      Value<String>? grounding,
      Value<String>? selectedSourceIdsJson,
      Value<String>? look,
      Value<String>? view,
      Value<String>? finish,
      Value<String>? contractVersion,
      Value<String>? proposalId,
      Value<String>? state,
      Value<bool>? automaticAcknowledged,
      Value<bool>? automaticUndoAvailable,
      Value<String?>? previousCoverJson,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return GeneratedCoversCompanion(
      id: id ?? this.id,
      dishId: dishId ?? this.dishId,
      localPath: localPath ?? this.localPath,
      previewPath: previewPath ?? this.previewPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      placeholderPath: placeholderPath ?? this.placeholderPath,
      origin: origin ?? this.origin,
      grounding: grounding ?? this.grounding,
      selectedSourceIdsJson:
          selectedSourceIdsJson ?? this.selectedSourceIdsJson,
      look: look ?? this.look,
      view: view ?? this.view,
      finish: finish ?? this.finish,
      contractVersion: contractVersion ?? this.contractVersion,
      proposalId: proposalId ?? this.proposalId,
      state: state ?? this.state,
      automaticAcknowledged:
          automaticAcknowledged ?? this.automaticAcknowledged,
      automaticUndoAvailable:
          automaticUndoAvailable ?? this.automaticUndoAvailable,
      previousCoverJson: previousCoverJson ?? this.previousCoverJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dishId.present) {
      map['dish_id'] = Variable<String>(dishId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (previewPath.present) {
      map['preview_path'] = Variable<String>(previewPath.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (placeholderPath.present) {
      map['placeholder_path'] = Variable<String>(placeholderPath.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (grounding.present) {
      map['grounding'] = Variable<String>(grounding.value);
    }
    if (selectedSourceIdsJson.present) {
      map['selected_source_ids_json'] =
          Variable<String>(selectedSourceIdsJson.value);
    }
    if (look.present) {
      map['look'] = Variable<String>(look.value);
    }
    if (view.present) {
      map['view'] = Variable<String>(view.value);
    }
    if (finish.present) {
      map['finish'] = Variable<String>(finish.value);
    }
    if (contractVersion.present) {
      map['contract_version'] = Variable<String>(contractVersion.value);
    }
    if (proposalId.present) {
      map['proposal_id'] = Variable<String>(proposalId.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (automaticAcknowledged.present) {
      map['automatic_acknowledged'] =
          Variable<bool>(automaticAcknowledged.value);
    }
    if (automaticUndoAvailable.present) {
      map['automatic_undo_available'] =
          Variable<bool>(automaticUndoAvailable.value);
    }
    if (previousCoverJson.present) {
      map['previous_cover_json'] = Variable<String>(previousCoverJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GeneratedCoversCompanion(')
          ..write('id: $id, ')
          ..write('dishId: $dishId, ')
          ..write('localPath: $localPath, ')
          ..write('previewPath: $previewPath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('placeholderPath: $placeholderPath, ')
          ..write('origin: $origin, ')
          ..write('grounding: $grounding, ')
          ..write('selectedSourceIdsJson: $selectedSourceIdsJson, ')
          ..write('look: $look, ')
          ..write('view: $view, ')
          ..write('finish: $finish, ')
          ..write('contractVersion: $contractVersion, ')
          ..write('proposalId: $proposalId, ')
          ..write('state: $state, ')
          ..write('automaticAcknowledged: $automaticAcknowledged, ')
          ..write('automaticUndoAvailable: $automaticUndoAvailable, ')
          ..write('previousCoverJson: $previousCoverJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CaptureBatchesTable extends CaptureBatches
    with TableInfo<$CaptureBatchesTable, CaptureBatchRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CaptureBatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _failureReasonMeta =
      const VerificationMeta('failureReason');
  @override
  late final GeneratedColumn<String> failureReason = GeneratedColumn<String>(
      'failure_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, status, createdAt, updatedAt, failureReason];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'capture_batches';
  @override
  VerificationContext validateIntegrity(Insertable<CaptureBatchRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('failure_reason')) {
      context.handle(
          _failureReasonMeta,
          failureReason.isAcceptableOrUnknown(
              data['failure_reason']!, _failureReasonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CaptureBatchRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CaptureBatchRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      failureReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}failure_reason']),
    );
  }

  @override
  $CaptureBatchesTable createAlias(String alias) {
    return $CaptureBatchesTable(attachedDatabase, alias);
  }
}

class CaptureBatchRow extends DataClass implements Insertable<CaptureBatchRow> {
  final String id;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? failureReason;
  const CaptureBatchRow(
      {required this.id,
      required this.status,
      required this.createdAt,
      required this.updatedAt,
      this.failureReason});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || failureReason != null) {
      map['failure_reason'] = Variable<String>(failureReason);
    }
    return map;
  }

  CaptureBatchesCompanion toCompanion(bool nullToAbsent) {
    return CaptureBatchesCompanion(
      id: Value(id),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      failureReason: failureReason == null && nullToAbsent
          ? const Value.absent()
          : Value(failureReason),
    );
  }

  factory CaptureBatchRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CaptureBatchRow(
      id: serializer.fromJson<String>(json['id']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      failureReason: serializer.fromJson<String?>(json['failureReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'failureReason': serializer.toJson<String?>(failureReason),
    };
  }

  CaptureBatchRow copyWith(
          {String? id,
          String? status,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<String?> failureReason = const Value.absent()}) =>
      CaptureBatchRow(
        id: id ?? this.id,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        failureReason:
            failureReason.present ? failureReason.value : this.failureReason,
      );
  CaptureBatchRow copyWithCompanion(CaptureBatchesCompanion data) {
    return CaptureBatchRow(
      id: data.id.present ? data.id.value : this.id,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      failureReason: data.failureReason.present
          ? data.failureReason.value
          : this.failureReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CaptureBatchRow(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('failureReason: $failureReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, status, createdAt, updatedAt, failureReason);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CaptureBatchRow &&
          other.id == this.id &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.failureReason == this.failureReason);
}

class CaptureBatchesCompanion extends UpdateCompanion<CaptureBatchRow> {
  final Value<String> id;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> failureReason;
  final Value<int> rowid;
  const CaptureBatchesCompanion({
    this.id = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.failureReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CaptureBatchesCompanion.insert({
    required String id,
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.failureReason = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        status = Value(status),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<CaptureBatchRow> custom({
    Expression<String>? id,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? failureReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (failureReason != null) 'failure_reason': failureReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CaptureBatchesCompanion copyWith(
      {Value<String>? id,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String?>? failureReason,
      Value<int>? rowid}) {
    return CaptureBatchesCompanion(
      id: id ?? this.id,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      failureReason: failureReason ?? this.failureReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (failureReason.present) {
      map['failure_reason'] = Variable<String>(failureReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CaptureBatchesCompanion(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('failureReason: $failureReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CaptureItemsTable extends CaptureItems
    with TableInfo<$CaptureItemsTable, CaptureItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CaptureItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _batchIdMeta =
      const VerificationMeta('batchId');
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
      'batch_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ordinalMeta =
      const VerificationMeta('ordinal');
  @override
  late final GeneratedColumn<int> ordinal = GeneratedColumn<int>(
      'ordinal', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _localMediaRefMeta =
      const VerificationMeta('localMediaRef');
  @override
  late final GeneratedColumn<String> localMediaRef = GeneratedColumn<String>(
      'local_media_ref', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _localPreviewRefMeta =
      const VerificationMeta('localPreviewRef');
  @override
  late final GeneratedColumn<String> localPreviewRef = GeneratedColumn<String>(
      'local_preview_ref', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _localThumbnailRefMeta =
      const VerificationMeta('localThumbnailRef');
  @override
  late final GeneratedColumn<String> localThumbnailRef =
      GeneratedColumn<String>('local_thumbnail_ref', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _localPlaceholderRefMeta =
      const VerificationMeta('localPlaceholderRef');
  @override
  late final GeneratedColumn<String> localPlaceholderRef =
      GeneratedColumn<String>('local_placeholder_ref', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _remoteMediaRefMeta =
      const VerificationMeta('remoteMediaRef');
  @override
  late final GeneratedColumn<String> remoteMediaRef = GeneratedColumn<String>(
      'remote_media_ref', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ideaTextMeta =
      const VerificationMeta('ideaText');
  @override
  late final GeneratedColumn<String> ideaText = GeneratedColumn<String>(
      'idea_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _capturedAtMeta =
      const VerificationMeta('capturedAt');
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
      'captured_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _capturedLocalDateMeta =
      const VerificationMeta('capturedLocalDate');
  @override
  late final GeneratedColumn<String> capturedLocalDate =
      GeneratedColumn<String>('captured_local_date', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _captureDateSourceMeta =
      const VerificationMeta('captureDateSource');
  @override
  late final GeneratedColumn<String> captureDateSource =
      GeneratedColumn<String>('capture_date_source', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _appliedDishIdMeta =
      const VerificationMeta('appliedDishId');
  @override
  late final GeneratedColumn<String> appliedDishId = GeneratedColumn<String>(
      'applied_dish_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _failureReasonMeta =
      const VerificationMeta('failureReason');
  @override
  late final GeneratedColumn<String> failureReason = GeneratedColumn<String>(
      'failure_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        batchId,
        ordinal,
        kind,
        status,
        createdAt,
        localMediaRef,
        localPreviewRef,
        localThumbnailRef,
        localPlaceholderRef,
        remoteMediaRef,
        ideaText,
        capturedAt,
        capturedLocalDate,
        captureDateSource,
        appliedDishId,
        failureReason
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'capture_items';
  @override
  VerificationContext validateIntegrity(Insertable<CaptureItemRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(_batchIdMeta,
          batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta));
    }
    if (data.containsKey('ordinal')) {
      context.handle(_ordinalMeta,
          ordinal.isAcceptableOrUnknown(data['ordinal']!, _ordinalMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('local_media_ref')) {
      context.handle(
          _localMediaRefMeta,
          localMediaRef.isAcceptableOrUnknown(
              data['local_media_ref']!, _localMediaRefMeta));
    }
    if (data.containsKey('local_preview_ref')) {
      context.handle(
          _localPreviewRefMeta,
          localPreviewRef.isAcceptableOrUnknown(
              data['local_preview_ref']!, _localPreviewRefMeta));
    }
    if (data.containsKey('local_thumbnail_ref')) {
      context.handle(
          _localThumbnailRefMeta,
          localThumbnailRef.isAcceptableOrUnknown(
              data['local_thumbnail_ref']!, _localThumbnailRefMeta));
    }
    if (data.containsKey('local_placeholder_ref')) {
      context.handle(
          _localPlaceholderRefMeta,
          localPlaceholderRef.isAcceptableOrUnknown(
              data['local_placeholder_ref']!, _localPlaceholderRefMeta));
    }
    if (data.containsKey('remote_media_ref')) {
      context.handle(
          _remoteMediaRefMeta,
          remoteMediaRef.isAcceptableOrUnknown(
              data['remote_media_ref']!, _remoteMediaRefMeta));
    }
    if (data.containsKey('idea_text')) {
      context.handle(_ideaTextMeta,
          ideaText.isAcceptableOrUnknown(data['idea_text']!, _ideaTextMeta));
    }
    if (data.containsKey('captured_at')) {
      context.handle(
          _capturedAtMeta,
          capturedAt.isAcceptableOrUnknown(
              data['captured_at']!, _capturedAtMeta));
    }
    if (data.containsKey('captured_local_date')) {
      context.handle(
          _capturedLocalDateMeta,
          capturedLocalDate.isAcceptableOrUnknown(
              data['captured_local_date']!, _capturedLocalDateMeta));
    }
    if (data.containsKey('capture_date_source')) {
      context.handle(
          _captureDateSourceMeta,
          captureDateSource.isAcceptableOrUnknown(
              data['capture_date_source']!, _captureDateSourceMeta));
    }
    if (data.containsKey('applied_dish_id')) {
      context.handle(
          _appliedDishIdMeta,
          appliedDishId.isAcceptableOrUnknown(
              data['applied_dish_id']!, _appliedDishIdMeta));
    }
    if (data.containsKey('failure_reason')) {
      context.handle(
          _failureReasonMeta,
          failureReason.isAcceptableOrUnknown(
              data['failure_reason']!, _failureReasonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CaptureItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CaptureItemRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      batchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}batch_id']),
      ordinal: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ordinal'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      localMediaRef: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_media_ref']),
      localPreviewRef: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}local_preview_ref']),
      localThumbnailRef: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}local_thumbnail_ref']),
      localPlaceholderRef: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}local_placeholder_ref']),
      remoteMediaRef: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}remote_media_ref']),
      ideaText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}idea_text']),
      capturedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}captured_at']),
      capturedLocalDate: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}captured_local_date']),
      captureDateSource: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}capture_date_source']),
      appliedDishId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}applied_dish_id']),
      failureReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}failure_reason']),
    );
  }

  @override
  $CaptureItemsTable createAlias(String alias) {
    return $CaptureItemsTable(attachedDatabase, alias);
  }
}

class CaptureItemRow extends DataClass implements Insertable<CaptureItemRow> {
  final String id;
  final String? batchId;
  final int ordinal;
  final String kind;
  final String status;
  final DateTime createdAt;
  final String? localMediaRef;
  final String? localPreviewRef;
  final String? localThumbnailRef;
  final String? localPlaceholderRef;
  final String? remoteMediaRef;
  final String? ideaText;
  final DateTime? capturedAt;
  final String? capturedLocalDate;
  final String? captureDateSource;
  final String? appliedDishId;
  final String? failureReason;
  const CaptureItemRow(
      {required this.id,
      this.batchId,
      required this.ordinal,
      required this.kind,
      required this.status,
      required this.createdAt,
      this.localMediaRef,
      this.localPreviewRef,
      this.localThumbnailRef,
      this.localPlaceholderRef,
      this.remoteMediaRef,
      this.ideaText,
      this.capturedAt,
      this.capturedLocalDate,
      this.captureDateSource,
      this.appliedDishId,
      this.failureReason});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || batchId != null) {
      map['batch_id'] = Variable<String>(batchId);
    }
    map['ordinal'] = Variable<int>(ordinal);
    map['kind'] = Variable<String>(kind);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || localMediaRef != null) {
      map['local_media_ref'] = Variable<String>(localMediaRef);
    }
    if (!nullToAbsent || localPreviewRef != null) {
      map['local_preview_ref'] = Variable<String>(localPreviewRef);
    }
    if (!nullToAbsent || localThumbnailRef != null) {
      map['local_thumbnail_ref'] = Variable<String>(localThumbnailRef);
    }
    if (!nullToAbsent || localPlaceholderRef != null) {
      map['local_placeholder_ref'] = Variable<String>(localPlaceholderRef);
    }
    if (!nullToAbsent || remoteMediaRef != null) {
      map['remote_media_ref'] = Variable<String>(remoteMediaRef);
    }
    if (!nullToAbsent || ideaText != null) {
      map['idea_text'] = Variable<String>(ideaText);
    }
    if (!nullToAbsent || capturedAt != null) {
      map['captured_at'] = Variable<DateTime>(capturedAt);
    }
    if (!nullToAbsent || capturedLocalDate != null) {
      map['captured_local_date'] = Variable<String>(capturedLocalDate);
    }
    if (!nullToAbsent || captureDateSource != null) {
      map['capture_date_source'] = Variable<String>(captureDateSource);
    }
    if (!nullToAbsent || appliedDishId != null) {
      map['applied_dish_id'] = Variable<String>(appliedDishId);
    }
    if (!nullToAbsent || failureReason != null) {
      map['failure_reason'] = Variable<String>(failureReason);
    }
    return map;
  }

  CaptureItemsCompanion toCompanion(bool nullToAbsent) {
    return CaptureItemsCompanion(
      id: Value(id),
      batchId: batchId == null && nullToAbsent
          ? const Value.absent()
          : Value(batchId),
      ordinal: Value(ordinal),
      kind: Value(kind),
      status: Value(status),
      createdAt: Value(createdAt),
      localMediaRef: localMediaRef == null && nullToAbsent
          ? const Value.absent()
          : Value(localMediaRef),
      localPreviewRef: localPreviewRef == null && nullToAbsent
          ? const Value.absent()
          : Value(localPreviewRef),
      localThumbnailRef: localThumbnailRef == null && nullToAbsent
          ? const Value.absent()
          : Value(localThumbnailRef),
      localPlaceholderRef: localPlaceholderRef == null && nullToAbsent
          ? const Value.absent()
          : Value(localPlaceholderRef),
      remoteMediaRef: remoteMediaRef == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteMediaRef),
      ideaText: ideaText == null && nullToAbsent
          ? const Value.absent()
          : Value(ideaText),
      capturedAt: capturedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(capturedAt),
      capturedLocalDate: capturedLocalDate == null && nullToAbsent
          ? const Value.absent()
          : Value(capturedLocalDate),
      captureDateSource: captureDateSource == null && nullToAbsent
          ? const Value.absent()
          : Value(captureDateSource),
      appliedDishId: appliedDishId == null && nullToAbsent
          ? const Value.absent()
          : Value(appliedDishId),
      failureReason: failureReason == null && nullToAbsent
          ? const Value.absent()
          : Value(failureReason),
    );
  }

  factory CaptureItemRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CaptureItemRow(
      id: serializer.fromJson<String>(json['id']),
      batchId: serializer.fromJson<String?>(json['batchId']),
      ordinal: serializer.fromJson<int>(json['ordinal']),
      kind: serializer.fromJson<String>(json['kind']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      localMediaRef: serializer.fromJson<String?>(json['localMediaRef']),
      localPreviewRef: serializer.fromJson<String?>(json['localPreviewRef']),
      localThumbnailRef:
          serializer.fromJson<String?>(json['localThumbnailRef']),
      localPlaceholderRef:
          serializer.fromJson<String?>(json['localPlaceholderRef']),
      remoteMediaRef: serializer.fromJson<String?>(json['remoteMediaRef']),
      ideaText: serializer.fromJson<String?>(json['ideaText']),
      capturedAt: serializer.fromJson<DateTime?>(json['capturedAt']),
      capturedLocalDate:
          serializer.fromJson<String?>(json['capturedLocalDate']),
      captureDateSource:
          serializer.fromJson<String?>(json['captureDateSource']),
      appliedDishId: serializer.fromJson<String?>(json['appliedDishId']),
      failureReason: serializer.fromJson<String?>(json['failureReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'batchId': serializer.toJson<String?>(batchId),
      'ordinal': serializer.toJson<int>(ordinal),
      'kind': serializer.toJson<String>(kind),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'localMediaRef': serializer.toJson<String?>(localMediaRef),
      'localPreviewRef': serializer.toJson<String?>(localPreviewRef),
      'localThumbnailRef': serializer.toJson<String?>(localThumbnailRef),
      'localPlaceholderRef': serializer.toJson<String?>(localPlaceholderRef),
      'remoteMediaRef': serializer.toJson<String?>(remoteMediaRef),
      'ideaText': serializer.toJson<String?>(ideaText),
      'capturedAt': serializer.toJson<DateTime?>(capturedAt),
      'capturedLocalDate': serializer.toJson<String?>(capturedLocalDate),
      'captureDateSource': serializer.toJson<String?>(captureDateSource),
      'appliedDishId': serializer.toJson<String?>(appliedDishId),
      'failureReason': serializer.toJson<String?>(failureReason),
    };
  }

  CaptureItemRow copyWith(
          {String? id,
          Value<String?> batchId = const Value.absent(),
          int? ordinal,
          String? kind,
          String? status,
          DateTime? createdAt,
          Value<String?> localMediaRef = const Value.absent(),
          Value<String?> localPreviewRef = const Value.absent(),
          Value<String?> localThumbnailRef = const Value.absent(),
          Value<String?> localPlaceholderRef = const Value.absent(),
          Value<String?> remoteMediaRef = const Value.absent(),
          Value<String?> ideaText = const Value.absent(),
          Value<DateTime?> capturedAt = const Value.absent(),
          Value<String?> capturedLocalDate = const Value.absent(),
          Value<String?> captureDateSource = const Value.absent(),
          Value<String?> appliedDishId = const Value.absent(),
          Value<String?> failureReason = const Value.absent()}) =>
      CaptureItemRow(
        id: id ?? this.id,
        batchId: batchId.present ? batchId.value : this.batchId,
        ordinal: ordinal ?? this.ordinal,
        kind: kind ?? this.kind,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        localMediaRef:
            localMediaRef.present ? localMediaRef.value : this.localMediaRef,
        localPreviewRef: localPreviewRef.present
            ? localPreviewRef.value
            : this.localPreviewRef,
        localThumbnailRef: localThumbnailRef.present
            ? localThumbnailRef.value
            : this.localThumbnailRef,
        localPlaceholderRef: localPlaceholderRef.present
            ? localPlaceholderRef.value
            : this.localPlaceholderRef,
        remoteMediaRef:
            remoteMediaRef.present ? remoteMediaRef.value : this.remoteMediaRef,
        ideaText: ideaText.present ? ideaText.value : this.ideaText,
        capturedAt: capturedAt.present ? capturedAt.value : this.capturedAt,
        capturedLocalDate: capturedLocalDate.present
            ? capturedLocalDate.value
            : this.capturedLocalDate,
        captureDateSource: captureDateSource.present
            ? captureDateSource.value
            : this.captureDateSource,
        appliedDishId:
            appliedDishId.present ? appliedDishId.value : this.appliedDishId,
        failureReason:
            failureReason.present ? failureReason.value : this.failureReason,
      );
  CaptureItemRow copyWithCompanion(CaptureItemsCompanion data) {
    return CaptureItemRow(
      id: data.id.present ? data.id.value : this.id,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      ordinal: data.ordinal.present ? data.ordinal.value : this.ordinal,
      kind: data.kind.present ? data.kind.value : this.kind,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      localMediaRef: data.localMediaRef.present
          ? data.localMediaRef.value
          : this.localMediaRef,
      localPreviewRef: data.localPreviewRef.present
          ? data.localPreviewRef.value
          : this.localPreviewRef,
      localThumbnailRef: data.localThumbnailRef.present
          ? data.localThumbnailRef.value
          : this.localThumbnailRef,
      localPlaceholderRef: data.localPlaceholderRef.present
          ? data.localPlaceholderRef.value
          : this.localPlaceholderRef,
      remoteMediaRef: data.remoteMediaRef.present
          ? data.remoteMediaRef.value
          : this.remoteMediaRef,
      ideaText: data.ideaText.present ? data.ideaText.value : this.ideaText,
      capturedAt:
          data.capturedAt.present ? data.capturedAt.value : this.capturedAt,
      capturedLocalDate: data.capturedLocalDate.present
          ? data.capturedLocalDate.value
          : this.capturedLocalDate,
      captureDateSource: data.captureDateSource.present
          ? data.captureDateSource.value
          : this.captureDateSource,
      appliedDishId: data.appliedDishId.present
          ? data.appliedDishId.value
          : this.appliedDishId,
      failureReason: data.failureReason.present
          ? data.failureReason.value
          : this.failureReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CaptureItemRow(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('ordinal: $ordinal, ')
          ..write('kind: $kind, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('localMediaRef: $localMediaRef, ')
          ..write('localPreviewRef: $localPreviewRef, ')
          ..write('localThumbnailRef: $localThumbnailRef, ')
          ..write('localPlaceholderRef: $localPlaceholderRef, ')
          ..write('remoteMediaRef: $remoteMediaRef, ')
          ..write('ideaText: $ideaText, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('capturedLocalDate: $capturedLocalDate, ')
          ..write('captureDateSource: $captureDateSource, ')
          ..write('appliedDishId: $appliedDishId, ')
          ..write('failureReason: $failureReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      batchId,
      ordinal,
      kind,
      status,
      createdAt,
      localMediaRef,
      localPreviewRef,
      localThumbnailRef,
      localPlaceholderRef,
      remoteMediaRef,
      ideaText,
      capturedAt,
      capturedLocalDate,
      captureDateSource,
      appliedDishId,
      failureReason);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CaptureItemRow &&
          other.id == this.id &&
          other.batchId == this.batchId &&
          other.ordinal == this.ordinal &&
          other.kind == this.kind &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.localMediaRef == this.localMediaRef &&
          other.localPreviewRef == this.localPreviewRef &&
          other.localThumbnailRef == this.localThumbnailRef &&
          other.localPlaceholderRef == this.localPlaceholderRef &&
          other.remoteMediaRef == this.remoteMediaRef &&
          other.ideaText == this.ideaText &&
          other.capturedAt == this.capturedAt &&
          other.capturedLocalDate == this.capturedLocalDate &&
          other.captureDateSource == this.captureDateSource &&
          other.appliedDishId == this.appliedDishId &&
          other.failureReason == this.failureReason);
}

class CaptureItemsCompanion extends UpdateCompanion<CaptureItemRow> {
  final Value<String> id;
  final Value<String?> batchId;
  final Value<int> ordinal;
  final Value<String> kind;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<String?> localMediaRef;
  final Value<String?> localPreviewRef;
  final Value<String?> localThumbnailRef;
  final Value<String?> localPlaceholderRef;
  final Value<String?> remoteMediaRef;
  final Value<String?> ideaText;
  final Value<DateTime?> capturedAt;
  final Value<String?> capturedLocalDate;
  final Value<String?> captureDateSource;
  final Value<String?> appliedDishId;
  final Value<String?> failureReason;
  final Value<int> rowid;
  const CaptureItemsCompanion({
    this.id = const Value.absent(),
    this.batchId = const Value.absent(),
    this.ordinal = const Value.absent(),
    this.kind = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.localMediaRef = const Value.absent(),
    this.localPreviewRef = const Value.absent(),
    this.localThumbnailRef = const Value.absent(),
    this.localPlaceholderRef = const Value.absent(),
    this.remoteMediaRef = const Value.absent(),
    this.ideaText = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.capturedLocalDate = const Value.absent(),
    this.captureDateSource = const Value.absent(),
    this.appliedDishId = const Value.absent(),
    this.failureReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CaptureItemsCompanion.insert({
    required String id,
    this.batchId = const Value.absent(),
    this.ordinal = const Value.absent(),
    required String kind,
    required String status,
    required DateTime createdAt,
    this.localMediaRef = const Value.absent(),
    this.localPreviewRef = const Value.absent(),
    this.localThumbnailRef = const Value.absent(),
    this.localPlaceholderRef = const Value.absent(),
    this.remoteMediaRef = const Value.absent(),
    this.ideaText = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.capturedLocalDate = const Value.absent(),
    this.captureDateSource = const Value.absent(),
    this.appliedDishId = const Value.absent(),
    this.failureReason = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        kind = Value(kind),
        status = Value(status),
        createdAt = Value(createdAt);
  static Insertable<CaptureItemRow> custom({
    Expression<String>? id,
    Expression<String>? batchId,
    Expression<int>? ordinal,
    Expression<String>? kind,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<String>? localMediaRef,
    Expression<String>? localPreviewRef,
    Expression<String>? localThumbnailRef,
    Expression<String>? localPlaceholderRef,
    Expression<String>? remoteMediaRef,
    Expression<String>? ideaText,
    Expression<DateTime>? capturedAt,
    Expression<String>? capturedLocalDate,
    Expression<String>? captureDateSource,
    Expression<String>? appliedDishId,
    Expression<String>? failureReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (batchId != null) 'batch_id': batchId,
      if (ordinal != null) 'ordinal': ordinal,
      if (kind != null) 'kind': kind,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (localMediaRef != null) 'local_media_ref': localMediaRef,
      if (localPreviewRef != null) 'local_preview_ref': localPreviewRef,
      if (localThumbnailRef != null) 'local_thumbnail_ref': localThumbnailRef,
      if (localPlaceholderRef != null)
        'local_placeholder_ref': localPlaceholderRef,
      if (remoteMediaRef != null) 'remote_media_ref': remoteMediaRef,
      if (ideaText != null) 'idea_text': ideaText,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (capturedLocalDate != null) 'captured_local_date': capturedLocalDate,
      if (captureDateSource != null) 'capture_date_source': captureDateSource,
      if (appliedDishId != null) 'applied_dish_id': appliedDishId,
      if (failureReason != null) 'failure_reason': failureReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CaptureItemsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? batchId,
      Value<int>? ordinal,
      Value<String>? kind,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<String?>? localMediaRef,
      Value<String?>? localPreviewRef,
      Value<String?>? localThumbnailRef,
      Value<String?>? localPlaceholderRef,
      Value<String?>? remoteMediaRef,
      Value<String?>? ideaText,
      Value<DateTime?>? capturedAt,
      Value<String?>? capturedLocalDate,
      Value<String?>? captureDateSource,
      Value<String?>? appliedDishId,
      Value<String?>? failureReason,
      Value<int>? rowid}) {
    return CaptureItemsCompanion(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      ordinal: ordinal ?? this.ordinal,
      kind: kind ?? this.kind,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      localMediaRef: localMediaRef ?? this.localMediaRef,
      localPreviewRef: localPreviewRef ?? this.localPreviewRef,
      localThumbnailRef: localThumbnailRef ?? this.localThumbnailRef,
      localPlaceholderRef: localPlaceholderRef ?? this.localPlaceholderRef,
      remoteMediaRef: remoteMediaRef ?? this.remoteMediaRef,
      ideaText: ideaText ?? this.ideaText,
      capturedAt: capturedAt ?? this.capturedAt,
      capturedLocalDate: capturedLocalDate ?? this.capturedLocalDate,
      captureDateSource: captureDateSource ?? this.captureDateSource,
      appliedDishId: appliedDishId ?? this.appliedDishId,
      failureReason: failureReason ?? this.failureReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (ordinal.present) {
      map['ordinal'] = Variable<int>(ordinal.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (localMediaRef.present) {
      map['local_media_ref'] = Variable<String>(localMediaRef.value);
    }
    if (localPreviewRef.present) {
      map['local_preview_ref'] = Variable<String>(localPreviewRef.value);
    }
    if (localThumbnailRef.present) {
      map['local_thumbnail_ref'] = Variable<String>(localThumbnailRef.value);
    }
    if (localPlaceholderRef.present) {
      map['local_placeholder_ref'] =
          Variable<String>(localPlaceholderRef.value);
    }
    if (remoteMediaRef.present) {
      map['remote_media_ref'] = Variable<String>(remoteMediaRef.value);
    }
    if (ideaText.present) {
      map['idea_text'] = Variable<String>(ideaText.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (capturedLocalDate.present) {
      map['captured_local_date'] = Variable<String>(capturedLocalDate.value);
    }
    if (captureDateSource.present) {
      map['capture_date_source'] = Variable<String>(captureDateSource.value);
    }
    if (appliedDishId.present) {
      map['applied_dish_id'] = Variable<String>(appliedDishId.value);
    }
    if (failureReason.present) {
      map['failure_reason'] = Variable<String>(failureReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CaptureItemsCompanion(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('ordinal: $ordinal, ')
          ..write('kind: $kind, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('localMediaRef: $localMediaRef, ')
          ..write('localPreviewRef: $localPreviewRef, ')
          ..write('localThumbnailRef: $localThumbnailRef, ')
          ..write('localPlaceholderRef: $localPlaceholderRef, ')
          ..write('remoteMediaRef: $remoteMediaRef, ')
          ..write('ideaText: $ideaText, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('capturedLocalDate: $capturedLocalDate, ')
          ..write('captureDateSource: $captureDateSource, ')
          ..write('appliedDishId: $appliedDishId, ')
          ..write('failureReason: $failureReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CaptureCorrectionsTable extends CaptureCorrections
    with TableInfo<$CaptureCorrectionsTable, CaptureCorrectionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CaptureCorrectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _batchIdMeta =
      const VerificationMeta('batchId');
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
      'batch_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionTypeMeta =
      const VerificationMeta('actionType');
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
      'action_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _captureIdsJsonMeta =
      const VerificationMeta('captureIdsJson');
  @override
  late final GeneratedColumn<String> captureIdsJson = GeneratedColumn<String>(
      'capture_ids_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _previousDishIdsJsonMeta =
      const VerificationMeta('previousDishIdsJson');
  @override
  late final GeneratedColumn<String> previousDishIdsJson =
      GeneratedColumn<String>('previous_dish_ids_json', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetDishIdMeta =
      const VerificationMeta('targetDishId');
  @override
  late final GeneratedColumn<String> targetDishId = GeneratedColumn<String>(
      'target_dish_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdDishIdMeta =
      const VerificationMeta('createdDishId');
  @override
  late final GeneratedColumn<String> createdDishId = GeneratedColumn<String>(
      'created_dish_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
      'error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _undoneAtMeta =
      const VerificationMeta('undoneAt');
  @override
  late final GeneratedColumn<DateTime> undoneAt = GeneratedColumn<DateTime>(
      'undone_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        batchId,
        actionType,
        captureIdsJson,
        previousDishIdsJson,
        targetDishId,
        createdDishId,
        status,
        error,
        createdAt,
        updatedAt,
        undoneAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'capture_corrections';
  @override
  VerificationContext validateIntegrity(
      Insertable<CaptureCorrectionRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(_batchIdMeta,
          batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta));
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('action_type')) {
      context.handle(
          _actionTypeMeta,
          actionType.isAcceptableOrUnknown(
              data['action_type']!, _actionTypeMeta));
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
    }
    if (data.containsKey('capture_ids_json')) {
      context.handle(
          _captureIdsJsonMeta,
          captureIdsJson.isAcceptableOrUnknown(
              data['capture_ids_json']!, _captureIdsJsonMeta));
    } else if (isInserting) {
      context.missing(_captureIdsJsonMeta);
    }
    if (data.containsKey('previous_dish_ids_json')) {
      context.handle(
          _previousDishIdsJsonMeta,
          previousDishIdsJson.isAcceptableOrUnknown(
              data['previous_dish_ids_json']!, _previousDishIdsJsonMeta));
    } else if (isInserting) {
      context.missing(_previousDishIdsJsonMeta);
    }
    if (data.containsKey('target_dish_id')) {
      context.handle(
          _targetDishIdMeta,
          targetDishId.isAcceptableOrUnknown(
              data['target_dish_id']!, _targetDishIdMeta));
    } else if (isInserting) {
      context.missing(_targetDishIdMeta);
    }
    if (data.containsKey('created_dish_id')) {
      context.handle(
          _createdDishIdMeta,
          createdDishId.isAcceptableOrUnknown(
              data['created_dish_id']!, _createdDishIdMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('error')) {
      context.handle(
          _errorMeta, error.isAcceptableOrUnknown(data['error']!, _errorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('undone_at')) {
      context.handle(_undoneAtMeta,
          undoneAt.isAcceptableOrUnknown(data['undone_at']!, _undoneAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CaptureCorrectionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CaptureCorrectionRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      batchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}batch_id'])!,
      actionType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action_type'])!,
      captureIdsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}capture_ids_json'])!,
      previousDishIdsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}previous_dish_ids_json'])!,
      targetDishId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_dish_id'])!,
      createdDishId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_dish_id']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      error: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      undoneAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}undone_at']),
    );
  }

  @override
  $CaptureCorrectionsTable createAlias(String alias) {
    return $CaptureCorrectionsTable(attachedDatabase, alias);
  }
}

class CaptureCorrectionRow extends DataClass
    implements Insertable<CaptureCorrectionRow> {
  final String id;
  final String batchId;
  final String actionType;
  final String captureIdsJson;
  final String previousDishIdsJson;
  final String targetDishId;
  final String? createdDishId;
  final String status;
  final String? error;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? undoneAt;
  const CaptureCorrectionRow(
      {required this.id,
      required this.batchId,
      required this.actionType,
      required this.captureIdsJson,
      required this.previousDishIdsJson,
      required this.targetDishId,
      this.createdDishId,
      required this.status,
      this.error,
      required this.createdAt,
      required this.updatedAt,
      this.undoneAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['batch_id'] = Variable<String>(batchId);
    map['action_type'] = Variable<String>(actionType);
    map['capture_ids_json'] = Variable<String>(captureIdsJson);
    map['previous_dish_ids_json'] = Variable<String>(previousDishIdsJson);
    map['target_dish_id'] = Variable<String>(targetDishId);
    if (!nullToAbsent || createdDishId != null) {
      map['created_dish_id'] = Variable<String>(createdDishId);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || undoneAt != null) {
      map['undone_at'] = Variable<DateTime>(undoneAt);
    }
    return map;
  }

  CaptureCorrectionsCompanion toCompanion(bool nullToAbsent) {
    return CaptureCorrectionsCompanion(
      id: Value(id),
      batchId: Value(batchId),
      actionType: Value(actionType),
      captureIdsJson: Value(captureIdsJson),
      previousDishIdsJson: Value(previousDishIdsJson),
      targetDishId: Value(targetDishId),
      createdDishId: createdDishId == null && nullToAbsent
          ? const Value.absent()
          : Value(createdDishId),
      status: Value(status),
      error:
          error == null && nullToAbsent ? const Value.absent() : Value(error),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      undoneAt: undoneAt == null && nullToAbsent
          ? const Value.absent()
          : Value(undoneAt),
    );
  }

  factory CaptureCorrectionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CaptureCorrectionRow(
      id: serializer.fromJson<String>(json['id']),
      batchId: serializer.fromJson<String>(json['batchId']),
      actionType: serializer.fromJson<String>(json['actionType']),
      captureIdsJson: serializer.fromJson<String>(json['captureIdsJson']),
      previousDishIdsJson:
          serializer.fromJson<String>(json['previousDishIdsJson']),
      targetDishId: serializer.fromJson<String>(json['targetDishId']),
      createdDishId: serializer.fromJson<String?>(json['createdDishId']),
      status: serializer.fromJson<String>(json['status']),
      error: serializer.fromJson<String?>(json['error']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      undoneAt: serializer.fromJson<DateTime?>(json['undoneAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'batchId': serializer.toJson<String>(batchId),
      'actionType': serializer.toJson<String>(actionType),
      'captureIdsJson': serializer.toJson<String>(captureIdsJson),
      'previousDishIdsJson': serializer.toJson<String>(previousDishIdsJson),
      'targetDishId': serializer.toJson<String>(targetDishId),
      'createdDishId': serializer.toJson<String?>(createdDishId),
      'status': serializer.toJson<String>(status),
      'error': serializer.toJson<String?>(error),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'undoneAt': serializer.toJson<DateTime?>(undoneAt),
    };
  }

  CaptureCorrectionRow copyWith(
          {String? id,
          String? batchId,
          String? actionType,
          String? captureIdsJson,
          String? previousDishIdsJson,
          String? targetDishId,
          Value<String?> createdDishId = const Value.absent(),
          String? status,
          Value<String?> error = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> undoneAt = const Value.absent()}) =>
      CaptureCorrectionRow(
        id: id ?? this.id,
        batchId: batchId ?? this.batchId,
        actionType: actionType ?? this.actionType,
        captureIdsJson: captureIdsJson ?? this.captureIdsJson,
        previousDishIdsJson: previousDishIdsJson ?? this.previousDishIdsJson,
        targetDishId: targetDishId ?? this.targetDishId,
        createdDishId:
            createdDishId.present ? createdDishId.value : this.createdDishId,
        status: status ?? this.status,
        error: error.present ? error.value : this.error,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        undoneAt: undoneAt.present ? undoneAt.value : this.undoneAt,
      );
  CaptureCorrectionRow copyWithCompanion(CaptureCorrectionsCompanion data) {
    return CaptureCorrectionRow(
      id: data.id.present ? data.id.value : this.id,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      actionType:
          data.actionType.present ? data.actionType.value : this.actionType,
      captureIdsJson: data.captureIdsJson.present
          ? data.captureIdsJson.value
          : this.captureIdsJson,
      previousDishIdsJson: data.previousDishIdsJson.present
          ? data.previousDishIdsJson.value
          : this.previousDishIdsJson,
      targetDishId: data.targetDishId.present
          ? data.targetDishId.value
          : this.targetDishId,
      createdDishId: data.createdDishId.present
          ? data.createdDishId.value
          : this.createdDishId,
      status: data.status.present ? data.status.value : this.status,
      error: data.error.present ? data.error.value : this.error,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      undoneAt: data.undoneAt.present ? data.undoneAt.value : this.undoneAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CaptureCorrectionRow(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('actionType: $actionType, ')
          ..write('captureIdsJson: $captureIdsJson, ')
          ..write('previousDishIdsJson: $previousDishIdsJson, ')
          ..write('targetDishId: $targetDishId, ')
          ..write('createdDishId: $createdDishId, ')
          ..write('status: $status, ')
          ..write('error: $error, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('undoneAt: $undoneAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      batchId,
      actionType,
      captureIdsJson,
      previousDishIdsJson,
      targetDishId,
      createdDishId,
      status,
      error,
      createdAt,
      updatedAt,
      undoneAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CaptureCorrectionRow &&
          other.id == this.id &&
          other.batchId == this.batchId &&
          other.actionType == this.actionType &&
          other.captureIdsJson == this.captureIdsJson &&
          other.previousDishIdsJson == this.previousDishIdsJson &&
          other.targetDishId == this.targetDishId &&
          other.createdDishId == this.createdDishId &&
          other.status == this.status &&
          other.error == this.error &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.undoneAt == this.undoneAt);
}

class CaptureCorrectionsCompanion
    extends UpdateCompanion<CaptureCorrectionRow> {
  final Value<String> id;
  final Value<String> batchId;
  final Value<String> actionType;
  final Value<String> captureIdsJson;
  final Value<String> previousDishIdsJson;
  final Value<String> targetDishId;
  final Value<String?> createdDishId;
  final Value<String> status;
  final Value<String?> error;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> undoneAt;
  final Value<int> rowid;
  const CaptureCorrectionsCompanion({
    this.id = const Value.absent(),
    this.batchId = const Value.absent(),
    this.actionType = const Value.absent(),
    this.captureIdsJson = const Value.absent(),
    this.previousDishIdsJson = const Value.absent(),
    this.targetDishId = const Value.absent(),
    this.createdDishId = const Value.absent(),
    this.status = const Value.absent(),
    this.error = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.undoneAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CaptureCorrectionsCompanion.insert({
    required String id,
    required String batchId,
    required String actionType,
    required String captureIdsJson,
    required String previousDishIdsJson,
    required String targetDishId,
    this.createdDishId = const Value.absent(),
    required String status,
    this.error = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.undoneAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        batchId = Value(batchId),
        actionType = Value(actionType),
        captureIdsJson = Value(captureIdsJson),
        previousDishIdsJson = Value(previousDishIdsJson),
        targetDishId = Value(targetDishId),
        status = Value(status),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<CaptureCorrectionRow> custom({
    Expression<String>? id,
    Expression<String>? batchId,
    Expression<String>? actionType,
    Expression<String>? captureIdsJson,
    Expression<String>? previousDishIdsJson,
    Expression<String>? targetDishId,
    Expression<String>? createdDishId,
    Expression<String>? status,
    Expression<String>? error,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? undoneAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (batchId != null) 'batch_id': batchId,
      if (actionType != null) 'action_type': actionType,
      if (captureIdsJson != null) 'capture_ids_json': captureIdsJson,
      if (previousDishIdsJson != null)
        'previous_dish_ids_json': previousDishIdsJson,
      if (targetDishId != null) 'target_dish_id': targetDishId,
      if (createdDishId != null) 'created_dish_id': createdDishId,
      if (status != null) 'status': status,
      if (error != null) 'error': error,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (undoneAt != null) 'undone_at': undoneAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CaptureCorrectionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? batchId,
      Value<String>? actionType,
      Value<String>? captureIdsJson,
      Value<String>? previousDishIdsJson,
      Value<String>? targetDishId,
      Value<String?>? createdDishId,
      Value<String>? status,
      Value<String?>? error,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? undoneAt,
      Value<int>? rowid}) {
    return CaptureCorrectionsCompanion(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      actionType: actionType ?? this.actionType,
      captureIdsJson: captureIdsJson ?? this.captureIdsJson,
      previousDishIdsJson: previousDishIdsJson ?? this.previousDishIdsJson,
      targetDishId: targetDishId ?? this.targetDishId,
      createdDishId: createdDishId ?? this.createdDishId,
      status: status ?? this.status,
      error: error ?? this.error,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      undoneAt: undoneAt ?? this.undoneAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (captureIdsJson.present) {
      map['capture_ids_json'] = Variable<String>(captureIdsJson.value);
    }
    if (previousDishIdsJson.present) {
      map['previous_dish_ids_json'] =
          Variable<String>(previousDishIdsJson.value);
    }
    if (targetDishId.present) {
      map['target_dish_id'] = Variable<String>(targetDishId.value);
    }
    if (createdDishId.present) {
      map['created_dish_id'] = Variable<String>(createdDishId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (undoneAt.present) {
      map['undone_at'] = Variable<DateTime>(undoneAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CaptureCorrectionsCompanion(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('actionType: $actionType, ')
          ..write('captureIdsJson: $captureIdsJson, ')
          ..write('previousDishIdsJson: $previousDishIdsJson, ')
          ..write('targetDishId: $targetDishId, ')
          ..write('createdDishId: $createdDishId, ')
          ..write('status: $status, ')
          ..write('error: $error, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('undoneAt: $undoneAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlannedMealsTable extends PlannedMeals
    with TableInfo<$PlannedMealsTable, PlannedMealRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlannedMealsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dayKeyMeta = const VerificationMeta('dayKey');
  @override
  late final GeneratedColumn<String> dayKey = GeneratedColumn<String>(
      'day_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dishIdMeta = const VerificationMeta('dishId');
  @override
  late final GeneratedColumn<String> dishId = GeneratedColumn<String>(
      'dish_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [id, dayKey, dishId, label, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'planned_meals';
  @override
  VerificationContext validateIntegrity(Insertable<PlannedMealRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('day_key')) {
      context.handle(_dayKeyMeta,
          dayKey.isAcceptableOrUnknown(data['day_key']!, _dayKeyMeta));
    } else if (isInserting) {
      context.missing(_dayKeyMeta);
    }
    if (data.containsKey('dish_id')) {
      context.handle(_dishIdMeta,
          dishId.isAcceptableOrUnknown(data['dish_id']!, _dishIdMeta));
    } else if (isInserting) {
      context.missing(_dishIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlannedMealRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlannedMealRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      dayKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}day_key'])!,
      dishId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dish_id'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label']),
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
    );
  }

  @override
  $PlannedMealsTable createAlias(String alias) {
    return $PlannedMealsTable(attachedDatabase, alias);
  }
}

class PlannedMealRow extends DataClass implements Insertable<PlannedMealRow> {
  final String id;
  final String dayKey;
  final String dishId;
  final String? label;
  final int position;
  const PlannedMealRow(
      {required this.id,
      required this.dayKey,
      required this.dishId,
      this.label,
      required this.position});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['day_key'] = Variable<String>(dayKey);
    map['dish_id'] = Variable<String>(dishId);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['position'] = Variable<int>(position);
    return map;
  }

  PlannedMealsCompanion toCompanion(bool nullToAbsent) {
    return PlannedMealsCompanion(
      id: Value(id),
      dayKey: Value(dayKey),
      dishId: Value(dishId),
      label:
          label == null && nullToAbsent ? const Value.absent() : Value(label),
      position: Value(position),
    );
  }

  factory PlannedMealRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlannedMealRow(
      id: serializer.fromJson<String>(json['id']),
      dayKey: serializer.fromJson<String>(json['dayKey']),
      dishId: serializer.fromJson<String>(json['dishId']),
      label: serializer.fromJson<String?>(json['label']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dayKey': serializer.toJson<String>(dayKey),
      'dishId': serializer.toJson<String>(dishId),
      'label': serializer.toJson<String?>(label),
      'position': serializer.toJson<int>(position),
    };
  }

  PlannedMealRow copyWith(
          {String? id,
          String? dayKey,
          String? dishId,
          Value<String?> label = const Value.absent(),
          int? position}) =>
      PlannedMealRow(
        id: id ?? this.id,
        dayKey: dayKey ?? this.dayKey,
        dishId: dishId ?? this.dishId,
        label: label.present ? label.value : this.label,
        position: position ?? this.position,
      );
  PlannedMealRow copyWithCompanion(PlannedMealsCompanion data) {
    return PlannedMealRow(
      id: data.id.present ? data.id.value : this.id,
      dayKey: data.dayKey.present ? data.dayKey.value : this.dayKey,
      dishId: data.dishId.present ? data.dishId.value : this.dishId,
      label: data.label.present ? data.label.value : this.label,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlannedMealRow(')
          ..write('id: $id, ')
          ..write('dayKey: $dayKey, ')
          ..write('dishId: $dishId, ')
          ..write('label: $label, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dayKey, dishId, label, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlannedMealRow &&
          other.id == this.id &&
          other.dayKey == this.dayKey &&
          other.dishId == this.dishId &&
          other.label == this.label &&
          other.position == this.position);
}

class PlannedMealsCompanion extends UpdateCompanion<PlannedMealRow> {
  final Value<String> id;
  final Value<String> dayKey;
  final Value<String> dishId;
  final Value<String?> label;
  final Value<int> position;
  final Value<int> rowid;
  const PlannedMealsCompanion({
    this.id = const Value.absent(),
    this.dayKey = const Value.absent(),
    this.dishId = const Value.absent(),
    this.label = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlannedMealsCompanion.insert({
    required String id,
    required String dayKey,
    required String dishId,
    this.label = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        dayKey = Value(dayKey),
        dishId = Value(dishId);
  static Insertable<PlannedMealRow> custom({
    Expression<String>? id,
    Expression<String>? dayKey,
    Expression<String>? dishId,
    Expression<String>? label,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dayKey != null) 'day_key': dayKey,
      if (dishId != null) 'dish_id': dishId,
      if (label != null) 'label': label,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlannedMealsCompanion copyWith(
      {Value<String>? id,
      Value<String>? dayKey,
      Value<String>? dishId,
      Value<String?>? label,
      Value<int>? position,
      Value<int>? rowid}) {
    return PlannedMealsCompanion(
      id: id ?? this.id,
      dayKey: dayKey ?? this.dayKey,
      dishId: dishId ?? this.dishId,
      label: label ?? this.label,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dayKey.present) {
      map['day_key'] = Variable<String>(dayKey.value);
    }
    if (dishId.present) {
      map['dish_id'] = Variable<String>(dishId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlannedMealsCompanion(')
          ..write('id: $id, ')
          ..write('dayKey: $dayKey, ')
          ..write('dishId: $dishId, ')
          ..write('label: $label, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReviewItemsTable extends ReviewItems
    with TableInfo<$ReviewItemsTable, ReviewItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _captureIdMeta =
      const VerificationMeta('captureId');
  @override
  late final GeneratedColumn<String> captureId = GeneratedColumn<String>(
      'capture_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _summaryMeta =
      const VerificationMeta('summary');
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
      'summary', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _suggestedDishIdsJsonMeta =
      const VerificationMeta('suggestedDishIdsJson');
  @override
  late final GeneratedColumn<String> suggestedDishIdsJson =
      GeneratedColumn<String>('suggested_dish_ids_json', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _confidenceLabelMeta =
      const VerificationMeta('confidenceLabel');
  @override
  late final GeneratedColumn<String> confidenceLabel = GeneratedColumn<String>(
      'confidence_label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imageRefMeta =
      const VerificationMeta('imageRef');
  @override
  late final GeneratedColumn<String> imageRef = GeneratedColumn<String>(
      'image_ref', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, captureId, summary, suggestedDishIdsJson, confidenceLabel, imageRef];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_items';
  @override
  VerificationContext validateIntegrity(Insertable<ReviewItemRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('capture_id')) {
      context.handle(_captureIdMeta,
          captureId.isAcceptableOrUnknown(data['capture_id']!, _captureIdMeta));
    }
    if (data.containsKey('summary')) {
      context.handle(_summaryMeta,
          summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta));
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    if (data.containsKey('suggested_dish_ids_json')) {
      context.handle(
          _suggestedDishIdsJsonMeta,
          suggestedDishIdsJson.isAcceptableOrUnknown(
              data['suggested_dish_ids_json']!, _suggestedDishIdsJsonMeta));
    } else if (isInserting) {
      context.missing(_suggestedDishIdsJsonMeta);
    }
    if (data.containsKey('confidence_label')) {
      context.handle(
          _confidenceLabelMeta,
          confidenceLabel.isAcceptableOrUnknown(
              data['confidence_label']!, _confidenceLabelMeta));
    } else if (isInserting) {
      context.missing(_confidenceLabelMeta);
    }
    if (data.containsKey('image_ref')) {
      context.handle(_imageRefMeta,
          imageRef.isAcceptableOrUnknown(data['image_ref']!, _imageRefMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewItemRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      captureId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}capture_id']),
      summary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}summary'])!,
      suggestedDishIdsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}suggested_dish_ids_json'])!,
      confidenceLabel: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}confidence_label'])!,
      imageRef: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_ref']),
    );
  }

  @override
  $ReviewItemsTable createAlias(String alias) {
    return $ReviewItemsTable(attachedDatabase, alias);
  }
}

class ReviewItemRow extends DataClass implements Insertable<ReviewItemRow> {
  final String id;
  final String? captureId;
  final String summary;
  final String suggestedDishIdsJson;
  final String confidenceLabel;
  final String? imageRef;
  const ReviewItemRow(
      {required this.id,
      this.captureId,
      required this.summary,
      required this.suggestedDishIdsJson,
      required this.confidenceLabel,
      this.imageRef});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || captureId != null) {
      map['capture_id'] = Variable<String>(captureId);
    }
    map['summary'] = Variable<String>(summary);
    map['suggested_dish_ids_json'] = Variable<String>(suggestedDishIdsJson);
    map['confidence_label'] = Variable<String>(confidenceLabel);
    if (!nullToAbsent || imageRef != null) {
      map['image_ref'] = Variable<String>(imageRef);
    }
    return map;
  }

  ReviewItemsCompanion toCompanion(bool nullToAbsent) {
    return ReviewItemsCompanion(
      id: Value(id),
      captureId: captureId == null && nullToAbsent
          ? const Value.absent()
          : Value(captureId),
      summary: Value(summary),
      suggestedDishIdsJson: Value(suggestedDishIdsJson),
      confidenceLabel: Value(confidenceLabel),
      imageRef: imageRef == null && nullToAbsent
          ? const Value.absent()
          : Value(imageRef),
    );
  }

  factory ReviewItemRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewItemRow(
      id: serializer.fromJson<String>(json['id']),
      captureId: serializer.fromJson<String?>(json['captureId']),
      summary: serializer.fromJson<String>(json['summary']),
      suggestedDishIdsJson:
          serializer.fromJson<String>(json['suggestedDishIdsJson']),
      confidenceLabel: serializer.fromJson<String>(json['confidenceLabel']),
      imageRef: serializer.fromJson<String?>(json['imageRef']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'captureId': serializer.toJson<String?>(captureId),
      'summary': serializer.toJson<String>(summary),
      'suggestedDishIdsJson': serializer.toJson<String>(suggestedDishIdsJson),
      'confidenceLabel': serializer.toJson<String>(confidenceLabel),
      'imageRef': serializer.toJson<String?>(imageRef),
    };
  }

  ReviewItemRow copyWith(
          {String? id,
          Value<String?> captureId = const Value.absent(),
          String? summary,
          String? suggestedDishIdsJson,
          String? confidenceLabel,
          Value<String?> imageRef = const Value.absent()}) =>
      ReviewItemRow(
        id: id ?? this.id,
        captureId: captureId.present ? captureId.value : this.captureId,
        summary: summary ?? this.summary,
        suggestedDishIdsJson: suggestedDishIdsJson ?? this.suggestedDishIdsJson,
        confidenceLabel: confidenceLabel ?? this.confidenceLabel,
        imageRef: imageRef.present ? imageRef.value : this.imageRef,
      );
  ReviewItemRow copyWithCompanion(ReviewItemsCompanion data) {
    return ReviewItemRow(
      id: data.id.present ? data.id.value : this.id,
      captureId: data.captureId.present ? data.captureId.value : this.captureId,
      summary: data.summary.present ? data.summary.value : this.summary,
      suggestedDishIdsJson: data.suggestedDishIdsJson.present
          ? data.suggestedDishIdsJson.value
          : this.suggestedDishIdsJson,
      confidenceLabel: data.confidenceLabel.present
          ? data.confidenceLabel.value
          : this.confidenceLabel,
      imageRef: data.imageRef.present ? data.imageRef.value : this.imageRef,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewItemRow(')
          ..write('id: $id, ')
          ..write('captureId: $captureId, ')
          ..write('summary: $summary, ')
          ..write('suggestedDishIdsJson: $suggestedDishIdsJson, ')
          ..write('confidenceLabel: $confidenceLabel, ')
          ..write('imageRef: $imageRef')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, captureId, summary, suggestedDishIdsJson, confidenceLabel, imageRef);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewItemRow &&
          other.id == this.id &&
          other.captureId == this.captureId &&
          other.summary == this.summary &&
          other.suggestedDishIdsJson == this.suggestedDishIdsJson &&
          other.confidenceLabel == this.confidenceLabel &&
          other.imageRef == this.imageRef);
}

class ReviewItemsCompanion extends UpdateCompanion<ReviewItemRow> {
  final Value<String> id;
  final Value<String?> captureId;
  final Value<String> summary;
  final Value<String> suggestedDishIdsJson;
  final Value<String> confidenceLabel;
  final Value<String?> imageRef;
  final Value<int> rowid;
  const ReviewItemsCompanion({
    this.id = const Value.absent(),
    this.captureId = const Value.absent(),
    this.summary = const Value.absent(),
    this.suggestedDishIdsJson = const Value.absent(),
    this.confidenceLabel = const Value.absent(),
    this.imageRef = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReviewItemsCompanion.insert({
    required String id,
    this.captureId = const Value.absent(),
    required String summary,
    required String suggestedDishIdsJson,
    required String confidenceLabel,
    this.imageRef = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        summary = Value(summary),
        suggestedDishIdsJson = Value(suggestedDishIdsJson),
        confidenceLabel = Value(confidenceLabel);
  static Insertable<ReviewItemRow> custom({
    Expression<String>? id,
    Expression<String>? captureId,
    Expression<String>? summary,
    Expression<String>? suggestedDishIdsJson,
    Expression<String>? confidenceLabel,
    Expression<String>? imageRef,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (captureId != null) 'capture_id': captureId,
      if (summary != null) 'summary': summary,
      if (suggestedDishIdsJson != null)
        'suggested_dish_ids_json': suggestedDishIdsJson,
      if (confidenceLabel != null) 'confidence_label': confidenceLabel,
      if (imageRef != null) 'image_ref': imageRef,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReviewItemsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? captureId,
      Value<String>? summary,
      Value<String>? suggestedDishIdsJson,
      Value<String>? confidenceLabel,
      Value<String?>? imageRef,
      Value<int>? rowid}) {
    return ReviewItemsCompanion(
      id: id ?? this.id,
      captureId: captureId ?? this.captureId,
      summary: summary ?? this.summary,
      suggestedDishIdsJson: suggestedDishIdsJson ?? this.suggestedDishIdsJson,
      confidenceLabel: confidenceLabel ?? this.confidenceLabel,
      imageRef: imageRef ?? this.imageRef,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (captureId.present) {
      map['capture_id'] = Variable<String>(captureId.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (suggestedDishIdsJson.present) {
      map['suggested_dish_ids_json'] =
          Variable<String>(suggestedDishIdsJson.value);
    }
    if (confidenceLabel.present) {
      map['confidence_label'] = Variable<String>(confidenceLabel.value);
    }
    if (imageRef.present) {
      map['image_ref'] = Variable<String>(imageRef.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewItemsCompanion(')
          ..write('id: $id, ')
          ..write('captureId: $captureId, ')
          ..write('summary: $summary, ')
          ..write('suggestedDishIdsJson: $suggestedDishIdsJson, ')
          ..write('confidenceLabel: $confidenceLabel, ')
          ..write('imageRef: $imageRef, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOperationsTable extends SyncOperations
    with TableInfo<$SyncOperationsTable, SyncOperationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
      'entity', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operationTypeMeta =
      const VerificationMeta('operationType');
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
      'operation_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entity,
        entityId,
        operationType,
        payloadJson,
        createdAt,
        completedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_operations';
  @override
  VerificationContext validateIntegrity(Insertable<SyncOperationRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(_entityMeta,
          entity.isAcceptableOrUnknown(data['entity']!, _entityMeta));
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation_type')) {
      context.handle(
          _operationTypeMeta,
          operationType.isAcceptableOrUnknown(
              data['operation_type']!, _operationTypeMeta));
    } else if (isInserting) {
      context.missing(_operationTypeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncOperationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOperationRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      operationType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation_type'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
    );
  }

  @override
  $SyncOperationsTable createAlias(String alias) {
    return $SyncOperationsTable(attachedDatabase, alias);
  }
}

class SyncOperationRow extends DataClass
    implements Insertable<SyncOperationRow> {
  final String id;
  final String entity;
  final String entityId;
  final String operationType;
  final String payloadJson;
  final DateTime createdAt;
  final DateTime? completedAt;
  const SyncOperationRow(
      {required this.id,
      required this.entity,
      required this.entityId,
      required this.operationType,
      required this.payloadJson,
      required this.createdAt,
      this.completedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    map['operation_type'] = Variable<String>(operationType);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  SyncOperationsCompanion toCompanion(bool nullToAbsent) {
    return SyncOperationsCompanion(
      id: Value(id),
      entity: Value(entity),
      entityId: Value(entityId),
      operationType: Value(operationType),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory SyncOperationRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOperationRow(
      id: serializer.fromJson<String>(json['id']),
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operationType: serializer.fromJson<String>(json['operationType']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String>(entityId),
      'operationType': serializer.toJson<String>(operationType),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  SyncOperationRow copyWith(
          {String? id,
          String? entity,
          String? entityId,
          String? operationType,
          String? payloadJson,
          DateTime? createdAt,
          Value<DateTime?> completedAt = const Value.absent()}) =>
      SyncOperationRow(
        id: id ?? this.id,
        entity: entity ?? this.entity,
        entityId: entityId ?? this.entityId,
        operationType: operationType ?? this.operationType,
        payloadJson: payloadJson ?? this.payloadJson,
        createdAt: createdAt ?? this.createdAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
      );
  SyncOperationRow copyWithCompanion(SyncOperationsCompanion data) {
    return SyncOperationRow(
      id: data.id.present ? data.id.value : this.id,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOperationRow(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('operationType: $operationType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, entity, entityId, operationType, payloadJson, createdAt, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOperationRow &&
          other.id == this.id &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.operationType == this.operationType &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt);
}

class SyncOperationsCompanion extends UpdateCompanion<SyncOperationRow> {
  final Value<String> id;
  final Value<String> entity;
  final Value<String> entityId;
  final Value<String> operationType;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const SyncOperationsCompanion({
    this.id = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operationType = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOperationsCompanion.insert({
    required String id,
    required String entity,
    required String entityId,
    required String operationType,
    required String payloadJson,
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entity = Value(entity),
        entityId = Value(entityId),
        operationType = Value(operationType),
        payloadJson = Value(payloadJson),
        createdAt = Value(createdAt);
  static Insertable<SyncOperationRow> custom({
    Expression<String>? id,
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? operationType,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (operationType != null) 'operation_type': operationType,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOperationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? entity,
      Value<String>? entityId,
      Value<String>? operationType,
      Value<String>? payloadJson,
      Value<DateTime>? createdAt,
      Value<DateTime?>? completedAt,
      Value<int>? rowid}) {
    return SyncOperationsCompanion(
      id: id ?? this.id,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      operationType: operationType ?? this.operationType,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOperationsCompanion(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('operationType: $operationType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTable extends SyncMetadata
    with TableInfo<$SyncMetadataTable, SyncMetadataRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata';
  @override
  VerificationContext validateIntegrity(Insertable<SyncMetadataRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncMetadataRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadataRow(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SyncMetadataTable createAlias(String alias) {
    return $SyncMetadataTable(attachedDatabase, alias);
  }
}

class SyncMetadataRow extends DataClass implements Insertable<SyncMetadataRow> {
  final String key;
  final String value;
  const SyncMetadataRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SyncMetadataCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory SyncMetadataRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadataRow(
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

  SyncMetadataRow copyWith({String? key, String? value}) => SyncMetadataRow(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  SyncMetadataRow copyWithCompanion(SyncMetadataCompanion data) {
    return SyncMetadataRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataRow(')
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
      (other is SyncMetadataRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SyncMetadataCompanion extends UpdateCompanion<SyncMetadataRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SyncMetadataCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetadataCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<SyncMetadataRow> custom({
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

  SyncMetadataCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SyncMetadataCompanion(
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
    return (StringBuffer('SyncMetadataCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSettingsTable extends LocalSettings
    with TableInfo<$LocalSettingsTable, LocalSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_settings';
  @override
  VerificationContext validateIntegrity(Insertable<LocalSettingRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  LocalSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSettingRow(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $LocalSettingsTable createAlias(String alias) {
    return $LocalSettingsTable(attachedDatabase, alias);
  }
}

class LocalSettingRow extends DataClass implements Insertable<LocalSettingRow> {
  final String key;
  final String value;
  const LocalSettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  LocalSettingsCompanion toCompanion(bool nullToAbsent) {
    return LocalSettingsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory LocalSettingRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSettingRow(
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

  LocalSettingRow copyWith({String? key, String? value}) => LocalSettingRow(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  LocalSettingRow copyWithCompanion(LocalSettingsCompanion data) {
    return LocalSettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSettingRow(')
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
      (other is LocalSettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class LocalSettingsCompanion extends UpdateCompanion<LocalSettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const LocalSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<LocalSettingRow> custom({
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

  LocalSettingsCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return LocalSettingsCompanion(
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
    return (StringBuffer('LocalSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiJobsTable extends AiJobs with TableInfo<$AiJobsTable, AiJobRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _jobTypeMeta =
      const VerificationMeta('jobType');
  @override
  late final GeneratedColumn<String> jobType = GeneratedColumn<String>(
      'job_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subjectIdMeta =
      const VerificationMeta('subjectId');
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
      'subject_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idempotencyKeyMeta =
      const VerificationMeta('idempotencyKey');
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
      'idempotency_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _inputHashMeta =
      const VerificationMeta('inputHash');
  @override
  late final GeneratedColumn<String> inputHash = GeneratedColumn<String>(
      'input_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _inputVersionMeta =
      const VerificationMeta('inputVersion');
  @override
  late final GeneratedColumn<String> inputVersion = GeneratedColumn<String>(
      'input_version', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _attemptCountMeta =
      const VerificationMeta('attemptCount');
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
      'attempt_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _maxAttemptsMeta =
      const VerificationMeta('maxAttempts');
  @override
  late final GeneratedColumn<int> maxAttempts = GeneratedColumn<int>(
      'max_attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _nextRetryAtMeta =
      const VerificationMeta('nextRetryAt');
  @override
  late final GeneratedColumn<DateTime> nextRetryAt = GeneratedColumn<DateTime>(
      'next_retry_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _promptVersionMeta =
      const VerificationMeta('promptVersion');
  @override
  late final GeneratedColumn<String> promptVersion = GeneratedColumn<String>(
      'prompt_version', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('1'));
  static const VerificationMeta _modelVersionMeta =
      const VerificationMeta('modelVersion');
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
      'model_version', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('default'));
  static const VerificationMeta _schemaVersionMeta =
      const VerificationMeta('schemaVersion');
  @override
  late final GeneratedColumn<String> schemaVersion = GeneratedColumn<String>(
      'schema_version', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('1'));
  static const VerificationMeta _resultJsonMeta =
      const VerificationMeta('resultJson');
  @override
  late final GeneratedColumn<String> resultJson = GeneratedColumn<String>(
      'result_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _errorJsonMeta =
      const VerificationMeta('errorJson');
  @override
  late final GeneratedColumn<String> errorJson = GeneratedColumn<String>(
      'error_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pendingActionMeta =
      const VerificationMeta('pendingAction');
  @override
  late final GeneratedColumn<String> pendingAction = GeneratedColumn<String>(
      'pending_action', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dismissedAtMeta =
      const VerificationMeta('dismissedAt');
  @override
  late final GeneratedColumn<DateTime> dismissedAt = GeneratedColumn<DateTime>(
      'dismissed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        jobType,
        subjectId,
        status,
        idempotencyKey,
        inputHash,
        inputVersion,
        attemptCount,
        maxAttempts,
        nextRetryAt,
        promptVersion,
        modelVersion,
        schemaVersion,
        resultJson,
        errorJson,
        pendingAction,
        startedAt,
        completedAt,
        dismissedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_jobs';
  @override
  VerificationContext validateIntegrity(Insertable<AiJobRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('job_type')) {
      context.handle(_jobTypeMeta,
          jobType.isAcceptableOrUnknown(data['job_type']!, _jobTypeMeta));
    } else if (isInserting) {
      context.missing(_jobTypeMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(_subjectIdMeta,
          subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta));
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
          _idempotencyKeyMeta,
          idempotencyKey.isAcceptableOrUnknown(
              data['idempotency_key']!, _idempotencyKeyMeta));
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('input_hash')) {
      context.handle(_inputHashMeta,
          inputHash.isAcceptableOrUnknown(data['input_hash']!, _inputHashMeta));
    } else if (isInserting) {
      context.missing(_inputHashMeta);
    }
    if (data.containsKey('input_version')) {
      context.handle(
          _inputVersionMeta,
          inputVersion.isAcceptableOrUnknown(
              data['input_version']!, _inputVersionMeta));
    } else if (isInserting) {
      context.missing(_inputVersionMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
          _attemptCountMeta,
          attemptCount.isAcceptableOrUnknown(
              data['attempt_count']!, _attemptCountMeta));
    }
    if (data.containsKey('max_attempts')) {
      context.handle(
          _maxAttemptsMeta,
          maxAttempts.isAcceptableOrUnknown(
              data['max_attempts']!, _maxAttemptsMeta));
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
          _nextRetryAtMeta,
          nextRetryAt.isAcceptableOrUnknown(
              data['next_retry_at']!, _nextRetryAtMeta));
    }
    if (data.containsKey('prompt_version')) {
      context.handle(
          _promptVersionMeta,
          promptVersion.isAcceptableOrUnknown(
              data['prompt_version']!, _promptVersionMeta));
    }
    if (data.containsKey('model_version')) {
      context.handle(
          _modelVersionMeta,
          modelVersion.isAcceptableOrUnknown(
              data['model_version']!, _modelVersionMeta));
    }
    if (data.containsKey('schema_version')) {
      context.handle(
          _schemaVersionMeta,
          schemaVersion.isAcceptableOrUnknown(
              data['schema_version']!, _schemaVersionMeta));
    }
    if (data.containsKey('result_json')) {
      context.handle(
          _resultJsonMeta,
          resultJson.isAcceptableOrUnknown(
              data['result_json']!, _resultJsonMeta));
    }
    if (data.containsKey('error_json')) {
      context.handle(_errorJsonMeta,
          errorJson.isAcceptableOrUnknown(data['error_json']!, _errorJsonMeta));
    }
    if (data.containsKey('pending_action')) {
      context.handle(
          _pendingActionMeta,
          pendingAction.isAcceptableOrUnknown(
              data['pending_action']!, _pendingActionMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('dismissed_at')) {
      context.handle(
          _dismissedAtMeta,
          dismissedAt.isAcceptableOrUnknown(
              data['dismissed_at']!, _dismissedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {idempotencyKey},
      ];
  @override
  AiJobRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiJobRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      jobType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}job_type'])!,
      subjectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject_id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      idempotencyKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}idempotency_key'])!,
      inputHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}input_hash'])!,
      inputVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}input_version'])!,
      attemptCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempt_count'])!,
      maxAttempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_attempts'])!,
      nextRetryAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}next_retry_at']),
      promptVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prompt_version'])!,
      modelVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model_version'])!,
      schemaVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}schema_version'])!,
      resultJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}result_json']),
      errorJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_json']),
      pendingAction: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pending_action']),
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at']),
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      dismissedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}dismissed_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AiJobsTable createAlias(String alias) {
    return $AiJobsTable(attachedDatabase, alias);
  }
}

class AiJobRow extends DataClass implements Insertable<AiJobRow> {
  final String id;
  final String jobType;
  final String subjectId;
  final String status;
  final String idempotencyKey;
  final String inputHash;
  final String inputVersion;
  final int attemptCount;
  final int maxAttempts;
  final DateTime? nextRetryAt;
  final String promptVersion;
  final String modelVersion;
  final String schemaVersion;
  final String? resultJson;
  final String? errorJson;
  final String? pendingAction;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? dismissedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AiJobRow(
      {required this.id,
      required this.jobType,
      required this.subjectId,
      required this.status,
      required this.idempotencyKey,
      required this.inputHash,
      required this.inputVersion,
      required this.attemptCount,
      required this.maxAttempts,
      this.nextRetryAt,
      required this.promptVersion,
      required this.modelVersion,
      required this.schemaVersion,
      this.resultJson,
      this.errorJson,
      this.pendingAction,
      this.startedAt,
      this.completedAt,
      this.dismissedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['job_type'] = Variable<String>(jobType);
    map['subject_id'] = Variable<String>(subjectId);
    map['status'] = Variable<String>(status);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['input_hash'] = Variable<String>(inputHash);
    map['input_version'] = Variable<String>(inputVersion);
    map['attempt_count'] = Variable<int>(attemptCount);
    map['max_attempts'] = Variable<int>(maxAttempts);
    if (!nullToAbsent || nextRetryAt != null) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt);
    }
    map['prompt_version'] = Variable<String>(promptVersion);
    map['model_version'] = Variable<String>(modelVersion);
    map['schema_version'] = Variable<String>(schemaVersion);
    if (!nullToAbsent || resultJson != null) {
      map['result_json'] = Variable<String>(resultJson);
    }
    if (!nullToAbsent || errorJson != null) {
      map['error_json'] = Variable<String>(errorJson);
    }
    if (!nullToAbsent || pendingAction != null) {
      map['pending_action'] = Variable<String>(pendingAction);
    }
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || dismissedAt != null) {
      map['dismissed_at'] = Variable<DateTime>(dismissedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AiJobsCompanion toCompanion(bool nullToAbsent) {
    return AiJobsCompanion(
      id: Value(id),
      jobType: Value(jobType),
      subjectId: Value(subjectId),
      status: Value(status),
      idempotencyKey: Value(idempotencyKey),
      inputHash: Value(inputHash),
      inputVersion: Value(inputVersion),
      attemptCount: Value(attemptCount),
      maxAttempts: Value(maxAttempts),
      nextRetryAt: nextRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAt),
      promptVersion: Value(promptVersion),
      modelVersion: Value(modelVersion),
      schemaVersion: Value(schemaVersion),
      resultJson: resultJson == null && nullToAbsent
          ? const Value.absent()
          : Value(resultJson),
      errorJson: errorJson == null && nullToAbsent
          ? const Value.absent()
          : Value(errorJson),
      pendingAction: pendingAction == null && nullToAbsent
          ? const Value.absent()
          : Value(pendingAction),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      dismissedAt: dismissedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dismissedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AiJobRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiJobRow(
      id: serializer.fromJson<String>(json['id']),
      jobType: serializer.fromJson<String>(json['jobType']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      status: serializer.fromJson<String>(json['status']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      inputHash: serializer.fromJson<String>(json['inputHash']),
      inputVersion: serializer.fromJson<String>(json['inputVersion']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      maxAttempts: serializer.fromJson<int>(json['maxAttempts']),
      nextRetryAt: serializer.fromJson<DateTime?>(json['nextRetryAt']),
      promptVersion: serializer.fromJson<String>(json['promptVersion']),
      modelVersion: serializer.fromJson<String>(json['modelVersion']),
      schemaVersion: serializer.fromJson<String>(json['schemaVersion']),
      resultJson: serializer.fromJson<String?>(json['resultJson']),
      errorJson: serializer.fromJson<String?>(json['errorJson']),
      pendingAction: serializer.fromJson<String?>(json['pendingAction']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      dismissedAt: serializer.fromJson<DateTime?>(json['dismissedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'jobType': serializer.toJson<String>(jobType),
      'subjectId': serializer.toJson<String>(subjectId),
      'status': serializer.toJson<String>(status),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'inputHash': serializer.toJson<String>(inputHash),
      'inputVersion': serializer.toJson<String>(inputVersion),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'maxAttempts': serializer.toJson<int>(maxAttempts),
      'nextRetryAt': serializer.toJson<DateTime?>(nextRetryAt),
      'promptVersion': serializer.toJson<String>(promptVersion),
      'modelVersion': serializer.toJson<String>(modelVersion),
      'schemaVersion': serializer.toJson<String>(schemaVersion),
      'resultJson': serializer.toJson<String?>(resultJson),
      'errorJson': serializer.toJson<String?>(errorJson),
      'pendingAction': serializer.toJson<String?>(pendingAction),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'dismissedAt': serializer.toJson<DateTime?>(dismissedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AiJobRow copyWith(
          {String? id,
          String? jobType,
          String? subjectId,
          String? status,
          String? idempotencyKey,
          String? inputHash,
          String? inputVersion,
          int? attemptCount,
          int? maxAttempts,
          Value<DateTime?> nextRetryAt = const Value.absent(),
          String? promptVersion,
          String? modelVersion,
          String? schemaVersion,
          Value<String?> resultJson = const Value.absent(),
          Value<String?> errorJson = const Value.absent(),
          Value<String?> pendingAction = const Value.absent(),
          Value<DateTime?> startedAt = const Value.absent(),
          Value<DateTime?> completedAt = const Value.absent(),
          Value<DateTime?> dismissedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      AiJobRow(
        id: id ?? this.id,
        jobType: jobType ?? this.jobType,
        subjectId: subjectId ?? this.subjectId,
        status: status ?? this.status,
        idempotencyKey: idempotencyKey ?? this.idempotencyKey,
        inputHash: inputHash ?? this.inputHash,
        inputVersion: inputVersion ?? this.inputVersion,
        attemptCount: attemptCount ?? this.attemptCount,
        maxAttempts: maxAttempts ?? this.maxAttempts,
        nextRetryAt: nextRetryAt.present ? nextRetryAt.value : this.nextRetryAt,
        promptVersion: promptVersion ?? this.promptVersion,
        modelVersion: modelVersion ?? this.modelVersion,
        schemaVersion: schemaVersion ?? this.schemaVersion,
        resultJson: resultJson.present ? resultJson.value : this.resultJson,
        errorJson: errorJson.present ? errorJson.value : this.errorJson,
        pendingAction:
            pendingAction.present ? pendingAction.value : this.pendingAction,
        startedAt: startedAt.present ? startedAt.value : this.startedAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        dismissedAt: dismissedAt.present ? dismissedAt.value : this.dismissedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AiJobRow copyWithCompanion(AiJobsCompanion data) {
    return AiJobRow(
      id: data.id.present ? data.id.value : this.id,
      jobType: data.jobType.present ? data.jobType.value : this.jobType,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      status: data.status.present ? data.status.value : this.status,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      inputHash: data.inputHash.present ? data.inputHash.value : this.inputHash,
      inputVersion: data.inputVersion.present
          ? data.inputVersion.value
          : this.inputVersion,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      maxAttempts:
          data.maxAttempts.present ? data.maxAttempts.value : this.maxAttempts,
      nextRetryAt:
          data.nextRetryAt.present ? data.nextRetryAt.value : this.nextRetryAt,
      promptVersion: data.promptVersion.present
          ? data.promptVersion.value
          : this.promptVersion,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      resultJson:
          data.resultJson.present ? data.resultJson.value : this.resultJson,
      errorJson: data.errorJson.present ? data.errorJson.value : this.errorJson,
      pendingAction: data.pendingAction.present
          ? data.pendingAction.value
          : this.pendingAction,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      dismissedAt:
          data.dismissedAt.present ? data.dismissedAt.value : this.dismissedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiJobRow(')
          ..write('id: $id, ')
          ..write('jobType: $jobType, ')
          ..write('subjectId: $subjectId, ')
          ..write('status: $status, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('inputHash: $inputHash, ')
          ..write('inputVersion: $inputVersion, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('maxAttempts: $maxAttempts, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('promptVersion: $promptVersion, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('resultJson: $resultJson, ')
          ..write('errorJson: $errorJson, ')
          ..write('pendingAction: $pendingAction, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('dismissedAt: $dismissedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        jobType,
        subjectId,
        status,
        idempotencyKey,
        inputHash,
        inputVersion,
        attemptCount,
        maxAttempts,
        nextRetryAt,
        promptVersion,
        modelVersion,
        schemaVersion,
        resultJson,
        errorJson,
        pendingAction,
        startedAt,
        completedAt,
        dismissedAt,
        createdAt,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiJobRow &&
          other.id == this.id &&
          other.jobType == this.jobType &&
          other.subjectId == this.subjectId &&
          other.status == this.status &&
          other.idempotencyKey == this.idempotencyKey &&
          other.inputHash == this.inputHash &&
          other.inputVersion == this.inputVersion &&
          other.attemptCount == this.attemptCount &&
          other.maxAttempts == this.maxAttempts &&
          other.nextRetryAt == this.nextRetryAt &&
          other.promptVersion == this.promptVersion &&
          other.modelVersion == this.modelVersion &&
          other.schemaVersion == this.schemaVersion &&
          other.resultJson == this.resultJson &&
          other.errorJson == this.errorJson &&
          other.pendingAction == this.pendingAction &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.dismissedAt == this.dismissedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AiJobsCompanion extends UpdateCompanion<AiJobRow> {
  final Value<String> id;
  final Value<String> jobType;
  final Value<String> subjectId;
  final Value<String> status;
  final Value<String> idempotencyKey;
  final Value<String> inputHash;
  final Value<String> inputVersion;
  final Value<int> attemptCount;
  final Value<int> maxAttempts;
  final Value<DateTime?> nextRetryAt;
  final Value<String> promptVersion;
  final Value<String> modelVersion;
  final Value<String> schemaVersion;
  final Value<String?> resultJson;
  final Value<String?> errorJson;
  final Value<String?> pendingAction;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> completedAt;
  final Value<DateTime?> dismissedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AiJobsCompanion({
    this.id = const Value.absent(),
    this.jobType = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.status = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.inputHash = const Value.absent(),
    this.inputVersion = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.maxAttempts = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.promptVersion = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.resultJson = const Value.absent(),
    this.errorJson = const Value.absent(),
    this.pendingAction = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.dismissedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiJobsCompanion.insert({
    required String id,
    required String jobType,
    required String subjectId,
    required String status,
    required String idempotencyKey,
    required String inputHash,
    required String inputVersion,
    this.attemptCount = const Value.absent(),
    this.maxAttempts = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.promptVersion = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.resultJson = const Value.absent(),
    this.errorJson = const Value.absent(),
    this.pendingAction = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.dismissedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        jobType = Value(jobType),
        subjectId = Value(subjectId),
        status = Value(status),
        idempotencyKey = Value(idempotencyKey),
        inputHash = Value(inputHash),
        inputVersion = Value(inputVersion),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<AiJobRow> custom({
    Expression<String>? id,
    Expression<String>? jobType,
    Expression<String>? subjectId,
    Expression<String>? status,
    Expression<String>? idempotencyKey,
    Expression<String>? inputHash,
    Expression<String>? inputVersion,
    Expression<int>? attemptCount,
    Expression<int>? maxAttempts,
    Expression<DateTime>? nextRetryAt,
    Expression<String>? promptVersion,
    Expression<String>? modelVersion,
    Expression<String>? schemaVersion,
    Expression<String>? resultJson,
    Expression<String>? errorJson,
    Expression<String>? pendingAction,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? dismissedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jobType != null) 'job_type': jobType,
      if (subjectId != null) 'subject_id': subjectId,
      if (status != null) 'status': status,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (inputHash != null) 'input_hash': inputHash,
      if (inputVersion != null) 'input_version': inputVersion,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (maxAttempts != null) 'max_attempts': maxAttempts,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (promptVersion != null) 'prompt_version': promptVersion,
      if (modelVersion != null) 'model_version': modelVersion,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (resultJson != null) 'result_json': resultJson,
      if (errorJson != null) 'error_json': errorJson,
      if (pendingAction != null) 'pending_action': pendingAction,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (dismissedAt != null) 'dismissed_at': dismissedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiJobsCompanion copyWith(
      {Value<String>? id,
      Value<String>? jobType,
      Value<String>? subjectId,
      Value<String>? status,
      Value<String>? idempotencyKey,
      Value<String>? inputHash,
      Value<String>? inputVersion,
      Value<int>? attemptCount,
      Value<int>? maxAttempts,
      Value<DateTime?>? nextRetryAt,
      Value<String>? promptVersion,
      Value<String>? modelVersion,
      Value<String>? schemaVersion,
      Value<String?>? resultJson,
      Value<String?>? errorJson,
      Value<String?>? pendingAction,
      Value<DateTime?>? startedAt,
      Value<DateTime?>? completedAt,
      Value<DateTime?>? dismissedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return AiJobsCompanion(
      id: id ?? this.id,
      jobType: jobType ?? this.jobType,
      subjectId: subjectId ?? this.subjectId,
      status: status ?? this.status,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      inputHash: inputHash ?? this.inputHash,
      inputVersion: inputVersion ?? this.inputVersion,
      attemptCount: attemptCount ?? this.attemptCount,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      promptVersion: promptVersion ?? this.promptVersion,
      modelVersion: modelVersion ?? this.modelVersion,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      resultJson: resultJson ?? this.resultJson,
      errorJson: errorJson ?? this.errorJson,
      pendingAction: pendingAction ?? this.pendingAction,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      dismissedAt: dismissedAt ?? this.dismissedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (jobType.present) {
      map['job_type'] = Variable<String>(jobType.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (inputHash.present) {
      map['input_hash'] = Variable<String>(inputHash.value);
    }
    if (inputVersion.present) {
      map['input_version'] = Variable<String>(inputVersion.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (maxAttempts.present) {
      map['max_attempts'] = Variable<int>(maxAttempts.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt.value);
    }
    if (promptVersion.present) {
      map['prompt_version'] = Variable<String>(promptVersion.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<String>(schemaVersion.value);
    }
    if (resultJson.present) {
      map['result_json'] = Variable<String>(resultJson.value);
    }
    if (errorJson.present) {
      map['error_json'] = Variable<String>(errorJson.value);
    }
    if (pendingAction.present) {
      map['pending_action'] = Variable<String>(pendingAction.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (dismissedAt.present) {
      map['dismissed_at'] = Variable<DateTime>(dismissedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiJobsCompanion(')
          ..write('id: $id, ')
          ..write('jobType: $jobType, ')
          ..write('subjectId: $subjectId, ')
          ..write('status: $status, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('inputHash: $inputHash, ')
          ..write('inputVersion: $inputVersion, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('maxAttempts: $maxAttempts, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('promptVersion: $promptVersion, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('resultJson: $resultJson, ')
          ..write('errorJson: $errorJson, ')
          ..write('pendingAction: $pendingAction, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('dismissedAt: $dismissedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProcessingOutboxTable extends ProcessingOutbox
    with TableInfo<$ProcessingOutboxTable, ProcessingOutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProcessingOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _requestKindMeta =
      const VerificationMeta('requestKind');
  @override
  late final GeneratedColumn<String> requestKind = GeneratedColumn<String>(
      'request_kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subjectIdMeta =
      const VerificationMeta('subjectId');
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
      'subject_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deliveryStateMeta =
      const VerificationMeta('deliveryState');
  @override
  late final GeneratedColumn<String> deliveryState = GeneratedColumn<String>(
      'delivery_state', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _adoptionStateMeta =
      const VerificationMeta('adoptionState');
  @override
  late final GeneratedColumn<String> adoptionState = GeneratedColumn<String>(
      'adoption_state', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _privacyNoticeVersionMeta =
      const VerificationMeta('privacyNoticeVersion');
  @override
  late final GeneratedColumn<String> privacyNoticeVersion =
      GeneratedColumn<String>('privacy_notice_version', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _idempotencyKeyMeta =
      const VerificationMeta('idempotencyKey');
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
      'idempotency_key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _serverJobIdMeta =
      const VerificationMeta('serverJobId');
  @override
  late final GeneratedColumn<String> serverJobId = GeneratedColumn<String>(
      'server_job_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _serverExpiresAtMeta =
      const VerificationMeta('serverExpiresAt');
  @override
  late final GeneratedColumn<DateTime> serverExpiresAt =
      GeneratedColumn<DateTime>('server_expires_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _uploadedAssetIdsJsonMeta =
      const VerificationMeta('uploadedAssetIdsJson');
  @override
  late final GeneratedColumn<String> uploadedAssetIdsJson =
      GeneratedColumn<String>('uploaded_asset_ids_json', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _resultPayloadJsonMeta =
      const VerificationMeta('resultPayloadJson');
  @override
  late final GeneratedColumn<String> resultPayloadJson =
      GeneratedColumn<String>('result_payload_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _resultSchemaVersionMeta =
      const VerificationMeta('resultSchemaVersion');
  @override
  late final GeneratedColumn<String> resultSchemaVersion =
      GeneratedColumn<String>('result_schema_version', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _attemptCountMeta =
      const VerificationMeta('attemptCount');
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
      'attempt_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _nextRetryAtMeta =
      const VerificationMeta('nextRetryAt');
  @override
  late final GeneratedColumn<DateTime> nextRetryAt = GeneratedColumn<DateTime>(
      'next_retry_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _failureCodeMeta =
      const VerificationMeta('failureCode');
  @override
  late final GeneratedColumn<String> failureCode = GeneratedColumn<String>(
      'failure_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        requestKind,
        subjectId,
        payloadJson,
        deliveryState,
        adoptionState,
        privacyNoticeVersion,
        idempotencyKey,
        serverJobId,
        serverExpiresAt,
        uploadedAssetIdsJson,
        resultPayloadJson,
        resultSchemaVersion,
        attemptCount,
        nextRetryAt,
        failureCode,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'processing_outbox';
  @override
  VerificationContext validateIntegrity(
      Insertable<ProcessingOutboxRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('request_kind')) {
      context.handle(
          _requestKindMeta,
          requestKind.isAcceptableOrUnknown(
              data['request_kind']!, _requestKindMeta));
    } else if (isInserting) {
      context.missing(_requestKindMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(_subjectIdMeta,
          subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta));
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('delivery_state')) {
      context.handle(
          _deliveryStateMeta,
          deliveryState.isAcceptableOrUnknown(
              data['delivery_state']!, _deliveryStateMeta));
    } else if (isInserting) {
      context.missing(_deliveryStateMeta);
    }
    if (data.containsKey('adoption_state')) {
      context.handle(
          _adoptionStateMeta,
          adoptionState.isAcceptableOrUnknown(
              data['adoption_state']!, _adoptionStateMeta));
    } else if (isInserting) {
      context.missing(_adoptionStateMeta);
    }
    if (data.containsKey('privacy_notice_version')) {
      context.handle(
          _privacyNoticeVersionMeta,
          privacyNoticeVersion.isAcceptableOrUnknown(
              data['privacy_notice_version']!, _privacyNoticeVersionMeta));
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
          _idempotencyKeyMeta,
          idempotencyKey.isAcceptableOrUnknown(
              data['idempotency_key']!, _idempotencyKeyMeta));
    }
    if (data.containsKey('server_job_id')) {
      context.handle(
          _serverJobIdMeta,
          serverJobId.isAcceptableOrUnknown(
              data['server_job_id']!, _serverJobIdMeta));
    }
    if (data.containsKey('server_expires_at')) {
      context.handle(
          _serverExpiresAtMeta,
          serverExpiresAt.isAcceptableOrUnknown(
              data['server_expires_at']!, _serverExpiresAtMeta));
    }
    if (data.containsKey('uploaded_asset_ids_json')) {
      context.handle(
          _uploadedAssetIdsJsonMeta,
          uploadedAssetIdsJson.isAcceptableOrUnknown(
              data['uploaded_asset_ids_json']!, _uploadedAssetIdsJsonMeta));
    }
    if (data.containsKey('result_payload_json')) {
      context.handle(
          _resultPayloadJsonMeta,
          resultPayloadJson.isAcceptableOrUnknown(
              data['result_payload_json']!, _resultPayloadJsonMeta));
    }
    if (data.containsKey('result_schema_version')) {
      context.handle(
          _resultSchemaVersionMeta,
          resultSchemaVersion.isAcceptableOrUnknown(
              data['result_schema_version']!, _resultSchemaVersionMeta));
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
          _attemptCountMeta,
          attemptCount.isAcceptableOrUnknown(
              data['attempt_count']!, _attemptCountMeta));
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
          _nextRetryAtMeta,
          nextRetryAt.isAcceptableOrUnknown(
              data['next_retry_at']!, _nextRetryAtMeta));
    }
    if (data.containsKey('failure_code')) {
      context.handle(
          _failureCodeMeta,
          failureCode.isAcceptableOrUnknown(
              data['failure_code']!, _failureCodeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {requestKind, subjectId},
      ];
  @override
  ProcessingOutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProcessingOutboxRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      requestKind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}request_kind'])!,
      subjectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject_id'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      deliveryState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}delivery_state'])!,
      adoptionState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}adoption_state'])!,
      privacyNoticeVersion: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}privacy_notice_version']),
      idempotencyKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}idempotency_key'])!,
      serverJobId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_job_id']),
      serverExpiresAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}server_expires_at']),
      uploadedAssetIdsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}uploaded_asset_ids_json'])!,
      resultPayloadJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}result_payload_json']),
      resultSchemaVersion: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}result_schema_version']),
      attemptCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempt_count'])!,
      nextRetryAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}next_retry_at']),
      failureCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}failure_code']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ProcessingOutboxTable createAlias(String alias) {
    return $ProcessingOutboxTable(attachedDatabase, alias);
  }
}

class ProcessingOutboxRow extends DataClass
    implements Insertable<ProcessingOutboxRow> {
  final String id;
  final String requestKind;
  final String subjectId;
  final String payloadJson;
  final String deliveryState;
  final String adoptionState;
  final String? privacyNoticeVersion;
  final String idempotencyKey;
  final String? serverJobId;
  final DateTime? serverExpiresAt;
  final String uploadedAssetIdsJson;
  final String? resultPayloadJson;
  final String? resultSchemaVersion;
  final int attemptCount;
  final DateTime? nextRetryAt;
  final String? failureCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ProcessingOutboxRow(
      {required this.id,
      required this.requestKind,
      required this.subjectId,
      required this.payloadJson,
      required this.deliveryState,
      required this.adoptionState,
      this.privacyNoticeVersion,
      required this.idempotencyKey,
      this.serverJobId,
      this.serverExpiresAt,
      required this.uploadedAssetIdsJson,
      this.resultPayloadJson,
      this.resultSchemaVersion,
      required this.attemptCount,
      this.nextRetryAt,
      this.failureCode,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['request_kind'] = Variable<String>(requestKind);
    map['subject_id'] = Variable<String>(subjectId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['delivery_state'] = Variable<String>(deliveryState);
    map['adoption_state'] = Variable<String>(adoptionState);
    if (!nullToAbsent || privacyNoticeVersion != null) {
      map['privacy_notice_version'] = Variable<String>(privacyNoticeVersion);
    }
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    if (!nullToAbsent || serverJobId != null) {
      map['server_job_id'] = Variable<String>(serverJobId);
    }
    if (!nullToAbsent || serverExpiresAt != null) {
      map['server_expires_at'] = Variable<DateTime>(serverExpiresAt);
    }
    map['uploaded_asset_ids_json'] = Variable<String>(uploadedAssetIdsJson);
    if (!nullToAbsent || resultPayloadJson != null) {
      map['result_payload_json'] = Variable<String>(resultPayloadJson);
    }
    if (!nullToAbsent || resultSchemaVersion != null) {
      map['result_schema_version'] = Variable<String>(resultSchemaVersion);
    }
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || nextRetryAt != null) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt);
    }
    if (!nullToAbsent || failureCode != null) {
      map['failure_code'] = Variable<String>(failureCode);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProcessingOutboxCompanion toCompanion(bool nullToAbsent) {
    return ProcessingOutboxCompanion(
      id: Value(id),
      requestKind: Value(requestKind),
      subjectId: Value(subjectId),
      payloadJson: Value(payloadJson),
      deliveryState: Value(deliveryState),
      adoptionState: Value(adoptionState),
      privacyNoticeVersion: privacyNoticeVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(privacyNoticeVersion),
      idempotencyKey: Value(idempotencyKey),
      serverJobId: serverJobId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverJobId),
      serverExpiresAt: serverExpiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverExpiresAt),
      uploadedAssetIdsJson: Value(uploadedAssetIdsJson),
      resultPayloadJson: resultPayloadJson == null && nullToAbsent
          ? const Value.absent()
          : Value(resultPayloadJson),
      resultSchemaVersion: resultSchemaVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(resultSchemaVersion),
      attemptCount: Value(attemptCount),
      nextRetryAt: nextRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAt),
      failureCode: failureCode == null && nullToAbsent
          ? const Value.absent()
          : Value(failureCode),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProcessingOutboxRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProcessingOutboxRow(
      id: serializer.fromJson<String>(json['id']),
      requestKind: serializer.fromJson<String>(json['requestKind']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      deliveryState: serializer.fromJson<String>(json['deliveryState']),
      adoptionState: serializer.fromJson<String>(json['adoptionState']),
      privacyNoticeVersion:
          serializer.fromJson<String?>(json['privacyNoticeVersion']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      serverJobId: serializer.fromJson<String?>(json['serverJobId']),
      serverExpiresAt: serializer.fromJson<DateTime?>(json['serverExpiresAt']),
      uploadedAssetIdsJson:
          serializer.fromJson<String>(json['uploadedAssetIdsJson']),
      resultPayloadJson:
          serializer.fromJson<String?>(json['resultPayloadJson']),
      resultSchemaVersion:
          serializer.fromJson<String?>(json['resultSchemaVersion']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      nextRetryAt: serializer.fromJson<DateTime?>(json['nextRetryAt']),
      failureCode: serializer.fromJson<String?>(json['failureCode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'requestKind': serializer.toJson<String>(requestKind),
      'subjectId': serializer.toJson<String>(subjectId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'deliveryState': serializer.toJson<String>(deliveryState),
      'adoptionState': serializer.toJson<String>(adoptionState),
      'privacyNoticeVersion': serializer.toJson<String?>(privacyNoticeVersion),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'serverJobId': serializer.toJson<String?>(serverJobId),
      'serverExpiresAt': serializer.toJson<DateTime?>(serverExpiresAt),
      'uploadedAssetIdsJson': serializer.toJson<String>(uploadedAssetIdsJson),
      'resultPayloadJson': serializer.toJson<String?>(resultPayloadJson),
      'resultSchemaVersion': serializer.toJson<String?>(resultSchemaVersion),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'nextRetryAt': serializer.toJson<DateTime?>(nextRetryAt),
      'failureCode': serializer.toJson<String?>(failureCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProcessingOutboxRow copyWith(
          {String? id,
          String? requestKind,
          String? subjectId,
          String? payloadJson,
          String? deliveryState,
          String? adoptionState,
          Value<String?> privacyNoticeVersion = const Value.absent(),
          String? idempotencyKey,
          Value<String?> serverJobId = const Value.absent(),
          Value<DateTime?> serverExpiresAt = const Value.absent(),
          String? uploadedAssetIdsJson,
          Value<String?> resultPayloadJson = const Value.absent(),
          Value<String?> resultSchemaVersion = const Value.absent(),
          int? attemptCount,
          Value<DateTime?> nextRetryAt = const Value.absent(),
          Value<String?> failureCode = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ProcessingOutboxRow(
        id: id ?? this.id,
        requestKind: requestKind ?? this.requestKind,
        subjectId: subjectId ?? this.subjectId,
        payloadJson: payloadJson ?? this.payloadJson,
        deliveryState: deliveryState ?? this.deliveryState,
        adoptionState: adoptionState ?? this.adoptionState,
        privacyNoticeVersion: privacyNoticeVersion.present
            ? privacyNoticeVersion.value
            : this.privacyNoticeVersion,
        idempotencyKey: idempotencyKey ?? this.idempotencyKey,
        serverJobId: serverJobId.present ? serverJobId.value : this.serverJobId,
        serverExpiresAt: serverExpiresAt.present
            ? serverExpiresAt.value
            : this.serverExpiresAt,
        uploadedAssetIdsJson: uploadedAssetIdsJson ?? this.uploadedAssetIdsJson,
        resultPayloadJson: resultPayloadJson.present
            ? resultPayloadJson.value
            : this.resultPayloadJson,
        resultSchemaVersion: resultSchemaVersion.present
            ? resultSchemaVersion.value
            : this.resultSchemaVersion,
        attemptCount: attemptCount ?? this.attemptCount,
        nextRetryAt: nextRetryAt.present ? nextRetryAt.value : this.nextRetryAt,
        failureCode: failureCode.present ? failureCode.value : this.failureCode,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ProcessingOutboxRow copyWithCompanion(ProcessingOutboxCompanion data) {
    return ProcessingOutboxRow(
      id: data.id.present ? data.id.value : this.id,
      requestKind:
          data.requestKind.present ? data.requestKind.value : this.requestKind,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      deliveryState: data.deliveryState.present
          ? data.deliveryState.value
          : this.deliveryState,
      adoptionState: data.adoptionState.present
          ? data.adoptionState.value
          : this.adoptionState,
      privacyNoticeVersion: data.privacyNoticeVersion.present
          ? data.privacyNoticeVersion.value
          : this.privacyNoticeVersion,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      serverJobId:
          data.serverJobId.present ? data.serverJobId.value : this.serverJobId,
      serverExpiresAt: data.serverExpiresAt.present
          ? data.serverExpiresAt.value
          : this.serverExpiresAt,
      uploadedAssetIdsJson: data.uploadedAssetIdsJson.present
          ? data.uploadedAssetIdsJson.value
          : this.uploadedAssetIdsJson,
      resultPayloadJson: data.resultPayloadJson.present
          ? data.resultPayloadJson.value
          : this.resultPayloadJson,
      resultSchemaVersion: data.resultSchemaVersion.present
          ? data.resultSchemaVersion.value
          : this.resultSchemaVersion,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      nextRetryAt:
          data.nextRetryAt.present ? data.nextRetryAt.value : this.nextRetryAt,
      failureCode:
          data.failureCode.present ? data.failureCode.value : this.failureCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProcessingOutboxRow(')
          ..write('id: $id, ')
          ..write('requestKind: $requestKind, ')
          ..write('subjectId: $subjectId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('deliveryState: $deliveryState, ')
          ..write('adoptionState: $adoptionState, ')
          ..write('privacyNoticeVersion: $privacyNoticeVersion, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('serverJobId: $serverJobId, ')
          ..write('serverExpiresAt: $serverExpiresAt, ')
          ..write('uploadedAssetIdsJson: $uploadedAssetIdsJson, ')
          ..write('resultPayloadJson: $resultPayloadJson, ')
          ..write('resultSchemaVersion: $resultSchemaVersion, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('failureCode: $failureCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      requestKind,
      subjectId,
      payloadJson,
      deliveryState,
      adoptionState,
      privacyNoticeVersion,
      idempotencyKey,
      serverJobId,
      serverExpiresAt,
      uploadedAssetIdsJson,
      resultPayloadJson,
      resultSchemaVersion,
      attemptCount,
      nextRetryAt,
      failureCode,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProcessingOutboxRow &&
          other.id == this.id &&
          other.requestKind == this.requestKind &&
          other.subjectId == this.subjectId &&
          other.payloadJson == this.payloadJson &&
          other.deliveryState == this.deliveryState &&
          other.adoptionState == this.adoptionState &&
          other.privacyNoticeVersion == this.privacyNoticeVersion &&
          other.idempotencyKey == this.idempotencyKey &&
          other.serverJobId == this.serverJobId &&
          other.serverExpiresAt == this.serverExpiresAt &&
          other.uploadedAssetIdsJson == this.uploadedAssetIdsJson &&
          other.resultPayloadJson == this.resultPayloadJson &&
          other.resultSchemaVersion == this.resultSchemaVersion &&
          other.attemptCount == this.attemptCount &&
          other.nextRetryAt == this.nextRetryAt &&
          other.failureCode == this.failureCode &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProcessingOutboxCompanion extends UpdateCompanion<ProcessingOutboxRow> {
  final Value<String> id;
  final Value<String> requestKind;
  final Value<String> subjectId;
  final Value<String> payloadJson;
  final Value<String> deliveryState;
  final Value<String> adoptionState;
  final Value<String?> privacyNoticeVersion;
  final Value<String> idempotencyKey;
  final Value<String?> serverJobId;
  final Value<DateTime?> serverExpiresAt;
  final Value<String> uploadedAssetIdsJson;
  final Value<String?> resultPayloadJson;
  final Value<String?> resultSchemaVersion;
  final Value<int> attemptCount;
  final Value<DateTime?> nextRetryAt;
  final Value<String?> failureCode;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProcessingOutboxCompanion({
    this.id = const Value.absent(),
    this.requestKind = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.deliveryState = const Value.absent(),
    this.adoptionState = const Value.absent(),
    this.privacyNoticeVersion = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.serverJobId = const Value.absent(),
    this.serverExpiresAt = const Value.absent(),
    this.uploadedAssetIdsJson = const Value.absent(),
    this.resultPayloadJson = const Value.absent(),
    this.resultSchemaVersion = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.failureCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProcessingOutboxCompanion.insert({
    required String id,
    required String requestKind,
    required String subjectId,
    required String payloadJson,
    required String deliveryState,
    required String adoptionState,
    this.privacyNoticeVersion = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.serverJobId = const Value.absent(),
    this.serverExpiresAt = const Value.absent(),
    this.uploadedAssetIdsJson = const Value.absent(),
    this.resultPayloadJson = const Value.absent(),
    this.resultSchemaVersion = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.failureCode = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        requestKind = Value(requestKind),
        subjectId = Value(subjectId),
        payloadJson = Value(payloadJson),
        deliveryState = Value(deliveryState),
        adoptionState = Value(adoptionState),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ProcessingOutboxRow> custom({
    Expression<String>? id,
    Expression<String>? requestKind,
    Expression<String>? subjectId,
    Expression<String>? payloadJson,
    Expression<String>? deliveryState,
    Expression<String>? adoptionState,
    Expression<String>? privacyNoticeVersion,
    Expression<String>? idempotencyKey,
    Expression<String>? serverJobId,
    Expression<DateTime>? serverExpiresAt,
    Expression<String>? uploadedAssetIdsJson,
    Expression<String>? resultPayloadJson,
    Expression<String>? resultSchemaVersion,
    Expression<int>? attemptCount,
    Expression<DateTime>? nextRetryAt,
    Expression<String>? failureCode,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (requestKind != null) 'request_kind': requestKind,
      if (subjectId != null) 'subject_id': subjectId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (deliveryState != null) 'delivery_state': deliveryState,
      if (adoptionState != null) 'adoption_state': adoptionState,
      if (privacyNoticeVersion != null)
        'privacy_notice_version': privacyNoticeVersion,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (serverJobId != null) 'server_job_id': serverJobId,
      if (serverExpiresAt != null) 'server_expires_at': serverExpiresAt,
      if (uploadedAssetIdsJson != null)
        'uploaded_asset_ids_json': uploadedAssetIdsJson,
      if (resultPayloadJson != null) 'result_payload_json': resultPayloadJson,
      if (resultSchemaVersion != null)
        'result_schema_version': resultSchemaVersion,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (failureCode != null) 'failure_code': failureCode,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProcessingOutboxCompanion copyWith(
      {Value<String>? id,
      Value<String>? requestKind,
      Value<String>? subjectId,
      Value<String>? payloadJson,
      Value<String>? deliveryState,
      Value<String>? adoptionState,
      Value<String?>? privacyNoticeVersion,
      Value<String>? idempotencyKey,
      Value<String?>? serverJobId,
      Value<DateTime?>? serverExpiresAt,
      Value<String>? uploadedAssetIdsJson,
      Value<String?>? resultPayloadJson,
      Value<String?>? resultSchemaVersion,
      Value<int>? attemptCount,
      Value<DateTime?>? nextRetryAt,
      Value<String?>? failureCode,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ProcessingOutboxCompanion(
      id: id ?? this.id,
      requestKind: requestKind ?? this.requestKind,
      subjectId: subjectId ?? this.subjectId,
      payloadJson: payloadJson ?? this.payloadJson,
      deliveryState: deliveryState ?? this.deliveryState,
      adoptionState: adoptionState ?? this.adoptionState,
      privacyNoticeVersion: privacyNoticeVersion ?? this.privacyNoticeVersion,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      serverJobId: serverJobId ?? this.serverJobId,
      serverExpiresAt: serverExpiresAt ?? this.serverExpiresAt,
      uploadedAssetIdsJson: uploadedAssetIdsJson ?? this.uploadedAssetIdsJson,
      resultPayloadJson: resultPayloadJson ?? this.resultPayloadJson,
      resultSchemaVersion: resultSchemaVersion ?? this.resultSchemaVersion,
      attemptCount: attemptCount ?? this.attemptCount,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      failureCode: failureCode ?? this.failureCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (requestKind.present) {
      map['request_kind'] = Variable<String>(requestKind.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (deliveryState.present) {
      map['delivery_state'] = Variable<String>(deliveryState.value);
    }
    if (adoptionState.present) {
      map['adoption_state'] = Variable<String>(adoptionState.value);
    }
    if (privacyNoticeVersion.present) {
      map['privacy_notice_version'] =
          Variable<String>(privacyNoticeVersion.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (serverJobId.present) {
      map['server_job_id'] = Variable<String>(serverJobId.value);
    }
    if (serverExpiresAt.present) {
      map['server_expires_at'] = Variable<DateTime>(serverExpiresAt.value);
    }
    if (uploadedAssetIdsJson.present) {
      map['uploaded_asset_ids_json'] =
          Variable<String>(uploadedAssetIdsJson.value);
    }
    if (resultPayloadJson.present) {
      map['result_payload_json'] = Variable<String>(resultPayloadJson.value);
    }
    if (resultSchemaVersion.present) {
      map['result_schema_version'] =
          Variable<String>(resultSchemaVersion.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt.value);
    }
    if (failureCode.present) {
      map['failure_code'] = Variable<String>(failureCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProcessingOutboxCompanion(')
          ..write('id: $id, ')
          ..write('requestKind: $requestKind, ')
          ..write('subjectId: $subjectId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('deliveryState: $deliveryState, ')
          ..write('adoptionState: $adoptionState, ')
          ..write('privacyNoticeVersion: $privacyNoticeVersion, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('serverJobId: $serverJobId, ')
          ..write('serverExpiresAt: $serverExpiresAt, ')
          ..write('uploadedAssetIdsJson: $uploadedAssetIdsJson, ')
          ..write('resultPayloadJson: $resultPayloadJson, ')
          ..write('resultSchemaVersion: $resultSchemaVersion, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('failureCode: $failureCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProcessingConsentsTable extends ProcessingConsents
    with TableInfo<$ProcessingConsentsTable, ProcessingConsentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProcessingConsentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _noticeVersionMeta =
      const VerificationMeta('noticeVersion');
  @override
  late final GeneratedColumn<String> noticeVersion = GeneratedColumn<String>(
      'notice_version', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _decisionMeta =
      const VerificationMeta('decision');
  @override
  late final GeneratedColumn<String> decision = GeneratedColumn<String>(
      'decision', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _decidedAtMeta =
      const VerificationMeta('decidedAt');
  @override
  late final GeneratedColumn<DateTime> decidedAt = GeneratedColumn<DateTime>(
      'decided_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [noticeVersion, decision, decidedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'processing_consents';
  @override
  VerificationContext validateIntegrity(
      Insertable<ProcessingConsentRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('notice_version')) {
      context.handle(
          _noticeVersionMeta,
          noticeVersion.isAcceptableOrUnknown(
              data['notice_version']!, _noticeVersionMeta));
    } else if (isInserting) {
      context.missing(_noticeVersionMeta);
    }
    if (data.containsKey('decision')) {
      context.handle(_decisionMeta,
          decision.isAcceptableOrUnknown(data['decision']!, _decisionMeta));
    } else if (isInserting) {
      context.missing(_decisionMeta);
    }
    if (data.containsKey('decided_at')) {
      context.handle(_decidedAtMeta,
          decidedAt.isAcceptableOrUnknown(data['decided_at']!, _decidedAtMeta));
    } else if (isInserting) {
      context.missing(_decidedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {noticeVersion};
  @override
  ProcessingConsentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProcessingConsentRow(
      noticeVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notice_version'])!,
      decision: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}decision'])!,
      decidedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}decided_at'])!,
    );
  }

  @override
  $ProcessingConsentsTable createAlias(String alias) {
    return $ProcessingConsentsTable(attachedDatabase, alias);
  }
}

class ProcessingConsentRow extends DataClass
    implements Insertable<ProcessingConsentRow> {
  final String noticeVersion;
  final String decision;
  final DateTime decidedAt;
  const ProcessingConsentRow(
      {required this.noticeVersion,
      required this.decision,
      required this.decidedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['notice_version'] = Variable<String>(noticeVersion);
    map['decision'] = Variable<String>(decision);
    map['decided_at'] = Variable<DateTime>(decidedAt);
    return map;
  }

  ProcessingConsentsCompanion toCompanion(bool nullToAbsent) {
    return ProcessingConsentsCompanion(
      noticeVersion: Value(noticeVersion),
      decision: Value(decision),
      decidedAt: Value(decidedAt),
    );
  }

  factory ProcessingConsentRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProcessingConsentRow(
      noticeVersion: serializer.fromJson<String>(json['noticeVersion']),
      decision: serializer.fromJson<String>(json['decision']),
      decidedAt: serializer.fromJson<DateTime>(json['decidedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'noticeVersion': serializer.toJson<String>(noticeVersion),
      'decision': serializer.toJson<String>(decision),
      'decidedAt': serializer.toJson<DateTime>(decidedAt),
    };
  }

  ProcessingConsentRow copyWith(
          {String? noticeVersion, String? decision, DateTime? decidedAt}) =>
      ProcessingConsentRow(
        noticeVersion: noticeVersion ?? this.noticeVersion,
        decision: decision ?? this.decision,
        decidedAt: decidedAt ?? this.decidedAt,
      );
  ProcessingConsentRow copyWithCompanion(ProcessingConsentsCompanion data) {
    return ProcessingConsentRow(
      noticeVersion: data.noticeVersion.present
          ? data.noticeVersion.value
          : this.noticeVersion,
      decision: data.decision.present ? data.decision.value : this.decision,
      decidedAt: data.decidedAt.present ? data.decidedAt.value : this.decidedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProcessingConsentRow(')
          ..write('noticeVersion: $noticeVersion, ')
          ..write('decision: $decision, ')
          ..write('decidedAt: $decidedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(noticeVersion, decision, decidedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProcessingConsentRow &&
          other.noticeVersion == this.noticeVersion &&
          other.decision == this.decision &&
          other.decidedAt == this.decidedAt);
}

class ProcessingConsentsCompanion
    extends UpdateCompanion<ProcessingConsentRow> {
  final Value<String> noticeVersion;
  final Value<String> decision;
  final Value<DateTime> decidedAt;
  final Value<int> rowid;
  const ProcessingConsentsCompanion({
    this.noticeVersion = const Value.absent(),
    this.decision = const Value.absent(),
    this.decidedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProcessingConsentsCompanion.insert({
    required String noticeVersion,
    required String decision,
    required DateTime decidedAt,
    this.rowid = const Value.absent(),
  })  : noticeVersion = Value(noticeVersion),
        decision = Value(decision),
        decidedAt = Value(decidedAt);
  static Insertable<ProcessingConsentRow> custom({
    Expression<String>? noticeVersion,
    Expression<String>? decision,
    Expression<DateTime>? decidedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (noticeVersion != null) 'notice_version': noticeVersion,
      if (decision != null) 'decision': decision,
      if (decidedAt != null) 'decided_at': decidedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProcessingConsentsCompanion copyWith(
      {Value<String>? noticeVersion,
      Value<String>? decision,
      Value<DateTime>? decidedAt,
      Value<int>? rowid}) {
    return ProcessingConsentsCompanion(
      noticeVersion: noticeVersion ?? this.noticeVersion,
      decision: decision ?? this.decision,
      decidedAt: decidedAt ?? this.decidedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (noticeVersion.present) {
      map['notice_version'] = Variable<String>(noticeVersion.value);
    }
    if (decision.present) {
      map['decision'] = Variable<String>(decision.value);
    }
    if (decidedAt.present) {
      map['decided_at'] = Variable<DateTime>(decidedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProcessingConsentsCompanion(')
          ..write('noticeVersion: $noticeVersion, ')
          ..write('decision: $decision, ')
          ..write('decidedAt: $decidedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DishesTable dishes = $DishesTable(this);
  late final $DishNotesTable dishNotes = $DishNotesTable(this);
  late final $SourcePhotosTable sourcePhotos = $SourcePhotosTable(this);
  late final $GeneratedCoversTable generatedCovers =
      $GeneratedCoversTable(this);
  late final $CaptureBatchesTable captureBatches = $CaptureBatchesTable(this);
  late final $CaptureItemsTable captureItems = $CaptureItemsTable(this);
  late final $CaptureCorrectionsTable captureCorrections =
      $CaptureCorrectionsTable(this);
  late final $PlannedMealsTable plannedMeals = $PlannedMealsTable(this);
  late final $ReviewItemsTable reviewItems = $ReviewItemsTable(this);
  late final $SyncOperationsTable syncOperations = $SyncOperationsTable(this);
  late final $SyncMetadataTable syncMetadata = $SyncMetadataTable(this);
  late final $LocalSettingsTable localSettings = $LocalSettingsTable(this);
  late final $AiJobsTable aiJobs = $AiJobsTable(this);
  late final $ProcessingOutboxTable processingOutbox =
      $ProcessingOutboxTable(this);
  late final $ProcessingConsentsTable processingConsents =
      $ProcessingConsentsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        dishes,
        dishNotes,
        sourcePhotos,
        generatedCovers,
        captureBatches,
        captureItems,
        captureCorrections,
        plannedMeals,
        reviewItems,
        syncOperations,
        syncMetadata,
        localSettings,
        aiJobs,
        processingOutbox,
        processingConsents
      ];
}

typedef $$DishesTableCreateCompanionBuilder = DishesCompanion Function({
  required String id,
  required String title,
  required String description,
  required String heroImageUrl,
  Value<String?> heroPreviewUrl,
  Value<String?> heroThumbnailUrl,
  Value<String?> heroPlaceholderUrl,
  required String category,
  required int prepMinutes,
  required String difficulty,
  required int madeCount,
  required String lastMadeLabel,
  required String ingredientsJson,
  required String recipeStepsJson,
  required String notesJson,
  Value<bool> isFavorite,
  Value<DateTime?> createdAt,
  Value<DateTime?> openedAt,
  Value<int> rowid,
});
typedef $$DishesTableUpdateCompanionBuilder = DishesCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> description,
  Value<String> heroImageUrl,
  Value<String?> heroPreviewUrl,
  Value<String?> heroThumbnailUrl,
  Value<String?> heroPlaceholderUrl,
  Value<String> category,
  Value<int> prepMinutes,
  Value<String> difficulty,
  Value<int> madeCount,
  Value<String> lastMadeLabel,
  Value<String> ingredientsJson,
  Value<String> recipeStepsJson,
  Value<String> notesJson,
  Value<bool> isFavorite,
  Value<DateTime?> createdAt,
  Value<DateTime?> openedAt,
  Value<int> rowid,
});

class $$DishesTableFilterComposer
    extends Composer<_$AppDatabase, $DishesTable> {
  $$DishesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get heroImageUrl => $composableBuilder(
      column: $table.heroImageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get heroPreviewUrl => $composableBuilder(
      column: $table.heroPreviewUrl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get heroThumbnailUrl => $composableBuilder(
      column: $table.heroThumbnailUrl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get heroPlaceholderUrl => $composableBuilder(
      column: $table.heroPlaceholderUrl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get prepMinutes => $composableBuilder(
      column: $table.prepMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get madeCount => $composableBuilder(
      column: $table.madeCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastMadeLabel => $composableBuilder(
      column: $table.lastMadeLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ingredientsJson => $composableBuilder(
      column: $table.ingredientsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recipeStepsJson => $composableBuilder(
      column: $table.recipeStepsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notesJson => $composableBuilder(
      column: $table.notesJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get openedAt => $composableBuilder(
      column: $table.openedAt, builder: (column) => ColumnFilters(column));
}

class $$DishesTableOrderingComposer
    extends Composer<_$AppDatabase, $DishesTable> {
  $$DishesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get heroImageUrl => $composableBuilder(
      column: $table.heroImageUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get heroPreviewUrl => $composableBuilder(
      column: $table.heroPreviewUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get heroThumbnailUrl => $composableBuilder(
      column: $table.heroThumbnailUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get heroPlaceholderUrl => $composableBuilder(
      column: $table.heroPlaceholderUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get prepMinutes => $composableBuilder(
      column: $table.prepMinutes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get madeCount => $composableBuilder(
      column: $table.madeCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastMadeLabel => $composableBuilder(
      column: $table.lastMadeLabel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ingredientsJson => $composableBuilder(
      column: $table.ingredientsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recipeStepsJson => $composableBuilder(
      column: $table.recipeStepsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notesJson => $composableBuilder(
      column: $table.notesJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get openedAt => $composableBuilder(
      column: $table.openedAt, builder: (column) => ColumnOrderings(column));
}

class $$DishesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DishesTable> {
  $$DishesTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get heroImageUrl => $composableBuilder(
      column: $table.heroImageUrl, builder: (column) => column);

  GeneratedColumn<String> get heroPreviewUrl => $composableBuilder(
      column: $table.heroPreviewUrl, builder: (column) => column);

  GeneratedColumn<String> get heroThumbnailUrl => $composableBuilder(
      column: $table.heroThumbnailUrl, builder: (column) => column);

  GeneratedColumn<String> get heroPlaceholderUrl => $composableBuilder(
      column: $table.heroPlaceholderUrl, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get prepMinutes => $composableBuilder(
      column: $table.prepMinutes, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<int> get madeCount =>
      $composableBuilder(column: $table.madeCount, builder: (column) => column);

  GeneratedColumn<String> get lastMadeLabel => $composableBuilder(
      column: $table.lastMadeLabel, builder: (column) => column);

  GeneratedColumn<String> get ingredientsJson => $composableBuilder(
      column: $table.ingredientsJson, builder: (column) => column);

  GeneratedColumn<String> get recipeStepsJson => $composableBuilder(
      column: $table.recipeStepsJson, builder: (column) => column);

  GeneratedColumn<String> get notesJson =>
      $composableBuilder(column: $table.notesJson, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);
}

class $$DishesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DishesTable,
    DishRow,
    $$DishesTableFilterComposer,
    $$DishesTableOrderingComposer,
    $$DishesTableAnnotationComposer,
    $$DishesTableCreateCompanionBuilder,
    $$DishesTableUpdateCompanionBuilder,
    (DishRow, BaseReferences<_$AppDatabase, $DishesTable, DishRow>),
    DishRow,
    PrefetchHooks Function()> {
  $$DishesTableTableManager(_$AppDatabase db, $DishesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DishesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DishesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DishesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> heroImageUrl = const Value.absent(),
            Value<String?> heroPreviewUrl = const Value.absent(),
            Value<String?> heroThumbnailUrl = const Value.absent(),
            Value<String?> heroPlaceholderUrl = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<int> prepMinutes = const Value.absent(),
            Value<String> difficulty = const Value.absent(),
            Value<int> madeCount = const Value.absent(),
            Value<String> lastMadeLabel = const Value.absent(),
            Value<String> ingredientsJson = const Value.absent(),
            Value<String> recipeStepsJson = const Value.absent(),
            Value<String> notesJson = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> openedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DishesCompanion(
            id: id,
            title: title,
            description: description,
            heroImageUrl: heroImageUrl,
            heroPreviewUrl: heroPreviewUrl,
            heroThumbnailUrl: heroThumbnailUrl,
            heroPlaceholderUrl: heroPlaceholderUrl,
            category: category,
            prepMinutes: prepMinutes,
            difficulty: difficulty,
            madeCount: madeCount,
            lastMadeLabel: lastMadeLabel,
            ingredientsJson: ingredientsJson,
            recipeStepsJson: recipeStepsJson,
            notesJson: notesJson,
            isFavorite: isFavorite,
            createdAt: createdAt,
            openedAt: openedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String description,
            required String heroImageUrl,
            Value<String?> heroPreviewUrl = const Value.absent(),
            Value<String?> heroThumbnailUrl = const Value.absent(),
            Value<String?> heroPlaceholderUrl = const Value.absent(),
            required String category,
            required int prepMinutes,
            required String difficulty,
            required int madeCount,
            required String lastMadeLabel,
            required String ingredientsJson,
            required String recipeStepsJson,
            required String notesJson,
            Value<bool> isFavorite = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> openedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DishesCompanion.insert(
            id: id,
            title: title,
            description: description,
            heroImageUrl: heroImageUrl,
            heroPreviewUrl: heroPreviewUrl,
            heroThumbnailUrl: heroThumbnailUrl,
            heroPlaceholderUrl: heroPlaceholderUrl,
            category: category,
            prepMinutes: prepMinutes,
            difficulty: difficulty,
            madeCount: madeCount,
            lastMadeLabel: lastMadeLabel,
            ingredientsJson: ingredientsJson,
            recipeStepsJson: recipeStepsJson,
            notesJson: notesJson,
            isFavorite: isFavorite,
            createdAt: createdAt,
            openedAt: openedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DishesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DishesTable,
    DishRow,
    $$DishesTableFilterComposer,
    $$DishesTableOrderingComposer,
    $$DishesTableAnnotationComposer,
    $$DishesTableCreateCompanionBuilder,
    $$DishesTableUpdateCompanionBuilder,
    (DishRow, BaseReferences<_$AppDatabase, $DishesTable, DishRow>),
    DishRow,
    PrefetchHooks Function()>;
typedef $$DishNotesTableCreateCompanionBuilder = DishNotesCompanion Function({
  required String id,
  required String dishId,
  required String body,
  required int position,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$DishNotesTableUpdateCompanionBuilder = DishNotesCompanion Function({
  Value<String> id,
  Value<String> dishId,
  Value<String> body,
  Value<int> position,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

class $$DishNotesTableFilterComposer
    extends Composer<_$AppDatabase, $DishNotesTable> {
  $$DishNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dishId => $composableBuilder(
      column: $table.dishId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$DishNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $DishNotesTable> {
  $$DishNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dishId => $composableBuilder(
      column: $table.dishId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$DishNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DishNotesTable> {
  $$DishNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dishId =>
      $composableBuilder(column: $table.dishId, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$DishNotesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DishNotesTable,
    DishNoteRow,
    $$DishNotesTableFilterComposer,
    $$DishNotesTableOrderingComposer,
    $$DishNotesTableAnnotationComposer,
    $$DishNotesTableCreateCompanionBuilder,
    $$DishNotesTableUpdateCompanionBuilder,
    (DishNoteRow, BaseReferences<_$AppDatabase, $DishNotesTable, DishNoteRow>),
    DishNoteRow,
    PrefetchHooks Function()> {
  $$DishNotesTableTableManager(_$AppDatabase db, $DishNotesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DishNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DishNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DishNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> dishId = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DishNotesCompanion(
            id: id,
            dishId: dishId,
            body: body,
            position: position,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String dishId,
            required String body,
            required int position,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DishNotesCompanion.insert(
            id: id,
            dishId: dishId,
            body: body,
            position: position,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DishNotesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DishNotesTable,
    DishNoteRow,
    $$DishNotesTableFilterComposer,
    $$DishNotesTableOrderingComposer,
    $$DishNotesTableAnnotationComposer,
    $$DishNotesTableCreateCompanionBuilder,
    $$DishNotesTableUpdateCompanionBuilder,
    (DishNoteRow, BaseReferences<_$AppDatabase, $DishNotesTable, DishNoteRow>),
    DishNoteRow,
    PrefetchHooks Function()>;
typedef $$SourcePhotosTableCreateCompanionBuilder = SourcePhotosCompanion
    Function({
  required String id,
  required String dishId,
  required String url,
  Value<String?> previewUrl,
  Value<String?> thumbnailUrl,
  Value<String?> placeholderUrl,
  required String capturedLabel,
  Value<String?> confidenceLabel,
  Value<String?> captureId,
  Value<String?> cookingOccasionId,
  Value<DateTime?> capturedAt,
  Value<int> rowid,
});
typedef $$SourcePhotosTableUpdateCompanionBuilder = SourcePhotosCompanion
    Function({
  Value<String> id,
  Value<String> dishId,
  Value<String> url,
  Value<String?> previewUrl,
  Value<String?> thumbnailUrl,
  Value<String?> placeholderUrl,
  Value<String> capturedLabel,
  Value<String?> confidenceLabel,
  Value<String?> captureId,
  Value<String?> cookingOccasionId,
  Value<DateTime?> capturedAt,
  Value<int> rowid,
});

class $$SourcePhotosTableFilterComposer
    extends Composer<_$AppDatabase, $SourcePhotosTable> {
  $$SourcePhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dishId => $composableBuilder(
      column: $table.dishId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get previewUrl => $composableBuilder(
      column: $table.previewUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
      column: $table.thumbnailUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get placeholderUrl => $composableBuilder(
      column: $table.placeholderUrl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get capturedLabel => $composableBuilder(
      column: $table.capturedLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get confidenceLabel => $composableBuilder(
      column: $table.confidenceLabel,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get captureId => $composableBuilder(
      column: $table.captureId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cookingOccasionId => $composableBuilder(
      column: $table.cookingOccasionId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => ColumnFilters(column));
}

class $$SourcePhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $SourcePhotosTable> {
  $$SourcePhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dishId => $composableBuilder(
      column: $table.dishId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get previewUrl => $composableBuilder(
      column: $table.previewUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
      column: $table.thumbnailUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get placeholderUrl => $composableBuilder(
      column: $table.placeholderUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get capturedLabel => $composableBuilder(
      column: $table.capturedLabel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get confidenceLabel => $composableBuilder(
      column: $table.confidenceLabel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get captureId => $composableBuilder(
      column: $table.captureId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cookingOccasionId => $composableBuilder(
      column: $table.cookingOccasionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => ColumnOrderings(column));
}

class $$SourcePhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $SourcePhotosTable> {
  $$SourcePhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dishId =>
      $composableBuilder(column: $table.dishId, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get previewUrl => $composableBuilder(
      column: $table.previewUrl, builder: (column) => column);

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
      column: $table.thumbnailUrl, builder: (column) => column);

  GeneratedColumn<String> get placeholderUrl => $composableBuilder(
      column: $table.placeholderUrl, builder: (column) => column);

  GeneratedColumn<String> get capturedLabel => $composableBuilder(
      column: $table.capturedLabel, builder: (column) => column);

  GeneratedColumn<String> get confidenceLabel => $composableBuilder(
      column: $table.confidenceLabel, builder: (column) => column);

  GeneratedColumn<String> get captureId =>
      $composableBuilder(column: $table.captureId, builder: (column) => column);

  GeneratedColumn<String> get cookingOccasionId => $composableBuilder(
      column: $table.cookingOccasionId, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => column);
}

class $$SourcePhotosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SourcePhotosTable,
    SourcePhotoRow,
    $$SourcePhotosTableFilterComposer,
    $$SourcePhotosTableOrderingComposer,
    $$SourcePhotosTableAnnotationComposer,
    $$SourcePhotosTableCreateCompanionBuilder,
    $$SourcePhotosTableUpdateCompanionBuilder,
    (
      SourcePhotoRow,
      BaseReferences<_$AppDatabase, $SourcePhotosTable, SourcePhotoRow>
    ),
    SourcePhotoRow,
    PrefetchHooks Function()> {
  $$SourcePhotosTableTableManager(_$AppDatabase db, $SourcePhotosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SourcePhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SourcePhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SourcePhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> dishId = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<String?> previewUrl = const Value.absent(),
            Value<String?> thumbnailUrl = const Value.absent(),
            Value<String?> placeholderUrl = const Value.absent(),
            Value<String> capturedLabel = const Value.absent(),
            Value<String?> confidenceLabel = const Value.absent(),
            Value<String?> captureId = const Value.absent(),
            Value<String?> cookingOccasionId = const Value.absent(),
            Value<DateTime?> capturedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SourcePhotosCompanion(
            id: id,
            dishId: dishId,
            url: url,
            previewUrl: previewUrl,
            thumbnailUrl: thumbnailUrl,
            placeholderUrl: placeholderUrl,
            capturedLabel: capturedLabel,
            confidenceLabel: confidenceLabel,
            captureId: captureId,
            cookingOccasionId: cookingOccasionId,
            capturedAt: capturedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String dishId,
            required String url,
            Value<String?> previewUrl = const Value.absent(),
            Value<String?> thumbnailUrl = const Value.absent(),
            Value<String?> placeholderUrl = const Value.absent(),
            required String capturedLabel,
            Value<String?> confidenceLabel = const Value.absent(),
            Value<String?> captureId = const Value.absent(),
            Value<String?> cookingOccasionId = const Value.absent(),
            Value<DateTime?> capturedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SourcePhotosCompanion.insert(
            id: id,
            dishId: dishId,
            url: url,
            previewUrl: previewUrl,
            thumbnailUrl: thumbnailUrl,
            placeholderUrl: placeholderUrl,
            capturedLabel: capturedLabel,
            confidenceLabel: confidenceLabel,
            captureId: captureId,
            cookingOccasionId: cookingOccasionId,
            capturedAt: capturedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SourcePhotosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SourcePhotosTable,
    SourcePhotoRow,
    $$SourcePhotosTableFilterComposer,
    $$SourcePhotosTableOrderingComposer,
    $$SourcePhotosTableAnnotationComposer,
    $$SourcePhotosTableCreateCompanionBuilder,
    $$SourcePhotosTableUpdateCompanionBuilder,
    (
      SourcePhotoRow,
      BaseReferences<_$AppDatabase, $SourcePhotosTable, SourcePhotoRow>
    ),
    SourcePhotoRow,
    PrefetchHooks Function()>;
typedef $$GeneratedCoversTableCreateCompanionBuilder = GeneratedCoversCompanion
    Function({
  required String id,
  required String dishId,
  required String localPath,
  Value<String?> previewPath,
  Value<String?> thumbnailPath,
  Value<String?> placeholderPath,
  required String origin,
  required String grounding,
  required String selectedSourceIdsJson,
  required String look,
  required String view,
  required String finish,
  required String contractVersion,
  required String proposalId,
  required String state,
  Value<bool> automaticAcknowledged,
  Value<bool> automaticUndoAvailable,
  Value<String?> previousCoverJson,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$GeneratedCoversTableUpdateCompanionBuilder = GeneratedCoversCompanion
    Function({
  Value<String> id,
  Value<String> dishId,
  Value<String> localPath,
  Value<String?> previewPath,
  Value<String?> thumbnailPath,
  Value<String?> placeholderPath,
  Value<String> origin,
  Value<String> grounding,
  Value<String> selectedSourceIdsJson,
  Value<String> look,
  Value<String> view,
  Value<String> finish,
  Value<String> contractVersion,
  Value<String> proposalId,
  Value<String> state,
  Value<bool> automaticAcknowledged,
  Value<bool> automaticUndoAvailable,
  Value<String?> previousCoverJson,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$GeneratedCoversTableFilterComposer
    extends Composer<_$AppDatabase, $GeneratedCoversTable> {
  $$GeneratedCoversTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dishId => $composableBuilder(
      column: $table.dishId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get previewPath => $composableBuilder(
      column: $table.previewPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get placeholderPath => $composableBuilder(
      column: $table.placeholderPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get origin => $composableBuilder(
      column: $table.origin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get grounding => $composableBuilder(
      column: $table.grounding, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get selectedSourceIdsJson => $composableBuilder(
      column: $table.selectedSourceIdsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get look => $composableBuilder(
      column: $table.look, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get view => $composableBuilder(
      column: $table.view, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get finish => $composableBuilder(
      column: $table.finish, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contractVersion => $composableBuilder(
      column: $table.contractVersion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get proposalId => $composableBuilder(
      column: $table.proposalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get automaticAcknowledged => $composableBuilder(
      column: $table.automaticAcknowledged,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get automaticUndoAvailable => $composableBuilder(
      column: $table.automaticUndoAvailable,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get previousCoverJson => $composableBuilder(
      column: $table.previousCoverJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$GeneratedCoversTableOrderingComposer
    extends Composer<_$AppDatabase, $GeneratedCoversTable> {
  $$GeneratedCoversTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dishId => $composableBuilder(
      column: $table.dishId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get previewPath => $composableBuilder(
      column: $table.previewPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get placeholderPath => $composableBuilder(
      column: $table.placeholderPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get origin => $composableBuilder(
      column: $table.origin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get grounding => $composableBuilder(
      column: $table.grounding, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get selectedSourceIdsJson => $composableBuilder(
      column: $table.selectedSourceIdsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get look => $composableBuilder(
      column: $table.look, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get view => $composableBuilder(
      column: $table.view, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get finish => $composableBuilder(
      column: $table.finish, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contractVersion => $composableBuilder(
      column: $table.contractVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get proposalId => $composableBuilder(
      column: $table.proposalId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get automaticAcknowledged => $composableBuilder(
      column: $table.automaticAcknowledged,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get automaticUndoAvailable => $composableBuilder(
      column: $table.automaticUndoAvailable,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get previousCoverJson => $composableBuilder(
      column: $table.previousCoverJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$GeneratedCoversTableAnnotationComposer
    extends Composer<_$AppDatabase, $GeneratedCoversTable> {
  $$GeneratedCoversTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dishId =>
      $composableBuilder(column: $table.dishId, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get previewPath => $composableBuilder(
      column: $table.previewPath, builder: (column) => column);

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath, builder: (column) => column);

  GeneratedColumn<String> get placeholderPath => $composableBuilder(
      column: $table.placeholderPath, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get grounding =>
      $composableBuilder(column: $table.grounding, builder: (column) => column);

  GeneratedColumn<String> get selectedSourceIdsJson => $composableBuilder(
      column: $table.selectedSourceIdsJson, builder: (column) => column);

  GeneratedColumn<String> get look =>
      $composableBuilder(column: $table.look, builder: (column) => column);

  GeneratedColumn<String> get view =>
      $composableBuilder(column: $table.view, builder: (column) => column);

  GeneratedColumn<String> get finish =>
      $composableBuilder(column: $table.finish, builder: (column) => column);

  GeneratedColumn<String> get contractVersion => $composableBuilder(
      column: $table.contractVersion, builder: (column) => column);

  GeneratedColumn<String> get proposalId => $composableBuilder(
      column: $table.proposalId, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<bool> get automaticAcknowledged => $composableBuilder(
      column: $table.automaticAcknowledged, builder: (column) => column);

  GeneratedColumn<bool> get automaticUndoAvailable => $composableBuilder(
      column: $table.automaticUndoAvailable, builder: (column) => column);

  GeneratedColumn<String> get previousCoverJson => $composableBuilder(
      column: $table.previousCoverJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$GeneratedCoversTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GeneratedCoversTable,
    GeneratedCoverRow,
    $$GeneratedCoversTableFilterComposer,
    $$GeneratedCoversTableOrderingComposer,
    $$GeneratedCoversTableAnnotationComposer,
    $$GeneratedCoversTableCreateCompanionBuilder,
    $$GeneratedCoversTableUpdateCompanionBuilder,
    (
      GeneratedCoverRow,
      BaseReferences<_$AppDatabase, $GeneratedCoversTable, GeneratedCoverRow>
    ),
    GeneratedCoverRow,
    PrefetchHooks Function()> {
  $$GeneratedCoversTableTableManager(
      _$AppDatabase db, $GeneratedCoversTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GeneratedCoversTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GeneratedCoversTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GeneratedCoversTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> dishId = const Value.absent(),
            Value<String> localPath = const Value.absent(),
            Value<String?> previewPath = const Value.absent(),
            Value<String?> thumbnailPath = const Value.absent(),
            Value<String?> placeholderPath = const Value.absent(),
            Value<String> origin = const Value.absent(),
            Value<String> grounding = const Value.absent(),
            Value<String> selectedSourceIdsJson = const Value.absent(),
            Value<String> look = const Value.absent(),
            Value<String> view = const Value.absent(),
            Value<String> finish = const Value.absent(),
            Value<String> contractVersion = const Value.absent(),
            Value<String> proposalId = const Value.absent(),
            Value<String> state = const Value.absent(),
            Value<bool> automaticAcknowledged = const Value.absent(),
            Value<bool> automaticUndoAvailable = const Value.absent(),
            Value<String?> previousCoverJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GeneratedCoversCompanion(
            id: id,
            dishId: dishId,
            localPath: localPath,
            previewPath: previewPath,
            thumbnailPath: thumbnailPath,
            placeholderPath: placeholderPath,
            origin: origin,
            grounding: grounding,
            selectedSourceIdsJson: selectedSourceIdsJson,
            look: look,
            view: view,
            finish: finish,
            contractVersion: contractVersion,
            proposalId: proposalId,
            state: state,
            automaticAcknowledged: automaticAcknowledged,
            automaticUndoAvailable: automaticUndoAvailable,
            previousCoverJson: previousCoverJson,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String dishId,
            required String localPath,
            Value<String?> previewPath = const Value.absent(),
            Value<String?> thumbnailPath = const Value.absent(),
            Value<String?> placeholderPath = const Value.absent(),
            required String origin,
            required String grounding,
            required String selectedSourceIdsJson,
            required String look,
            required String view,
            required String finish,
            required String contractVersion,
            required String proposalId,
            required String state,
            Value<bool> automaticAcknowledged = const Value.absent(),
            Value<bool> automaticUndoAvailable = const Value.absent(),
            Value<String?> previousCoverJson = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              GeneratedCoversCompanion.insert(
            id: id,
            dishId: dishId,
            localPath: localPath,
            previewPath: previewPath,
            thumbnailPath: thumbnailPath,
            placeholderPath: placeholderPath,
            origin: origin,
            grounding: grounding,
            selectedSourceIdsJson: selectedSourceIdsJson,
            look: look,
            view: view,
            finish: finish,
            contractVersion: contractVersion,
            proposalId: proposalId,
            state: state,
            automaticAcknowledged: automaticAcknowledged,
            automaticUndoAvailable: automaticUndoAvailable,
            previousCoverJson: previousCoverJson,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GeneratedCoversTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GeneratedCoversTable,
    GeneratedCoverRow,
    $$GeneratedCoversTableFilterComposer,
    $$GeneratedCoversTableOrderingComposer,
    $$GeneratedCoversTableAnnotationComposer,
    $$GeneratedCoversTableCreateCompanionBuilder,
    $$GeneratedCoversTableUpdateCompanionBuilder,
    (
      GeneratedCoverRow,
      BaseReferences<_$AppDatabase, $GeneratedCoversTable, GeneratedCoverRow>
    ),
    GeneratedCoverRow,
    PrefetchHooks Function()>;
typedef $$CaptureBatchesTableCreateCompanionBuilder = CaptureBatchesCompanion
    Function({
  required String id,
  required String status,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String?> failureReason,
  Value<int> rowid,
});
typedef $$CaptureBatchesTableUpdateCompanionBuilder = CaptureBatchesCompanion
    Function({
  Value<String> id,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String?> failureReason,
  Value<int> rowid,
});

class $$CaptureBatchesTableFilterComposer
    extends Composer<_$AppDatabase, $CaptureBatchesTable> {
  $$CaptureBatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get failureReason => $composableBuilder(
      column: $table.failureReason, builder: (column) => ColumnFilters(column));
}

class $$CaptureBatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $CaptureBatchesTable> {
  $$CaptureBatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get failureReason => $composableBuilder(
      column: $table.failureReason,
      builder: (column) => ColumnOrderings(column));
}

class $$CaptureBatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CaptureBatchesTable> {
  $$CaptureBatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get failureReason => $composableBuilder(
      column: $table.failureReason, builder: (column) => column);
}

class $$CaptureBatchesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CaptureBatchesTable,
    CaptureBatchRow,
    $$CaptureBatchesTableFilterComposer,
    $$CaptureBatchesTableOrderingComposer,
    $$CaptureBatchesTableAnnotationComposer,
    $$CaptureBatchesTableCreateCompanionBuilder,
    $$CaptureBatchesTableUpdateCompanionBuilder,
    (
      CaptureBatchRow,
      BaseReferences<_$AppDatabase, $CaptureBatchesTable, CaptureBatchRow>
    ),
    CaptureBatchRow,
    PrefetchHooks Function()> {
  $$CaptureBatchesTableTableManager(
      _$AppDatabase db, $CaptureBatchesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CaptureBatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CaptureBatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CaptureBatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String?> failureReason = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CaptureBatchesCompanion(
            id: id,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            failureReason: failureReason,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String status,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String?> failureReason = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CaptureBatchesCompanion.insert(
            id: id,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            failureReason: failureReason,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CaptureBatchesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CaptureBatchesTable,
    CaptureBatchRow,
    $$CaptureBatchesTableFilterComposer,
    $$CaptureBatchesTableOrderingComposer,
    $$CaptureBatchesTableAnnotationComposer,
    $$CaptureBatchesTableCreateCompanionBuilder,
    $$CaptureBatchesTableUpdateCompanionBuilder,
    (
      CaptureBatchRow,
      BaseReferences<_$AppDatabase, $CaptureBatchesTable, CaptureBatchRow>
    ),
    CaptureBatchRow,
    PrefetchHooks Function()>;
typedef $$CaptureItemsTableCreateCompanionBuilder = CaptureItemsCompanion
    Function({
  required String id,
  Value<String?> batchId,
  Value<int> ordinal,
  required String kind,
  required String status,
  required DateTime createdAt,
  Value<String?> localMediaRef,
  Value<String?> localPreviewRef,
  Value<String?> localThumbnailRef,
  Value<String?> localPlaceholderRef,
  Value<String?> remoteMediaRef,
  Value<String?> ideaText,
  Value<DateTime?> capturedAt,
  Value<String?> capturedLocalDate,
  Value<String?> captureDateSource,
  Value<String?> appliedDishId,
  Value<String?> failureReason,
  Value<int> rowid,
});
typedef $$CaptureItemsTableUpdateCompanionBuilder = CaptureItemsCompanion
    Function({
  Value<String> id,
  Value<String?> batchId,
  Value<int> ordinal,
  Value<String> kind,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<String?> localMediaRef,
  Value<String?> localPreviewRef,
  Value<String?> localThumbnailRef,
  Value<String?> localPlaceholderRef,
  Value<String?> remoteMediaRef,
  Value<String?> ideaText,
  Value<DateTime?> capturedAt,
  Value<String?> capturedLocalDate,
  Value<String?> captureDateSource,
  Value<String?> appliedDishId,
  Value<String?> failureReason,
  Value<int> rowid,
});

class $$CaptureItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CaptureItemsTable> {
  $$CaptureItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get batchId => $composableBuilder(
      column: $table.batchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ordinal => $composableBuilder(
      column: $table.ordinal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localMediaRef => $composableBuilder(
      column: $table.localMediaRef, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPreviewRef => $composableBuilder(
      column: $table.localPreviewRef,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localThumbnailRef => $composableBuilder(
      column: $table.localThumbnailRef,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPlaceholderRef => $composableBuilder(
      column: $table.localPlaceholderRef,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteMediaRef => $composableBuilder(
      column: $table.remoteMediaRef,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ideaText => $composableBuilder(
      column: $table.ideaText, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get capturedLocalDate => $composableBuilder(
      column: $table.capturedLocalDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get captureDateSource => $composableBuilder(
      column: $table.captureDateSource,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get appliedDishId => $composableBuilder(
      column: $table.appliedDishId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get failureReason => $composableBuilder(
      column: $table.failureReason, builder: (column) => ColumnFilters(column));
}

class $$CaptureItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CaptureItemsTable> {
  $$CaptureItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get batchId => $composableBuilder(
      column: $table.batchId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ordinal => $composableBuilder(
      column: $table.ordinal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localMediaRef => $composableBuilder(
      column: $table.localMediaRef,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPreviewRef => $composableBuilder(
      column: $table.localPreviewRef,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localThumbnailRef => $composableBuilder(
      column: $table.localThumbnailRef,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPlaceholderRef => $composableBuilder(
      column: $table.localPlaceholderRef,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteMediaRef => $composableBuilder(
      column: $table.remoteMediaRef,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ideaText => $composableBuilder(
      column: $table.ideaText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get capturedLocalDate => $composableBuilder(
      column: $table.capturedLocalDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get captureDateSource => $composableBuilder(
      column: $table.captureDateSource,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get appliedDishId => $composableBuilder(
      column: $table.appliedDishId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get failureReason => $composableBuilder(
      column: $table.failureReason,
      builder: (column) => ColumnOrderings(column));
}

class $$CaptureItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CaptureItemsTable> {
  $$CaptureItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<int> get ordinal =>
      $composableBuilder(column: $table.ordinal, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get localMediaRef => $composableBuilder(
      column: $table.localMediaRef, builder: (column) => column);

  GeneratedColumn<String> get localPreviewRef => $composableBuilder(
      column: $table.localPreviewRef, builder: (column) => column);

  GeneratedColumn<String> get localThumbnailRef => $composableBuilder(
      column: $table.localThumbnailRef, builder: (column) => column);

  GeneratedColumn<String> get localPlaceholderRef => $composableBuilder(
      column: $table.localPlaceholderRef, builder: (column) => column);

  GeneratedColumn<String> get remoteMediaRef => $composableBuilder(
      column: $table.remoteMediaRef, builder: (column) => column);

  GeneratedColumn<String> get ideaText =>
      $composableBuilder(column: $table.ideaText, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => column);

  GeneratedColumn<String> get capturedLocalDate => $composableBuilder(
      column: $table.capturedLocalDate, builder: (column) => column);

  GeneratedColumn<String> get captureDateSource => $composableBuilder(
      column: $table.captureDateSource, builder: (column) => column);

  GeneratedColumn<String> get appliedDishId => $composableBuilder(
      column: $table.appliedDishId, builder: (column) => column);

  GeneratedColumn<String> get failureReason => $composableBuilder(
      column: $table.failureReason, builder: (column) => column);
}

class $$CaptureItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CaptureItemsTable,
    CaptureItemRow,
    $$CaptureItemsTableFilterComposer,
    $$CaptureItemsTableOrderingComposer,
    $$CaptureItemsTableAnnotationComposer,
    $$CaptureItemsTableCreateCompanionBuilder,
    $$CaptureItemsTableUpdateCompanionBuilder,
    (
      CaptureItemRow,
      BaseReferences<_$AppDatabase, $CaptureItemsTable, CaptureItemRow>
    ),
    CaptureItemRow,
    PrefetchHooks Function()> {
  $$CaptureItemsTableTableManager(_$AppDatabase db, $CaptureItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CaptureItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CaptureItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CaptureItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> batchId = const Value.absent(),
            Value<int> ordinal = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String?> localMediaRef = const Value.absent(),
            Value<String?> localPreviewRef = const Value.absent(),
            Value<String?> localThumbnailRef = const Value.absent(),
            Value<String?> localPlaceholderRef = const Value.absent(),
            Value<String?> remoteMediaRef = const Value.absent(),
            Value<String?> ideaText = const Value.absent(),
            Value<DateTime?> capturedAt = const Value.absent(),
            Value<String?> capturedLocalDate = const Value.absent(),
            Value<String?> captureDateSource = const Value.absent(),
            Value<String?> appliedDishId = const Value.absent(),
            Value<String?> failureReason = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CaptureItemsCompanion(
            id: id,
            batchId: batchId,
            ordinal: ordinal,
            kind: kind,
            status: status,
            createdAt: createdAt,
            localMediaRef: localMediaRef,
            localPreviewRef: localPreviewRef,
            localThumbnailRef: localThumbnailRef,
            localPlaceholderRef: localPlaceholderRef,
            remoteMediaRef: remoteMediaRef,
            ideaText: ideaText,
            capturedAt: capturedAt,
            capturedLocalDate: capturedLocalDate,
            captureDateSource: captureDateSource,
            appliedDishId: appliedDishId,
            failureReason: failureReason,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> batchId = const Value.absent(),
            Value<int> ordinal = const Value.absent(),
            required String kind,
            required String status,
            required DateTime createdAt,
            Value<String?> localMediaRef = const Value.absent(),
            Value<String?> localPreviewRef = const Value.absent(),
            Value<String?> localThumbnailRef = const Value.absent(),
            Value<String?> localPlaceholderRef = const Value.absent(),
            Value<String?> remoteMediaRef = const Value.absent(),
            Value<String?> ideaText = const Value.absent(),
            Value<DateTime?> capturedAt = const Value.absent(),
            Value<String?> capturedLocalDate = const Value.absent(),
            Value<String?> captureDateSource = const Value.absent(),
            Value<String?> appliedDishId = const Value.absent(),
            Value<String?> failureReason = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CaptureItemsCompanion.insert(
            id: id,
            batchId: batchId,
            ordinal: ordinal,
            kind: kind,
            status: status,
            createdAt: createdAt,
            localMediaRef: localMediaRef,
            localPreviewRef: localPreviewRef,
            localThumbnailRef: localThumbnailRef,
            localPlaceholderRef: localPlaceholderRef,
            remoteMediaRef: remoteMediaRef,
            ideaText: ideaText,
            capturedAt: capturedAt,
            capturedLocalDate: capturedLocalDate,
            captureDateSource: captureDateSource,
            appliedDishId: appliedDishId,
            failureReason: failureReason,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CaptureItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CaptureItemsTable,
    CaptureItemRow,
    $$CaptureItemsTableFilterComposer,
    $$CaptureItemsTableOrderingComposer,
    $$CaptureItemsTableAnnotationComposer,
    $$CaptureItemsTableCreateCompanionBuilder,
    $$CaptureItemsTableUpdateCompanionBuilder,
    (
      CaptureItemRow,
      BaseReferences<_$AppDatabase, $CaptureItemsTable, CaptureItemRow>
    ),
    CaptureItemRow,
    PrefetchHooks Function()>;
typedef $$CaptureCorrectionsTableCreateCompanionBuilder
    = CaptureCorrectionsCompanion Function({
  required String id,
  required String batchId,
  required String actionType,
  required String captureIdsJson,
  required String previousDishIdsJson,
  required String targetDishId,
  Value<String?> createdDishId,
  required String status,
  Value<String?> error,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> undoneAt,
  Value<int> rowid,
});
typedef $$CaptureCorrectionsTableUpdateCompanionBuilder
    = CaptureCorrectionsCompanion Function({
  Value<String> id,
  Value<String> batchId,
  Value<String> actionType,
  Value<String> captureIdsJson,
  Value<String> previousDishIdsJson,
  Value<String> targetDishId,
  Value<String?> createdDishId,
  Value<String> status,
  Value<String?> error,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> undoneAt,
  Value<int> rowid,
});

class $$CaptureCorrectionsTableFilterComposer
    extends Composer<_$AppDatabase, $CaptureCorrectionsTable> {
  $$CaptureCorrectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get batchId => $composableBuilder(
      column: $table.batchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get captureIdsJson => $composableBuilder(
      column: $table.captureIdsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get previousDishIdsJson => $composableBuilder(
      column: $table.previousDishIdsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetDishId => $composableBuilder(
      column: $table.targetDishId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdDishId => $composableBuilder(
      column: $table.createdDishId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get undoneAt => $composableBuilder(
      column: $table.undoneAt, builder: (column) => ColumnFilters(column));
}

class $$CaptureCorrectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CaptureCorrectionsTable> {
  $$CaptureCorrectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get batchId => $composableBuilder(
      column: $table.batchId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get captureIdsJson => $composableBuilder(
      column: $table.captureIdsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get previousDishIdsJson => $composableBuilder(
      column: $table.previousDishIdsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetDishId => $composableBuilder(
      column: $table.targetDishId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdDishId => $composableBuilder(
      column: $table.createdDishId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get undoneAt => $composableBuilder(
      column: $table.undoneAt, builder: (column) => ColumnOrderings(column));
}

class $$CaptureCorrectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CaptureCorrectionsTable> {
  $$CaptureCorrectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => column);

  GeneratedColumn<String> get captureIdsJson => $composableBuilder(
      column: $table.captureIdsJson, builder: (column) => column);

  GeneratedColumn<String> get previousDishIdsJson => $composableBuilder(
      column: $table.previousDishIdsJson, builder: (column) => column);

  GeneratedColumn<String> get targetDishId => $composableBuilder(
      column: $table.targetDishId, builder: (column) => column);

  GeneratedColumn<String> get createdDishId => $composableBuilder(
      column: $table.createdDishId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get undoneAt =>
      $composableBuilder(column: $table.undoneAt, builder: (column) => column);
}

class $$CaptureCorrectionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CaptureCorrectionsTable,
    CaptureCorrectionRow,
    $$CaptureCorrectionsTableFilterComposer,
    $$CaptureCorrectionsTableOrderingComposer,
    $$CaptureCorrectionsTableAnnotationComposer,
    $$CaptureCorrectionsTableCreateCompanionBuilder,
    $$CaptureCorrectionsTableUpdateCompanionBuilder,
    (
      CaptureCorrectionRow,
      BaseReferences<_$AppDatabase, $CaptureCorrectionsTable,
          CaptureCorrectionRow>
    ),
    CaptureCorrectionRow,
    PrefetchHooks Function()> {
  $$CaptureCorrectionsTableTableManager(
      _$AppDatabase db, $CaptureCorrectionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CaptureCorrectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CaptureCorrectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CaptureCorrectionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> batchId = const Value.absent(),
            Value<String> actionType = const Value.absent(),
            Value<String> captureIdsJson = const Value.absent(),
            Value<String> previousDishIdsJson = const Value.absent(),
            Value<String> targetDishId = const Value.absent(),
            Value<String?> createdDishId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> error = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> undoneAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CaptureCorrectionsCompanion(
            id: id,
            batchId: batchId,
            actionType: actionType,
            captureIdsJson: captureIdsJson,
            previousDishIdsJson: previousDishIdsJson,
            targetDishId: targetDishId,
            createdDishId: createdDishId,
            status: status,
            error: error,
            createdAt: createdAt,
            updatedAt: updatedAt,
            undoneAt: undoneAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String batchId,
            required String actionType,
            required String captureIdsJson,
            required String previousDishIdsJson,
            required String targetDishId,
            Value<String?> createdDishId = const Value.absent(),
            required String status,
            Value<String?> error = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> undoneAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CaptureCorrectionsCompanion.insert(
            id: id,
            batchId: batchId,
            actionType: actionType,
            captureIdsJson: captureIdsJson,
            previousDishIdsJson: previousDishIdsJson,
            targetDishId: targetDishId,
            createdDishId: createdDishId,
            status: status,
            error: error,
            createdAt: createdAt,
            updatedAt: updatedAt,
            undoneAt: undoneAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CaptureCorrectionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CaptureCorrectionsTable,
    CaptureCorrectionRow,
    $$CaptureCorrectionsTableFilterComposer,
    $$CaptureCorrectionsTableOrderingComposer,
    $$CaptureCorrectionsTableAnnotationComposer,
    $$CaptureCorrectionsTableCreateCompanionBuilder,
    $$CaptureCorrectionsTableUpdateCompanionBuilder,
    (
      CaptureCorrectionRow,
      BaseReferences<_$AppDatabase, $CaptureCorrectionsTable,
          CaptureCorrectionRow>
    ),
    CaptureCorrectionRow,
    PrefetchHooks Function()>;
typedef $$PlannedMealsTableCreateCompanionBuilder = PlannedMealsCompanion
    Function({
  required String id,
  required String dayKey,
  required String dishId,
  Value<String?> label,
  Value<int> position,
  Value<int> rowid,
});
typedef $$PlannedMealsTableUpdateCompanionBuilder = PlannedMealsCompanion
    Function({
  Value<String> id,
  Value<String> dayKey,
  Value<String> dishId,
  Value<String?> label,
  Value<int> position,
  Value<int> rowid,
});

class $$PlannedMealsTableFilterComposer
    extends Composer<_$AppDatabase, $PlannedMealsTable> {
  $$PlannedMealsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dayKey => $composableBuilder(
      column: $table.dayKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dishId => $composableBuilder(
      column: $table.dishId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));
}

class $$PlannedMealsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlannedMealsTable> {
  $$PlannedMealsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dayKey => $composableBuilder(
      column: $table.dayKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dishId => $composableBuilder(
      column: $table.dishId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));
}

class $$PlannedMealsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlannedMealsTable> {
  $$PlannedMealsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dayKey =>
      $composableBuilder(column: $table.dayKey, builder: (column) => column);

  GeneratedColumn<String> get dishId =>
      $composableBuilder(column: $table.dishId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$PlannedMealsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlannedMealsTable,
    PlannedMealRow,
    $$PlannedMealsTableFilterComposer,
    $$PlannedMealsTableOrderingComposer,
    $$PlannedMealsTableAnnotationComposer,
    $$PlannedMealsTableCreateCompanionBuilder,
    $$PlannedMealsTableUpdateCompanionBuilder,
    (
      PlannedMealRow,
      BaseReferences<_$AppDatabase, $PlannedMealsTable, PlannedMealRow>
    ),
    PlannedMealRow,
    PrefetchHooks Function()> {
  $$PlannedMealsTableTableManager(_$AppDatabase db, $PlannedMealsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlannedMealsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlannedMealsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlannedMealsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> dayKey = const Value.absent(),
            Value<String> dishId = const Value.absent(),
            Value<String?> label = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlannedMealsCompanion(
            id: id,
            dayKey: dayKey,
            dishId: dishId,
            label: label,
            position: position,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String dayKey,
            required String dishId,
            Value<String?> label = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlannedMealsCompanion.insert(
            id: id,
            dayKey: dayKey,
            dishId: dishId,
            label: label,
            position: position,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlannedMealsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlannedMealsTable,
    PlannedMealRow,
    $$PlannedMealsTableFilterComposer,
    $$PlannedMealsTableOrderingComposer,
    $$PlannedMealsTableAnnotationComposer,
    $$PlannedMealsTableCreateCompanionBuilder,
    $$PlannedMealsTableUpdateCompanionBuilder,
    (
      PlannedMealRow,
      BaseReferences<_$AppDatabase, $PlannedMealsTable, PlannedMealRow>
    ),
    PlannedMealRow,
    PrefetchHooks Function()>;
typedef $$ReviewItemsTableCreateCompanionBuilder = ReviewItemsCompanion
    Function({
  required String id,
  Value<String?> captureId,
  required String summary,
  required String suggestedDishIdsJson,
  required String confidenceLabel,
  Value<String?> imageRef,
  Value<int> rowid,
});
typedef $$ReviewItemsTableUpdateCompanionBuilder = ReviewItemsCompanion
    Function({
  Value<String> id,
  Value<String?> captureId,
  Value<String> summary,
  Value<String> suggestedDishIdsJson,
  Value<String> confidenceLabel,
  Value<String?> imageRef,
  Value<int> rowid,
});

class $$ReviewItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewItemsTable> {
  $$ReviewItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get captureId => $composableBuilder(
      column: $table.captureId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get suggestedDishIdsJson => $composableBuilder(
      column: $table.suggestedDishIdsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get confidenceLabel => $composableBuilder(
      column: $table.confidenceLabel,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageRef => $composableBuilder(
      column: $table.imageRef, builder: (column) => ColumnFilters(column));
}

class $$ReviewItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewItemsTable> {
  $$ReviewItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get captureId => $composableBuilder(
      column: $table.captureId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get suggestedDishIdsJson => $composableBuilder(
      column: $table.suggestedDishIdsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get confidenceLabel => $composableBuilder(
      column: $table.confidenceLabel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageRef => $composableBuilder(
      column: $table.imageRef, builder: (column) => ColumnOrderings(column));
}

class $$ReviewItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewItemsTable> {
  $$ReviewItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get captureId =>
      $composableBuilder(column: $table.captureId, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get suggestedDishIdsJson => $composableBuilder(
      column: $table.suggestedDishIdsJson, builder: (column) => column);

  GeneratedColumn<String> get confidenceLabel => $composableBuilder(
      column: $table.confidenceLabel, builder: (column) => column);

  GeneratedColumn<String> get imageRef =>
      $composableBuilder(column: $table.imageRef, builder: (column) => column);
}

class $$ReviewItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReviewItemsTable,
    ReviewItemRow,
    $$ReviewItemsTableFilterComposer,
    $$ReviewItemsTableOrderingComposer,
    $$ReviewItemsTableAnnotationComposer,
    $$ReviewItemsTableCreateCompanionBuilder,
    $$ReviewItemsTableUpdateCompanionBuilder,
    (
      ReviewItemRow,
      BaseReferences<_$AppDatabase, $ReviewItemsTable, ReviewItemRow>
    ),
    ReviewItemRow,
    PrefetchHooks Function()> {
  $$ReviewItemsTableTableManager(_$AppDatabase db, $ReviewItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> captureId = const Value.absent(),
            Value<String> summary = const Value.absent(),
            Value<String> suggestedDishIdsJson = const Value.absent(),
            Value<String> confidenceLabel = const Value.absent(),
            Value<String?> imageRef = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReviewItemsCompanion(
            id: id,
            captureId: captureId,
            summary: summary,
            suggestedDishIdsJson: suggestedDishIdsJson,
            confidenceLabel: confidenceLabel,
            imageRef: imageRef,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> captureId = const Value.absent(),
            required String summary,
            required String suggestedDishIdsJson,
            required String confidenceLabel,
            Value<String?> imageRef = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReviewItemsCompanion.insert(
            id: id,
            captureId: captureId,
            summary: summary,
            suggestedDishIdsJson: suggestedDishIdsJson,
            confidenceLabel: confidenceLabel,
            imageRef: imageRef,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReviewItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReviewItemsTable,
    ReviewItemRow,
    $$ReviewItemsTableFilterComposer,
    $$ReviewItemsTableOrderingComposer,
    $$ReviewItemsTableAnnotationComposer,
    $$ReviewItemsTableCreateCompanionBuilder,
    $$ReviewItemsTableUpdateCompanionBuilder,
    (
      ReviewItemRow,
      BaseReferences<_$AppDatabase, $ReviewItemsTable, ReviewItemRow>
    ),
    ReviewItemRow,
    PrefetchHooks Function()>;
typedef $$SyncOperationsTableCreateCompanionBuilder = SyncOperationsCompanion
    Function({
  required String id,
  required String entity,
  required String entityId,
  required String operationType,
  required String payloadJson,
  required DateTime createdAt,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});
typedef $$SyncOperationsTableUpdateCompanionBuilder = SyncOperationsCompanion
    Function({
  Value<String> id,
  Value<String> entity,
  Value<String> entityId,
  Value<String> operationType,
  Value<String> payloadJson,
  Value<DateTime> createdAt,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});

class $$SyncOperationsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOperationsTable> {
  $$SyncOperationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entity => $composableBuilder(
      column: $table.entity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operationType => $composableBuilder(
      column: $table.operationType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));
}

class $$SyncOperationsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOperationsTable> {
  $$SyncOperationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entity => $composableBuilder(
      column: $table.entity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operationType => $composableBuilder(
      column: $table.operationType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncOperationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOperationsTable> {
  $$SyncOperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operationType => $composableBuilder(
      column: $table.operationType, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);
}

class $$SyncOperationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncOperationsTable,
    SyncOperationRow,
    $$SyncOperationsTableFilterComposer,
    $$SyncOperationsTableOrderingComposer,
    $$SyncOperationsTableAnnotationComposer,
    $$SyncOperationsTableCreateCompanionBuilder,
    $$SyncOperationsTableUpdateCompanionBuilder,
    (
      SyncOperationRow,
      BaseReferences<_$AppDatabase, $SyncOperationsTable, SyncOperationRow>
    ),
    SyncOperationRow,
    PrefetchHooks Function()> {
  $$SyncOperationsTableTableManager(
      _$AppDatabase db, $SyncOperationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOperationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOperationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOperationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entity = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> operationType = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncOperationsCompanion(
            id: id,
            entity: entity,
            entityId: entityId,
            operationType: operationType,
            payloadJson: payloadJson,
            createdAt: createdAt,
            completedAt: completedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entity,
            required String entityId,
            required String operationType,
            required String payloadJson,
            required DateTime createdAt,
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncOperationsCompanion.insert(
            id: id,
            entity: entity,
            entityId: entityId,
            operationType: operationType,
            payloadJson: payloadJson,
            createdAt: createdAt,
            completedAt: completedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncOperationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncOperationsTable,
    SyncOperationRow,
    $$SyncOperationsTableFilterComposer,
    $$SyncOperationsTableOrderingComposer,
    $$SyncOperationsTableAnnotationComposer,
    $$SyncOperationsTableCreateCompanionBuilder,
    $$SyncOperationsTableUpdateCompanionBuilder,
    (
      SyncOperationRow,
      BaseReferences<_$AppDatabase, $SyncOperationsTable, SyncOperationRow>
    ),
    SyncOperationRow,
    PrefetchHooks Function()>;
typedef $$SyncMetadataTableCreateCompanionBuilder = SyncMetadataCompanion
    Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SyncMetadataTableUpdateCompanionBuilder = SyncMetadataCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SyncMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$SyncMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$SyncMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableAnnotationComposer({
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

class $$SyncMetadataTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncMetadataTable,
    SyncMetadataRow,
    $$SyncMetadataTableFilterComposer,
    $$SyncMetadataTableOrderingComposer,
    $$SyncMetadataTableAnnotationComposer,
    $$SyncMetadataTableCreateCompanionBuilder,
    $$SyncMetadataTableUpdateCompanionBuilder,
    (
      SyncMetadataRow,
      BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataRow>
    ),
    SyncMetadataRow,
    PrefetchHooks Function()> {
  $$SyncMetadataTableTableManager(_$AppDatabase db, $SyncMetadataTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncMetadataCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncMetadataCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncMetadataTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncMetadataTable,
    SyncMetadataRow,
    $$SyncMetadataTableFilterComposer,
    $$SyncMetadataTableOrderingComposer,
    $$SyncMetadataTableAnnotationComposer,
    $$SyncMetadataTableCreateCompanionBuilder,
    $$SyncMetadataTableUpdateCompanionBuilder,
    (
      SyncMetadataRow,
      BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataRow>
    ),
    SyncMetadataRow,
    PrefetchHooks Function()>;
typedef $$LocalSettingsTableCreateCompanionBuilder = LocalSettingsCompanion
    Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$LocalSettingsTableUpdateCompanionBuilder = LocalSettingsCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$LocalSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSettingsTable> {
  $$LocalSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$LocalSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSettingsTable> {
  $$LocalSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$LocalSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSettingsTable> {
  $$LocalSettingsTableAnnotationComposer({
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

class $$LocalSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalSettingsTable,
    LocalSettingRow,
    $$LocalSettingsTableFilterComposer,
    $$LocalSettingsTableOrderingComposer,
    $$LocalSettingsTableAnnotationComposer,
    $$LocalSettingsTableCreateCompanionBuilder,
    $$LocalSettingsTableUpdateCompanionBuilder,
    (
      LocalSettingRow,
      BaseReferences<_$AppDatabase, $LocalSettingsTable, LocalSettingRow>
    ),
    LocalSettingRow,
    PrefetchHooks Function()> {
  $$LocalSettingsTableTableManager(_$AppDatabase db, $LocalSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalSettingsCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalSettingsCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalSettingsTable,
    LocalSettingRow,
    $$LocalSettingsTableFilterComposer,
    $$LocalSettingsTableOrderingComposer,
    $$LocalSettingsTableAnnotationComposer,
    $$LocalSettingsTableCreateCompanionBuilder,
    $$LocalSettingsTableUpdateCompanionBuilder,
    (
      LocalSettingRow,
      BaseReferences<_$AppDatabase, $LocalSettingsTable, LocalSettingRow>
    ),
    LocalSettingRow,
    PrefetchHooks Function()>;
typedef $$AiJobsTableCreateCompanionBuilder = AiJobsCompanion Function({
  required String id,
  required String jobType,
  required String subjectId,
  required String status,
  required String idempotencyKey,
  required String inputHash,
  required String inputVersion,
  Value<int> attemptCount,
  Value<int> maxAttempts,
  Value<DateTime?> nextRetryAt,
  Value<String> promptVersion,
  Value<String> modelVersion,
  Value<String> schemaVersion,
  Value<String?> resultJson,
  Value<String?> errorJson,
  Value<String?> pendingAction,
  Value<DateTime?> startedAt,
  Value<DateTime?> completedAt,
  Value<DateTime?> dismissedAt,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$AiJobsTableUpdateCompanionBuilder = AiJobsCompanion Function({
  Value<String> id,
  Value<String> jobType,
  Value<String> subjectId,
  Value<String> status,
  Value<String> idempotencyKey,
  Value<String> inputHash,
  Value<String> inputVersion,
  Value<int> attemptCount,
  Value<int> maxAttempts,
  Value<DateTime?> nextRetryAt,
  Value<String> promptVersion,
  Value<String> modelVersion,
  Value<String> schemaVersion,
  Value<String?> resultJson,
  Value<String?> errorJson,
  Value<String?> pendingAction,
  Value<DateTime?> startedAt,
  Value<DateTime?> completedAt,
  Value<DateTime?> dismissedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$AiJobsTableFilterComposer
    extends Composer<_$AppDatabase, $AiJobsTable> {
  $$AiJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get jobType => $composableBuilder(
      column: $table.jobType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get inputHash => $composableBuilder(
      column: $table.inputHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get inputVersion => $composableBuilder(
      column: $table.inputVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attemptCount => $composableBuilder(
      column: $table.attemptCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxAttempts => $composableBuilder(
      column: $table.maxAttempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextRetryAt => $composableBuilder(
      column: $table.nextRetryAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get promptVersion => $composableBuilder(
      column: $table.promptVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modelVersion => $composableBuilder(
      column: $table.modelVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get schemaVersion => $composableBuilder(
      column: $table.schemaVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resultJson => $composableBuilder(
      column: $table.resultJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorJson => $composableBuilder(
      column: $table.errorJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pendingAction => $composableBuilder(
      column: $table.pendingAction, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dismissedAt => $composableBuilder(
      column: $table.dismissedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$AiJobsTableOrderingComposer
    extends Composer<_$AppDatabase, $AiJobsTable> {
  $$AiJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get jobType => $composableBuilder(
      column: $table.jobType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get inputHash => $composableBuilder(
      column: $table.inputHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get inputVersion => $composableBuilder(
      column: $table.inputVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attemptCount => $composableBuilder(
      column: $table.attemptCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxAttempts => $composableBuilder(
      column: $table.maxAttempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextRetryAt => $composableBuilder(
      column: $table.nextRetryAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get promptVersion => $composableBuilder(
      column: $table.promptVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modelVersion => $composableBuilder(
      column: $table.modelVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get schemaVersion => $composableBuilder(
      column: $table.schemaVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resultJson => $composableBuilder(
      column: $table.resultJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorJson => $composableBuilder(
      column: $table.errorJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pendingAction => $composableBuilder(
      column: $table.pendingAction,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dismissedAt => $composableBuilder(
      column: $table.dismissedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AiJobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiJobsTable> {
  $$AiJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get jobType =>
      $composableBuilder(column: $table.jobType, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey, builder: (column) => column);

  GeneratedColumn<String> get inputHash =>
      $composableBuilder(column: $table.inputHash, builder: (column) => column);

  GeneratedColumn<String> get inputVersion => $composableBuilder(
      column: $table.inputVersion, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
      column: $table.attemptCount, builder: (column) => column);

  GeneratedColumn<int> get maxAttempts => $composableBuilder(
      column: $table.maxAttempts, builder: (column) => column);

  GeneratedColumn<DateTime> get nextRetryAt => $composableBuilder(
      column: $table.nextRetryAt, builder: (column) => column);

  GeneratedColumn<String> get promptVersion => $composableBuilder(
      column: $table.promptVersion, builder: (column) => column);

  GeneratedColumn<String> get modelVersion => $composableBuilder(
      column: $table.modelVersion, builder: (column) => column);

  GeneratedColumn<String> get schemaVersion => $composableBuilder(
      column: $table.schemaVersion, builder: (column) => column);

  GeneratedColumn<String> get resultJson => $composableBuilder(
      column: $table.resultJson, builder: (column) => column);

  GeneratedColumn<String> get errorJson =>
      $composableBuilder(column: $table.errorJson, builder: (column) => column);

  GeneratedColumn<String> get pendingAction => $composableBuilder(
      column: $table.pendingAction, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get dismissedAt => $composableBuilder(
      column: $table.dismissedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AiJobsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AiJobsTable,
    AiJobRow,
    $$AiJobsTableFilterComposer,
    $$AiJobsTableOrderingComposer,
    $$AiJobsTableAnnotationComposer,
    $$AiJobsTableCreateCompanionBuilder,
    $$AiJobsTableUpdateCompanionBuilder,
    (AiJobRow, BaseReferences<_$AppDatabase, $AiJobsTable, AiJobRow>),
    AiJobRow,
    PrefetchHooks Function()> {
  $$AiJobsTableTableManager(_$AppDatabase db, $AiJobsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> jobType = const Value.absent(),
            Value<String> subjectId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> idempotencyKey = const Value.absent(),
            Value<String> inputHash = const Value.absent(),
            Value<String> inputVersion = const Value.absent(),
            Value<int> attemptCount = const Value.absent(),
            Value<int> maxAttempts = const Value.absent(),
            Value<DateTime?> nextRetryAt = const Value.absent(),
            Value<String> promptVersion = const Value.absent(),
            Value<String> modelVersion = const Value.absent(),
            Value<String> schemaVersion = const Value.absent(),
            Value<String?> resultJson = const Value.absent(),
            Value<String?> errorJson = const Value.absent(),
            Value<String?> pendingAction = const Value.absent(),
            Value<DateTime?> startedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime?> dismissedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AiJobsCompanion(
            id: id,
            jobType: jobType,
            subjectId: subjectId,
            status: status,
            idempotencyKey: idempotencyKey,
            inputHash: inputHash,
            inputVersion: inputVersion,
            attemptCount: attemptCount,
            maxAttempts: maxAttempts,
            nextRetryAt: nextRetryAt,
            promptVersion: promptVersion,
            modelVersion: modelVersion,
            schemaVersion: schemaVersion,
            resultJson: resultJson,
            errorJson: errorJson,
            pendingAction: pendingAction,
            startedAt: startedAt,
            completedAt: completedAt,
            dismissedAt: dismissedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String jobType,
            required String subjectId,
            required String status,
            required String idempotencyKey,
            required String inputHash,
            required String inputVersion,
            Value<int> attemptCount = const Value.absent(),
            Value<int> maxAttempts = const Value.absent(),
            Value<DateTime?> nextRetryAt = const Value.absent(),
            Value<String> promptVersion = const Value.absent(),
            Value<String> modelVersion = const Value.absent(),
            Value<String> schemaVersion = const Value.absent(),
            Value<String?> resultJson = const Value.absent(),
            Value<String?> errorJson = const Value.absent(),
            Value<String?> pendingAction = const Value.absent(),
            Value<DateTime?> startedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime?> dismissedAt = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AiJobsCompanion.insert(
            id: id,
            jobType: jobType,
            subjectId: subjectId,
            status: status,
            idempotencyKey: idempotencyKey,
            inputHash: inputHash,
            inputVersion: inputVersion,
            attemptCount: attemptCount,
            maxAttempts: maxAttempts,
            nextRetryAt: nextRetryAt,
            promptVersion: promptVersion,
            modelVersion: modelVersion,
            schemaVersion: schemaVersion,
            resultJson: resultJson,
            errorJson: errorJson,
            pendingAction: pendingAction,
            startedAt: startedAt,
            completedAt: completedAt,
            dismissedAt: dismissedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AiJobsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AiJobsTable,
    AiJobRow,
    $$AiJobsTableFilterComposer,
    $$AiJobsTableOrderingComposer,
    $$AiJobsTableAnnotationComposer,
    $$AiJobsTableCreateCompanionBuilder,
    $$AiJobsTableUpdateCompanionBuilder,
    (AiJobRow, BaseReferences<_$AppDatabase, $AiJobsTable, AiJobRow>),
    AiJobRow,
    PrefetchHooks Function()>;
typedef $$ProcessingOutboxTableCreateCompanionBuilder
    = ProcessingOutboxCompanion Function({
  required String id,
  required String requestKind,
  required String subjectId,
  required String payloadJson,
  required String deliveryState,
  required String adoptionState,
  Value<String?> privacyNoticeVersion,
  Value<String> idempotencyKey,
  Value<String?> serverJobId,
  Value<DateTime?> serverExpiresAt,
  Value<String> uploadedAssetIdsJson,
  Value<String?> resultPayloadJson,
  Value<String?> resultSchemaVersion,
  Value<int> attemptCount,
  Value<DateTime?> nextRetryAt,
  Value<String?> failureCode,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ProcessingOutboxTableUpdateCompanionBuilder
    = ProcessingOutboxCompanion Function({
  Value<String> id,
  Value<String> requestKind,
  Value<String> subjectId,
  Value<String> payloadJson,
  Value<String> deliveryState,
  Value<String> adoptionState,
  Value<String?> privacyNoticeVersion,
  Value<String> idempotencyKey,
  Value<String?> serverJobId,
  Value<DateTime?> serverExpiresAt,
  Value<String> uploadedAssetIdsJson,
  Value<String?> resultPayloadJson,
  Value<String?> resultSchemaVersion,
  Value<int> attemptCount,
  Value<DateTime?> nextRetryAt,
  Value<String?> failureCode,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ProcessingOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $ProcessingOutboxTable> {
  $$ProcessingOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get requestKind => $composableBuilder(
      column: $table.requestKind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deliveryState => $composableBuilder(
      column: $table.deliveryState, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get adoptionState => $composableBuilder(
      column: $table.adoptionState, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get privacyNoticeVersion => $composableBuilder(
      column: $table.privacyNoticeVersion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverJobId => $composableBuilder(
      column: $table.serverJobId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get serverExpiresAt => $composableBuilder(
      column: $table.serverExpiresAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uploadedAssetIdsJson => $composableBuilder(
      column: $table.uploadedAssetIdsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resultPayloadJson => $composableBuilder(
      column: $table.resultPayloadJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resultSchemaVersion => $composableBuilder(
      column: $table.resultSchemaVersion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attemptCount => $composableBuilder(
      column: $table.attemptCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextRetryAt => $composableBuilder(
      column: $table.nextRetryAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get failureCode => $composableBuilder(
      column: $table.failureCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ProcessingOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $ProcessingOutboxTable> {
  $$ProcessingOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get requestKind => $composableBuilder(
      column: $table.requestKind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deliveryState => $composableBuilder(
      column: $table.deliveryState,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get adoptionState => $composableBuilder(
      column: $table.adoptionState,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get privacyNoticeVersion => $composableBuilder(
      column: $table.privacyNoticeVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverJobId => $composableBuilder(
      column: $table.serverJobId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get serverExpiresAt => $composableBuilder(
      column: $table.serverExpiresAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uploadedAssetIdsJson => $composableBuilder(
      column: $table.uploadedAssetIdsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resultPayloadJson => $composableBuilder(
      column: $table.resultPayloadJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resultSchemaVersion => $composableBuilder(
      column: $table.resultSchemaVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attemptCount => $composableBuilder(
      column: $table.attemptCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextRetryAt => $composableBuilder(
      column: $table.nextRetryAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get failureCode => $composableBuilder(
      column: $table.failureCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ProcessingOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProcessingOutboxTable> {
  $$ProcessingOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get requestKind => $composableBuilder(
      column: $table.requestKind, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<String> get deliveryState => $composableBuilder(
      column: $table.deliveryState, builder: (column) => column);

  GeneratedColumn<String> get adoptionState => $composableBuilder(
      column: $table.adoptionState, builder: (column) => column);

  GeneratedColumn<String> get privacyNoticeVersion => $composableBuilder(
      column: $table.privacyNoticeVersion, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey, builder: (column) => column);

  GeneratedColumn<String> get serverJobId => $composableBuilder(
      column: $table.serverJobId, builder: (column) => column);

  GeneratedColumn<DateTime> get serverExpiresAt => $composableBuilder(
      column: $table.serverExpiresAt, builder: (column) => column);

  GeneratedColumn<String> get uploadedAssetIdsJson => $composableBuilder(
      column: $table.uploadedAssetIdsJson, builder: (column) => column);

  GeneratedColumn<String> get resultPayloadJson => $composableBuilder(
      column: $table.resultPayloadJson, builder: (column) => column);

  GeneratedColumn<String> get resultSchemaVersion => $composableBuilder(
      column: $table.resultSchemaVersion, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
      column: $table.attemptCount, builder: (column) => column);

  GeneratedColumn<DateTime> get nextRetryAt => $composableBuilder(
      column: $table.nextRetryAt, builder: (column) => column);

  GeneratedColumn<String> get failureCode => $composableBuilder(
      column: $table.failureCode, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProcessingOutboxTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProcessingOutboxTable,
    ProcessingOutboxRow,
    $$ProcessingOutboxTableFilterComposer,
    $$ProcessingOutboxTableOrderingComposer,
    $$ProcessingOutboxTableAnnotationComposer,
    $$ProcessingOutboxTableCreateCompanionBuilder,
    $$ProcessingOutboxTableUpdateCompanionBuilder,
    (
      ProcessingOutboxRow,
      BaseReferences<_$AppDatabase, $ProcessingOutboxTable, ProcessingOutboxRow>
    ),
    ProcessingOutboxRow,
    PrefetchHooks Function()> {
  $$ProcessingOutboxTableTableManager(
      _$AppDatabase db, $ProcessingOutboxTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProcessingOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProcessingOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProcessingOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> requestKind = const Value.absent(),
            Value<String> subjectId = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<String> deliveryState = const Value.absent(),
            Value<String> adoptionState = const Value.absent(),
            Value<String?> privacyNoticeVersion = const Value.absent(),
            Value<String> idempotencyKey = const Value.absent(),
            Value<String?> serverJobId = const Value.absent(),
            Value<DateTime?> serverExpiresAt = const Value.absent(),
            Value<String> uploadedAssetIdsJson = const Value.absent(),
            Value<String?> resultPayloadJson = const Value.absent(),
            Value<String?> resultSchemaVersion = const Value.absent(),
            Value<int> attemptCount = const Value.absent(),
            Value<DateTime?> nextRetryAt = const Value.absent(),
            Value<String?> failureCode = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProcessingOutboxCompanion(
            id: id,
            requestKind: requestKind,
            subjectId: subjectId,
            payloadJson: payloadJson,
            deliveryState: deliveryState,
            adoptionState: adoptionState,
            privacyNoticeVersion: privacyNoticeVersion,
            idempotencyKey: idempotencyKey,
            serverJobId: serverJobId,
            serverExpiresAt: serverExpiresAt,
            uploadedAssetIdsJson: uploadedAssetIdsJson,
            resultPayloadJson: resultPayloadJson,
            resultSchemaVersion: resultSchemaVersion,
            attemptCount: attemptCount,
            nextRetryAt: nextRetryAt,
            failureCode: failureCode,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String requestKind,
            required String subjectId,
            required String payloadJson,
            required String deliveryState,
            required String adoptionState,
            Value<String?> privacyNoticeVersion = const Value.absent(),
            Value<String> idempotencyKey = const Value.absent(),
            Value<String?> serverJobId = const Value.absent(),
            Value<DateTime?> serverExpiresAt = const Value.absent(),
            Value<String> uploadedAssetIdsJson = const Value.absent(),
            Value<String?> resultPayloadJson = const Value.absent(),
            Value<String?> resultSchemaVersion = const Value.absent(),
            Value<int> attemptCount = const Value.absent(),
            Value<DateTime?> nextRetryAt = const Value.absent(),
            Value<String?> failureCode = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ProcessingOutboxCompanion.insert(
            id: id,
            requestKind: requestKind,
            subjectId: subjectId,
            payloadJson: payloadJson,
            deliveryState: deliveryState,
            adoptionState: adoptionState,
            privacyNoticeVersion: privacyNoticeVersion,
            idempotencyKey: idempotencyKey,
            serverJobId: serverJobId,
            serverExpiresAt: serverExpiresAt,
            uploadedAssetIdsJson: uploadedAssetIdsJson,
            resultPayloadJson: resultPayloadJson,
            resultSchemaVersion: resultSchemaVersion,
            attemptCount: attemptCount,
            nextRetryAt: nextRetryAt,
            failureCode: failureCode,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProcessingOutboxTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProcessingOutboxTable,
    ProcessingOutboxRow,
    $$ProcessingOutboxTableFilterComposer,
    $$ProcessingOutboxTableOrderingComposer,
    $$ProcessingOutboxTableAnnotationComposer,
    $$ProcessingOutboxTableCreateCompanionBuilder,
    $$ProcessingOutboxTableUpdateCompanionBuilder,
    (
      ProcessingOutboxRow,
      BaseReferences<_$AppDatabase, $ProcessingOutboxTable, ProcessingOutboxRow>
    ),
    ProcessingOutboxRow,
    PrefetchHooks Function()>;
typedef $$ProcessingConsentsTableCreateCompanionBuilder
    = ProcessingConsentsCompanion Function({
  required String noticeVersion,
  required String decision,
  required DateTime decidedAt,
  Value<int> rowid,
});
typedef $$ProcessingConsentsTableUpdateCompanionBuilder
    = ProcessingConsentsCompanion Function({
  Value<String> noticeVersion,
  Value<String> decision,
  Value<DateTime> decidedAt,
  Value<int> rowid,
});

class $$ProcessingConsentsTableFilterComposer
    extends Composer<_$AppDatabase, $ProcessingConsentsTable> {
  $$ProcessingConsentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get noticeVersion => $composableBuilder(
      column: $table.noticeVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get decision => $composableBuilder(
      column: $table.decision, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get decidedAt => $composableBuilder(
      column: $table.decidedAt, builder: (column) => ColumnFilters(column));
}

class $$ProcessingConsentsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProcessingConsentsTable> {
  $$ProcessingConsentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get noticeVersion => $composableBuilder(
      column: $table.noticeVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get decision => $composableBuilder(
      column: $table.decision, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get decidedAt => $composableBuilder(
      column: $table.decidedAt, builder: (column) => ColumnOrderings(column));
}

class $$ProcessingConsentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProcessingConsentsTable> {
  $$ProcessingConsentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get noticeVersion => $composableBuilder(
      column: $table.noticeVersion, builder: (column) => column);

  GeneratedColumn<String> get decision =>
      $composableBuilder(column: $table.decision, builder: (column) => column);

  GeneratedColumn<DateTime> get decidedAt =>
      $composableBuilder(column: $table.decidedAt, builder: (column) => column);
}

class $$ProcessingConsentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProcessingConsentsTable,
    ProcessingConsentRow,
    $$ProcessingConsentsTableFilterComposer,
    $$ProcessingConsentsTableOrderingComposer,
    $$ProcessingConsentsTableAnnotationComposer,
    $$ProcessingConsentsTableCreateCompanionBuilder,
    $$ProcessingConsentsTableUpdateCompanionBuilder,
    (
      ProcessingConsentRow,
      BaseReferences<_$AppDatabase, $ProcessingConsentsTable,
          ProcessingConsentRow>
    ),
    ProcessingConsentRow,
    PrefetchHooks Function()> {
  $$ProcessingConsentsTableTableManager(
      _$AppDatabase db, $ProcessingConsentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProcessingConsentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProcessingConsentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProcessingConsentsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> noticeVersion = const Value.absent(),
            Value<String> decision = const Value.absent(),
            Value<DateTime> decidedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProcessingConsentsCompanion(
            noticeVersion: noticeVersion,
            decision: decision,
            decidedAt: decidedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String noticeVersion,
            required String decision,
            required DateTime decidedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ProcessingConsentsCompanion.insert(
            noticeVersion: noticeVersion,
            decision: decision,
            decidedAt: decidedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProcessingConsentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProcessingConsentsTable,
    ProcessingConsentRow,
    $$ProcessingConsentsTableFilterComposer,
    $$ProcessingConsentsTableOrderingComposer,
    $$ProcessingConsentsTableAnnotationComposer,
    $$ProcessingConsentsTableCreateCompanionBuilder,
    $$ProcessingConsentsTableUpdateCompanionBuilder,
    (
      ProcessingConsentRow,
      BaseReferences<_$AppDatabase, $ProcessingConsentsTable,
          ProcessingConsentRow>
    ),
    ProcessingConsentRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DishesTableTableManager get dishes =>
      $$DishesTableTableManager(_db, _db.dishes);
  $$DishNotesTableTableManager get dishNotes =>
      $$DishNotesTableTableManager(_db, _db.dishNotes);
  $$SourcePhotosTableTableManager get sourcePhotos =>
      $$SourcePhotosTableTableManager(_db, _db.sourcePhotos);
  $$GeneratedCoversTableTableManager get generatedCovers =>
      $$GeneratedCoversTableTableManager(_db, _db.generatedCovers);
  $$CaptureBatchesTableTableManager get captureBatches =>
      $$CaptureBatchesTableTableManager(_db, _db.captureBatches);
  $$CaptureItemsTableTableManager get captureItems =>
      $$CaptureItemsTableTableManager(_db, _db.captureItems);
  $$CaptureCorrectionsTableTableManager get captureCorrections =>
      $$CaptureCorrectionsTableTableManager(_db, _db.captureCorrections);
  $$PlannedMealsTableTableManager get plannedMeals =>
      $$PlannedMealsTableTableManager(_db, _db.plannedMeals);
  $$ReviewItemsTableTableManager get reviewItems =>
      $$ReviewItemsTableTableManager(_db, _db.reviewItems);
  $$SyncOperationsTableTableManager get syncOperations =>
      $$SyncOperationsTableTableManager(_db, _db.syncOperations);
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db, _db.syncMetadata);
  $$LocalSettingsTableTableManager get localSettings =>
      $$LocalSettingsTableTableManager(_db, _db.localSettings);
  $$AiJobsTableTableManager get aiJobs =>
      $$AiJobsTableTableManager(_db, _db.aiJobs);
  $$ProcessingOutboxTableTableManager get processingOutbox =>
      $$ProcessingOutboxTableTableManager(_db, _db.processingOutbox);
  $$ProcessingConsentsTableTableManager get processingConsents =>
      $$ProcessingConsentsTableTableManager(_db, _db.processingConsents);
}
