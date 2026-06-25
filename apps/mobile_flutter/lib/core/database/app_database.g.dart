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
        isFavorite
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
      required this.isFavorite});
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
          bool? isFavorite}) =>
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
          ..write('isFavorite: $isFavorite')
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
      isFavorite);
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
          other.isFavorite == this.isFavorite);
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
  @override
  List<GeneratedColumn> get $columns =>
      [id, dishId, url, capturedLabel, note, confidenceLabel];
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
  const SourcePhotoRow(
      {required this.id,
      required this.dishId,
      required this.url,
      required this.capturedLabel,
      this.note,
      this.confidenceLabel});
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
    };
  }

  SourcePhotoRow copyWith(
          {String? id,
          String? dishId,
          String? url,
          String? capturedLabel,
          Value<String?> note = const Value.absent(),
          Value<String?> confidenceLabel = const Value.absent()}) =>
      SourcePhotoRow(
        id: id ?? this.id,
        dishId: dishId ?? this.dishId,
        url: url ?? this.url,
        capturedLabel: capturedLabel ?? this.capturedLabel,
        note: note.present ? note.value : this.note,
        confidenceLabel: confidenceLabel.present
            ? confidenceLabel.value
            : this.confidenceLabel,
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
          ..write('confidenceLabel: $confidenceLabel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, dishId, url, capturedLabel, note, confidenceLabel);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SourcePhotoRow &&
          other.id == this.id &&
          other.dishId == this.dishId &&
          other.url == this.url &&
          other.capturedLabel == this.capturedLabel &&
          other.note == this.note &&
          other.confidenceLabel == this.confidenceLabel);
}

