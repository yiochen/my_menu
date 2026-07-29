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
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        description,
        heroImageUrl,
        category,
        prepMinutes,
        difficulty,
        madeCount,
        lastMadeLabel,
        ingredientsJson,
        recipeStepsJson,
        notesJson,
        isFavorite,
        createdAt
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
  const DishRow(
      {required this.id,
      required this.title,
      required this.description,
      required this.heroImageUrl,
      required this.category,
      required this.prepMinutes,
      required this.difficulty,
      required this.madeCount,
      required this.lastMadeLabel,
      required this.ingredientsJson,
      required this.recipeStepsJson,
      required this.notesJson,
      required this.isFavorite,
      this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['hero_image_url'] = Variable<String>(heroImageUrl);
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
    return map;
  }

  DishesCompanion toCompanion(bool nullToAbsent) {
    return DishesCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      heroImageUrl: Value(heroImageUrl),
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
    };
  }

  DishRow copyWith(
          {String? id,
          String? title,
          String? description,
          String? heroImageUrl,
          String? category,
          int? prepMinutes,
          String? difficulty,
          int? madeCount,
          String? lastMadeLabel,
          String? ingredientsJson,
          String? recipeStepsJson,
          String? notesJson,
          bool? isFavorite,
          Value<DateTime?> createdAt = const Value.absent()}) =>
      DishRow(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        heroImageUrl: heroImageUrl ?? this.heroImageUrl,
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
    );
  }

  @override
  String toString() {
    return (StringBuffer('DishRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('heroImageUrl: $heroImageUrl, ')
          ..write('category: $category, ')
          ..write('prepMinutes: $prepMinutes, ')
          ..write('difficulty: $difficulty, ')
          ..write('madeCount: $madeCount, ')
          ..write('lastMadeLabel: $lastMadeLabel, ')
          ..write('ingredientsJson: $ingredientsJson, ')
          ..write('recipeStepsJson: $recipeStepsJson, ')
          ..write('notesJson: $notesJson, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      description,
      heroImageUrl,
      category,
      prepMinutes,
      difficulty,
      madeCount,
      lastMadeLabel,
      ingredientsJson,
      recipeStepsJson,
      notesJson,
      isFavorite,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DishRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.heroImageUrl == this.heroImageUrl &&
          other.category == this.category &&
          other.prepMinutes == this.prepMinutes &&
          other.difficulty == this.difficulty &&
          other.madeCount == this.madeCount &&
          other.lastMadeLabel == this.lastMadeLabel &&
          other.ingredientsJson == this.ingredientsJson &&
          other.recipeStepsJson == this.recipeStepsJson &&
          other.notesJson == this.notesJson &&
          other.isFavorite == this.isFavorite &&
          other.createdAt == this.createdAt);
}

class DishesCompanion extends UpdateCompanion<DishRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<String> heroImageUrl;
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
  final Value<int> rowid;
  const DishesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.heroImageUrl = const Value.absent(),
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
    this.rowid = const Value.absent(),
  });
  DishesCompanion.insert({
    required String id,
    required String title,
    required String description,
    required String heroImageUrl,
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
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (heroImageUrl != null) 'hero_image_url': heroImageUrl,
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
      if (rowid != null) 'rowid': rowid,
    });
  }

  DishesCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? description,
      Value<String>? heroImageUrl,
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
      Value<int>? rowid}) {
    return DishesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      heroImageUrl: heroImageUrl ?? this.heroImageUrl,
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
  static const VerificationMeta _capturedLabelMeta =
      const VerificationMeta('capturedLabel');
  @override
  late final GeneratedColumn<String> capturedLabel = GeneratedColumn<String>(
      'captured_label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
        capturedLabel,
        note,
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
    if (data.containsKey('captured_label')) {
      context.handle(
          _capturedLabelMeta,
          capturedLabel.isAcceptableOrUnknown(
              data['captured_label']!, _capturedLabelMeta));
    } else if (isInserting) {
      context.missing(_capturedLabelMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
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
      capturedLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}captured_label'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
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
  final String capturedLabel;
  final String? note;
  final String? confidenceLabel;
  final String? captureId;
  final String? cookingOccasionId;
  final DateTime? capturedAt;
  const SourcePhotoRow(
      {required this.id,
      required this.dishId,
      required this.url,
      required this.capturedLabel,
      this.note,
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
    map['captured_label'] = Variable<String>(capturedLabel);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
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
      capturedLabel: Value(capturedLabel),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
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
      capturedLabel: serializer.fromJson<String>(json['capturedLabel']),
      note: serializer.fromJson<String?>(json['note']),
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
      'capturedLabel': serializer.toJson<String>(capturedLabel),
      'note': serializer.toJson<String?>(note),
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
          String? capturedLabel,
          Value<String?> note = const Value.absent(),
          Value<String?> confidenceLabel = const Value.absent(),
          Value<String?> captureId = const Value.absent(),
          Value<String?> cookingOccasionId = const Value.absent(),
          Value<DateTime?> capturedAt = const Value.absent()}) =>
      SourcePhotoRow(
        id: id ?? this.id,
        dishId: dishId ?? this.dishId,
        url: url ?? this.url,
        capturedLabel: capturedLabel ?? this.capturedLabel,
        note: note.present ? note.value : this.note,
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
      capturedLabel: data.capturedLabel.present
          ? data.capturedLabel.value
          : this.capturedLabel,
      note: data.note.present ? data.note.value : this.note,
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
          ..write('capturedLabel: $capturedLabel, ')
          ..write('note: $note, ')
          ..write('confidenceLabel: $confidenceLabel, ')
          ..write('captureId: $captureId, ')
          ..write('cookingOccasionId: $cookingOccasionId, ')
          ..write('capturedAt: $capturedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dishId, url, capturedLabel, note,
      confidenceLabel, captureId, cookingOccasionId, capturedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SourcePhotoRow &&
          other.id == this.id &&
          other.dishId == this.dishId &&
          other.url == this.url &&
          other.capturedLabel == this.capturedLabel &&
          other.note == this.note &&
          other.confidenceLabel == this.confidenceLabel &&
          other.captureId == this.captureId &&
          other.cookingOccasionId == this.cookingOccasionId &&
          other.capturedAt == this.capturedAt);
}

class SourcePhotosCompanion extends UpdateCompanion<SourcePhotoRow> {
  final Value<String> id;
  final Value<String> dishId;
  final Value<String> url;
  final Value<String> capturedLabel;
  final Value<String?> note;
  final Value<String?> confidenceLabel;
  final Value<String?> captureId;
  final Value<String?> cookingOccasionId;
  final Value<DateTime?> capturedAt;
  final Value<int> rowid;
  const SourcePhotosCompanion({
    this.id = const Value.absent(),
    this.dishId = const Value.absent(),
    this.url = const Value.absent(),
    this.capturedLabel = const Value.absent(),
    this.note = const Value.absent(),
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
    required String capturedLabel,
    this.note = const Value.absent(),
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
    Expression<String>? capturedLabel,
    Expression<String>? note,
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
      if (capturedLabel != null) 'captured_label': capturedLabel,
      if (note != null) 'note': note,
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
      Value<String>? capturedLabel,
      Value<String?>? note,
      Value<String?>? confidenceLabel,
      Value<String?>? captureId,
      Value<String?>? cookingOccasionId,
      Value<DateTime?>? capturedAt,
      Value<int>? rowid}) {
    return SourcePhotosCompanion(
      id: id ?? this.id,
      dishId: dishId ?? this.dishId,
      url: url ?? this.url,
      capturedLabel: capturedLabel ?? this.capturedLabel,
      note: note ?? this.note,
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
    if (capturedLabel.present) {
      map['captured_label'] = Variable<String>(capturedLabel.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
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
          ..write('capturedLabel: $capturedLabel, ')
          ..write('note: $note, ')
          ..write('confidenceLabel: $confidenceLabel, ')
          ..write('captureId: $captureId, ')
          ..write('cookingOccasionId: $cookingOccasionId, ')
          ..write('capturedAt: $capturedAt, ')
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
  @override
  List<GeneratedColumn> get $columns => [id, dayKey, dishId, label];
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
  const PlannedMealRow(
      {required this.id,
      required this.dayKey,
      required this.dishId,
      this.label});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['day_key'] = Variable<String>(dayKey);
    map['dish_id'] = Variable<String>(dishId);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    return map;
  }

  PlannedMealsCompanion toCompanion(bool nullToAbsent) {
    return PlannedMealsCompanion(
      id: Value(id),
      dayKey: Value(dayKey),
      dishId: Value(dishId),
      label:
          label == null && nullToAbsent ? const Value.absent() : Value(label),
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
    };
  }

  PlannedMealRow copyWith(
          {String? id,
          String? dayKey,
          String? dishId,
          Value<String?> label = const Value.absent()}) =>
      PlannedMealRow(
        id: id ?? this.id,
        dayKey: dayKey ?? this.dayKey,
        dishId: dishId ?? this.dishId,
        label: label.present ? label.value : this.label,
      );
  PlannedMealRow copyWithCompanion(PlannedMealsCompanion data) {
    return PlannedMealRow(
      id: data.id.present ? data.id.value : this.id,
      dayKey: data.dayKey.present ? data.dayKey.value : this.dayKey,
      dishId: data.dishId.present ? data.dishId.value : this.dishId,
      label: data.label.present ? data.label.value : this.label,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlannedMealRow(')
          ..write('id: $id, ')
          ..write('dayKey: $dayKey, ')
          ..write('dishId: $dishId, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dayKey, dishId, label);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlannedMealRow &&
          other.id == this.id &&
          other.dayKey == this.dayKey &&
          other.dishId == this.dishId &&
          other.label == this.label);
}

class PlannedMealsCompanion extends UpdateCompanion<PlannedMealRow> {
  final Value<String> id;
  final Value<String> dayKey;
  final Value<String> dishId;
  final Value<String?> label;
  final Value<int> rowid;
  const PlannedMealsCompanion({
    this.id = const Value.absent(),
    this.dayKey = const Value.absent(),
    this.dishId = const Value.absent(),
    this.label = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlannedMealsCompanion.insert({
    required String id,
    required String dayKey,
    required String dishId,
    this.label = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        dayKey = Value(dayKey),
        dishId = Value(dishId);
  static Insertable<PlannedMealRow> custom({
    Expression<String>? id,
    Expression<String>? dayKey,
    Expression<String>? dishId,
    Expression<String>? label,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dayKey != null) 'day_key': dayKey,
      if (dishId != null) 'dish_id': dishId,
      if (label != null) 'label': label,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlannedMealsCompanion copyWith(
      {Value<String>? id,
      Value<String>? dayKey,
      Value<String>? dishId,
      Value<String?>? label,
      Value<int>? rowid}) {
    return PlannedMealsCompanion(
      id: id ?? this.id,
      dayKey: dayKey ?? this.dayKey,
      dishId: dishId ?? this.dishId,
      label: label ?? this.label,
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DishesTable dishes = $DishesTable(this);
  late final $DishNotesTable dishNotes = $DishNotesTable(this);
  late final $SourcePhotosTable sourcePhotos = $SourcePhotosTable(this);
  late final $CaptureBatchesTable captureBatches = $CaptureBatchesTable(this);
  late final $CaptureItemsTable captureItems = $CaptureItemsTable(this);
  late final $CaptureCorrectionsTable captureCorrections =
      $CaptureCorrectionsTable(this);
  late final $PlannedMealsTable plannedMeals = $PlannedMealsTable(this);
  late final $ReviewItemsTable reviewItems = $ReviewItemsTable(this);
  late final $SyncOperationsTable syncOperations = $SyncOperationsTable(this);
  late final $SyncMetadataTable syncMetadata = $SyncMetadataTable(this);
  late final $AiJobsTable aiJobs = $AiJobsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        dishes,
        dishNotes,
        sourcePhotos,
        captureBatches,
        captureItems,
        captureCorrections,
        plannedMeals,
        reviewItems,
        syncOperations,
        syncMetadata,
        aiJobs
      ];
}

typedef $$DishesTableCreateCompanionBuilder = DishesCompanion Function({
  required String id,
  required String title,
  required String description,
  required String heroImageUrl,
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
  Value<int> rowid,
});
typedef $$DishesTableUpdateCompanionBuilder = DishesCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> description,
  Value<String> heroImageUrl,
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
            Value<int> rowid = const Value.absent(),
          }) =>
              DishesCompanion(
            id: id,
            title: title,
            description: description,
            heroImageUrl: heroImageUrl,
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
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String description,
            required String heroImageUrl,
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
            Value<int> rowid = const Value.absent(),
          }) =>
              DishesCompanion.insert(
            id: id,
            title: title,
            description: description,
            heroImageUrl: heroImageUrl,
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
  required String capturedLabel,
  Value<String?> note,
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
  Value<String> capturedLabel,
  Value<String?> note,
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

  ColumnFilters<String> get capturedLabel => $composableBuilder(
      column: $table.capturedLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<String> get capturedLabel => $composableBuilder(
      column: $table.capturedLabel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<String> get capturedLabel => $composableBuilder(
      column: $table.capturedLabel, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

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
            Value<String> capturedLabel = const Value.absent(),
            Value<String?> note = const Value.absent(),
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
            capturedLabel: capturedLabel,
            note: note,
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
            required String capturedLabel,
            Value<String?> note = const Value.absent(),
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
            capturedLabel: capturedLabel,
            note: note,
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
  Value<int> rowid,
});
typedef $$PlannedMealsTableUpdateCompanionBuilder = PlannedMealsCompanion
    Function({
  Value<String> id,
  Value<String> dayKey,
  Value<String> dishId,
  Value<String?> label,
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
            Value<int> rowid = const Value.absent(),
          }) =>
              PlannedMealsCompanion(
            id: id,
            dayKey: dayKey,
            dishId: dishId,
            label: label,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String dayKey,
            required String dishId,
            Value<String?> label = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlannedMealsCompanion.insert(
            id: id,
            dayKey: dayKey,
            dishId: dishId,
            label: label,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DishesTableTableManager get dishes =>
      $$DishesTableTableManager(_db, _db.dishes);
  $$DishNotesTableTableManager get dishNotes =>
      $$DishNotesTableTableManager(_db, _db.dishNotes);
  $$SourcePhotosTableTableManager get sourcePhotos =>
      $$SourcePhotosTableTableManager(_db, _db.sourcePhotos);
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
  $$AiJobsTableTableManager get aiJobs =>
      $$AiJobsTableTableManager(_db, _db.aiJobs);
}