class SourcePhotosCompanion extends UpdateCompanion<SourcePhotoRow> {
  final Value<String> id;
  final Value<String> dishId;
  final Value<String> url;
  final Value<String> capturedLabel;
  final Value<String?> note;
  final Value<String?> confidenceLabel;
  final Value<int> rowid;
  const SourcePhotosCompanion({
    this.id = const Value.absent(),
    this.dishId = const Value.absent(),
    this.url = const Value.absent(),
    this.capturedLabel = const Value.absent(),
    this.note = const Value.absent(),
    this.confidenceLabel = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SourcePhotosCompanion.insert({
    required String id,
    required String dishId,
    required String url,
    required String capturedLabel,
    this.note = const Value.absent(),
    this.confidenceLabel = const Value.absent(),
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
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dishId != null) 'dish_id': dishId,
      if (url != null) 'url': url,
      if (capturedLabel != null) 'captured_label': capturedLabel,
      if (note != null) 'note': note,
      if (confidenceLabel != null) 'confidence_label': confidenceLabel,
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
      Value<int>? rowid}) {
    return SourcePhotosCompanion(
      id: id ?? this.id,
      dishId: dishId ?? this.dishId,
      url: url ?? this.url,
      capturedLabel: capturedLabel ?? this.capturedLabel,
      note: note ?? this.note,
      confidenceLabel: confidenceLabel ?? this.confidenceLabel,
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
  static const VerificationMeta _appliedDishIdMeta =
      const VerificationMeta('appliedDishId');
  @override
  late final GeneratedColumn<String> appliedDishId = GeneratedColumn<String>(
      'applied_dish_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        kind,
        status,
        createdAt,
        localMediaRef,
        remoteMediaRef,
        ideaText,
        appliedDishId
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
    if (data.containsKey('applied_dish_id')) {
      context.handle(
          _appliedDishIdMeta,
          appliedDishId.isAcceptableOrUnknown(
              data['applied_dish_id']!, _appliedDishIdMeta));
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
      appliedDishId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}applied_dish_id']),
    );
  }

  @override
  $CaptureItemsTable createAlias(String alias) {
    return $CaptureItemsTable(attachedDatabase, alias);
  }
}

class CaptureItemRow extends DataClass implements Insertable<CaptureItemRow> {
  final String id;
  final String kind;
  final String status;
  final DateTime createdAt;
  final String? localMediaRef;
  final String? remoteMediaRef;
  final String? ideaText;
  final String? appliedDishId;
  const CaptureItemRow(
      {required this.id,
      required this.kind,
      required this.status,
      required this.createdAt,
      this.localMediaRef,
      this.remoteMediaRef,
      this.ideaText,
      this.appliedDishId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
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
    if (!nullToAbsent || appliedDishId != null) {
      map['applied_dish_id'] = Variable<String>(appliedDishId);
    }
    return map;
  }

  CaptureItemsCompanion toCompanion(bool nullToAbsent) {
    return CaptureItemsCompanion(
      id: Value(id),
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
      appliedDishId: appliedDishId == null && nullToAbsent
          ? const Value.absent()
          : Value(appliedDishId),
    );
  }

  factory CaptureItemRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CaptureItemRow(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      localMediaRef: serializer.fromJson<String?>(json['localMediaRef']),
      remoteMediaRef: serializer.fromJson<String?>(json['remoteMediaRef']),
      ideaText: serializer.fromJson<String?>(json['ideaText']),
      appliedDishId: serializer.fromJson<String?>(json['appliedDishId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'localMediaRef': serializer.toJson<String?>(localMediaRef),
      'remoteMediaRef': serializer.toJson<String?>(remoteMediaRef),
      'ideaText': serializer.toJson<String?>(ideaText),
      'appliedDishId': serializer.toJson<String?>(appliedDishId),
    };
  }

  CaptureItemRow copyWith(
          {String? id,
          String? kind,
          String? status,
          DateTime? createdAt,
          Value<String?> localMediaRef = const Value.absent(),
          Value<String?> remoteMediaRef = const Value.absent(),
          Value<String?> ideaText = const Value.absent(),
          Value<String?> appliedDishId = const Value.absent()}) =>
      CaptureItemRow(
        id: id ?? this.id,
        kind: kind ?? this.kind,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        localMediaRef:
            localMediaRef.present ? localMediaRef.value : this.localMediaRef,
        remoteMediaRef:
            remoteMediaRef.present ? remoteMediaRef.value : this.remoteMediaRef,
        ideaText: ideaText.present ? ideaText.value : this.ideaText,
        appliedDishId:
            appliedDishId.present ? appliedDishId.value : this.appliedDishId,
      );
  CaptureItemRow copyWithCompanion(CaptureItemsCompanion data) {
    return CaptureItemRow(
      id: data.id.present ? data.id.value : this.id,
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
      appliedDishId: data.appliedDishId.present
          ? data.appliedDishId.value
          : this.appliedDishId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CaptureItemRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('localMediaRef: $localMediaRef, ')
          ..write('remoteMediaRef: $remoteMediaRef, ')
          ..write('ideaText: $ideaText, ')
          ..write('appliedDishId: $appliedDishId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, kind, status, createdAt, localMediaRef,
      remoteMediaRef, ideaText, appliedDishId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CaptureItemRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.localMediaRef == this.localMediaRef &&
          other.remoteMediaRef == this.remoteMediaRef &&
          other.ideaText == this.ideaText &&
          other.appliedDishId == this.appliedDishId);
}

class CaptureItemsCompanion extends UpdateCompanion<CaptureItemRow> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<String?> localMediaRef;
  final Value<String?> remoteMediaRef;
  final Value<String?> ideaText;
  final Value<String?> appliedDishId;
  final Value<int> rowid;
  const CaptureItemsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.localMediaRef = const Value.absent(),
    this.remoteMediaRef = const Value.absent(),
    this.ideaText = const Value.absent(),
    this.appliedDishId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CaptureItemsCompanion.insert({
    required String id,
    required String kind,
    required String status,
    required DateTime createdAt,
    this.localMediaRef = const Value.absent(),
    this.remoteMediaRef = const Value.absent(),
    this.ideaText = const Value.absent(),
    this.appliedDishId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        kind = Value(kind),
        status = Value(status),
        createdAt = Value(createdAt);
  static Insertable<CaptureItemRow> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<String>? localMediaRef,
    Expression<String>? remoteMediaRef,
    Expression<String>? ideaText,
    Expression<String>? appliedDishId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (localMediaRef != null) 'local_media_ref': localMediaRef,
      if (remoteMediaRef != null) 'remote_media_ref': remoteMediaRef,
      if (ideaText != null) 'idea_text': ideaText,
      if (appliedDishId != null) 'applied_dish_id': appliedDishId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CaptureItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? kind,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<String?>? localMediaRef,
      Value<String?>? remoteMediaRef,
      Value<String?>? ideaText,
      Value<String?>? appliedDishId,
      Value<int>? rowid}) {
    return CaptureItemsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      localMediaRef: localMediaRef ?? this.localMediaRef,
      remoteMediaRef: remoteMediaRef ?? this.remoteMediaRef,
      ideaText: ideaText ?? this.ideaText,
      appliedDishId: appliedDishId ?? this.appliedDishId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
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
    if (appliedDishId.present) {
      map['applied_dish_id'] = Variable<String>(appliedDishId.value);
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
          ..write('kind: $kind, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('localMediaRef: $localMediaRef, ')
          ..write('remoteMediaRef: $remoteMediaRef, ')
          ..write('ideaText: $ideaText, ')
          ..write('appliedDishId: $appliedDishId, ')
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
      [id, summary, suggestedDishIdsJson, confidenceLabel, imageRef];
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
  final String summary;
  final String suggestedDishIdsJson;
  final String confidenceLabel;
  final String? imageRef;
  const ReviewItemRow(
      {required this.id,
      required this.summary,
      required this.suggestedDishIdsJson,
      required this.confidenceLabel,
      this.imageRef});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
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
      'summary': serializer.toJson<String>(summary),
      'suggestedDishIdsJson': serializer.toJson<String>(suggestedDishIdsJson),
      'confidenceLabel': serializer.toJson<String>(confidenceLabel),
      'imageRef': serializer.toJson<String?>(imageRef),
    };
  }

  ReviewItemRow copyWith(
          {String? id,
          String? summary,
          String? suggestedDishIdsJson,
          String? confidenceLabel,
          Value<String?> imageRef = const Value.absent()}) =>
      ReviewItemRow(
        id: id ?? this.id,
        summary: summary ?? this.summary,
        suggestedDishIdsJson: suggestedDishIdsJson ?? this.suggestedDishIdsJson,
        confidenceLabel: confidenceLabel ?? this.confidenceLabel,
        imageRef: imageRef.present ? imageRef.value : this.imageRef,
      );
  ReviewItemRow copyWithCompanion(ReviewItemsCompanion data) {
    return ReviewItemRow(
      id: data.id.present ? data.id.value : this.id,
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
          ..write('summary: $summary, ')
          ..write('suggestedDishIdsJson: $suggestedDishIdsJson, ')
          ..write('confidenceLabel: $confidenceLabel, ')
          ..write('imageRef: $imageRef')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, summary, suggestedDishIdsJson, confidenceLabel, imageRef);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewItemRow &&
          other.id == this.id &&
          other.summary == this.summary &&
          other.suggestedDishIdsJson == this.suggestedDishIdsJson &&
          other.confidenceLabel == this.confidenceLabel &&
          other.imageRef == this.imageRef);
}

class ReviewItemsCompanion extends UpdateCompanion<ReviewItemRow> {
  final Value<String> id;
  final Value<String> summary;
  final Value<String> suggestedDishIdsJson;
  final Value<String> confidenceLabel;
  final Value<String?> imageRef;
  final Value<int> rowid;
  const ReviewItemsCompanion({
    this.id = const Value.absent(),
    this.summary = const Value.absent(),
    this.suggestedDishIdsJson = const Value.absent(),
    this.confidenceLabel = const Value.absent(),
    this.imageRef = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReviewItemsCompanion.insert({
    required String id,
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
    Expression<String>? summary,
    Expression<String>? suggestedDishIdsJson,
    Expression<String>? confidenceLabel,
    Expression<String>? imageRef,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
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
      Value<String>? summary,
      Value<String>? suggestedDishIdsJson,
      Value<String>? confidenceLabel,
      Value<String?>? imageRef,
      Value<int>? rowid}) {
    return ReviewItemsCompanion(
      id: id ?? this.id,
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DishesTable dishes = $DishesTable(this);
  late final $SourcePhotosTable sourcePhotos = $SourcePhotosTable(this);
  late final $CaptureItemsTable captureItems = $CaptureItemsTable(this);
  late final $PlannedMealsTable plannedMeals = $PlannedMealsTable(this);
  late final $ReviewItemsTable reviewItems = $ReviewItemsTable(this);
  late final $SyncOperationsTable syncOperations = $SyncOperationsTable(this);
  late final $SyncMetadataTable syncMetadata = $SyncMetadataTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        dishes,
        sourcePhotos,
        captureItems,
        plannedMeals,
        reviewItems,
        syncOperations,
        syncMetadata
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
typedef $$SourcePhotosTableCreateCompanionBuilder = SourcePhotosCompanion
    Function({
  required String id,
  required String dishId,
  required String url,
  required String capturedLabel,
  Value<String?> note,
  Value<String?> confidenceLabel,
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
            Value<int> rowid = const Value.absent(),
          }) =>
              SourcePhotosCompanion(
            id: id,
            dishId: dishId,
            url: url,
            capturedLabel: capturedLabel,
            note: note,
            confidenceLabel: confidenceLabel,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String dishId,
            required String url,
            required String capturedLabel,
            Value<String?> note = const Value.absent(),
            Value<String?> confidenceLabel = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SourcePhotosCompanion.insert(
            id: id,
            dishId: dishId,
            url: url,
            capturedLabel: capturedLabel,
            note: note,
            confidenceLabel: confidenceLabel,
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
typedef $$CaptureItemsTableCreateCompanionBuilder = CaptureItemsCompanion
    Function({
  required String id,
  required String kind,
  required String status,
  required DateTime createdAt,
  Value<String?> localMediaRef,
  Value<String?> remoteMediaRef,
  Value<String?> ideaText,
  Value<String?> appliedDishId,
  Value<int> rowid,
});
typedef $$CaptureItemsTableUpdateCompanionBuilder = CaptureItemsCompanion
    Function({
  Value<String> id,
  Value<String> kind,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<String?> localMediaRef,
  Value<String?> remoteMediaRef,
  Value<String?> ideaText,
  Value<String?> appliedDishId,
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

  ColumnFilters<String> get appliedDishId => $composableBuilder(
      column: $table.appliedDishId, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<String> get appliedDishId => $composableBuilder(
      column: $table.appliedDishId,
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

  GeneratedColumn<String> get appliedDishId => $composableBuilder(
      column: $table.appliedDishId, builder: (column) => column);
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
            Value<String> kind = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String?> localMediaRef = const Value.absent(),
            Value<String?> remoteMediaRef = const Value.absent(),
            Value<String?> ideaText = const Value.absent(),
            Value<String?> appliedDishId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CaptureItemsCompanion(
            id: id,
            kind: kind,
            status: status,
            createdAt: createdAt,
            localMediaRef: localMediaRef,
            remoteMediaRef: remoteMediaRef,
            ideaText: ideaText,
            appliedDishId: appliedDishId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String kind,
            required String status,
            required DateTime createdAt,
            Value<String?> localMediaRef = const Value.absent(),
            Value<String?> remoteMediaRef = const Value.absent(),
            Value<String?> ideaText = const Value.absent(),
            Value<String?> appliedDishId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CaptureItemsCompanion.insert(
            id: id,
            kind: kind,
            status: status,
            createdAt: createdAt,
            localMediaRef: localMediaRef,
            remoteMediaRef: remoteMediaRef,
            ideaText: ideaText,
            appliedDishId: appliedDishId,
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
  required String summary,
  required String suggestedDishIdsJson,
  required String confidenceLabel,
  Value<String?> imageRef,
  Value<int> rowid,
});
typedef $$ReviewItemsTableUpdateCompanionBuilder = ReviewItemsCompanion
    Function({
  Value<String> id,
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
            Value<String> summary = const Value.absent(),
            Value<String> suggestedDishIdsJson = const Value.absent(),
            Value<String> confidenceLabel = const Value.absent(),
            Value<String?> imageRef = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReviewItemsCompanion(
            id: id,
            summary: summary,
            suggestedDishIdsJson: suggestedDishIdsJson,
            confidenceLabel: confidenceLabel,
            imageRef: imageRef,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String summary,
            required String suggestedDishIdsJson,
            required String confidenceLabel,
            Value<String?> imageRef = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReviewItemsCompanion.insert(
            id: id,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DishesTableTableManager get dishes =>
      $$DishesTableTableManager(_db, _db.dishes);
  $$SourcePhotosTableTableManager get sourcePhotos =>
      $$SourcePhotosTableTableManager(_db, _db.sourcePhotos);
  $$CaptureItemsTableTableManager get captureItems =>
      $$CaptureItemsTableTableManager(_db, _db.captureItems);
  $$PlannedMealsTableTableManager get plannedMeals =>
      $$PlannedMealsTableTableManager(_db, _db.plannedMeals);
  $$ReviewItemsTableTableManager get reviewItems =>
      $$ReviewItemsTableTableManager(_db, _db.reviewItems);
  $$SyncOperationsTableTableManager get syncOperations =>
      $$SyncOperationsTableTableManager(_db, _db.syncOperations);
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db, _db.syncMetadata);
}
