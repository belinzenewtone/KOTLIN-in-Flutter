// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    email,
    username,
    createdAt,
    avatarUrl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final int id;
  final String name;
  final String? email;
  final String username;
  final int createdAt;
  final String avatarUrl;
  const User({
    required this.id,
    required this.name,
    this.email,
    required this.username,
    required this.createdAt,
    required this.avatarUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['username'] = Variable<String>(username);
    map['created_at'] = Variable<int>(createdAt);
    map['avatar_url'] = Variable<String>(avatarUrl);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      name: Value(name),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      username: Value(username),
      createdAt: Value(createdAt),
      avatarUrl: Value(avatarUrl),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String?>(json['email']),
      username: serializer.fromJson<String>(json['username']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      avatarUrl: serializer.fromJson<String>(json['avatarUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String?>(email),
      'username': serializer.toJson<String>(username),
      'createdAt': serializer.toJson<int>(createdAt),
      'avatarUrl': serializer.toJson<String>(avatarUrl),
    };
  }

  User copyWith({
    int? id,
    String? name,
    Value<String?> email = const Value.absent(),
    String? username,
    int? createdAt,
    String? avatarUrl,
  }) => User(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email.present ? email.value : this.email,
    username: username ?? this.username,
    createdAt: createdAt ?? this.createdAt,
    avatarUrl: avatarUrl ?? this.avatarUrl,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      username: data.username.present ? data.username.value : this.username,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('username: $username, ')
          ..write('createdAt: $createdAt, ')
          ..write('avatarUrl: $avatarUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, email, username, createdAt, avatarUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.username == this.username &&
          other.createdAt == this.createdAt &&
          other.avatarUrl == this.avatarUrl);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> email;
  final Value<String> username;
  final Value<int> createdAt;
  final Value<String> avatarUrl;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.username = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.avatarUrl = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.email = const Value.absent(),
    this.username = const Value.absent(),
    required int createdAt,
    this.avatarUrl = const Value.absent(),
  }) : name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<User> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? username,
    Expression<int>? createdAt,
    Expression<String>? avatarUrl,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (username != null) 'username': username,
      if (createdAt != null) 'created_at': createdAt,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    });
  }

  UsersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? email,
    Value<String>? username,
    Value<int>? createdAt,
    Value<String>? avatarUrl,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('username: $username, ')
          ..write('createdAt: $createdAt, ')
          ..write('avatarUrl: $avatarUrl')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _merchantMeta = const VerificationMeta(
    'merchant',
  );
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
    'merchant',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<int> date = GeneratedColumn<int>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _transactionTypeMeta = const VerificationMeta(
    'transactionType',
  );
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
    'transaction_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mpesaCodeMeta = const VerificationMeta(
    'mpesaCode',
  );
  @override
  late final GeneratedColumn<String> mpesaCode = GeneratedColumn<String>(
    'mpesa_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceHashMeta = const VerificationMeta(
    'sourceHash',
  );
  @override
  late final GeneratedColumn<String> sourceHash = GeneratedColumn<String>(
    'source_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawSmsMeta = const VerificationMeta('rawSms');
  @override
  late final GeneratedColumn<String> rawSms = GeneratedColumn<String>(
    'raw_sms',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordSourceMeta = const VerificationMeta(
    'recordSource',
  );
  @override
  late final GeneratedColumn<String> recordSource = GeneratedColumn<String>(
    'record_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inferredCategoryMeta = const VerificationMeta(
    'inferredCategory',
  );
  @override
  late final GeneratedColumn<String> inferredCategory = GeneratedColumn<String>(
    'inferred_category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inferenceSourceMeta = const VerificationMeta(
    'inferenceSource',
  );
  @override
  late final GeneratedColumn<String> inferenceSource = GeneratedColumn<String>(
    'inference_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _semanticHashMeta = const VerificationMeta(
    'semanticHash',
  );
  @override
  late final GeneratedColumn<String> semanticHash = GeneratedColumn<String>(
    'semantic_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _parseRouteMeta = const VerificationMeta(
    'parseRoute',
  );
  @override
  late final GeneratedColumn<String> parseRoute = GeneratedColumn<String>(
    'parse_route',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _feeMeta = const VerificationMeta('fee');
  @override
  late final GeneratedColumn<double> fee = GeneratedColumn<double>(
    'fee',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _balanceAfterMeta = const VerificationMeta(
    'balanceAfter',
  );
  @override
  late final GeneratedColumn<double> balanceAfter = GeneratedColumn<double>(
    'balance_after',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('completed'),
  );
  static const VerificationMeta _institutionIdMeta = const VerificationMeta(
    'institutionId',
  );
  @override
  late final GeneratedColumn<String> institutionId = GeneratedColumn<String>(
    'institution_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('mpesa'),
  );
  static const VerificationMeta _externalRefMeta = const VerificationMeta(
    'externalRef',
  );
  @override
  late final GeneratedColumn<String> externalRef = GeneratedColumn<String>(
    'external_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawSenderMeta = const VerificationMeta(
    'rawSender',
  );
  @override
  late final GeneratedColumn<String> rawSender = GeneratedColumn<String>(
    'raw_sender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _crossRefMpesaCodeMeta = const VerificationMeta(
    'crossRefMpesaCode',
  );
  @override
  late final GeneratedColumn<String> crossRefMpesaCode =
      GeneratedColumn<String>(
        'cross_ref_mpesa_code',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    amount,
    merchant,
    category,
    date,
    source,
    transactionType,
    mpesaCode,
    sourceHash,
    rawSms,
    createdAt,
    updatedAt,
    syncState,
    recordSource,
    deletedAt,
    revision,
    inferredCategory,
    inferenceSource,
    semanticHash,
    confidence,
    parseRoute,
    description,
    notes,
    fee,
    balanceAfter,
    status,
    institutionId,
    externalRef,
    rawSender,
    crossRefMpesaCode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('merchant')) {
      context.handle(
        _merchantMeta,
        merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta),
      );
    } else if (isInserting) {
      context.missing(_merchantMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
        _transactionTypeMeta,
        transactionType.isAcceptableOrUnknown(
          data['transaction_type']!,
          _transactionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionTypeMeta);
    }
    if (data.containsKey('mpesa_code')) {
      context.handle(
        _mpesaCodeMeta,
        mpesaCode.isAcceptableOrUnknown(data['mpesa_code']!, _mpesaCodeMeta),
      );
    }
    if (data.containsKey('source_hash')) {
      context.handle(
        _sourceHashMeta,
        sourceHash.isAcceptableOrUnknown(data['source_hash']!, _sourceHashMeta),
      );
    }
    if (data.containsKey('raw_sms')) {
      context.handle(
        _rawSmsMeta,
        rawSms.isAcceptableOrUnknown(data['raw_sms']!, _rawSmsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStateMeta);
    }
    if (data.containsKey('record_source')) {
      context.handle(
        _recordSourceMeta,
        recordSource.isAcceptableOrUnknown(
          data['record_source']!,
          _recordSourceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordSourceMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('inferred_category')) {
      context.handle(
        _inferredCategoryMeta,
        inferredCategory.isAcceptableOrUnknown(
          data['inferred_category']!,
          _inferredCategoryMeta,
        ),
      );
    }
    if (data.containsKey('inference_source')) {
      context.handle(
        _inferenceSourceMeta,
        inferenceSource.isAcceptableOrUnknown(
          data['inference_source']!,
          _inferenceSourceMeta,
        ),
      );
    }
    if (data.containsKey('semantic_hash')) {
      context.handle(
        _semanticHashMeta,
        semanticHash.isAcceptableOrUnknown(
          data['semantic_hash']!,
          _semanticHashMeta,
        ),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('parse_route')) {
      context.handle(
        _parseRouteMeta,
        parseRoute.isAcceptableOrUnknown(data['parse_route']!, _parseRouteMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('fee')) {
      context.handle(
        _feeMeta,
        fee.isAcceptableOrUnknown(data['fee']!, _feeMeta),
      );
    }
    if (data.containsKey('balance_after')) {
      context.handle(
        _balanceAfterMeta,
        balanceAfter.isAcceptableOrUnknown(
          data['balance_after']!,
          _balanceAfterMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('institution_id')) {
      context.handle(
        _institutionIdMeta,
        institutionId.isAcceptableOrUnknown(
          data['institution_id']!,
          _institutionIdMeta,
        ),
      );
    }
    if (data.containsKey('external_ref')) {
      context.handle(
        _externalRefMeta,
        externalRef.isAcceptableOrUnknown(
          data['external_ref']!,
          _externalRefMeta,
        ),
      );
    }
    if (data.containsKey('raw_sender')) {
      context.handle(
        _rawSenderMeta,
        rawSender.isAcceptableOrUnknown(data['raw_sender']!, _rawSenderMeta),
      );
    }
    if (data.containsKey('cross_ref_mpesa_code')) {
      context.handle(
        _crossRefMpesaCodeMeta,
        crossRefMpesaCode.isAcceptableOrUnknown(
          data['cross_ref_mpesa_code']!,
          _crossRefMpesaCodeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      merchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      transactionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_type'],
      )!,
      mpesaCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mpesa_code'],
      ),
      sourceHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_hash'],
      ),
      rawSms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_sms'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      recordSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_source'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      inferredCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}inferred_category'],
      ),
      inferenceSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}inference_source'],
      ),
      semanticHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}semantic_hash'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      parseRoute: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parse_route'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      fee: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fee'],
      )!,
      balanceAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}balance_after'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      institutionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}institution_id'],
      )!,
      externalRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_ref'],
      ),
      rawSender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_sender'],
      ),
      crossRefMpesaCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cross_ref_mpesa_code'],
      ),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final String userId;
  final double amount;
  final String merchant;
  final String category;
  final int date;
  final String source;
  final String transactionType;
  final String? mpesaCode;
  final String? sourceHash;
  final String? rawSms;
  final int createdAt;
  final int updatedAt;
  final String syncState;
  final String recordSource;
  final int? deletedAt;
  final int revision;
  final String? inferredCategory;
  final String? inferenceSource;
  final String? semanticHash;
  final double confidence;
  final String parseRoute;
  final String? description;
  final String? notes;
  final double fee;
  final double? balanceAfter;
  final String status;
  final String institutionId;
  final String? externalRef;
  final String? rawSender;
  final String? crossRefMpesaCode;
  const Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.merchant,
    required this.category,
    required this.date,
    required this.source,
    required this.transactionType,
    this.mpesaCode,
    this.sourceHash,
    this.rawSms,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
    required this.recordSource,
    this.deletedAt,
    required this.revision,
    this.inferredCategory,
    this.inferenceSource,
    this.semanticHash,
    required this.confidence,
    required this.parseRoute,
    this.description,
    this.notes,
    required this.fee,
    this.balanceAfter,
    required this.status,
    required this.institutionId,
    this.externalRef,
    this.rawSender,
    this.crossRefMpesaCode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['amount'] = Variable<double>(amount);
    map['merchant'] = Variable<String>(merchant);
    map['category'] = Variable<String>(category);
    map['date'] = Variable<int>(date);
    map['source'] = Variable<String>(source);
    map['transaction_type'] = Variable<String>(transactionType);
    if (!nullToAbsent || mpesaCode != null) {
      map['mpesa_code'] = Variable<String>(mpesaCode);
    }
    if (!nullToAbsent || sourceHash != null) {
      map['source_hash'] = Variable<String>(sourceHash);
    }
    if (!nullToAbsent || rawSms != null) {
      map['raw_sms'] = Variable<String>(rawSms);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    map['record_source'] = Variable<String>(recordSource);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || inferredCategory != null) {
      map['inferred_category'] = Variable<String>(inferredCategory);
    }
    if (!nullToAbsent || inferenceSource != null) {
      map['inference_source'] = Variable<String>(inferenceSource);
    }
    if (!nullToAbsent || semanticHash != null) {
      map['semantic_hash'] = Variable<String>(semanticHash);
    }
    map['confidence'] = Variable<double>(confidence);
    map['parse_route'] = Variable<String>(parseRoute);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['fee'] = Variable<double>(fee);
    if (!nullToAbsent || balanceAfter != null) {
      map['balance_after'] = Variable<double>(balanceAfter);
    }
    map['status'] = Variable<String>(status);
    map['institution_id'] = Variable<String>(institutionId);
    if (!nullToAbsent || externalRef != null) {
      map['external_ref'] = Variable<String>(externalRef);
    }
    if (!nullToAbsent || rawSender != null) {
      map['raw_sender'] = Variable<String>(rawSender);
    }
    if (!nullToAbsent || crossRefMpesaCode != null) {
      map['cross_ref_mpesa_code'] = Variable<String>(crossRefMpesaCode);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      userId: Value(userId),
      amount: Value(amount),
      merchant: Value(merchant),
      category: Value(category),
      date: Value(date),
      source: Value(source),
      transactionType: Value(transactionType),
      mpesaCode: mpesaCode == null && nullToAbsent
          ? const Value.absent()
          : Value(mpesaCode),
      sourceHash: sourceHash == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceHash),
      rawSms: rawSms == null && nullToAbsent
          ? const Value.absent()
          : Value(rawSms),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
      recordSource: Value(recordSource),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      revision: Value(revision),
      inferredCategory: inferredCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(inferredCategory),
      inferenceSource: inferenceSource == null && nullToAbsent
          ? const Value.absent()
          : Value(inferenceSource),
      semanticHash: semanticHash == null && nullToAbsent
          ? const Value.absent()
          : Value(semanticHash),
      confidence: Value(confidence),
      parseRoute: Value(parseRoute),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      fee: Value(fee),
      balanceAfter: balanceAfter == null && nullToAbsent
          ? const Value.absent()
          : Value(balanceAfter),
      status: Value(status),
      institutionId: Value(institutionId),
      externalRef: externalRef == null && nullToAbsent
          ? const Value.absent()
          : Value(externalRef),
      rawSender: rawSender == null && nullToAbsent
          ? const Value.absent()
          : Value(rawSender),
      crossRefMpesaCode: crossRefMpesaCode == null && nullToAbsent
          ? const Value.absent()
          : Value(crossRefMpesaCode),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      amount: serializer.fromJson<double>(json['amount']),
      merchant: serializer.fromJson<String>(json['merchant']),
      category: serializer.fromJson<String>(json['category']),
      date: serializer.fromJson<int>(json['date']),
      source: serializer.fromJson<String>(json['source']),
      transactionType: serializer.fromJson<String>(json['transactionType']),
      mpesaCode: serializer.fromJson<String?>(json['mpesaCode']),
      sourceHash: serializer.fromJson<String?>(json['sourceHash']),
      rawSms: serializer.fromJson<String?>(json['rawSms']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      recordSource: serializer.fromJson<String>(json['recordSource']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      revision: serializer.fromJson<int>(json['revision']),
      inferredCategory: serializer.fromJson<String?>(json['inferredCategory']),
      inferenceSource: serializer.fromJson<String?>(json['inferenceSource']),
      semanticHash: serializer.fromJson<String?>(json['semanticHash']),
      confidence: serializer.fromJson<double>(json['confidence']),
      parseRoute: serializer.fromJson<String>(json['parseRoute']),
      description: serializer.fromJson<String?>(json['description']),
      notes: serializer.fromJson<String?>(json['notes']),
      fee: serializer.fromJson<double>(json['fee']),
      balanceAfter: serializer.fromJson<double?>(json['balanceAfter']),
      status: serializer.fromJson<String>(json['status']),
      institutionId: serializer.fromJson<String>(json['institutionId']),
      externalRef: serializer.fromJson<String?>(json['externalRef']),
      rawSender: serializer.fromJson<String?>(json['rawSender']),
      crossRefMpesaCode: serializer.fromJson<String?>(
        json['crossRefMpesaCode'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'amount': serializer.toJson<double>(amount),
      'merchant': serializer.toJson<String>(merchant),
      'category': serializer.toJson<String>(category),
      'date': serializer.toJson<int>(date),
      'source': serializer.toJson<String>(source),
      'transactionType': serializer.toJson<String>(transactionType),
      'mpesaCode': serializer.toJson<String?>(mpesaCode),
      'sourceHash': serializer.toJson<String?>(sourceHash),
      'rawSms': serializer.toJson<String?>(rawSms),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
      'recordSource': serializer.toJson<String>(recordSource),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'revision': serializer.toJson<int>(revision),
      'inferredCategory': serializer.toJson<String?>(inferredCategory),
      'inferenceSource': serializer.toJson<String?>(inferenceSource),
      'semanticHash': serializer.toJson<String?>(semanticHash),
      'confidence': serializer.toJson<double>(confidence),
      'parseRoute': serializer.toJson<String>(parseRoute),
      'description': serializer.toJson<String?>(description),
      'notes': serializer.toJson<String?>(notes),
      'fee': serializer.toJson<double>(fee),
      'balanceAfter': serializer.toJson<double?>(balanceAfter),
      'status': serializer.toJson<String>(status),
      'institutionId': serializer.toJson<String>(institutionId),
      'externalRef': serializer.toJson<String?>(externalRef),
      'rawSender': serializer.toJson<String?>(rawSender),
      'crossRefMpesaCode': serializer.toJson<String?>(crossRefMpesaCode),
    };
  }

  Transaction copyWith({
    int? id,
    String? userId,
    double? amount,
    String? merchant,
    String? category,
    int? date,
    String? source,
    String? transactionType,
    Value<String?> mpesaCode = const Value.absent(),
    Value<String?> sourceHash = const Value.absent(),
    Value<String?> rawSms = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    String? syncState,
    String? recordSource,
    Value<int?> deletedAt = const Value.absent(),
    int? revision,
    Value<String?> inferredCategory = const Value.absent(),
    Value<String?> inferenceSource = const Value.absent(),
    Value<String?> semanticHash = const Value.absent(),
    double? confidence,
    String? parseRoute,
    Value<String?> description = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    double? fee,
    Value<double?> balanceAfter = const Value.absent(),
    String? status,
    String? institutionId,
    Value<String?> externalRef = const Value.absent(),
    Value<String?> rawSender = const Value.absent(),
    Value<String?> crossRefMpesaCode = const Value.absent(),
  }) => Transaction(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    amount: amount ?? this.amount,
    merchant: merchant ?? this.merchant,
    category: category ?? this.category,
    date: date ?? this.date,
    source: source ?? this.source,
    transactionType: transactionType ?? this.transactionType,
    mpesaCode: mpesaCode.present ? mpesaCode.value : this.mpesaCode,
    sourceHash: sourceHash.present ? sourceHash.value : this.sourceHash,
    rawSms: rawSms.present ? rawSms.value : this.rawSms,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncState: syncState ?? this.syncState,
    recordSource: recordSource ?? this.recordSource,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    revision: revision ?? this.revision,
    inferredCategory: inferredCategory.present
        ? inferredCategory.value
        : this.inferredCategory,
    inferenceSource: inferenceSource.present
        ? inferenceSource.value
        : this.inferenceSource,
    semanticHash: semanticHash.present ? semanticHash.value : this.semanticHash,
    confidence: confidence ?? this.confidence,
    parseRoute: parseRoute ?? this.parseRoute,
    description: description.present ? description.value : this.description,
    notes: notes.present ? notes.value : this.notes,
    fee: fee ?? this.fee,
    balanceAfter: balanceAfter.present ? balanceAfter.value : this.balanceAfter,
    status: status ?? this.status,
    institutionId: institutionId ?? this.institutionId,
    externalRef: externalRef.present ? externalRef.value : this.externalRef,
    rawSender: rawSender.present ? rawSender.value : this.rawSender,
    crossRefMpesaCode: crossRefMpesaCode.present
        ? crossRefMpesaCode.value
        : this.crossRefMpesaCode,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      amount: data.amount.present ? data.amount.value : this.amount,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      category: data.category.present ? data.category.value : this.category,
      date: data.date.present ? data.date.value : this.date,
      source: data.source.present ? data.source.value : this.source,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      mpesaCode: data.mpesaCode.present ? data.mpesaCode.value : this.mpesaCode,
      sourceHash: data.sourceHash.present
          ? data.sourceHash.value
          : this.sourceHash,
      rawSms: data.rawSms.present ? data.rawSms.value : this.rawSms,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      recordSource: data.recordSource.present
          ? data.recordSource.value
          : this.recordSource,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
      inferredCategory: data.inferredCategory.present
          ? data.inferredCategory.value
          : this.inferredCategory,
      inferenceSource: data.inferenceSource.present
          ? data.inferenceSource.value
          : this.inferenceSource,
      semanticHash: data.semanticHash.present
          ? data.semanticHash.value
          : this.semanticHash,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      parseRoute: data.parseRoute.present
          ? data.parseRoute.value
          : this.parseRoute,
      description: data.description.present
          ? data.description.value
          : this.description,
      notes: data.notes.present ? data.notes.value : this.notes,
      fee: data.fee.present ? data.fee.value : this.fee,
      balanceAfter: data.balanceAfter.present
          ? data.balanceAfter.value
          : this.balanceAfter,
      status: data.status.present ? data.status.value : this.status,
      institutionId: data.institutionId.present
          ? data.institutionId.value
          : this.institutionId,
      externalRef: data.externalRef.present
          ? data.externalRef.value
          : this.externalRef,
      rawSender: data.rawSender.present ? data.rawSender.value : this.rawSender,
      crossRefMpesaCode: data.crossRefMpesaCode.present
          ? data.crossRefMpesaCode.value
          : this.crossRefMpesaCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('amount: $amount, ')
          ..write('merchant: $merchant, ')
          ..write('category: $category, ')
          ..write('date: $date, ')
          ..write('source: $source, ')
          ..write('transactionType: $transactionType, ')
          ..write('mpesaCode: $mpesaCode, ')
          ..write('sourceHash: $sourceHash, ')
          ..write('rawSms: $rawSms, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('recordSource: $recordSource, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision, ')
          ..write('inferredCategory: $inferredCategory, ')
          ..write('inferenceSource: $inferenceSource, ')
          ..write('semanticHash: $semanticHash, ')
          ..write('confidence: $confidence, ')
          ..write('parseRoute: $parseRoute, ')
          ..write('description: $description, ')
          ..write('notes: $notes, ')
          ..write('fee: $fee, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('status: $status, ')
          ..write('institutionId: $institutionId, ')
          ..write('externalRef: $externalRef, ')
          ..write('rawSender: $rawSender, ')
          ..write('crossRefMpesaCode: $crossRefMpesaCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    userId,
    amount,
    merchant,
    category,
    date,
    source,
    transactionType,
    mpesaCode,
    sourceHash,
    rawSms,
    createdAt,
    updatedAt,
    syncState,
    recordSource,
    deletedAt,
    revision,
    inferredCategory,
    inferenceSource,
    semanticHash,
    confidence,
    parseRoute,
    description,
    notes,
    fee,
    balanceAfter,
    status,
    institutionId,
    externalRef,
    rawSender,
    crossRefMpesaCode,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.amount == this.amount &&
          other.merchant == this.merchant &&
          other.category == this.category &&
          other.date == this.date &&
          other.source == this.source &&
          other.transactionType == this.transactionType &&
          other.mpesaCode == this.mpesaCode &&
          other.sourceHash == this.sourceHash &&
          other.rawSms == this.rawSms &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState &&
          other.recordSource == this.recordSource &&
          other.deletedAt == this.deletedAt &&
          other.revision == this.revision &&
          other.inferredCategory == this.inferredCategory &&
          other.inferenceSource == this.inferenceSource &&
          other.semanticHash == this.semanticHash &&
          other.confidence == this.confidence &&
          other.parseRoute == this.parseRoute &&
          other.description == this.description &&
          other.notes == this.notes &&
          other.fee == this.fee &&
          other.balanceAfter == this.balanceAfter &&
          other.status == this.status &&
          other.institutionId == this.institutionId &&
          other.externalRef == this.externalRef &&
          other.rawSender == this.rawSender &&
          other.crossRefMpesaCode == this.crossRefMpesaCode);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<String> userId;
  final Value<double> amount;
  final Value<String> merchant;
  final Value<String> category;
  final Value<int> date;
  final Value<String> source;
  final Value<String> transactionType;
  final Value<String?> mpesaCode;
  final Value<String?> sourceHash;
  final Value<String?> rawSms;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> syncState;
  final Value<String> recordSource;
  final Value<int?> deletedAt;
  final Value<int> revision;
  final Value<String?> inferredCategory;
  final Value<String?> inferenceSource;
  final Value<String?> semanticHash;
  final Value<double> confidence;
  final Value<String> parseRoute;
  final Value<String?> description;
  final Value<String?> notes;
  final Value<double> fee;
  final Value<double?> balanceAfter;
  final Value<String> status;
  final Value<String> institutionId;
  final Value<String?> externalRef;
  final Value<String?> rawSender;
  final Value<String?> crossRefMpesaCode;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.amount = const Value.absent(),
    this.merchant = const Value.absent(),
    this.category = const Value.absent(),
    this.date = const Value.absent(),
    this.source = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.mpesaCode = const Value.absent(),
    this.sourceHash = const Value.absent(),
    this.rawSms = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.recordSource = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.inferredCategory = const Value.absent(),
    this.inferenceSource = const Value.absent(),
    this.semanticHash = const Value.absent(),
    this.confidence = const Value.absent(),
    this.parseRoute = const Value.absent(),
    this.description = const Value.absent(),
    this.notes = const Value.absent(),
    this.fee = const Value.absent(),
    this.balanceAfter = const Value.absent(),
    this.status = const Value.absent(),
    this.institutionId = const Value.absent(),
    this.externalRef = const Value.absent(),
    this.rawSender = const Value.absent(),
    this.crossRefMpesaCode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required int id,
    required String userId,
    required double amount,
    required String merchant,
    required String category,
    required int date,
    required String source,
    required String transactionType,
    this.mpesaCode = const Value.absent(),
    this.sourceHash = const Value.absent(),
    this.rawSms = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    required String syncState,
    required String recordSource,
    this.deletedAt = const Value.absent(),
    required int revision,
    this.inferredCategory = const Value.absent(),
    this.inferenceSource = const Value.absent(),
    this.semanticHash = const Value.absent(),
    this.confidence = const Value.absent(),
    this.parseRoute = const Value.absent(),
    this.description = const Value.absent(),
    this.notes = const Value.absent(),
    this.fee = const Value.absent(),
    this.balanceAfter = const Value.absent(),
    this.status = const Value.absent(),
    this.institutionId = const Value.absent(),
    this.externalRef = const Value.absent(),
    this.rawSender = const Value.absent(),
    this.crossRefMpesaCode = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       amount = Value(amount),
       merchant = Value(merchant),
       category = Value(category),
       date = Value(date),
       source = Value(source),
       transactionType = Value(transactionType),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncState = Value(syncState),
       recordSource = Value(recordSource),
       revision = Value(revision);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<double>? amount,
    Expression<String>? merchant,
    Expression<String>? category,
    Expression<int>? date,
    Expression<String>? source,
    Expression<String>? transactionType,
    Expression<String>? mpesaCode,
    Expression<String>? sourceHash,
    Expression<String>? rawSms,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? syncState,
    Expression<String>? recordSource,
    Expression<int>? deletedAt,
    Expression<int>? revision,
    Expression<String>? inferredCategory,
    Expression<String>? inferenceSource,
    Expression<String>? semanticHash,
    Expression<double>? confidence,
    Expression<String>? parseRoute,
    Expression<String>? description,
    Expression<String>? notes,
    Expression<double>? fee,
    Expression<double>? balanceAfter,
    Expression<String>? status,
    Expression<String>? institutionId,
    Expression<String>? externalRef,
    Expression<String>? rawSender,
    Expression<String>? crossRefMpesaCode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (amount != null) 'amount': amount,
      if (merchant != null) 'merchant': merchant,
      if (category != null) 'category': category,
      if (date != null) 'date': date,
      if (source != null) 'source': source,
      if (transactionType != null) 'transaction_type': transactionType,
      if (mpesaCode != null) 'mpesa_code': mpesaCode,
      if (sourceHash != null) 'source_hash': sourceHash,
      if (rawSms != null) 'raw_sms': rawSms,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (recordSource != null) 'record_source': recordSource,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (revision != null) 'revision': revision,
      if (inferredCategory != null) 'inferred_category': inferredCategory,
      if (inferenceSource != null) 'inference_source': inferenceSource,
      if (semanticHash != null) 'semantic_hash': semanticHash,
      if (confidence != null) 'confidence': confidence,
      if (parseRoute != null) 'parse_route': parseRoute,
      if (description != null) 'description': description,
      if (notes != null) 'notes': notes,
      if (fee != null) 'fee': fee,
      if (balanceAfter != null) 'balance_after': balanceAfter,
      if (status != null) 'status': status,
      if (institutionId != null) 'institution_id': institutionId,
      if (externalRef != null) 'external_ref': externalRef,
      if (rawSender != null) 'raw_sender': rawSender,
      if (crossRefMpesaCode != null) 'cross_ref_mpesa_code': crossRefMpesaCode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<double>? amount,
    Value<String>? merchant,
    Value<String>? category,
    Value<int>? date,
    Value<String>? source,
    Value<String>? transactionType,
    Value<String?>? mpesaCode,
    Value<String?>? sourceHash,
    Value<String?>? rawSms,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? syncState,
    Value<String>? recordSource,
    Value<int?>? deletedAt,
    Value<int>? revision,
    Value<String?>? inferredCategory,
    Value<String?>? inferenceSource,
    Value<String?>? semanticHash,
    Value<double>? confidence,
    Value<String>? parseRoute,
    Value<String?>? description,
    Value<String?>? notes,
    Value<double>? fee,
    Value<double?>? balanceAfter,
    Value<String>? status,
    Value<String>? institutionId,
    Value<String?>? externalRef,
    Value<String?>? rawSender,
    Value<String?>? crossRefMpesaCode,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      merchant: merchant ?? this.merchant,
      category: category ?? this.category,
      date: date ?? this.date,
      source: source ?? this.source,
      transactionType: transactionType ?? this.transactionType,
      mpesaCode: mpesaCode ?? this.mpesaCode,
      sourceHash: sourceHash ?? this.sourceHash,
      rawSms: rawSms ?? this.rawSms,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      recordSource: recordSource ?? this.recordSource,
      deletedAt: deletedAt ?? this.deletedAt,
      revision: revision ?? this.revision,
      inferredCategory: inferredCategory ?? this.inferredCategory,
      inferenceSource: inferenceSource ?? this.inferenceSource,
      semanticHash: semanticHash ?? this.semanticHash,
      confidence: confidence ?? this.confidence,
      parseRoute: parseRoute ?? this.parseRoute,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      fee: fee ?? this.fee,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      status: status ?? this.status,
      institutionId: institutionId ?? this.institutionId,
      externalRef: externalRef ?? this.externalRef,
      rawSender: rawSender ?? this.rawSender,
      crossRefMpesaCode: crossRefMpesaCode ?? this.crossRefMpesaCode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (date.present) {
      map['date'] = Variable<int>(date.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(transactionType.value);
    }
    if (mpesaCode.present) {
      map['mpesa_code'] = Variable<String>(mpesaCode.value);
    }
    if (sourceHash.present) {
      map['source_hash'] = Variable<String>(sourceHash.value);
    }
    if (rawSms.present) {
      map['raw_sms'] = Variable<String>(rawSms.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (recordSource.present) {
      map['record_source'] = Variable<String>(recordSource.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (inferredCategory.present) {
      map['inferred_category'] = Variable<String>(inferredCategory.value);
    }
    if (inferenceSource.present) {
      map['inference_source'] = Variable<String>(inferenceSource.value);
    }
    if (semanticHash.present) {
      map['semantic_hash'] = Variable<String>(semanticHash.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (parseRoute.present) {
      map['parse_route'] = Variable<String>(parseRoute.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (fee.present) {
      map['fee'] = Variable<double>(fee.value);
    }
    if (balanceAfter.present) {
      map['balance_after'] = Variable<double>(balanceAfter.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (institutionId.present) {
      map['institution_id'] = Variable<String>(institutionId.value);
    }
    if (externalRef.present) {
      map['external_ref'] = Variable<String>(externalRef.value);
    }
    if (rawSender.present) {
      map['raw_sender'] = Variable<String>(rawSender.value);
    }
    if (crossRefMpesaCode.present) {
      map['cross_ref_mpesa_code'] = Variable<String>(crossRefMpesaCode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('amount: $amount, ')
          ..write('merchant: $merchant, ')
          ..write('category: $category, ')
          ..write('date: $date, ')
          ..write('source: $source, ')
          ..write('transactionType: $transactionType, ')
          ..write('mpesaCode: $mpesaCode, ')
          ..write('sourceHash: $sourceHash, ')
          ..write('rawSms: $rawSms, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('recordSource: $recordSource, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision, ')
          ..write('inferredCategory: $inferredCategory, ')
          ..write('inferenceSource: $inferenceSource, ')
          ..write('semanticHash: $semanticHash, ')
          ..write('confidence: $confidence, ')
          ..write('parseRoute: $parseRoute, ')
          ..write('description: $description, ')
          ..write('notes: $notes, ')
          ..write('fee: $fee, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('status: $status, ')
          ..write('institutionId: $institutionId, ')
          ..write('externalRef: $externalRef, ')
          ..write('rawSender: $rawSender, ')
          ..write('crossRefMpesaCode: $crossRefMpesaCode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deadlineMeta = const VerificationMeta(
    'deadline',
  );
  @override
  late final GeneratedColumn<int> deadline = GeneratedColumn<int>(
    'deadline',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderOffsetsMeta = const VerificationMeta(
    'reminderOffsets',
  );
  @override
  late final GeneratedColumn<String> reminderOffsets = GeneratedColumn<String>(
    'reminder_offsets',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _alarmEnabledMeta = const VerificationMeta(
    'alarmEnabled',
  );
  @override
  late final GeneratedColumn<bool> alarmEnabled = GeneratedColumn<bool>(
    'alarm_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("alarm_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordSourceMeta = const VerificationMeta(
    'recordSource',
  );
  @override
  late final GeneratedColumn<String> recordSource = GeneratedColumn<String>(
    'record_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    title,
    description,
    priority,
    deadline,
    status,
    completedAt,
    createdAt,
    updatedAt,
    reminderOffsets,
    alarmEnabled,
    syncState,
    recordSource,
    deletedAt,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('deadline')) {
      context.handle(
        _deadlineMeta,
        deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('reminder_offsets')) {
      context.handle(
        _reminderOffsetsMeta,
        reminderOffsets.isAcceptableOrUnknown(
          data['reminder_offsets']!,
          _reminderOffsetsMeta,
        ),
      );
    }
    if (data.containsKey('alarm_enabled')) {
      context.handle(
        _alarmEnabledMeta,
        alarmEnabled.isAcceptableOrUnknown(
          data['alarm_enabled']!,
          _alarmEnabledMeta,
        ),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStateMeta);
    }
    if (data.containsKey('record_source')) {
      context.handle(
        _recordSourceMeta,
        recordSource.isAcceptableOrUnknown(
          data['record_source']!,
          _recordSourceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordSourceMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      deadline: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deadline'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      reminderOffsets: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_offsets'],
      )!,
      alarmEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}alarm_enabled'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      recordSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_source'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final int id;
  final String userId;
  final String title;
  final String description;
  final String priority;
  final int? deadline;
  final String status;
  final int? completedAt;
  final int createdAt;
  final int updatedAt;
  final String reminderOffsets;
  final bool alarmEnabled;
  final String syncState;
  final String recordSource;
  final int? deletedAt;
  final int revision;
  const Task({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.priority,
    this.deadline,
    required this.status,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.reminderOffsets,
    required this.alarmEnabled,
    required this.syncState,
    required this.recordSource,
    this.deletedAt,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['priority'] = Variable<String>(priority);
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<int>(deadline);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['reminder_offsets'] = Variable<String>(reminderOffsets);
    map['alarm_enabled'] = Variable<bool>(alarmEnabled);
    map['sync_state'] = Variable<String>(syncState);
    map['record_source'] = Variable<String>(recordSource);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['revision'] = Variable<int>(revision);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      description: Value(description),
      priority: Value(priority),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      status: Value(status),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      reminderOffsets: Value(reminderOffsets),
      alarmEnabled: Value(alarmEnabled),
      syncState: Value(syncState),
      recordSource: Value(recordSource),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      revision: Value(revision),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      priority: serializer.fromJson<String>(json['priority']),
      deadline: serializer.fromJson<int?>(json['deadline']),
      status: serializer.fromJson<String>(json['status']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      reminderOffsets: serializer.fromJson<String>(json['reminderOffsets']),
      alarmEnabled: serializer.fromJson<bool>(json['alarmEnabled']),
      syncState: serializer.fromJson<String>(json['syncState']),
      recordSource: serializer.fromJson<String>(json['recordSource']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'priority': serializer.toJson<String>(priority),
      'deadline': serializer.toJson<int?>(deadline),
      'status': serializer.toJson<String>(status),
      'completedAt': serializer.toJson<int?>(completedAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'reminderOffsets': serializer.toJson<String>(reminderOffsets),
      'alarmEnabled': serializer.toJson<bool>(alarmEnabled),
      'syncState': serializer.toJson<String>(syncState),
      'recordSource': serializer.toJson<String>(recordSource),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'revision': serializer.toJson<int>(revision),
    };
  }

  Task copyWith({
    int? id,
    String? userId,
    String? title,
    String? description,
    String? priority,
    Value<int?> deadline = const Value.absent(),
    String? status,
    Value<int?> completedAt = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    String? reminderOffsets,
    bool? alarmEnabled,
    String? syncState,
    String? recordSource,
    Value<int?> deletedAt = const Value.absent(),
    int? revision,
  }) => Task(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    description: description ?? this.description,
    priority: priority ?? this.priority,
    deadline: deadline.present ? deadline.value : this.deadline,
    status: status ?? this.status,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    reminderOffsets: reminderOffsets ?? this.reminderOffsets,
    alarmEnabled: alarmEnabled ?? this.alarmEnabled,
    syncState: syncState ?? this.syncState,
    recordSource: recordSource ?? this.recordSource,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    revision: revision ?? this.revision,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      priority: data.priority.present ? data.priority.value : this.priority,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      status: data.status.present ? data.status.value : this.status,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      reminderOffsets: data.reminderOffsets.present
          ? data.reminderOffsets.value
          : this.reminderOffsets,
      alarmEnabled: data.alarmEnabled.present
          ? data.alarmEnabled.value
          : this.alarmEnabled,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      recordSource: data.recordSource.present
          ? data.recordSource.value
          : this.recordSource,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('priority: $priority, ')
          ..write('deadline: $deadline, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('reminderOffsets: $reminderOffsets, ')
          ..write('alarmEnabled: $alarmEnabled, ')
          ..write('syncState: $syncState, ')
          ..write('recordSource: $recordSource, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    title,
    description,
    priority,
    deadline,
    status,
    completedAt,
    createdAt,
    updatedAt,
    reminderOffsets,
    alarmEnabled,
    syncState,
    recordSource,
    deletedAt,
    revision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.description == this.description &&
          other.priority == this.priority &&
          other.deadline == this.deadline &&
          other.status == this.status &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.reminderOffsets == this.reminderOffsets &&
          other.alarmEnabled == this.alarmEnabled &&
          other.syncState == this.syncState &&
          other.recordSource == this.recordSource &&
          other.deletedAt == this.deletedAt &&
          other.revision == this.revision);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> title;
  final Value<String> description;
  final Value<String> priority;
  final Value<int?> deadline;
  final Value<String> status;
  final Value<int?> completedAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> reminderOffsets;
  final Value<bool> alarmEnabled;
  final Value<String> syncState;
  final Value<String> recordSource;
  final Value<int?> deletedAt;
  final Value<int> revision;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.priority = const Value.absent(),
    this.deadline = const Value.absent(),
    this.status = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.reminderOffsets = const Value.absent(),
    this.alarmEnabled = const Value.absent(),
    this.syncState = const Value.absent(),
    this.recordSource = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required int id,
    required String userId,
    required String title,
    required String description,
    required String priority,
    this.deadline = const Value.absent(),
    required String status,
    this.completedAt = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.reminderOffsets = const Value.absent(),
    this.alarmEnabled = const Value.absent(),
    required String syncState,
    required String recordSource,
    this.deletedAt = const Value.absent(),
    required int revision,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       title = Value(title),
       description = Value(description),
       priority = Value(priority),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncState = Value(syncState),
       recordSource = Value(recordSource),
       revision = Value(revision);
  static Insertable<Task> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? priority,
    Expression<int>? deadline,
    Expression<String>? status,
    Expression<int>? completedAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? reminderOffsets,
    Expression<bool>? alarmEnabled,
    Expression<String>? syncState,
    Expression<String>? recordSource,
    Expression<int>? deletedAt,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (priority != null) 'priority': priority,
      if (deadline != null) 'deadline': deadline,
      if (status != null) 'status': status,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (reminderOffsets != null) 'reminder_offsets': reminderOffsets,
      if (alarmEnabled != null) 'alarm_enabled': alarmEnabled,
      if (syncState != null) 'sync_state': syncState,
      if (recordSource != null) 'record_source': recordSource,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? title,
    Value<String>? description,
    Value<String>? priority,
    Value<int?>? deadline,
    Value<String>? status,
    Value<int?>? completedAt,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? reminderOffsets,
    Value<bool>? alarmEnabled,
    Value<String>? syncState,
    Value<String>? recordSource,
    Value<int?>? deletedAt,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reminderOffsets: reminderOffsets ?? this.reminderOffsets,
      alarmEnabled: alarmEnabled ?? this.alarmEnabled,
      syncState: syncState ?? this.syncState,
      recordSource: recordSource ?? this.recordSource,
      deletedAt: deletedAt ?? this.deletedAt,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<int>(deadline.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (reminderOffsets.present) {
      map['reminder_offsets'] = Variable<String>(reminderOffsets.value);
    }
    if (alarmEnabled.present) {
      map['alarm_enabled'] = Variable<bool>(alarmEnabled.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (recordSource.present) {
      map['record_source'] = Variable<String>(recordSource.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('priority: $priority, ')
          ..write('deadline: $deadline, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('reminderOffsets: $reminderOffsets, ')
          ..write('alarmEnabled: $alarmEnabled, ')
          ..write('syncState: $syncState, ')
          ..write('recordSource: $recordSource, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskTimeEntriesTable extends TaskTimeEntries
    with TableInfo<$TaskTimeEntriesTable, TaskTimeEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskTimeEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<int> endedAt = GeneratedColumn<int>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    taskId,
    startedAt,
    endedAt,
    durationMinutes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_time_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskTimeEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationMinutesMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  TaskTimeEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskTimeEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_at'],
      ),
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TaskTimeEntriesTable createAlias(String alias) {
    return $TaskTimeEntriesTable(attachedDatabase, alias);
  }
}

class TaskTimeEntry extends DataClass implements Insertable<TaskTimeEntry> {
  final int id;
  final String userId;
  final int taskId;
  final int startedAt;
  final int? endedAt;
  final int durationMinutes;
  final int createdAt;
  const TaskTimeEntry({
    required this.id,
    required this.userId,
    required this.taskId,
    required this.startedAt,
    this.endedAt,
    required this.durationMinutes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['task_id'] = Variable<int>(taskId);
    map['started_at'] = Variable<int>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<int>(endedAt);
    }
    map['duration_minutes'] = Variable<int>(durationMinutes);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  TaskTimeEntriesCompanion toCompanion(bool nullToAbsent) {
    return TaskTimeEntriesCompanion(
      id: Value(id),
      userId: Value(userId),
      taskId: Value(taskId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      durationMinutes: Value(durationMinutes),
      createdAt: Value(createdAt),
    );
  }

  factory TaskTimeEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskTimeEntry(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      taskId: serializer.fromJson<int>(json['taskId']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      endedAt: serializer.fromJson<int?>(json['endedAt']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'taskId': serializer.toJson<int>(taskId),
      'startedAt': serializer.toJson<int>(startedAt),
      'endedAt': serializer.toJson<int?>(endedAt),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  TaskTimeEntry copyWith({
    int? id,
    String? userId,
    int? taskId,
    int? startedAt,
    Value<int?> endedAt = const Value.absent(),
    int? durationMinutes,
    int? createdAt,
  }) => TaskTimeEntry(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    taskId: taskId ?? this.taskId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    createdAt: createdAt ?? this.createdAt,
  );
  TaskTimeEntry copyWithCompanion(TaskTimeEntriesCompanion data) {
    return TaskTimeEntry(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskTimeEntry(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('taskId: $taskId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    taskId,
    startedAt,
    endedAt,
    durationMinutes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskTimeEntry &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.taskId == this.taskId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.durationMinutes == this.durationMinutes &&
          other.createdAt == this.createdAt);
}

class TaskTimeEntriesCompanion extends UpdateCompanion<TaskTimeEntry> {
  final Value<int> id;
  final Value<String> userId;
  final Value<int> taskId;
  final Value<int> startedAt;
  final Value<int?> endedAt;
  final Value<int> durationMinutes;
  final Value<int> createdAt;
  final Value<int> rowid;
  const TaskTimeEntriesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskTimeEntriesCompanion.insert({
    required int id,
    required String userId,
    required int taskId,
    required int startedAt,
    this.endedAt = const Value.absent(),
    required int durationMinutes,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       taskId = Value(taskId),
       startedAt = Value(startedAt),
       durationMinutes = Value(durationMinutes),
       createdAt = Value(createdAt);
  static Insertable<TaskTimeEntry> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<int>? taskId,
    Expression<int>? startedAt,
    Expression<int>? endedAt,
    Expression<int>? durationMinutes,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (taskId != null) 'task_id': taskId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskTimeEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<int>? taskId,
    Value<int>? startedAt,
    Value<int?>? endedAt,
    Value<int>? durationMinutes,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return TaskTimeEntriesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taskId: taskId ?? this.taskId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<int>(endedAt.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskTimeEntriesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('taskId: $taskId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventsTable extends Events with TableInfo<$EventsTable, Event> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<int> date = GeneratedColumn<int>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<int> endDate = GeneratedColumn<int>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importanceMeta = const VerificationMeta(
    'importance',
  );
  @override
  late final GeneratedColumn<String> importance = GeneratedColumn<String>(
    'importance',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hasReminderMeta = const VerificationMeta(
    'hasReminder',
  );
  @override
  late final GeneratedColumn<bool> hasReminder = GeneratedColumn<bool>(
    'has_reminder',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_reminder" IN (0, 1))',
    ),
  );
  static const VerificationMeta _reminderMinutesBeforeMeta =
      const VerificationMeta('reminderMinutesBefore');
  @override
  late final GeneratedColumn<int> reminderMinutesBefore = GeneratedColumn<int>(
    'reminder_minutes_before',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('EVENT'),
  );
  static const VerificationMeta _allDayMeta = const VerificationMeta('allDay');
  @override
  late final GeneratedColumn<bool> allDay = GeneratedColumn<bool>(
    'all_day',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("all_day" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _repeatRuleMeta = const VerificationMeta(
    'repeatRule',
  );
  @override
  late final GeneratedColumn<String> repeatRule = GeneratedColumn<String>(
    'repeat_rule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('NEVER'),
  );
  static const VerificationMeta _reminderOffsetsMeta = const VerificationMeta(
    'reminderOffsets',
  );
  @override
  late final GeneratedColumn<String> reminderOffsets = GeneratedColumn<String>(
    'reminder_offsets',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _alarmEnabledMeta = const VerificationMeta(
    'alarmEnabled',
  );
  @override
  late final GeneratedColumn<bool> alarmEnabled = GeneratedColumn<bool>(
    'alarm_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("alarm_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _guestsMeta = const VerificationMeta('guests');
  @override
  late final GeneratedColumn<String> guests = GeneratedColumn<String>(
    'guests',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _timeZoneIdMeta = const VerificationMeta(
    'timeZoneId',
  );
  @override
  late final GeneratedColumn<String> timeZoneId = GeneratedColumn<String>(
    'time_zone_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _reminderTimeOfDayMinutesMeta =
      const VerificationMeta('reminderTimeOfDayMinutes');
  @override
  late final GeneratedColumn<int> reminderTimeOfDayMinutes =
      GeneratedColumn<int>(
        'reminder_time_of_day_minutes',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(480),
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordSourceMeta = const VerificationMeta(
    'recordSource',
  );
  @override
  late final GeneratedColumn<String> recordSource = GeneratedColumn<String>(
    'record_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    title,
    description,
    date,
    endDate,
    type,
    importance,
    status,
    hasReminder,
    reminderMinutesBefore,
    createdAt,
    kind,
    allDay,
    repeatRule,
    reminderOffsets,
    alarmEnabled,
    guests,
    timeZoneId,
    reminderTimeOfDayMinutes,
    updatedAt,
    syncState,
    recordSource,
    deletedAt,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(
    Insertable<Event> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('importance')) {
      context.handle(
        _importanceMeta,
        importance.isAcceptableOrUnknown(data['importance']!, _importanceMeta),
      );
    } else if (isInserting) {
      context.missing(_importanceMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('has_reminder')) {
      context.handle(
        _hasReminderMeta,
        hasReminder.isAcceptableOrUnknown(
          data['has_reminder']!,
          _hasReminderMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hasReminderMeta);
    }
    if (data.containsKey('reminder_minutes_before')) {
      context.handle(
        _reminderMinutesBeforeMeta,
        reminderMinutesBefore.isAcceptableOrUnknown(
          data['reminder_minutes_before']!,
          _reminderMinutesBeforeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reminderMinutesBeforeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('all_day')) {
      context.handle(
        _allDayMeta,
        allDay.isAcceptableOrUnknown(data['all_day']!, _allDayMeta),
      );
    }
    if (data.containsKey('repeat_rule')) {
      context.handle(
        _repeatRuleMeta,
        repeatRule.isAcceptableOrUnknown(data['repeat_rule']!, _repeatRuleMeta),
      );
    }
    if (data.containsKey('reminder_offsets')) {
      context.handle(
        _reminderOffsetsMeta,
        reminderOffsets.isAcceptableOrUnknown(
          data['reminder_offsets']!,
          _reminderOffsetsMeta,
        ),
      );
    }
    if (data.containsKey('alarm_enabled')) {
      context.handle(
        _alarmEnabledMeta,
        alarmEnabled.isAcceptableOrUnknown(
          data['alarm_enabled']!,
          _alarmEnabledMeta,
        ),
      );
    }
    if (data.containsKey('guests')) {
      context.handle(
        _guestsMeta,
        guests.isAcceptableOrUnknown(data['guests']!, _guestsMeta),
      );
    }
    if (data.containsKey('time_zone_id')) {
      context.handle(
        _timeZoneIdMeta,
        timeZoneId.isAcceptableOrUnknown(
          data['time_zone_id']!,
          _timeZoneIdMeta,
        ),
      );
    }
    if (data.containsKey('reminder_time_of_day_minutes')) {
      context.handle(
        _reminderTimeOfDayMinutesMeta,
        reminderTimeOfDayMinutes.isAcceptableOrUnknown(
          data['reminder_time_of_day_minutes']!,
          _reminderTimeOfDayMinutesMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStateMeta);
    }
    if (data.containsKey('record_source')) {
      context.handle(
        _recordSourceMeta,
        recordSource.isAcceptableOrUnknown(
          data['record_source']!,
          _recordSourceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordSourceMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  Event map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Event(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_date'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      importance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}importance'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      hasReminder: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_reminder'],
      )!,
      reminderMinutesBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_minutes_before'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      allDay: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}all_day'],
      )!,
      repeatRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_rule'],
      )!,
      reminderOffsets: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_offsets'],
      )!,
      alarmEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}alarm_enabled'],
      )!,
      guests: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guests'],
      )!,
      timeZoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_zone_id'],
      )!,
      reminderTimeOfDayMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_time_of_day_minutes'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      recordSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_source'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class Event extends DataClass implements Insertable<Event> {
  final int id;
  final String userId;
  final String title;
  final String description;
  final int date;
  final int? endDate;
  final String type;
  final String importance;
  final String status;
  final bool hasReminder;
  final int reminderMinutesBefore;
  final int createdAt;
  final String kind;
  final bool allDay;
  final String repeatRule;
  final String reminderOffsets;
  final bool alarmEnabled;
  final String guests;
  final String timeZoneId;
  final int reminderTimeOfDayMinutes;
  final int updatedAt;
  final String syncState;
  final String recordSource;
  final int? deletedAt;
  final int revision;
  const Event({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.date,
    this.endDate,
    required this.type,
    required this.importance,
    required this.status,
    required this.hasReminder,
    required this.reminderMinutesBefore,
    required this.createdAt,
    required this.kind,
    required this.allDay,
    required this.repeatRule,
    required this.reminderOffsets,
    required this.alarmEnabled,
    required this.guests,
    required this.timeZoneId,
    required this.reminderTimeOfDayMinutes,
    required this.updatedAt,
    required this.syncState,
    required this.recordSource,
    this.deletedAt,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['date'] = Variable<int>(date);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<int>(endDate);
    }
    map['type'] = Variable<String>(type);
    map['importance'] = Variable<String>(importance);
    map['status'] = Variable<String>(status);
    map['has_reminder'] = Variable<bool>(hasReminder);
    map['reminder_minutes_before'] = Variable<int>(reminderMinutesBefore);
    map['created_at'] = Variable<int>(createdAt);
    map['kind'] = Variable<String>(kind);
    map['all_day'] = Variable<bool>(allDay);
    map['repeat_rule'] = Variable<String>(repeatRule);
    map['reminder_offsets'] = Variable<String>(reminderOffsets);
    map['alarm_enabled'] = Variable<bool>(alarmEnabled);
    map['guests'] = Variable<String>(guests);
    map['time_zone_id'] = Variable<String>(timeZoneId);
    map['reminder_time_of_day_minutes'] = Variable<int>(
      reminderTimeOfDayMinutes,
    );
    map['updated_at'] = Variable<int>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    map['record_source'] = Variable<String>(recordSource);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['revision'] = Variable<int>(revision);
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      description: Value(description),
      date: Value(date),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      type: Value(type),
      importance: Value(importance),
      status: Value(status),
      hasReminder: Value(hasReminder),
      reminderMinutesBefore: Value(reminderMinutesBefore),
      createdAt: Value(createdAt),
      kind: Value(kind),
      allDay: Value(allDay),
      repeatRule: Value(repeatRule),
      reminderOffsets: Value(reminderOffsets),
      alarmEnabled: Value(alarmEnabled),
      guests: Value(guests),
      timeZoneId: Value(timeZoneId),
      reminderTimeOfDayMinutes: Value(reminderTimeOfDayMinutes),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
      recordSource: Value(recordSource),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      revision: Value(revision),
    );
  }

  factory Event.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Event(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      date: serializer.fromJson<int>(json['date']),
      endDate: serializer.fromJson<int?>(json['endDate']),
      type: serializer.fromJson<String>(json['type']),
      importance: serializer.fromJson<String>(json['importance']),
      status: serializer.fromJson<String>(json['status']),
      hasReminder: serializer.fromJson<bool>(json['hasReminder']),
      reminderMinutesBefore: serializer.fromJson<int>(
        json['reminderMinutesBefore'],
      ),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      kind: serializer.fromJson<String>(json['kind']),
      allDay: serializer.fromJson<bool>(json['allDay']),
      repeatRule: serializer.fromJson<String>(json['repeatRule']),
      reminderOffsets: serializer.fromJson<String>(json['reminderOffsets']),
      alarmEnabled: serializer.fromJson<bool>(json['alarmEnabled']),
      guests: serializer.fromJson<String>(json['guests']),
      timeZoneId: serializer.fromJson<String>(json['timeZoneId']),
      reminderTimeOfDayMinutes: serializer.fromJson<int>(
        json['reminderTimeOfDayMinutes'],
      ),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      recordSource: serializer.fromJson<String>(json['recordSource']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'date': serializer.toJson<int>(date),
      'endDate': serializer.toJson<int?>(endDate),
      'type': serializer.toJson<String>(type),
      'importance': serializer.toJson<String>(importance),
      'status': serializer.toJson<String>(status),
      'hasReminder': serializer.toJson<bool>(hasReminder),
      'reminderMinutesBefore': serializer.toJson<int>(reminderMinutesBefore),
      'createdAt': serializer.toJson<int>(createdAt),
      'kind': serializer.toJson<String>(kind),
      'allDay': serializer.toJson<bool>(allDay),
      'repeatRule': serializer.toJson<String>(repeatRule),
      'reminderOffsets': serializer.toJson<String>(reminderOffsets),
      'alarmEnabled': serializer.toJson<bool>(alarmEnabled),
      'guests': serializer.toJson<String>(guests),
      'timeZoneId': serializer.toJson<String>(timeZoneId),
      'reminderTimeOfDayMinutes': serializer.toJson<int>(
        reminderTimeOfDayMinutes,
      ),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
      'recordSource': serializer.toJson<String>(recordSource),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'revision': serializer.toJson<int>(revision),
    };
  }

  Event copyWith({
    int? id,
    String? userId,
    String? title,
    String? description,
    int? date,
    Value<int?> endDate = const Value.absent(),
    String? type,
    String? importance,
    String? status,
    bool? hasReminder,
    int? reminderMinutesBefore,
    int? createdAt,
    String? kind,
    bool? allDay,
    String? repeatRule,
    String? reminderOffsets,
    bool? alarmEnabled,
    String? guests,
    String? timeZoneId,
    int? reminderTimeOfDayMinutes,
    int? updatedAt,
    String? syncState,
    String? recordSource,
    Value<int?> deletedAt = const Value.absent(),
    int? revision,
  }) => Event(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    description: description ?? this.description,
    date: date ?? this.date,
    endDate: endDate.present ? endDate.value : this.endDate,
    type: type ?? this.type,
    importance: importance ?? this.importance,
    status: status ?? this.status,
    hasReminder: hasReminder ?? this.hasReminder,
    reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
    createdAt: createdAt ?? this.createdAt,
    kind: kind ?? this.kind,
    allDay: allDay ?? this.allDay,
    repeatRule: repeatRule ?? this.repeatRule,
    reminderOffsets: reminderOffsets ?? this.reminderOffsets,
    alarmEnabled: alarmEnabled ?? this.alarmEnabled,
    guests: guests ?? this.guests,
    timeZoneId: timeZoneId ?? this.timeZoneId,
    reminderTimeOfDayMinutes:
        reminderTimeOfDayMinutes ?? this.reminderTimeOfDayMinutes,
    updatedAt: updatedAt ?? this.updatedAt,
    syncState: syncState ?? this.syncState,
    recordSource: recordSource ?? this.recordSource,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    revision: revision ?? this.revision,
  );
  Event copyWithCompanion(EventsCompanion data) {
    return Event(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      date: data.date.present ? data.date.value : this.date,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      type: data.type.present ? data.type.value : this.type,
      importance: data.importance.present
          ? data.importance.value
          : this.importance,
      status: data.status.present ? data.status.value : this.status,
      hasReminder: data.hasReminder.present
          ? data.hasReminder.value
          : this.hasReminder,
      reminderMinutesBefore: data.reminderMinutesBefore.present
          ? data.reminderMinutesBefore.value
          : this.reminderMinutesBefore,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      kind: data.kind.present ? data.kind.value : this.kind,
      allDay: data.allDay.present ? data.allDay.value : this.allDay,
      repeatRule: data.repeatRule.present
          ? data.repeatRule.value
          : this.repeatRule,
      reminderOffsets: data.reminderOffsets.present
          ? data.reminderOffsets.value
          : this.reminderOffsets,
      alarmEnabled: data.alarmEnabled.present
          ? data.alarmEnabled.value
          : this.alarmEnabled,
      guests: data.guests.present ? data.guests.value : this.guests,
      timeZoneId: data.timeZoneId.present
          ? data.timeZoneId.value
          : this.timeZoneId,
      reminderTimeOfDayMinutes: data.reminderTimeOfDayMinutes.present
          ? data.reminderTimeOfDayMinutes.value
          : this.reminderTimeOfDayMinutes,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      recordSource: data.recordSource.present
          ? data.recordSource.value
          : this.recordSource,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Event(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('endDate: $endDate, ')
          ..write('type: $type, ')
          ..write('importance: $importance, ')
          ..write('status: $status, ')
          ..write('hasReminder: $hasReminder, ')
          ..write('reminderMinutesBefore: $reminderMinutesBefore, ')
          ..write('createdAt: $createdAt, ')
          ..write('kind: $kind, ')
          ..write('allDay: $allDay, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('reminderOffsets: $reminderOffsets, ')
          ..write('alarmEnabled: $alarmEnabled, ')
          ..write('guests: $guests, ')
          ..write('timeZoneId: $timeZoneId, ')
          ..write('reminderTimeOfDayMinutes: $reminderTimeOfDayMinutes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('recordSource: $recordSource, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    userId,
    title,
    description,
    date,
    endDate,
    type,
    importance,
    status,
    hasReminder,
    reminderMinutesBefore,
    createdAt,
    kind,
    allDay,
    repeatRule,
    reminderOffsets,
    alarmEnabled,
    guests,
    timeZoneId,
    reminderTimeOfDayMinutes,
    updatedAt,
    syncState,
    recordSource,
    deletedAt,
    revision,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Event &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.description == this.description &&
          other.date == this.date &&
          other.endDate == this.endDate &&
          other.type == this.type &&
          other.importance == this.importance &&
          other.status == this.status &&
          other.hasReminder == this.hasReminder &&
          other.reminderMinutesBefore == this.reminderMinutesBefore &&
          other.createdAt == this.createdAt &&
          other.kind == this.kind &&
          other.allDay == this.allDay &&
          other.repeatRule == this.repeatRule &&
          other.reminderOffsets == this.reminderOffsets &&
          other.alarmEnabled == this.alarmEnabled &&
          other.guests == this.guests &&
          other.timeZoneId == this.timeZoneId &&
          other.reminderTimeOfDayMinutes == this.reminderTimeOfDayMinutes &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState &&
          other.recordSource == this.recordSource &&
          other.deletedAt == this.deletedAt &&
          other.revision == this.revision);
}

class EventsCompanion extends UpdateCompanion<Event> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> title;
  final Value<String> description;
  final Value<int> date;
  final Value<int?> endDate;
  final Value<String> type;
  final Value<String> importance;
  final Value<String> status;
  final Value<bool> hasReminder;
  final Value<int> reminderMinutesBefore;
  final Value<int> createdAt;
  final Value<String> kind;
  final Value<bool> allDay;
  final Value<String> repeatRule;
  final Value<String> reminderOffsets;
  final Value<bool> alarmEnabled;
  final Value<String> guests;
  final Value<String> timeZoneId;
  final Value<int> reminderTimeOfDayMinutes;
  final Value<int> updatedAt;
  final Value<String> syncState;
  final Value<String> recordSource;
  final Value<int?> deletedAt;
  final Value<int> revision;
  final Value<int> rowid;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.date = const Value.absent(),
    this.endDate = const Value.absent(),
    this.type = const Value.absent(),
    this.importance = const Value.absent(),
    this.status = const Value.absent(),
    this.hasReminder = const Value.absent(),
    this.reminderMinutesBefore = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.kind = const Value.absent(),
    this.allDay = const Value.absent(),
    this.repeatRule = const Value.absent(),
    this.reminderOffsets = const Value.absent(),
    this.alarmEnabled = const Value.absent(),
    this.guests = const Value.absent(),
    this.timeZoneId = const Value.absent(),
    this.reminderTimeOfDayMinutes = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.recordSource = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventsCompanion.insert({
    required int id,
    required String userId,
    required String title,
    required String description,
    required int date,
    this.endDate = const Value.absent(),
    required String type,
    required String importance,
    required String status,
    required bool hasReminder,
    required int reminderMinutesBefore,
    required int createdAt,
    this.kind = const Value.absent(),
    this.allDay = const Value.absent(),
    this.repeatRule = const Value.absent(),
    this.reminderOffsets = const Value.absent(),
    this.alarmEnabled = const Value.absent(),
    this.guests = const Value.absent(),
    this.timeZoneId = const Value.absent(),
    this.reminderTimeOfDayMinutes = const Value.absent(),
    required int updatedAt,
    required String syncState,
    required String recordSource,
    this.deletedAt = const Value.absent(),
    required int revision,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       title = Value(title),
       description = Value(description),
       date = Value(date),
       type = Value(type),
       importance = Value(importance),
       status = Value(status),
       hasReminder = Value(hasReminder),
       reminderMinutesBefore = Value(reminderMinutesBefore),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncState = Value(syncState),
       recordSource = Value(recordSource),
       revision = Value(revision);
  static Insertable<Event> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? date,
    Expression<int>? endDate,
    Expression<String>? type,
    Expression<String>? importance,
    Expression<String>? status,
    Expression<bool>? hasReminder,
    Expression<int>? reminderMinutesBefore,
    Expression<int>? createdAt,
    Expression<String>? kind,
    Expression<bool>? allDay,
    Expression<String>? repeatRule,
    Expression<String>? reminderOffsets,
    Expression<bool>? alarmEnabled,
    Expression<String>? guests,
    Expression<String>? timeZoneId,
    Expression<int>? reminderTimeOfDayMinutes,
    Expression<int>? updatedAt,
    Expression<String>? syncState,
    Expression<String>? recordSource,
    Expression<int>? deletedAt,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (date != null) 'date': date,
      if (endDate != null) 'end_date': endDate,
      if (type != null) 'type': type,
      if (importance != null) 'importance': importance,
      if (status != null) 'status': status,
      if (hasReminder != null) 'has_reminder': hasReminder,
      if (reminderMinutesBefore != null)
        'reminder_minutes_before': reminderMinutesBefore,
      if (createdAt != null) 'created_at': createdAt,
      if (kind != null) 'kind': kind,
      if (allDay != null) 'all_day': allDay,
      if (repeatRule != null) 'repeat_rule': repeatRule,
      if (reminderOffsets != null) 'reminder_offsets': reminderOffsets,
      if (alarmEnabled != null) 'alarm_enabled': alarmEnabled,
      if (guests != null) 'guests': guests,
      if (timeZoneId != null) 'time_zone_id': timeZoneId,
      if (reminderTimeOfDayMinutes != null)
        'reminder_time_of_day_minutes': reminderTimeOfDayMinutes,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (recordSource != null) 'record_source': recordSource,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventsCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? title,
    Value<String>? description,
    Value<int>? date,
    Value<int?>? endDate,
    Value<String>? type,
    Value<String>? importance,
    Value<String>? status,
    Value<bool>? hasReminder,
    Value<int>? reminderMinutesBefore,
    Value<int>? createdAt,
    Value<String>? kind,
    Value<bool>? allDay,
    Value<String>? repeatRule,
    Value<String>? reminderOffsets,
    Value<bool>? alarmEnabled,
    Value<String>? guests,
    Value<String>? timeZoneId,
    Value<int>? reminderTimeOfDayMinutes,
    Value<int>? updatedAt,
    Value<String>? syncState,
    Value<String>? recordSource,
    Value<int?>? deletedAt,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return EventsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      endDate: endDate ?? this.endDate,
      type: type ?? this.type,
      importance: importance ?? this.importance,
      status: status ?? this.status,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
      createdAt: createdAt ?? this.createdAt,
      kind: kind ?? this.kind,
      allDay: allDay ?? this.allDay,
      repeatRule: repeatRule ?? this.repeatRule,
      reminderOffsets: reminderOffsets ?? this.reminderOffsets,
      alarmEnabled: alarmEnabled ?? this.alarmEnabled,
      guests: guests ?? this.guests,
      timeZoneId: timeZoneId ?? this.timeZoneId,
      reminderTimeOfDayMinutes:
          reminderTimeOfDayMinutes ?? this.reminderTimeOfDayMinutes,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      recordSource: recordSource ?? this.recordSource,
      deletedAt: deletedAt ?? this.deletedAt,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (date.present) {
      map['date'] = Variable<int>(date.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<int>(endDate.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (importance.present) {
      map['importance'] = Variable<String>(importance.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (hasReminder.present) {
      map['has_reminder'] = Variable<bool>(hasReminder.value);
    }
    if (reminderMinutesBefore.present) {
      map['reminder_minutes_before'] = Variable<int>(
        reminderMinutesBefore.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (allDay.present) {
      map['all_day'] = Variable<bool>(allDay.value);
    }
    if (repeatRule.present) {
      map['repeat_rule'] = Variable<String>(repeatRule.value);
    }
    if (reminderOffsets.present) {
      map['reminder_offsets'] = Variable<String>(reminderOffsets.value);
    }
    if (alarmEnabled.present) {
      map['alarm_enabled'] = Variable<bool>(alarmEnabled.value);
    }
    if (guests.present) {
      map['guests'] = Variable<String>(guests.value);
    }
    if (timeZoneId.present) {
      map['time_zone_id'] = Variable<String>(timeZoneId.value);
    }
    if (reminderTimeOfDayMinutes.present) {
      map['reminder_time_of_day_minutes'] = Variable<int>(
        reminderTimeOfDayMinutes.value,
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (recordSource.present) {
      map['record_source'] = Variable<String>(recordSource.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('endDate: $endDate, ')
          ..write('type: $type, ')
          ..write('importance: $importance, ')
          ..write('status: $status, ')
          ..write('hasReminder: $hasReminder, ')
          ..write('reminderMinutesBefore: $reminderMinutesBefore, ')
          ..write('createdAt: $createdAt, ')
          ..write('kind: $kind, ')
          ..write('allDay: $allDay, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('reminderOffsets: $reminderOffsets, ')
          ..write('alarmEnabled: $alarmEnabled, ')
          ..write('guests: $guests, ')
          ..write('timeZoneId: $timeZoneId, ')
          ..write('reminderTimeOfDayMinutes: $reminderTimeOfDayMinutes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('recordSource: $recordSource, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, Budget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _limitAmountMeta = const VerificationMeta(
    'limitAmount',
  );
  @override
  late final GeneratedColumn<double> limitAmount = GeneratedColumn<double>(
    'limit_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
    'period',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _alertThresholdMeta = const VerificationMeta(
    'alertThreshold',
  );
  @override
  late final GeneratedColumn<double> alertThreshold = GeneratedColumn<double>(
    'alert_threshold',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordSourceMeta = const VerificationMeta(
    'recordSource',
  );
  @override
  late final GeneratedColumn<String> recordSource = GeneratedColumn<String>(
    'record_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    category,
    limitAmount,
    period,
    alertThreshold,
    createdAt,
    updatedAt,
    syncState,
    recordSource,
    deletedAt,
    revision,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Budget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('limit_amount')) {
      context.handle(
        _limitAmountMeta,
        limitAmount.isAcceptableOrUnknown(
          data['limit_amount']!,
          _limitAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_limitAmountMeta);
    }
    if (data.containsKey('period')) {
      context.handle(
        _periodMeta,
        period.isAcceptableOrUnknown(data['period']!, _periodMeta),
      );
    } else if (isInserting) {
      context.missing(_periodMeta);
    }
    if (data.containsKey('alert_threshold')) {
      context.handle(
        _alertThresholdMeta,
        alertThreshold.isAcceptableOrUnknown(
          data['alert_threshold']!,
          _alertThresholdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStateMeta);
    }
    if (data.containsKey('record_source')) {
      context.handle(
        _recordSourceMeta,
        recordSource.isAcceptableOrUnknown(
          data['record_source']!,
          _recordSourceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordSourceMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  Budget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Budget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      limitAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}limit_amount'],
      )!,
      period: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period'],
      )!,
      alertThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}alert_threshold'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      recordSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_source'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class Budget extends DataClass implements Insertable<Budget> {
  final int id;
  final String userId;
  final String category;
  final double limitAmount;
  final String period;
  final double? alertThreshold;
  final int createdAt;
  final int updatedAt;
  final String syncState;
  final String recordSource;
  final int? deletedAt;
  final int revision;
  final bool isActive;
  const Budget({
    required this.id,
    required this.userId,
    required this.category,
    required this.limitAmount,
    required this.period,
    this.alertThreshold,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
    required this.recordSource,
    this.deletedAt,
    required this.revision,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['category'] = Variable<String>(category);
    map['limit_amount'] = Variable<double>(limitAmount);
    map['period'] = Variable<String>(period);
    if (!nullToAbsent || alertThreshold != null) {
      map['alert_threshold'] = Variable<double>(alertThreshold);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    map['record_source'] = Variable<String>(recordSource);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['revision'] = Variable<int>(revision);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      userId: Value(userId),
      category: Value(category),
      limitAmount: Value(limitAmount),
      period: Value(period),
      alertThreshold: alertThreshold == null && nullToAbsent
          ? const Value.absent()
          : Value(alertThreshold),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
      recordSource: Value(recordSource),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      revision: Value(revision),
      isActive: Value(isActive),
    );
  }

  factory Budget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      category: serializer.fromJson<String>(json['category']),
      limitAmount: serializer.fromJson<double>(json['limitAmount']),
      period: serializer.fromJson<String>(json['period']),
      alertThreshold: serializer.fromJson<double?>(json['alertThreshold']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      recordSource: serializer.fromJson<String>(json['recordSource']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      revision: serializer.fromJson<int>(json['revision']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'category': serializer.toJson<String>(category),
      'limitAmount': serializer.toJson<double>(limitAmount),
      'period': serializer.toJson<String>(period),
      'alertThreshold': serializer.toJson<double?>(alertThreshold),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
      'recordSource': serializer.toJson<String>(recordSource),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'revision': serializer.toJson<int>(revision),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  Budget copyWith({
    int? id,
    String? userId,
    String? category,
    double? limitAmount,
    String? period,
    Value<double?> alertThreshold = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    String? syncState,
    String? recordSource,
    Value<int?> deletedAt = const Value.absent(),
    int? revision,
    bool? isActive,
  }) => Budget(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    category: category ?? this.category,
    limitAmount: limitAmount ?? this.limitAmount,
    period: period ?? this.period,
    alertThreshold: alertThreshold.present
        ? alertThreshold.value
        : this.alertThreshold,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncState: syncState ?? this.syncState,
    recordSource: recordSource ?? this.recordSource,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    revision: revision ?? this.revision,
    isActive: isActive ?? this.isActive,
  );
  Budget copyWithCompanion(BudgetsCompanion data) {
    return Budget(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      category: data.category.present ? data.category.value : this.category,
      limitAmount: data.limitAmount.present
          ? data.limitAmount.value
          : this.limitAmount,
      period: data.period.present ? data.period.value : this.period,
      alertThreshold: data.alertThreshold.present
          ? data.alertThreshold.value
          : this.alertThreshold,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      recordSource: data.recordSource.present
          ? data.recordSource.value
          : this.recordSource,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Budget(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('category: $category, ')
          ..write('limitAmount: $limitAmount, ')
          ..write('period: $period, ')
          ..write('alertThreshold: $alertThreshold, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('recordSource: $recordSource, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    category,
    limitAmount,
    period,
    alertThreshold,
    createdAt,
    updatedAt,
    syncState,
    recordSource,
    deletedAt,
    revision,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.category == this.category &&
          other.limitAmount == this.limitAmount &&
          other.period == this.period &&
          other.alertThreshold == this.alertThreshold &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState &&
          other.recordSource == this.recordSource &&
          other.deletedAt == this.deletedAt &&
          other.revision == this.revision &&
          other.isActive == this.isActive);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> category;
  final Value<double> limitAmount;
  final Value<String> period;
  final Value<double?> alertThreshold;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> syncState;
  final Value<String> recordSource;
  final Value<int?> deletedAt;
  final Value<int> revision;
  final Value<bool> isActive;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.category = const Value.absent(),
    this.limitAmount = const Value.absent(),
    this.period = const Value.absent(),
    this.alertThreshold = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.recordSource = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    required int id,
    required String userId,
    required String category,
    required double limitAmount,
    required String period,
    this.alertThreshold = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    required String syncState,
    required String recordSource,
    this.deletedAt = const Value.absent(),
    required int revision,
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       category = Value(category),
       limitAmount = Value(limitAmount),
       period = Value(period),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncState = Value(syncState),
       recordSource = Value(recordSource),
       revision = Value(revision);
  static Insertable<Budget> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? category,
    Expression<double>? limitAmount,
    Expression<String>? period,
    Expression<double>? alertThreshold,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? syncState,
    Expression<String>? recordSource,
    Expression<int>? deletedAt,
    Expression<int>? revision,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (category != null) 'category': category,
      if (limitAmount != null) 'limit_amount': limitAmount,
      if (period != null) 'period': period,
      if (alertThreshold != null) 'alert_threshold': alertThreshold,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (recordSource != null) 'record_source': recordSource,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (revision != null) 'revision': revision,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? category,
    Value<double>? limitAmount,
    Value<String>? period,
    Value<double?>? alertThreshold,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? syncState,
    Value<String>? recordSource,
    Value<int?>? deletedAt,
    Value<int>? revision,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return BudgetsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      limitAmount: limitAmount ?? this.limitAmount,
      period: period ?? this.period,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      recordSource: recordSource ?? this.recordSource,
      deletedAt: deletedAt ?? this.deletedAt,
      revision: revision ?? this.revision,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (limitAmount.present) {
      map['limit_amount'] = Variable<double>(limitAmount.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (alertThreshold.present) {
      map['alert_threshold'] = Variable<double>(alertThreshold.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (recordSource.present) {
      map['record_source'] = Variable<String>(recordSource.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('category: $category, ')
          ..write('limitAmount: $limitAmount, ')
          ..write('period: $period, ')
          ..write('alertThreshold: $alertThreshold, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('recordSource: $recordSource, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IncomesTable extends Incomes with TableInfo<$IncomesTable, Income> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IncomesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
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
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<int> date = GeneratedColumn<int>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isRecurringMeta = const VerificationMeta(
    'isRecurring',
  );
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
    'is_recurring',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_recurring" IN (0, 1))',
    ),
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordSourceMeta = const VerificationMeta(
    'recordSource',
  );
  @override
  late final GeneratedColumn<String> recordSource = GeneratedColumn<String>(
    'record_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    amount,
    source,
    date,
    note,
    isRecurring,
    frequency,
    createdAt,
    updatedAt,
    syncState,
    recordSource,
    deletedAt,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'incomes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Income> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('is_recurring')) {
      context.handle(
        _isRecurringMeta,
        isRecurring.isAcceptableOrUnknown(
          data['is_recurring']!,
          _isRecurringMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isRecurringMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStateMeta);
    }
    if (data.containsKey('record_source')) {
      context.handle(
        _recordSourceMeta,
        recordSource.isAcceptableOrUnknown(
          data['record_source']!,
          _recordSourceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordSourceMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  Income map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Income(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      isRecurring: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_recurring'],
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      recordSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_source'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $IncomesTable createAlias(String alias) {
    return $IncomesTable(attachedDatabase, alias);
  }
}

class Income extends DataClass implements Insertable<Income> {
  final int id;
  final String userId;
  final double amount;
  final String source;
  final int date;
  final String note;
  final bool isRecurring;
  final String? frequency;
  final int createdAt;
  final int updatedAt;
  final String syncState;
  final String recordSource;
  final int? deletedAt;
  final int revision;
  const Income({
    required this.id,
    required this.userId,
    required this.amount,
    required this.source,
    required this.date,
    required this.note,
    required this.isRecurring,
    this.frequency,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
    required this.recordSource,
    this.deletedAt,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['amount'] = Variable<double>(amount);
    map['source'] = Variable<String>(source);
    map['date'] = Variable<int>(date);
    map['note'] = Variable<String>(note);
    map['is_recurring'] = Variable<bool>(isRecurring);
    if (!nullToAbsent || frequency != null) {
      map['frequency'] = Variable<String>(frequency);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    map['record_source'] = Variable<String>(recordSource);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['revision'] = Variable<int>(revision);
    return map;
  }

  IncomesCompanion toCompanion(bool nullToAbsent) {
    return IncomesCompanion(
      id: Value(id),
      userId: Value(userId),
      amount: Value(amount),
      source: Value(source),
      date: Value(date),
      note: Value(note),
      isRecurring: Value(isRecurring),
      frequency: frequency == null && nullToAbsent
          ? const Value.absent()
          : Value(frequency),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
      recordSource: Value(recordSource),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      revision: Value(revision),
    );
  }

  factory Income.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Income(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      amount: serializer.fromJson<double>(json['amount']),
      source: serializer.fromJson<String>(json['source']),
      date: serializer.fromJson<int>(json['date']),
      note: serializer.fromJson<String>(json['note']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
      frequency: serializer.fromJson<String?>(json['frequency']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      recordSource: serializer.fromJson<String>(json['recordSource']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'amount': serializer.toJson<double>(amount),
      'source': serializer.toJson<String>(source),
      'date': serializer.toJson<int>(date),
      'note': serializer.toJson<String>(note),
      'isRecurring': serializer.toJson<bool>(isRecurring),
      'frequency': serializer.toJson<String?>(frequency),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
      'recordSource': serializer.toJson<String>(recordSource),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'revision': serializer.toJson<int>(revision),
    };
  }

  Income copyWith({
    int? id,
    String? userId,
    double? amount,
    String? source,
    int? date,
    String? note,
    bool? isRecurring,
    Value<String?> frequency = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    String? syncState,
    String? recordSource,
    Value<int?> deletedAt = const Value.absent(),
    int? revision,
  }) => Income(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    amount: amount ?? this.amount,
    source: source ?? this.source,
    date: date ?? this.date,
    note: note ?? this.note,
    isRecurring: isRecurring ?? this.isRecurring,
    frequency: frequency.present ? frequency.value : this.frequency,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncState: syncState ?? this.syncState,
    recordSource: recordSource ?? this.recordSource,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    revision: revision ?? this.revision,
  );
  Income copyWithCompanion(IncomesCompanion data) {
    return Income(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      amount: data.amount.present ? data.amount.value : this.amount,
      source: data.source.present ? data.source.value : this.source,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
      isRecurring: data.isRecurring.present
          ? data.isRecurring.value
          : this.isRecurring,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      recordSource: data.recordSource.present
          ? data.recordSource.value
          : this.recordSource,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Income(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('amount: $amount, ')
          ..write('source: $source, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('frequency: $frequency, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('recordSource: $recordSource, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    amount,
    source,
    date,
    note,
    isRecurring,
    frequency,
    createdAt,
    updatedAt,
    syncState,
    recordSource,
    deletedAt,
    revision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Income &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.amount == this.amount &&
          other.source == this.source &&
          other.date == this.date &&
          other.note == this.note &&
          other.isRecurring == this.isRecurring &&
          other.frequency == this.frequency &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState &&
          other.recordSource == this.recordSource &&
          other.deletedAt == this.deletedAt &&
          other.revision == this.revision);
}

class IncomesCompanion extends UpdateCompanion<Income> {
  final Value<int> id;
  final Value<String> userId;
  final Value<double> amount;
  final Value<String> source;
  final Value<int> date;
  final Value<String> note;
  final Value<bool> isRecurring;
  final Value<String?> frequency;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> syncState;
  final Value<String> recordSource;
  final Value<int?> deletedAt;
  final Value<int> revision;
  final Value<int> rowid;
  const IncomesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.amount = const Value.absent(),
    this.source = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.frequency = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.recordSource = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IncomesCompanion.insert({
    required int id,
    required String userId,
    required double amount,
    required String source,
    required int date,
    required String note,
    required bool isRecurring,
    this.frequency = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    required String syncState,
    required String recordSource,
    this.deletedAt = const Value.absent(),
    required int revision,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       amount = Value(amount),
       source = Value(source),
       date = Value(date),
       note = Value(note),
       isRecurring = Value(isRecurring),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncState = Value(syncState),
       recordSource = Value(recordSource),
       revision = Value(revision);
  static Insertable<Income> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<double>? amount,
    Expression<String>? source,
    Expression<int>? date,
    Expression<String>? note,
    Expression<bool>? isRecurring,
    Expression<String>? frequency,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? syncState,
    Expression<String>? recordSource,
    Expression<int>? deletedAt,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (amount != null) 'amount': amount,
      if (source != null) 'source': source,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (frequency != null) 'frequency': frequency,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (recordSource != null) 'record_source': recordSource,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IncomesCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<double>? amount,
    Value<String>? source,
    Value<int>? date,
    Value<String>? note,
    Value<bool>? isRecurring,
    Value<String?>? frequency,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? syncState,
    Value<String>? recordSource,
    Value<int?>? deletedAt,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return IncomesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      source: source ?? this.source,
      date: date ?? this.date,
      note: note ?? this.note,
      isRecurring: isRecurring ?? this.isRecurring,
      frequency: frequency ?? this.frequency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      recordSource: recordSource ?? this.recordSource,
      deletedAt: deletedAt ?? this.deletedAt,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (date.present) {
      map['date'] = Variable<int>(date.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (recordSource.present) {
      map['record_source'] = Variable<String>(recordSource.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncomesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('amount: $amount, ')
          ..write('source: $source, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('frequency: $frequency, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('recordSource: $recordSource, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BillsTable extends Bills with TableInfo<$BillsTable, Bill> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BillsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
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
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cycleMeta = const VerificationMeta('cycle');
  @override
  late final GeneratedColumn<String> cycle = GeneratedColumn<String>(
    'cycle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextDueDateMeta = const VerificationMeta(
    'nextDueDate',
  );
  @override
  late final GeneratedColumn<int> nextDueDate = GeneratedColumn<int>(
    'next_due_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastPaidAtMeta = const VerificationMeta(
    'lastPaidAt',
  );
  @override
  late final GeneratedColumn<int> lastPaidAt = GeneratedColumn<int>(
    'last_paid_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
  );
  static const VerificationMeta _paidStatusMeta = const VerificationMeta(
    'paidStatus',
  );
  @override
  late final GeneratedColumn<bool> paidStatus = GeneratedColumn<bool>(
    'paid_status',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("paid_status" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    title,
    amount,
    cycle,
    nextDueDate,
    lastPaidAt,
    notes,
    isActive,
    paidStatus,
    createdAt,
    updatedAt,
    syncState,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bills';
  @override
  VerificationContext validateIntegrity(
    Insertable<Bill> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('cycle')) {
      context.handle(
        _cycleMeta,
        cycle.isAcceptableOrUnknown(data['cycle']!, _cycleMeta),
      );
    } else if (isInserting) {
      context.missing(_cycleMeta);
    }
    if (data.containsKey('next_due_date')) {
      context.handle(
        _nextDueDateMeta,
        nextDueDate.isAcceptableOrUnknown(
          data['next_due_date']!,
          _nextDueDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextDueDateMeta);
    }
    if (data.containsKey('last_paid_at')) {
      context.handle(
        _lastPaidAtMeta,
        lastPaidAt.isAcceptableOrUnknown(
          data['last_paid_at']!,
          _lastPaidAtMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    if (data.containsKey('paid_status')) {
      context.handle(
        _paidStatusMeta,
        paidStatus.isAcceptableOrUnknown(data['paid_status']!, _paidStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStateMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  Bill map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bill(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      cycle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cycle'],
      )!,
      nextDueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_due_date'],
      )!,
      lastPaidAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_paid_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      paidStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}paid_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $BillsTable createAlias(String alias) {
    return $BillsTable(attachedDatabase, alias);
  }
}

class Bill extends DataClass implements Insertable<Bill> {
  final int id;
  final String userId;
  final String title;
  final double amount;
  final String cycle;
  final int nextDueDate;
  final int? lastPaidAt;
  final String notes;
  final bool isActive;
  final bool paidStatus;
  final int createdAt;
  final int updatedAt;
  final String syncState;
  final int? deletedAt;
  const Bill({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.cycle,
    required this.nextDueDate,
    this.lastPaidAt,
    required this.notes,
    required this.isActive,
    required this.paidStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    map['amount'] = Variable<double>(amount);
    map['cycle'] = Variable<String>(cycle);
    map['next_due_date'] = Variable<int>(nextDueDate);
    if (!nullToAbsent || lastPaidAt != null) {
      map['last_paid_at'] = Variable<int>(lastPaidAt);
    }
    map['notes'] = Variable<String>(notes);
    map['is_active'] = Variable<bool>(isActive);
    map['paid_status'] = Variable<bool>(paidStatus);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  BillsCompanion toCompanion(bool nullToAbsent) {
    return BillsCompanion(
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      amount: Value(amount),
      cycle: Value(cycle),
      nextDueDate: Value(nextDueDate),
      lastPaidAt: lastPaidAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPaidAt),
      notes: Value(notes),
      isActive: Value(isActive),
      paidStatus: Value(paidStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Bill.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bill(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      amount: serializer.fromJson<double>(json['amount']),
      cycle: serializer.fromJson<String>(json['cycle']),
      nextDueDate: serializer.fromJson<int>(json['nextDueDate']),
      lastPaidAt: serializer.fromJson<int?>(json['lastPaidAt']),
      notes: serializer.fromJson<String>(json['notes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      paidStatus: serializer.fromJson<bool>(json['paidStatus']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'amount': serializer.toJson<double>(amount),
      'cycle': serializer.toJson<String>(cycle),
      'nextDueDate': serializer.toJson<int>(nextDueDate),
      'lastPaidAt': serializer.toJson<int?>(lastPaidAt),
      'notes': serializer.toJson<String>(notes),
      'isActive': serializer.toJson<bool>(isActive),
      'paidStatus': serializer.toJson<bool>(paidStatus),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  Bill copyWith({
    int? id,
    String? userId,
    String? title,
    double? amount,
    String? cycle,
    int? nextDueDate,
    Value<int?> lastPaidAt = const Value.absent(),
    String? notes,
    bool? isActive,
    bool? paidStatus,
    int? createdAt,
    int? updatedAt,
    String? syncState,
    Value<int?> deletedAt = const Value.absent(),
  }) => Bill(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    amount: amount ?? this.amount,
    cycle: cycle ?? this.cycle,
    nextDueDate: nextDueDate ?? this.nextDueDate,
    lastPaidAt: lastPaidAt.present ? lastPaidAt.value : this.lastPaidAt,
    notes: notes ?? this.notes,
    isActive: isActive ?? this.isActive,
    paidStatus: paidStatus ?? this.paidStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncState: syncState ?? this.syncState,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Bill copyWithCompanion(BillsCompanion data) {
    return Bill(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      amount: data.amount.present ? data.amount.value : this.amount,
      cycle: data.cycle.present ? data.cycle.value : this.cycle,
      nextDueDate: data.nextDueDate.present
          ? data.nextDueDate.value
          : this.nextDueDate,
      lastPaidAt: data.lastPaidAt.present
          ? data.lastPaidAt.value
          : this.lastPaidAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      paidStatus: data.paidStatus.present
          ? data.paidStatus.value
          : this.paidStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bill(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('cycle: $cycle, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('lastPaidAt: $lastPaidAt, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('paidStatus: $paidStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    title,
    amount,
    cycle,
    nextDueDate,
    lastPaidAt,
    notes,
    isActive,
    paidStatus,
    createdAt,
    updatedAt,
    syncState,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bill &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.amount == this.amount &&
          other.cycle == this.cycle &&
          other.nextDueDate == this.nextDueDate &&
          other.lastPaidAt == this.lastPaidAt &&
          other.notes == this.notes &&
          other.isActive == this.isActive &&
          other.paidStatus == this.paidStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState &&
          other.deletedAt == this.deletedAt);
}

class BillsCompanion extends UpdateCompanion<Bill> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> title;
  final Value<double> amount;
  final Value<String> cycle;
  final Value<int> nextDueDate;
  final Value<int?> lastPaidAt;
  final Value<String> notes;
  final Value<bool> isActive;
  final Value<bool> paidStatus;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> syncState;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const BillsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.amount = const Value.absent(),
    this.cycle = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.lastPaidAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.paidStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BillsCompanion.insert({
    required int id,
    required String userId,
    required String title,
    required double amount,
    required String cycle,
    required int nextDueDate,
    this.lastPaidAt = const Value.absent(),
    required String notes,
    required bool isActive,
    this.paidStatus = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    required String syncState,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       title = Value(title),
       amount = Value(amount),
       cycle = Value(cycle),
       nextDueDate = Value(nextDueDate),
       notes = Value(notes),
       isActive = Value(isActive),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncState = Value(syncState);
  static Insertable<Bill> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<double>? amount,
    Expression<String>? cycle,
    Expression<int>? nextDueDate,
    Expression<int>? lastPaidAt,
    Expression<String>? notes,
    Expression<bool>? isActive,
    Expression<bool>? paidStatus,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? syncState,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (amount != null) 'amount': amount,
      if (cycle != null) 'cycle': cycle,
      if (nextDueDate != null) 'next_due_date': nextDueDate,
      if (lastPaidAt != null) 'last_paid_at': lastPaidAt,
      if (notes != null) 'notes': notes,
      if (isActive != null) 'is_active': isActive,
      if (paidStatus != null) 'paid_status': paidStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BillsCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? title,
    Value<double>? amount,
    Value<String>? cycle,
    Value<int>? nextDueDate,
    Value<int?>? lastPaidAt,
    Value<String>? notes,
    Value<bool>? isActive,
    Value<bool>? paidStatus,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? syncState,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return BillsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      cycle: cycle ?? this.cycle,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      lastPaidAt: lastPaidAt ?? this.lastPaidAt,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      paidStatus: paidStatus ?? this.paidStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (cycle.present) {
      map['cycle'] = Variable<String>(cycle.value);
    }
    if (nextDueDate.present) {
      map['next_due_date'] = Variable<int>(nextDueDate.value);
    }
    if (lastPaidAt.present) {
      map['last_paid_at'] = Variable<int>(lastPaidAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (paidStatus.present) {
      map['paid_status'] = Variable<bool>(paidStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BillsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('cycle: $cycle, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('lastPaidAt: $lastPaidAt, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('paidStatus: $paidStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, Goal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetValueMeta = const VerificationMeta(
    'targetValue',
  );
  @override
  late final GeneratedColumn<double> targetValue = GeneratedColumn<double>(
    'target_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentValueMeta = const VerificationMeta(
    'currentValue',
  );
  @override
  late final GeneratedColumn<double> currentValue = GeneratedColumn<double>(
    'current_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deadlineMeta = const VerificationMeta(
    'deadline',
  );
  @override
  late final GeneratedColumn<int> deadline = GeneratedColumn<int>(
    'deadline',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    title,
    description,
    targetValue,
    currentValue,
    unit,
    category,
    deadline,
    status,
    createdAt,
    updatedAt,
    syncState,
    deletedAt,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Goal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('target_value')) {
      context.handle(
        _targetValueMeta,
        targetValue.isAcceptableOrUnknown(
          data['target_value']!,
          _targetValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetValueMeta);
    }
    if (data.containsKey('current_value')) {
      context.handle(
        _currentValueMeta,
        currentValue.isAcceptableOrUnknown(
          data['current_value']!,
          _currentValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentValueMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('deadline')) {
      context.handle(
        _deadlineMeta,
        deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStateMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  Goal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Goal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      targetValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_value'],
      )!,
      currentValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_value'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      deadline: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deadline'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class Goal extends DataClass implements Insertable<Goal> {
  final int id;
  final String userId;
  final String title;
  final String description;
  final double targetValue;
  final double currentValue;
  final String unit;
  final String category;
  final int? deadline;
  final String status;
  final int createdAt;
  final int updatedAt;
  final String syncState;
  final int? deletedAt;
  final int revision;
  const Goal({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.currentValue,
    required this.unit,
    required this.category,
    this.deadline,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
    this.deletedAt,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['target_value'] = Variable<double>(targetValue);
    map['current_value'] = Variable<double>(currentValue);
    map['unit'] = Variable<String>(unit);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<int>(deadline);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['revision'] = Variable<int>(revision);
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      description: Value(description),
      targetValue: Value(targetValue),
      currentValue: Value(currentValue),
      unit: Value(unit),
      category: Value(category),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      revision: Value(revision),
    );
  }

  factory Goal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Goal(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      targetValue: serializer.fromJson<double>(json['targetValue']),
      currentValue: serializer.fromJson<double>(json['currentValue']),
      unit: serializer.fromJson<String>(json['unit']),
      category: serializer.fromJson<String>(json['category']),
      deadline: serializer.fromJson<int?>(json['deadline']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'targetValue': serializer.toJson<double>(targetValue),
      'currentValue': serializer.toJson<double>(currentValue),
      'unit': serializer.toJson<String>(unit),
      'category': serializer.toJson<String>(category),
      'deadline': serializer.toJson<int?>(deadline),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'revision': serializer.toJson<int>(revision),
    };
  }

  Goal copyWith({
    int? id,
    String? userId,
    String? title,
    String? description,
    double? targetValue,
    double? currentValue,
    String? unit,
    String? category,
    Value<int?> deadline = const Value.absent(),
    String? status,
    int? createdAt,
    int? updatedAt,
    String? syncState,
    Value<int?> deletedAt = const Value.absent(),
    int? revision,
  }) => Goal(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    description: description ?? this.description,
    targetValue: targetValue ?? this.targetValue,
    currentValue: currentValue ?? this.currentValue,
    unit: unit ?? this.unit,
    category: category ?? this.category,
    deadline: deadline.present ? deadline.value : this.deadline,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncState: syncState ?? this.syncState,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    revision: revision ?? this.revision,
  );
  Goal copyWithCompanion(GoalsCompanion data) {
    return Goal(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      targetValue: data.targetValue.present
          ? data.targetValue.value
          : this.targetValue,
      currentValue: data.currentValue.present
          ? data.currentValue.value
          : this.currentValue,
      unit: data.unit.present ? data.unit.value : this.unit,
      category: data.category.present ? data.category.value : this.category,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Goal(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('targetValue: $targetValue, ')
          ..write('currentValue: $currentValue, ')
          ..write('unit: $unit, ')
          ..write('category: $category, ')
          ..write('deadline: $deadline, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    title,
    description,
    targetValue,
    currentValue,
    unit,
    category,
    deadline,
    status,
    createdAt,
    updatedAt,
    syncState,
    deletedAt,
    revision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Goal &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.description == this.description &&
          other.targetValue == this.targetValue &&
          other.currentValue == this.currentValue &&
          other.unit == this.unit &&
          other.category == this.category &&
          other.deadline == this.deadline &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState &&
          other.deletedAt == this.deletedAt &&
          other.revision == this.revision);
}

class GoalsCompanion extends UpdateCompanion<Goal> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> title;
  final Value<String> description;
  final Value<double> targetValue;
  final Value<double> currentValue;
  final Value<String> unit;
  final Value<String> category;
  final Value<int?> deadline;
  final Value<String> status;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> syncState;
  final Value<int?> deletedAt;
  final Value<int> revision;
  final Value<int> rowid;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.currentValue = const Value.absent(),
    this.unit = const Value.absent(),
    this.category = const Value.absent(),
    this.deadline = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalsCompanion.insert({
    required int id,
    required String userId,
    required String title,
    required String description,
    required double targetValue,
    required double currentValue,
    required String unit,
    required String category,
    this.deadline = const Value.absent(),
    required String status,
    required int createdAt,
    required int updatedAt,
    required String syncState,
    this.deletedAt = const Value.absent(),
    required int revision,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       title = Value(title),
       description = Value(description),
       targetValue = Value(targetValue),
       currentValue = Value(currentValue),
       unit = Value(unit),
       category = Value(category),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncState = Value(syncState),
       revision = Value(revision);
  static Insertable<Goal> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<double>? targetValue,
    Expression<double>? currentValue,
    Expression<String>? unit,
    Expression<String>? category,
    Expression<int>? deadline,
    Expression<String>? status,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? syncState,
    Expression<int>? deletedAt,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (targetValue != null) 'target_value': targetValue,
      if (currentValue != null) 'current_value': currentValue,
      if (unit != null) 'unit': unit,
      if (category != null) 'category': category,
      if (deadline != null) 'deadline': deadline,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalsCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? title,
    Value<String>? description,
    Value<double>? targetValue,
    Value<double>? currentValue,
    Value<String>? unit,
    Value<String>? category,
    Value<int?>? deadline,
    Value<String>? status,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? syncState,
    Value<int?>? deletedAt,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return GoalsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      deletedAt: deletedAt ?? this.deletedAt,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (targetValue.present) {
      map['target_value'] = Variable<double>(targetValue.value);
    }
    if (currentValue.present) {
      map['current_value'] = Variable<double>(currentValue.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<int>(deadline.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('targetValue: $targetValue, ')
          ..write('currentValue: $currentValue, ')
          ..write('unit: $unit, ')
          ..write('category: $category, ')
          ..write('deadline: $deadline, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringRulesTable extends RecurringRules
    with TableInfo<$RecurringRulesTable, RecurringRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cadenceMeta = const VerificationMeta(
    'cadence',
  );
  @override
  late final GeneratedColumn<String> cadence = GeneratedColumn<String>(
    'cadence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextRunAtMeta = const VerificationMeta(
    'nextRunAt',
  );
  @override
  late final GeneratedColumn<int> nextRunAt = GeneratedColumn<int>(
    'next_run_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('RECURRING'),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordSourceMeta = const VerificationMeta(
    'recordSource',
  );
  @override
  late final GeneratedColumn<String> recordSource = GeneratedColumn<String>(
    'record_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    title,
    type,
    cadence,
    nextRunAt,
    amount,
    category,
    enabled,
    createdAt,
    updatedAt,
    syncState,
    recordSource,
    deletedAt,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('cadence')) {
      context.handle(
        _cadenceMeta,
        cadence.isAcceptableOrUnknown(data['cadence']!, _cadenceMeta),
      );
    } else if (isInserting) {
      context.missing(_cadenceMeta);
    }
    if (data.containsKey('next_run_at')) {
      context.handle(
        _nextRunAtMeta,
        nextRunAt.isAcceptableOrUnknown(data['next_run_at']!, _nextRunAtMeta),
      );
    } else if (isInserting) {
      context.missing(_nextRunAtMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    } else if (isInserting) {
      context.missing(_enabledMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStateMeta);
    }
    if (data.containsKey('record_source')) {
      context.handle(
        _recordSourceMeta,
        recordSource.isAcceptableOrUnknown(
          data['record_source']!,
          _recordSourceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordSourceMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  RecurringRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      cadence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cadence'],
      )!,
      nextRunAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_run_at'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      recordSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_source'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $RecurringRulesTable createAlias(String alias) {
    return $RecurringRulesTable(attachedDatabase, alias);
  }
}

class RecurringRule extends DataClass implements Insertable<RecurringRule> {
  final int id;
  final String userId;
  final String title;
  final String type;
  final String cadence;
  final int nextRunAt;
  final double? amount;
  final String category;
  final bool enabled;
  final int createdAt;
  final int updatedAt;
  final String syncState;
  final String recordSource;
  final int? deletedAt;
  final int revision;
  const RecurringRule({
    required this.id,
    required this.userId,
    required this.title,
    required this.type,
    required this.cadence,
    required this.nextRunAt,
    this.amount,
    required this.category,
    required this.enabled,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
    required this.recordSource,
    this.deletedAt,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    map['type'] = Variable<String>(type);
    map['cadence'] = Variable<String>(cadence);
    map['next_run_at'] = Variable<int>(nextRunAt);
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<double>(amount);
    }
    map['category'] = Variable<String>(category);
    map['enabled'] = Variable<bool>(enabled);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    map['record_source'] = Variable<String>(recordSource);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['revision'] = Variable<int>(revision);
    return map;
  }

  RecurringRulesCompanion toCompanion(bool nullToAbsent) {
    return RecurringRulesCompanion(
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      type: Value(type),
      cadence: Value(cadence),
      nextRunAt: Value(nextRunAt),
      amount: amount == null && nullToAbsent
          ? const Value.absent()
          : Value(amount),
      category: Value(category),
      enabled: Value(enabled),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
      recordSource: Value(recordSource),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      revision: Value(revision),
    );
  }

  factory RecurringRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringRule(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      type: serializer.fromJson<String>(json['type']),
      cadence: serializer.fromJson<String>(json['cadence']),
      nextRunAt: serializer.fromJson<int>(json['nextRunAt']),
      amount: serializer.fromJson<double?>(json['amount']),
      category: serializer.fromJson<String>(json['category']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      recordSource: serializer.fromJson<String>(json['recordSource']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'type': serializer.toJson<String>(type),
      'cadence': serializer.toJson<String>(cadence),
      'nextRunAt': serializer.toJson<int>(nextRunAt),
      'amount': serializer.toJson<double?>(amount),
      'category': serializer.toJson<String>(category),
      'enabled': serializer.toJson<bool>(enabled),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
      'recordSource': serializer.toJson<String>(recordSource),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'revision': serializer.toJson<int>(revision),
    };
  }

  RecurringRule copyWith({
    int? id,
    String? userId,
    String? title,
    String? type,
    String? cadence,
    int? nextRunAt,
    Value<double?> amount = const Value.absent(),
    String? category,
    bool? enabled,
    int? createdAt,
    int? updatedAt,
    String? syncState,
    String? recordSource,
    Value<int?> deletedAt = const Value.absent(),
    int? revision,
  }) => RecurringRule(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    type: type ?? this.type,
    cadence: cadence ?? this.cadence,
    nextRunAt: nextRunAt ?? this.nextRunAt,
    amount: amount.present ? amount.value : this.amount,
    category: category ?? this.category,
    enabled: enabled ?? this.enabled,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncState: syncState ?? this.syncState,
    recordSource: recordSource ?? this.recordSource,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    revision: revision ?? this.revision,
  );
  RecurringRule copyWithCompanion(RecurringRulesCompanion data) {
    return RecurringRule(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      type: data.type.present ? data.type.value : this.type,
      cadence: data.cadence.present ? data.cadence.value : this.cadence,
      nextRunAt: data.nextRunAt.present ? data.nextRunAt.value : this.nextRunAt,
      amount: data.amount.present ? data.amount.value : this.amount,
      category: data.category.present ? data.category.value : this.category,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      recordSource: data.recordSource.present
          ? data.recordSource.value
          : this.recordSource,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRule(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('cadence: $cadence, ')
          ..write('nextRunAt: $nextRunAt, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('recordSource: $recordSource, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    title,
    type,
    cadence,
    nextRunAt,
    amount,
    category,
    enabled,
    createdAt,
    updatedAt,
    syncState,
    recordSource,
    deletedAt,
    revision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringRule &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.type == this.type &&
          other.cadence == this.cadence &&
          other.nextRunAt == this.nextRunAt &&
          other.amount == this.amount &&
          other.category == this.category &&
          other.enabled == this.enabled &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState &&
          other.recordSource == this.recordSource &&
          other.deletedAt == this.deletedAt &&
          other.revision == this.revision);
}

class RecurringRulesCompanion extends UpdateCompanion<RecurringRule> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> title;
  final Value<String> type;
  final Value<String> cadence;
  final Value<int> nextRunAt;
  final Value<double?> amount;
  final Value<String> category;
  final Value<bool> enabled;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> syncState;
  final Value<String> recordSource;
  final Value<int?> deletedAt;
  final Value<int> revision;
  final Value<int> rowid;
  const RecurringRulesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.type = const Value.absent(),
    this.cadence = const Value.absent(),
    this.nextRunAt = const Value.absent(),
    this.amount = const Value.absent(),
    this.category = const Value.absent(),
    this.enabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.recordSource = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringRulesCompanion.insert({
    required int id,
    required String userId,
    required String title,
    required String type,
    required String cadence,
    required int nextRunAt,
    this.amount = const Value.absent(),
    this.category = const Value.absent(),
    required bool enabled,
    required int createdAt,
    required int updatedAt,
    required String syncState,
    required String recordSource,
    this.deletedAt = const Value.absent(),
    required int revision,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       title = Value(title),
       type = Value(type),
       cadence = Value(cadence),
       nextRunAt = Value(nextRunAt),
       enabled = Value(enabled),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncState = Value(syncState),
       recordSource = Value(recordSource),
       revision = Value(revision);
  static Insertable<RecurringRule> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? type,
    Expression<String>? cadence,
    Expression<int>? nextRunAt,
    Expression<double>? amount,
    Expression<String>? category,
    Expression<bool>? enabled,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? syncState,
    Expression<String>? recordSource,
    Expression<int>? deletedAt,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (type != null) 'type': type,
      if (cadence != null) 'cadence': cadence,
      if (nextRunAt != null) 'next_run_at': nextRunAt,
      if (amount != null) 'amount': amount,
      if (category != null) 'category': category,
      if (enabled != null) 'enabled': enabled,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (recordSource != null) 'record_source': recordSource,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringRulesCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? title,
    Value<String>? type,
    Value<String>? cadence,
    Value<int>? nextRunAt,
    Value<double?>? amount,
    Value<String>? category,
    Value<bool>? enabled,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? syncState,
    Value<String>? recordSource,
    Value<int?>? deletedAt,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return RecurringRulesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      type: type ?? this.type,
      cadence: cadence ?? this.cadence,
      nextRunAt: nextRunAt ?? this.nextRunAt,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      recordSource: recordSource ?? this.recordSource,
      deletedAt: deletedAt ?? this.deletedAt,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (cadence.present) {
      map['cadence'] = Variable<String>(cadence.value);
    }
    if (nextRunAt.present) {
      map['next_run_at'] = Variable<int>(nextRunAt.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (recordSource.present) {
      map['record_source'] = Variable<String>(recordSource.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRulesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('cadence: $cadence, ')
          ..write('nextRunAt: $nextRunAt, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('recordSource: $recordSource, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FulizaLoansTable extends FulizaLoans
    with TableInfo<$FulizaLoansTable, FulizaLoan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FulizaLoansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _drawCodeMeta = const VerificationMeta(
    'drawCode',
  );
  @override
  late final GeneratedColumn<String> drawCode = GeneratedColumn<String>(
    'draw_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _drawAmountKesMeta = const VerificationMeta(
    'drawAmountKes',
  );
  @override
  late final GeneratedColumn<double> drawAmountKes = GeneratedColumn<double>(
    'draw_amount_kes',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalRepaidKesMeta = const VerificationMeta(
    'totalRepaidKes',
  );
  @override
  late final GeneratedColumn<double> totalRepaidKes = GeneratedColumn<double>(
    'total_repaid_kes',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _drawDateMeta = const VerificationMeta(
    'drawDate',
  );
  @override
  late final GeneratedColumn<int> drawDate = GeneratedColumn<int>(
    'draw_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastRepaymentDateMeta = const VerificationMeta(
    'lastRepaymentDate',
  );
  @override
  late final GeneratedColumn<int> lastRepaymentDate = GeneratedColumn<int>(
    'last_repayment_date',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    drawCode,
    drawAmountKes,
    totalRepaidKes,
    status,
    drawDate,
    lastRepaymentDate,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fuliza_loans';
  @override
  VerificationContext validateIntegrity(
    Insertable<FulizaLoan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('draw_code')) {
      context.handle(
        _drawCodeMeta,
        drawCode.isAcceptableOrUnknown(data['draw_code']!, _drawCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_drawCodeMeta);
    }
    if (data.containsKey('draw_amount_kes')) {
      context.handle(
        _drawAmountKesMeta,
        drawAmountKes.isAcceptableOrUnknown(
          data['draw_amount_kes']!,
          _drawAmountKesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_drawAmountKesMeta);
    }
    if (data.containsKey('total_repaid_kes')) {
      context.handle(
        _totalRepaidKesMeta,
        totalRepaidKes.isAcceptableOrUnknown(
          data['total_repaid_kes']!,
          _totalRepaidKesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalRepaidKesMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('draw_date')) {
      context.handle(
        _drawDateMeta,
        drawDate.isAcceptableOrUnknown(data['draw_date']!, _drawDateMeta),
      );
    } else if (isInserting) {
      context.missing(_drawDateMeta);
    }
    if (data.containsKey('last_repayment_date')) {
      context.handle(
        _lastRepaymentDateMeta,
        lastRepaymentDate.isAcceptableOrUnknown(
          data['last_repayment_date']!,
          _lastRepaymentDateMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  FulizaLoan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FulizaLoan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      drawCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}draw_code'],
      )!,
      drawAmountKes: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}draw_amount_kes'],
      )!,
      totalRepaidKes: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_repaid_kes'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      drawDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}draw_date'],
      )!,
      lastRepaymentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_repayment_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FulizaLoansTable createAlias(String alias) {
    return $FulizaLoansTable(attachedDatabase, alias);
  }
}

class FulizaLoan extends DataClass implements Insertable<FulizaLoan> {
  final int id;
  final String userId;
  final String drawCode;
  final double drawAmountKes;
  final double totalRepaidKes;
  final String status;
  final int drawDate;
  final int? lastRepaymentDate;
  final int createdAt;
  final int updatedAt;
  const FulizaLoan({
    required this.id,
    required this.userId,
    required this.drawCode,
    required this.drawAmountKes,
    required this.totalRepaidKes,
    required this.status,
    required this.drawDate,
    this.lastRepaymentDate,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['draw_code'] = Variable<String>(drawCode);
    map['draw_amount_kes'] = Variable<double>(drawAmountKes);
    map['total_repaid_kes'] = Variable<double>(totalRepaidKes);
    map['status'] = Variable<String>(status);
    map['draw_date'] = Variable<int>(drawDate);
    if (!nullToAbsent || lastRepaymentDate != null) {
      map['last_repayment_date'] = Variable<int>(lastRepaymentDate);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  FulizaLoansCompanion toCompanion(bool nullToAbsent) {
    return FulizaLoansCompanion(
      id: Value(id),
      userId: Value(userId),
      drawCode: Value(drawCode),
      drawAmountKes: Value(drawAmountKes),
      totalRepaidKes: Value(totalRepaidKes),
      status: Value(status),
      drawDate: Value(drawDate),
      lastRepaymentDate: lastRepaymentDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastRepaymentDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FulizaLoan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FulizaLoan(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      drawCode: serializer.fromJson<String>(json['drawCode']),
      drawAmountKes: serializer.fromJson<double>(json['drawAmountKes']),
      totalRepaidKes: serializer.fromJson<double>(json['totalRepaidKes']),
      status: serializer.fromJson<String>(json['status']),
      drawDate: serializer.fromJson<int>(json['drawDate']),
      lastRepaymentDate: serializer.fromJson<int?>(json['lastRepaymentDate']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'drawCode': serializer.toJson<String>(drawCode),
      'drawAmountKes': serializer.toJson<double>(drawAmountKes),
      'totalRepaidKes': serializer.toJson<double>(totalRepaidKes),
      'status': serializer.toJson<String>(status),
      'drawDate': serializer.toJson<int>(drawDate),
      'lastRepaymentDate': serializer.toJson<int?>(lastRepaymentDate),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  FulizaLoan copyWith({
    int? id,
    String? userId,
    String? drawCode,
    double? drawAmountKes,
    double? totalRepaidKes,
    String? status,
    int? drawDate,
    Value<int?> lastRepaymentDate = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => FulizaLoan(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    drawCode: drawCode ?? this.drawCode,
    drawAmountKes: drawAmountKes ?? this.drawAmountKes,
    totalRepaidKes: totalRepaidKes ?? this.totalRepaidKes,
    status: status ?? this.status,
    drawDate: drawDate ?? this.drawDate,
    lastRepaymentDate: lastRepaymentDate.present
        ? lastRepaymentDate.value
        : this.lastRepaymentDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FulizaLoan copyWithCompanion(FulizaLoansCompanion data) {
    return FulizaLoan(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      drawCode: data.drawCode.present ? data.drawCode.value : this.drawCode,
      drawAmountKes: data.drawAmountKes.present
          ? data.drawAmountKes.value
          : this.drawAmountKes,
      totalRepaidKes: data.totalRepaidKes.present
          ? data.totalRepaidKes.value
          : this.totalRepaidKes,
      status: data.status.present ? data.status.value : this.status,
      drawDate: data.drawDate.present ? data.drawDate.value : this.drawDate,
      lastRepaymentDate: data.lastRepaymentDate.present
          ? data.lastRepaymentDate.value
          : this.lastRepaymentDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FulizaLoan(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('drawCode: $drawCode, ')
          ..write('drawAmountKes: $drawAmountKes, ')
          ..write('totalRepaidKes: $totalRepaidKes, ')
          ..write('status: $status, ')
          ..write('drawDate: $drawDate, ')
          ..write('lastRepaymentDate: $lastRepaymentDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    drawCode,
    drawAmountKes,
    totalRepaidKes,
    status,
    drawDate,
    lastRepaymentDate,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FulizaLoan &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.drawCode == this.drawCode &&
          other.drawAmountKes == this.drawAmountKes &&
          other.totalRepaidKes == this.totalRepaidKes &&
          other.status == this.status &&
          other.drawDate == this.drawDate &&
          other.lastRepaymentDate == this.lastRepaymentDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FulizaLoansCompanion extends UpdateCompanion<FulizaLoan> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> drawCode;
  final Value<double> drawAmountKes;
  final Value<double> totalRepaidKes;
  final Value<String> status;
  final Value<int> drawDate;
  final Value<int?> lastRepaymentDate;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const FulizaLoansCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.drawCode = const Value.absent(),
    this.drawAmountKes = const Value.absent(),
    this.totalRepaidKes = const Value.absent(),
    this.status = const Value.absent(),
    this.drawDate = const Value.absent(),
    this.lastRepaymentDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FulizaLoansCompanion.insert({
    required int id,
    required String userId,
    required String drawCode,
    required double drawAmountKes,
    required double totalRepaidKes,
    required String status,
    required int drawDate,
    this.lastRepaymentDate = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       drawCode = Value(drawCode),
       drawAmountKes = Value(drawAmountKes),
       totalRepaidKes = Value(totalRepaidKes),
       status = Value(status),
       drawDate = Value(drawDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FulizaLoan> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? drawCode,
    Expression<double>? drawAmountKes,
    Expression<double>? totalRepaidKes,
    Expression<String>? status,
    Expression<int>? drawDate,
    Expression<int>? lastRepaymentDate,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (drawCode != null) 'draw_code': drawCode,
      if (drawAmountKes != null) 'draw_amount_kes': drawAmountKes,
      if (totalRepaidKes != null) 'total_repaid_kes': totalRepaidKes,
      if (status != null) 'status': status,
      if (drawDate != null) 'draw_date': drawDate,
      if (lastRepaymentDate != null) 'last_repayment_date': lastRepaymentDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FulizaLoansCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? drawCode,
    Value<double>? drawAmountKes,
    Value<double>? totalRepaidKes,
    Value<String>? status,
    Value<int>? drawDate,
    Value<int?>? lastRepaymentDate,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return FulizaLoansCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      drawCode: drawCode ?? this.drawCode,
      drawAmountKes: drawAmountKes ?? this.drawAmountKes,
      totalRepaidKes: totalRepaidKes ?? this.totalRepaidKes,
      status: status ?? this.status,
      drawDate: drawDate ?? this.drawDate,
      lastRepaymentDate: lastRepaymentDate ?? this.lastRepaymentDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (drawCode.present) {
      map['draw_code'] = Variable<String>(drawCode.value);
    }
    if (drawAmountKes.present) {
      map['draw_amount_kes'] = Variable<double>(drawAmountKes.value);
    }
    if (totalRepaidKes.present) {
      map['total_repaid_kes'] = Variable<double>(totalRepaidKes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (drawDate.present) {
      map['draw_date'] = Variable<int>(drawDate.value);
    }
    if (lastRepaymentDate.present) {
      map['last_repayment_date'] = Variable<int>(lastRepaymentDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FulizaLoansCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('drawCode: $drawCode, ')
          ..write('drawAmountKes: $drawAmountKes, ')
          ..write('totalRepaidKes: $totalRepaidKes, ')
          ..write('status: $status, ')
          ..write('drawDate: $drawDate, ')
          ..write('lastRepaymentDate: $lastRepaymentDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FulizaEventsTable extends FulizaEvents
    with TableInfo<$FulizaEventsTable, FulizaEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FulizaEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mpesaCodeMeta = const VerificationMeta(
    'mpesaCode',
  );
  @override
  late final GeneratedColumn<String> mpesaCode = GeneratedColumn<String>(
    'mpesa_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountKesMeta = const VerificationMeta(
    'amountKes',
  );
  @override
  late final GeneratedColumn<double> amountKes = GeneratedColumn<double>(
    'amount_kes',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outstandingAfterMeta = const VerificationMeta(
    'outstandingAfter',
  );
  @override
  late final GeneratedColumn<double> outstandingAfter = GeneratedColumn<double>(
    'outstanding_after',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _eventAtMeta = const VerificationMeta(
    'eventAt',
  );
  @override
  late final GeneratedColumn<int> eventAt = GeneratedColumn<int>(
    'event_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    eventType,
    mpesaCode,
    amountKes,
    outstandingAfter,
    eventAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fuliza_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<FulizaEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('mpesa_code')) {
      context.handle(
        _mpesaCodeMeta,
        mpesaCode.isAcceptableOrUnknown(data['mpesa_code']!, _mpesaCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_mpesaCodeMeta);
    }
    if (data.containsKey('amount_kes')) {
      context.handle(
        _amountKesMeta,
        amountKes.isAcceptableOrUnknown(data['amount_kes']!, _amountKesMeta),
      );
    } else if (isInserting) {
      context.missing(_amountKesMeta);
    }
    if (data.containsKey('outstanding_after')) {
      context.handle(
        _outstandingAfterMeta,
        outstandingAfter.isAcceptableOrUnknown(
          data['outstanding_after']!,
          _outstandingAfterMeta,
        ),
      );
    }
    if (data.containsKey('event_at')) {
      context.handle(
        _eventAtMeta,
        eventAt.isAcceptableOrUnknown(data['event_at']!, _eventAtMeta),
      );
    } else if (isInserting) {
      context.missing(_eventAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FulizaEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FulizaEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      mpesaCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mpesa_code'],
      )!,
      amountKes: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_kes'],
      )!,
      outstandingAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}outstanding_after'],
      )!,
      eventAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}event_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FulizaEventsTable createAlias(String alias) {
    return $FulizaEventsTable(attachedDatabase, alias);
  }
}

class FulizaEvent extends DataClass implements Insertable<FulizaEvent> {
  final int id;
  final String userId;
  final String eventType;
  final String mpesaCode;
  final double amountKes;
  final double outstandingAfter;
  final int eventAt;
  final int createdAt;
  const FulizaEvent({
    required this.id,
    required this.userId,
    required this.eventType,
    required this.mpesaCode,
    required this.amountKes,
    required this.outstandingAfter,
    required this.eventAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['event_type'] = Variable<String>(eventType);
    map['mpesa_code'] = Variable<String>(mpesaCode);
    map['amount_kes'] = Variable<double>(amountKes);
    map['outstanding_after'] = Variable<double>(outstandingAfter);
    map['event_at'] = Variable<int>(eventAt);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  FulizaEventsCompanion toCompanion(bool nullToAbsent) {
    return FulizaEventsCompanion(
      id: Value(id),
      userId: Value(userId),
      eventType: Value(eventType),
      mpesaCode: Value(mpesaCode),
      amountKes: Value(amountKes),
      outstandingAfter: Value(outstandingAfter),
      eventAt: Value(eventAt),
      createdAt: Value(createdAt),
    );
  }

  factory FulizaEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FulizaEvent(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      mpesaCode: serializer.fromJson<String>(json['mpesaCode']),
      amountKes: serializer.fromJson<double>(json['amountKes']),
      outstandingAfter: serializer.fromJson<double>(json['outstandingAfter']),
      eventAt: serializer.fromJson<int>(json['eventAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'eventType': serializer.toJson<String>(eventType),
      'mpesaCode': serializer.toJson<String>(mpesaCode),
      'amountKes': serializer.toJson<double>(amountKes),
      'outstandingAfter': serializer.toJson<double>(outstandingAfter),
      'eventAt': serializer.toJson<int>(eventAt),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  FulizaEvent copyWith({
    int? id,
    String? userId,
    String? eventType,
    String? mpesaCode,
    double? amountKes,
    double? outstandingAfter,
    int? eventAt,
    int? createdAt,
  }) => FulizaEvent(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    eventType: eventType ?? this.eventType,
    mpesaCode: mpesaCode ?? this.mpesaCode,
    amountKes: amountKes ?? this.amountKes,
    outstandingAfter: outstandingAfter ?? this.outstandingAfter,
    eventAt: eventAt ?? this.eventAt,
    createdAt: createdAt ?? this.createdAt,
  );
  FulizaEvent copyWithCompanion(FulizaEventsCompanion data) {
    return FulizaEvent(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      mpesaCode: data.mpesaCode.present ? data.mpesaCode.value : this.mpesaCode,
      amountKes: data.amountKes.present ? data.amountKes.value : this.amountKes,
      outstandingAfter: data.outstandingAfter.present
          ? data.outstandingAfter.value
          : this.outstandingAfter,
      eventAt: data.eventAt.present ? data.eventAt.value : this.eventAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FulizaEvent(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('eventType: $eventType, ')
          ..write('mpesaCode: $mpesaCode, ')
          ..write('amountKes: $amountKes, ')
          ..write('outstandingAfter: $outstandingAfter, ')
          ..write('eventAt: $eventAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    eventType,
    mpesaCode,
    amountKes,
    outstandingAfter,
    eventAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FulizaEvent &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.eventType == this.eventType &&
          other.mpesaCode == this.mpesaCode &&
          other.amountKes == this.amountKes &&
          other.outstandingAfter == this.outstandingAfter &&
          other.eventAt == this.eventAt &&
          other.createdAt == this.createdAt);
}

class FulizaEventsCompanion extends UpdateCompanion<FulizaEvent> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> eventType;
  final Value<String> mpesaCode;
  final Value<double> amountKes;
  final Value<double> outstandingAfter;
  final Value<int> eventAt;
  final Value<int> createdAt;
  const FulizaEventsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.mpesaCode = const Value.absent(),
    this.amountKes = const Value.absent(),
    this.outstandingAfter = const Value.absent(),
    this.eventAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FulizaEventsCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String eventType,
    required String mpesaCode,
    required double amountKes,
    this.outstandingAfter = const Value.absent(),
    required int eventAt,
    required int createdAt,
  }) : userId = Value(userId),
       eventType = Value(eventType),
       mpesaCode = Value(mpesaCode),
       amountKes = Value(amountKes),
       eventAt = Value(eventAt),
       createdAt = Value(createdAt);
  static Insertable<FulizaEvent> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? eventType,
    Expression<String>? mpesaCode,
    Expression<double>? amountKes,
    Expression<double>? outstandingAfter,
    Expression<int>? eventAt,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (eventType != null) 'event_type': eventType,
      if (mpesaCode != null) 'mpesa_code': mpesaCode,
      if (amountKes != null) 'amount_kes': amountKes,
      if (outstandingAfter != null) 'outstanding_after': outstandingAfter,
      if (eventAt != null) 'event_at': eventAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FulizaEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? eventType,
    Value<String>? mpesaCode,
    Value<double>? amountKes,
    Value<double>? outstandingAfter,
    Value<int>? eventAt,
    Value<int>? createdAt,
  }) {
    return FulizaEventsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventType: eventType ?? this.eventType,
      mpesaCode: mpesaCode ?? this.mpesaCode,
      amountKes: amountKes ?? this.amountKes,
      outstandingAfter: outstandingAfter ?? this.outstandingAfter,
      eventAt: eventAt ?? this.eventAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (mpesaCode.present) {
      map['mpesa_code'] = Variable<String>(mpesaCode.value);
    }
    if (amountKes.present) {
      map['amount_kes'] = Variable<double>(amountKes.value);
    }
    if (outstandingAfter.present) {
      map['outstanding_after'] = Variable<double>(outstandingAfter.value);
    }
    if (eventAt.present) {
      map['event_at'] = Variable<int>(eventAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FulizaEventsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('eventType: $eventType, ')
          ..write('mpesaCode: $mpesaCode, ')
          ..write('amountKes: $amountKes, ')
          ..write('outstandingAfter: $outstandingAfter, ')
          ..write('eventAt: $eventAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PaybillRegistryTable extends PaybillRegistry
    with TableInfo<$PaybillRegistryTable, PaybillRegistryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaybillRegistryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _paybillNumberMeta = const VerificationMeta(
    'paybillNumber',
  );
  @override
  late final GeneratedColumn<String> paybillNumber = GeneratedColumn<String>(
    'paybill_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<int> lastSeenAt = GeneratedColumn<int>(
    'last_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usageCountMeta = const VerificationMeta(
    'usageCount',
  );
  @override
  late final GeneratedColumn<int> usageCount = GeneratedColumn<int>(
    'usage_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAmountKesMeta = const VerificationMeta(
    'lastAmountKes',
  );
  @override
  late final GeneratedColumn<double> lastAmountKes = GeneratedColumn<double>(
    'last_amount_kes',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    paybillNumber,
    userId,
    displayName,
    lastSeenAt,
    usageCount,
    lastAmountKes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'paybill_registry';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaybillRegistryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('paybill_number')) {
      context.handle(
        _paybillNumberMeta,
        paybillNumber.isAcceptableOrUnknown(
          data['paybill_number']!,
          _paybillNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paybillNumberMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSeenAtMeta);
    }
    if (data.containsKey('usage_count')) {
      context.handle(
        _usageCountMeta,
        usageCount.isAcceptableOrUnknown(data['usage_count']!, _usageCountMeta),
      );
    } else if (isInserting) {
      context.missing(_usageCountMeta);
    }
    if (data.containsKey('last_amount_kes')) {
      context.handle(
        _lastAmountKesMeta,
        lastAmountKes.isAcceptableOrUnknown(
          data['last_amount_kes']!,
          _lastAmountKesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastAmountKesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, paybillNumber};
  @override
  PaybillRegistryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaybillRegistryData(
      paybillNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paybill_number'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seen_at'],
      )!,
      usageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}usage_count'],
      )!,
      lastAmountKes: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}last_amount_kes'],
      )!,
    );
  }

  @override
  $PaybillRegistryTable createAlias(String alias) {
    return $PaybillRegistryTable(attachedDatabase, alias);
  }
}

class PaybillRegistryData extends DataClass
    implements Insertable<PaybillRegistryData> {
  final String paybillNumber;
  final String userId;
  final String displayName;
  final int lastSeenAt;
  final int usageCount;
  final double lastAmountKes;
  const PaybillRegistryData({
    required this.paybillNumber,
    required this.userId,
    required this.displayName,
    required this.lastSeenAt,
    required this.usageCount,
    required this.lastAmountKes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['paybill_number'] = Variable<String>(paybillNumber);
    map['user_id'] = Variable<String>(userId);
    map['display_name'] = Variable<String>(displayName);
    map['last_seen_at'] = Variable<int>(lastSeenAt);
    map['usage_count'] = Variable<int>(usageCount);
    map['last_amount_kes'] = Variable<double>(lastAmountKes);
    return map;
  }

  PaybillRegistryCompanion toCompanion(bool nullToAbsent) {
    return PaybillRegistryCompanion(
      paybillNumber: Value(paybillNumber),
      userId: Value(userId),
      displayName: Value(displayName),
      lastSeenAt: Value(lastSeenAt),
      usageCount: Value(usageCount),
      lastAmountKes: Value(lastAmountKes),
    );
  }

  factory PaybillRegistryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaybillRegistryData(
      paybillNumber: serializer.fromJson<String>(json['paybillNumber']),
      userId: serializer.fromJson<String>(json['userId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      lastSeenAt: serializer.fromJson<int>(json['lastSeenAt']),
      usageCount: serializer.fromJson<int>(json['usageCount']),
      lastAmountKes: serializer.fromJson<double>(json['lastAmountKes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'paybillNumber': serializer.toJson<String>(paybillNumber),
      'userId': serializer.toJson<String>(userId),
      'displayName': serializer.toJson<String>(displayName),
      'lastSeenAt': serializer.toJson<int>(lastSeenAt),
      'usageCount': serializer.toJson<int>(usageCount),
      'lastAmountKes': serializer.toJson<double>(lastAmountKes),
    };
  }

  PaybillRegistryData copyWith({
    String? paybillNumber,
    String? userId,
    String? displayName,
    int? lastSeenAt,
    int? usageCount,
    double? lastAmountKes,
  }) => PaybillRegistryData(
    paybillNumber: paybillNumber ?? this.paybillNumber,
    userId: userId ?? this.userId,
    displayName: displayName ?? this.displayName,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    usageCount: usageCount ?? this.usageCount,
    lastAmountKes: lastAmountKes ?? this.lastAmountKes,
  );
  PaybillRegistryData copyWithCompanion(PaybillRegistryCompanion data) {
    return PaybillRegistryData(
      paybillNumber: data.paybillNumber.present
          ? data.paybillNumber.value
          : this.paybillNumber,
      userId: data.userId.present ? data.userId.value : this.userId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
      usageCount: data.usageCount.present
          ? data.usageCount.value
          : this.usageCount,
      lastAmountKes: data.lastAmountKes.present
          ? data.lastAmountKes.value
          : this.lastAmountKes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaybillRegistryData(')
          ..write('paybillNumber: $paybillNumber, ')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('usageCount: $usageCount, ')
          ..write('lastAmountKes: $lastAmountKes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    paybillNumber,
    userId,
    displayName,
    lastSeenAt,
    usageCount,
    lastAmountKes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaybillRegistryData &&
          other.paybillNumber == this.paybillNumber &&
          other.userId == this.userId &&
          other.displayName == this.displayName &&
          other.lastSeenAt == this.lastSeenAt &&
          other.usageCount == this.usageCount &&
          other.lastAmountKes == this.lastAmountKes);
}

class PaybillRegistryCompanion extends UpdateCompanion<PaybillRegistryData> {
  final Value<String> paybillNumber;
  final Value<String> userId;
  final Value<String> displayName;
  final Value<int> lastSeenAt;
  final Value<int> usageCount;
  final Value<double> lastAmountKes;
  final Value<int> rowid;
  const PaybillRegistryCompanion({
    this.paybillNumber = const Value.absent(),
    this.userId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.lastAmountKes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaybillRegistryCompanion.insert({
    required String paybillNumber,
    required String userId,
    required String displayName,
    required int lastSeenAt,
    required int usageCount,
    required double lastAmountKes,
    this.rowid = const Value.absent(),
  }) : paybillNumber = Value(paybillNumber),
       userId = Value(userId),
       displayName = Value(displayName),
       lastSeenAt = Value(lastSeenAt),
       usageCount = Value(usageCount),
       lastAmountKes = Value(lastAmountKes);
  static Insertable<PaybillRegistryData> custom({
    Expression<String>? paybillNumber,
    Expression<String>? userId,
    Expression<String>? displayName,
    Expression<int>? lastSeenAt,
    Expression<int>? usageCount,
    Expression<double>? lastAmountKes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (paybillNumber != null) 'paybill_number': paybillNumber,
      if (userId != null) 'user_id': userId,
      if (displayName != null) 'display_name': displayName,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (usageCount != null) 'usage_count': usageCount,
      if (lastAmountKes != null) 'last_amount_kes': lastAmountKes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaybillRegistryCompanion copyWith({
    Value<String>? paybillNumber,
    Value<String>? userId,
    Value<String>? displayName,
    Value<int>? lastSeenAt,
    Value<int>? usageCount,
    Value<double>? lastAmountKes,
    Value<int>? rowid,
  }) {
    return PaybillRegistryCompanion(
      paybillNumber: paybillNumber ?? this.paybillNumber,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      usageCount: usageCount ?? this.usageCount,
      lastAmountKes: lastAmountKes ?? this.lastAmountKes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (paybillNumber.present) {
      map['paybill_number'] = Variable<String>(paybillNumber.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<int>(lastSeenAt.value);
    }
    if (usageCount.present) {
      map['usage_count'] = Variable<int>(usageCount.value);
    }
    if (lastAmountKes.present) {
      map['last_amount_kes'] = Variable<double>(lastAmountKes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaybillRegistryCompanion(')
          ..write('paybillNumber: $paybillNumber, ')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('usageCount: $usageCount, ')
          ..write('lastAmountKes: $lastAmountKes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MerchantCategoriesTable extends MerchantCategories
    with TableInfo<$MerchantCategoriesTable, MerchantCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MerchantCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _merchantMeta = const VerificationMeta(
    'merchant',
  );
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
    'merchant',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userCorrectedMeta = const VerificationMeta(
    'userCorrected',
  );
  @override
  late final GeneratedColumn<bool> userCorrected = GeneratedColumn<bool>(
    'userCorrected',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("userCorrected" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordSourceMeta = const VerificationMeta(
    'recordSource',
  );
  @override
  late final GeneratedColumn<String> recordSource = GeneratedColumn<String>(
    'record_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    merchant,
    category,
    confidence,
    userCorrected,
    createdAt,
    updatedAt,
    syncState,
    recordSource,
    deletedAt,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'merchant_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<MerchantCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('merchant')) {
      context.handle(
        _merchantMeta,
        merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta),
      );
    } else if (isInserting) {
      context.missing(_merchantMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('userCorrected')) {
      context.handle(
        _userCorrectedMeta,
        userCorrected.isAcceptableOrUnknown(
          data['userCorrected']!,
          _userCorrectedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_userCorrectedMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStateMeta);
    }
    if (data.containsKey('record_source')) {
      context.handle(
        _recordSourceMeta,
        recordSource.isAcceptableOrUnknown(
          data['record_source']!,
          _recordSourceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordSourceMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  MerchantCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MerchantCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      merchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      userCorrected: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}userCorrected'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      recordSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_source'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $MerchantCategoriesTable createAlias(String alias) {
    return $MerchantCategoriesTable(attachedDatabase, alias);
  }
}

class MerchantCategory extends DataClass
    implements Insertable<MerchantCategory> {
  final int id;
  final String userId;
  final String merchant;
  final String category;
  final double confidence;
  final bool userCorrected;
  final int createdAt;
  final int updatedAt;
  final String syncState;
  final String recordSource;
  final int? deletedAt;
  final int revision;
  const MerchantCategory({
    required this.id,
    required this.userId,
    required this.merchant,
    required this.category,
    required this.confidence,
    required this.userCorrected,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
    required this.recordSource,
    this.deletedAt,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['merchant'] = Variable<String>(merchant);
    map['category'] = Variable<String>(category);
    map['confidence'] = Variable<double>(confidence);
    map['userCorrected'] = Variable<bool>(userCorrected);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    map['record_source'] = Variable<String>(recordSource);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['revision'] = Variable<int>(revision);
    return map;
  }

  MerchantCategoriesCompanion toCompanion(bool nullToAbsent) {
    return MerchantCategoriesCompanion(
      id: Value(id),
      userId: Value(userId),
      merchant: Value(merchant),
      category: Value(category),
      confidence: Value(confidence),
      userCorrected: Value(userCorrected),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
      recordSource: Value(recordSource),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      revision: Value(revision),
    );
  }

  factory MerchantCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MerchantCategory(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      merchant: serializer.fromJson<String>(json['merchant']),
      category: serializer.fromJson<String>(json['category']),
      confidence: serializer.fromJson<double>(json['confidence']),
      userCorrected: serializer.fromJson<bool>(json['userCorrected']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      recordSource: serializer.fromJson<String>(json['recordSource']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'merchant': serializer.toJson<String>(merchant),
      'category': serializer.toJson<String>(category),
      'confidence': serializer.toJson<double>(confidence),
      'userCorrected': serializer.toJson<bool>(userCorrected),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
      'recordSource': serializer.toJson<String>(recordSource),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'revision': serializer.toJson<int>(revision),
    };
  }

  MerchantCategory copyWith({
    int? id,
    String? userId,
    String? merchant,
    String? category,
    double? confidence,
    bool? userCorrected,
    int? createdAt,
    int? updatedAt,
    String? syncState,
    String? recordSource,
    Value<int?> deletedAt = const Value.absent(),
    int? revision,
  }) => MerchantCategory(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    merchant: merchant ?? this.merchant,
    category: category ?? this.category,
    confidence: confidence ?? this.confidence,
    userCorrected: userCorrected ?? this.userCorrected,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncState: syncState ?? this.syncState,
    recordSource: recordSource ?? this.recordSource,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    revision: revision ?? this.revision,
  );
  MerchantCategory copyWithCompanion(MerchantCategoriesCompanion data) {
    return MerchantCategory(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      category: data.category.present ? data.category.value : this.category,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      userCorrected: data.userCorrected.present
          ? data.userCorrected.value
          : this.userCorrected,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      recordSource: data.recordSource.present
          ? data.recordSource.value
          : this.recordSource,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MerchantCategory(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('merchant: $merchant, ')
          ..write('category: $category, ')
          ..write('confidence: $confidence, ')
          ..write('userCorrected: $userCorrected, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('recordSource: $recordSource, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    merchant,
    category,
    confidence,
    userCorrected,
    createdAt,
    updatedAt,
    syncState,
    recordSource,
    deletedAt,
    revision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MerchantCategory &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.merchant == this.merchant &&
          other.category == this.category &&
          other.confidence == this.confidence &&
          other.userCorrected == this.userCorrected &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState &&
          other.recordSource == this.recordSource &&
          other.deletedAt == this.deletedAt &&
          other.revision == this.revision);
}

class MerchantCategoriesCompanion extends UpdateCompanion<MerchantCategory> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> merchant;
  final Value<String> category;
  final Value<double> confidence;
  final Value<bool> userCorrected;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> syncState;
  final Value<String> recordSource;
  final Value<int?> deletedAt;
  final Value<int> revision;
  final Value<int> rowid;
  const MerchantCategoriesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.merchant = const Value.absent(),
    this.category = const Value.absent(),
    this.confidence = const Value.absent(),
    this.userCorrected = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.recordSource = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MerchantCategoriesCompanion.insert({
    required int id,
    required String userId,
    required String merchant,
    required String category,
    required double confidence,
    required bool userCorrected,
    required int createdAt,
    required int updatedAt,
    required String syncState,
    required String recordSource,
    this.deletedAt = const Value.absent(),
    required int revision,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       merchant = Value(merchant),
       category = Value(category),
       confidence = Value(confidence),
       userCorrected = Value(userCorrected),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncState = Value(syncState),
       recordSource = Value(recordSource),
       revision = Value(revision);
  static Insertable<MerchantCategory> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? merchant,
    Expression<String>? category,
    Expression<double>? confidence,
    Expression<bool>? userCorrected,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? syncState,
    Expression<String>? recordSource,
    Expression<int>? deletedAt,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (merchant != null) 'merchant': merchant,
      if (category != null) 'category': category,
      if (confidence != null) 'confidence': confidence,
      if (userCorrected != null) 'userCorrected': userCorrected,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (recordSource != null) 'record_source': recordSource,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MerchantCategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? merchant,
    Value<String>? category,
    Value<double>? confidence,
    Value<bool>? userCorrected,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? syncState,
    Value<String>? recordSource,
    Value<int?>? deletedAt,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return MerchantCategoriesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      merchant: merchant ?? this.merchant,
      category: category ?? this.category,
      confidence: confidence ?? this.confidence,
      userCorrected: userCorrected ?? this.userCorrected,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      recordSource: recordSource ?? this.recordSource,
      deletedAt: deletedAt ?? this.deletedAt,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (userCorrected.present) {
      map['userCorrected'] = Variable<bool>(userCorrected.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (recordSource.present) {
      map['record_source'] = Variable<String>(recordSource.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MerchantCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('merchant: $merchant, ')
          ..write('category: $category, ')
          ..write('confidence: $confidence, ')
          ..write('userCorrected: $userCorrected, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('recordSource: $recordSource, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SmsIngestQueueTable extends SmsIngestQueue
    with TableInfo<$SmsIngestQueueTable, SmsIngestQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SmsIngestQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawMessageMeta = const VerificationMeta(
    'rawMessage',
  );
  @override
  late final GeneratedColumn<String> rawMessage = GeneratedColumn<String>(
    'raw_message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderMeta = const VerificationMeta('sender');
  @override
  late final GeneratedColumn<String> sender = GeneratedColumn<String>(
    'sender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMsMeta = const VerificationMeta(
    'timestampMs',
  );
  @override
  late final GeneratedColumn<int> timestampMs = GeneratedColumn<int>(
    'timestamp_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enqueuedAtMeta = const VerificationMeta(
    'enqueuedAt',
  );
  @override
  late final GeneratedColumn<int> enqueuedAt = GeneratedColumn<int>(
    'enqueued_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDING'),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    rawMessage,
    sender,
    timestampMs,
    enqueuedAt,
    state,
    retryCount,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sms_ingest_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SmsIngestQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('raw_message')) {
      context.handle(
        _rawMessageMeta,
        rawMessage.isAcceptableOrUnknown(data['raw_message']!, _rawMessageMeta),
      );
    } else if (isInserting) {
      context.missing(_rawMessageMeta);
    }
    if (data.containsKey('sender')) {
      context.handle(
        _senderMeta,
        sender.isAcceptableOrUnknown(data['sender']!, _senderMeta),
      );
    } else if (isInserting) {
      context.missing(_senderMeta);
    }
    if (data.containsKey('timestamp_ms')) {
      context.handle(
        _timestampMsMeta,
        timestampMs.isAcceptableOrUnknown(
          data['timestamp_ms']!,
          _timestampMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timestampMsMeta);
    }
    if (data.containsKey('enqueued_at')) {
      context.handle(
        _enqueuedAtMeta,
        enqueuedAt.isAcceptableOrUnknown(data['enqueued_at']!, _enqueuedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_enqueuedAtMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SmsIngestQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SmsIngestQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      rawMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_message'],
      )!,
      sender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender'],
      )!,
      timestampMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp_ms'],
      )!,
      enqueuedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}enqueued_at'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $SmsIngestQueueTable createAlias(String alias) {
    return $SmsIngestQueueTable(attachedDatabase, alias);
  }
}

class SmsIngestQueueData extends DataClass
    implements Insertable<SmsIngestQueueData> {
  final int id;
  final String userId;
  final String rawMessage;
  final String sender;
  final int timestampMs;
  final int enqueuedAt;
  final String state;
  final int retryCount;
  final String? lastError;
  const SmsIngestQueueData({
    required this.id,
    required this.userId,
    required this.rawMessage,
    required this.sender,
    required this.timestampMs,
    required this.enqueuedAt,
    required this.state,
    required this.retryCount,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['raw_message'] = Variable<String>(rawMessage);
    map['sender'] = Variable<String>(sender);
    map['timestamp_ms'] = Variable<int>(timestampMs);
    map['enqueued_at'] = Variable<int>(enqueuedAt);
    map['state'] = Variable<String>(state);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SmsIngestQueueCompanion toCompanion(bool nullToAbsent) {
    return SmsIngestQueueCompanion(
      id: Value(id),
      userId: Value(userId),
      rawMessage: Value(rawMessage),
      sender: Value(sender),
      timestampMs: Value(timestampMs),
      enqueuedAt: Value(enqueuedAt),
      state: Value(state),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SmsIngestQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SmsIngestQueueData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      rawMessage: serializer.fromJson<String>(json['rawMessage']),
      sender: serializer.fromJson<String>(json['sender']),
      timestampMs: serializer.fromJson<int>(json['timestampMs']),
      enqueuedAt: serializer.fromJson<int>(json['enqueuedAt']),
      state: serializer.fromJson<String>(json['state']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'rawMessage': serializer.toJson<String>(rawMessage),
      'sender': serializer.toJson<String>(sender),
      'timestampMs': serializer.toJson<int>(timestampMs),
      'enqueuedAt': serializer.toJson<int>(enqueuedAt),
      'state': serializer.toJson<String>(state),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SmsIngestQueueData copyWith({
    int? id,
    String? userId,
    String? rawMessage,
    String? sender,
    int? timestampMs,
    int? enqueuedAt,
    String? state,
    int? retryCount,
    Value<String?> lastError = const Value.absent(),
  }) => SmsIngestQueueData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    rawMessage: rawMessage ?? this.rawMessage,
    sender: sender ?? this.sender,
    timestampMs: timestampMs ?? this.timestampMs,
    enqueuedAt: enqueuedAt ?? this.enqueuedAt,
    state: state ?? this.state,
    retryCount: retryCount ?? this.retryCount,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  SmsIngestQueueData copyWithCompanion(SmsIngestQueueCompanion data) {
    return SmsIngestQueueData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      rawMessage: data.rawMessage.present
          ? data.rawMessage.value
          : this.rawMessage,
      sender: data.sender.present ? data.sender.value : this.sender,
      timestampMs: data.timestampMs.present
          ? data.timestampMs.value
          : this.timestampMs,
      enqueuedAt: data.enqueuedAt.present
          ? data.enqueuedAt.value
          : this.enqueuedAt,
      state: data.state.present ? data.state.value : this.state,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SmsIngestQueueData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('rawMessage: $rawMessage, ')
          ..write('sender: $sender, ')
          ..write('timestampMs: $timestampMs, ')
          ..write('enqueuedAt: $enqueuedAt, ')
          ..write('state: $state, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    rawMessage,
    sender,
    timestampMs,
    enqueuedAt,
    state,
    retryCount,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SmsIngestQueueData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.rawMessage == this.rawMessage &&
          other.sender == this.sender &&
          other.timestampMs == this.timestampMs &&
          other.enqueuedAt == this.enqueuedAt &&
          other.state == this.state &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError);
}

class SmsIngestQueueCompanion extends UpdateCompanion<SmsIngestQueueData> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> rawMessage;
  final Value<String> sender;
  final Value<int> timestampMs;
  final Value<int> enqueuedAt;
  final Value<String> state;
  final Value<int> retryCount;
  final Value<String?> lastError;
  const SmsIngestQueueCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.rawMessage = const Value.absent(),
    this.sender = const Value.absent(),
    this.timestampMs = const Value.absent(),
    this.enqueuedAt = const Value.absent(),
    this.state = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  SmsIngestQueueCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String rawMessage,
    required String sender,
    required int timestampMs,
    required int enqueuedAt,
    this.state = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
  }) : userId = Value(userId),
       rawMessage = Value(rawMessage),
       sender = Value(sender),
       timestampMs = Value(timestampMs),
       enqueuedAt = Value(enqueuedAt);
  static Insertable<SmsIngestQueueData> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? rawMessage,
    Expression<String>? sender,
    Expression<int>? timestampMs,
    Expression<int>? enqueuedAt,
    Expression<String>? state,
    Expression<int>? retryCount,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (rawMessage != null) 'raw_message': rawMessage,
      if (sender != null) 'sender': sender,
      if (timestampMs != null) 'timestamp_ms': timestampMs,
      if (enqueuedAt != null) 'enqueued_at': enqueuedAt,
      if (state != null) 'state': state,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
    });
  }

  SmsIngestQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? rawMessage,
    Value<String>? sender,
    Value<int>? timestampMs,
    Value<int>? enqueuedAt,
    Value<String>? state,
    Value<int>? retryCount,
    Value<String?>? lastError,
  }) {
    return SmsIngestQueueCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      rawMessage: rawMessage ?? this.rawMessage,
      sender: sender ?? this.sender,
      timestampMs: timestampMs ?? this.timestampMs,
      enqueuedAt: enqueuedAt ?? this.enqueuedAt,
      state: state ?? this.state,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (rawMessage.present) {
      map['raw_message'] = Variable<String>(rawMessage.value);
    }
    if (sender.present) {
      map['sender'] = Variable<String>(sender.value);
    }
    if (timestampMs.present) {
      map['timestamp_ms'] = Variable<int>(timestampMs.value);
    }
    if (enqueuedAt.present) {
      map['enqueued_at'] = Variable<int>(enqueuedAt.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SmsIngestQueueCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('rawMessage: $rawMessage, ')
          ..write('sender: $sender, ')
          ..write('timestampMs: $timestampMs, ')
          ..write('enqueuedAt: $enqueuedAt, ')
          ..write('state: $state, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

class $SmsReviewQueueTable extends SmsReviewQueue
    with TableInfo<$SmsReviewQueueTable, SmsReviewQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SmsReviewQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawMessageMeta = const VerificationMeta(
    'rawMessage',
  );
  @override
  late final GeneratedColumn<String> rawMessage = GeneratedColumn<String>(
    'raw_message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderMeta = const VerificationMeta('sender');
  @override
  late final GeneratedColumn<String> sender = GeneratedColumn<String>(
    'sender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mpesaCodeMeta = const VerificationMeta(
    'mpesaCode',
  );
  @override
  late final GeneratedColumn<String> mpesaCode = GeneratedColumn<String>(
    'mpesa_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _counterpartyMeta = const VerificationMeta(
    'counterparty',
  );
  @override
  late final GeneratedColumn<String> counterparty = GeneratedColumn<String>(
    'counterparty',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _semanticHashMeta = const VerificationMeta(
    'semanticHash',
  );
  @override
  late final GeneratedColumn<String> semanticHash = GeneratedColumn<String>(
    'semantic_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceScoreMeta = const VerificationMeta(
    'confidenceScore',
  );
  @override
  late final GeneratedColumn<double> confidenceScore = GeneratedColumn<double>(
    'confidence_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _parseRouteMeta = const VerificationMeta(
    'parseRoute',
  );
  @override
  late final GeneratedColumn<String> parseRoute = GeneratedColumn<String>(
    'parse_route',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('REVIEW_QUEUE'),
  );
  static const VerificationMeta _enqueuedAtMeta = const VerificationMeta(
    'enqueuedAt',
  );
  @override
  late final GeneratedColumn<int> enqueuedAt = GeneratedColumn<int>(
    'enqueued_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reviewedAtMeta = const VerificationMeta(
    'reviewedAt',
  );
  @override
  late final GeneratedColumn<int> reviewedAt = GeneratedColumn<int>(
    'reviewed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewDecisionMeta = const VerificationMeta(
    'reviewDecision',
  );
  @override
  late final GeneratedColumn<String> reviewDecision = GeneratedColumn<String>(
    'review_decision',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewNotesMeta = const VerificationMeta(
    'reviewNotes',
  );
  @override
  late final GeneratedColumn<String> reviewNotes = GeneratedColumn<String>(
    'review_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    rawMessage,
    sender,
    mpesaCode,
    amount,
    counterparty,
    category,
    semanticHash,
    confidenceScore,
    parseRoute,
    enqueuedAt,
    reviewedAt,
    reviewDecision,
    reviewNotes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sms_review_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SmsReviewQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('raw_message')) {
      context.handle(
        _rawMessageMeta,
        rawMessage.isAcceptableOrUnknown(data['raw_message']!, _rawMessageMeta),
      );
    } else if (isInserting) {
      context.missing(_rawMessageMeta);
    }
    if (data.containsKey('sender')) {
      context.handle(
        _senderMeta,
        sender.isAcceptableOrUnknown(data['sender']!, _senderMeta),
      );
    }
    if (data.containsKey('mpesa_code')) {
      context.handle(
        _mpesaCodeMeta,
        mpesaCode.isAcceptableOrUnknown(data['mpesa_code']!, _mpesaCodeMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('counterparty')) {
      context.handle(
        _counterpartyMeta,
        counterparty.isAcceptableOrUnknown(
          data['counterparty']!,
          _counterpartyMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('semantic_hash')) {
      context.handle(
        _semanticHashMeta,
        semanticHash.isAcceptableOrUnknown(
          data['semantic_hash']!,
          _semanticHashMeta,
        ),
      );
    }
    if (data.containsKey('confidence_score')) {
      context.handle(
        _confidenceScoreMeta,
        confidenceScore.isAcceptableOrUnknown(
          data['confidence_score']!,
          _confidenceScoreMeta,
        ),
      );
    }
    if (data.containsKey('parse_route')) {
      context.handle(
        _parseRouteMeta,
        parseRoute.isAcceptableOrUnknown(data['parse_route']!, _parseRouteMeta),
      );
    }
    if (data.containsKey('enqueued_at')) {
      context.handle(
        _enqueuedAtMeta,
        enqueuedAt.isAcceptableOrUnknown(data['enqueued_at']!, _enqueuedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_enqueuedAtMeta);
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
        _reviewedAtMeta,
        reviewedAt.isAcceptableOrUnknown(data['reviewed_at']!, _reviewedAtMeta),
      );
    }
    if (data.containsKey('review_decision')) {
      context.handle(
        _reviewDecisionMeta,
        reviewDecision.isAcceptableOrUnknown(
          data['review_decision']!,
          _reviewDecisionMeta,
        ),
      );
    }
    if (data.containsKey('review_notes')) {
      context.handle(
        _reviewNotesMeta,
        reviewNotes.isAcceptableOrUnknown(
          data['review_notes']!,
          _reviewNotesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SmsReviewQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SmsReviewQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      rawMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_message'],
      )!,
      sender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender'],
      ),
      mpesaCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mpesa_code'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      ),
      counterparty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}counterparty'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      semanticHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}semantic_hash'],
      ),
      confidenceScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence_score'],
      )!,
      parseRoute: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parse_route'],
      )!,
      enqueuedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}enqueued_at'],
      )!,
      reviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reviewed_at'],
      ),
      reviewDecision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_decision'],
      ),
      reviewNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_notes'],
      ),
    );
  }

  @override
  $SmsReviewQueueTable createAlias(String alias) {
    return $SmsReviewQueueTable(attachedDatabase, alias);
  }
}

class SmsReviewQueueData extends DataClass
    implements Insertable<SmsReviewQueueData> {
  final int id;
  final String userId;
  final String rawMessage;
  final String? sender;
  final String? mpesaCode;
  final double? amount;
  final String? counterparty;
  final String? category;
  final String? semanticHash;
  final double confidenceScore;
  final String parseRoute;
  final int enqueuedAt;
  final int? reviewedAt;
  final String? reviewDecision;
  final String? reviewNotes;
  const SmsReviewQueueData({
    required this.id,
    required this.userId,
    required this.rawMessage,
    this.sender,
    this.mpesaCode,
    this.amount,
    this.counterparty,
    this.category,
    this.semanticHash,
    required this.confidenceScore,
    required this.parseRoute,
    required this.enqueuedAt,
    this.reviewedAt,
    this.reviewDecision,
    this.reviewNotes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['raw_message'] = Variable<String>(rawMessage);
    if (!nullToAbsent || sender != null) {
      map['sender'] = Variable<String>(sender);
    }
    if (!nullToAbsent || mpesaCode != null) {
      map['mpesa_code'] = Variable<String>(mpesaCode);
    }
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<double>(amount);
    }
    if (!nullToAbsent || counterparty != null) {
      map['counterparty'] = Variable<String>(counterparty);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || semanticHash != null) {
      map['semantic_hash'] = Variable<String>(semanticHash);
    }
    map['confidence_score'] = Variable<double>(confidenceScore);
    map['parse_route'] = Variable<String>(parseRoute);
    map['enqueued_at'] = Variable<int>(enqueuedAt);
    if (!nullToAbsent || reviewedAt != null) {
      map['reviewed_at'] = Variable<int>(reviewedAt);
    }
    if (!nullToAbsent || reviewDecision != null) {
      map['review_decision'] = Variable<String>(reviewDecision);
    }
    if (!nullToAbsent || reviewNotes != null) {
      map['review_notes'] = Variable<String>(reviewNotes);
    }
    return map;
  }

  SmsReviewQueueCompanion toCompanion(bool nullToAbsent) {
    return SmsReviewQueueCompanion(
      id: Value(id),
      userId: Value(userId),
      rawMessage: Value(rawMessage),
      sender: sender == null && nullToAbsent
          ? const Value.absent()
          : Value(sender),
      mpesaCode: mpesaCode == null && nullToAbsent
          ? const Value.absent()
          : Value(mpesaCode),
      amount: amount == null && nullToAbsent
          ? const Value.absent()
          : Value(amount),
      counterparty: counterparty == null && nullToAbsent
          ? const Value.absent()
          : Value(counterparty),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      semanticHash: semanticHash == null && nullToAbsent
          ? const Value.absent()
          : Value(semanticHash),
      confidenceScore: Value(confidenceScore),
      parseRoute: Value(parseRoute),
      enqueuedAt: Value(enqueuedAt),
      reviewedAt: reviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewedAt),
      reviewDecision: reviewDecision == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewDecision),
      reviewNotes: reviewNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewNotes),
    );
  }

  factory SmsReviewQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SmsReviewQueueData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      rawMessage: serializer.fromJson<String>(json['rawMessage']),
      sender: serializer.fromJson<String?>(json['sender']),
      mpesaCode: serializer.fromJson<String?>(json['mpesaCode']),
      amount: serializer.fromJson<double?>(json['amount']),
      counterparty: serializer.fromJson<String?>(json['counterparty']),
      category: serializer.fromJson<String?>(json['category']),
      semanticHash: serializer.fromJson<String?>(json['semanticHash']),
      confidenceScore: serializer.fromJson<double>(json['confidenceScore']),
      parseRoute: serializer.fromJson<String>(json['parseRoute']),
      enqueuedAt: serializer.fromJson<int>(json['enqueuedAt']),
      reviewedAt: serializer.fromJson<int?>(json['reviewedAt']),
      reviewDecision: serializer.fromJson<String?>(json['reviewDecision']),
      reviewNotes: serializer.fromJson<String?>(json['reviewNotes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'rawMessage': serializer.toJson<String>(rawMessage),
      'sender': serializer.toJson<String?>(sender),
      'mpesaCode': serializer.toJson<String?>(mpesaCode),
      'amount': serializer.toJson<double?>(amount),
      'counterparty': serializer.toJson<String?>(counterparty),
      'category': serializer.toJson<String?>(category),
      'semanticHash': serializer.toJson<String?>(semanticHash),
      'confidenceScore': serializer.toJson<double>(confidenceScore),
      'parseRoute': serializer.toJson<String>(parseRoute),
      'enqueuedAt': serializer.toJson<int>(enqueuedAt),
      'reviewedAt': serializer.toJson<int?>(reviewedAt),
      'reviewDecision': serializer.toJson<String?>(reviewDecision),
      'reviewNotes': serializer.toJson<String?>(reviewNotes),
    };
  }

  SmsReviewQueueData copyWith({
    int? id,
    String? userId,
    String? rawMessage,
    Value<String?> sender = const Value.absent(),
    Value<String?> mpesaCode = const Value.absent(),
    Value<double?> amount = const Value.absent(),
    Value<String?> counterparty = const Value.absent(),
    Value<String?> category = const Value.absent(),
    Value<String?> semanticHash = const Value.absent(),
    double? confidenceScore,
    String? parseRoute,
    int? enqueuedAt,
    Value<int?> reviewedAt = const Value.absent(),
    Value<String?> reviewDecision = const Value.absent(),
    Value<String?> reviewNotes = const Value.absent(),
  }) => SmsReviewQueueData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    rawMessage: rawMessage ?? this.rawMessage,
    sender: sender.present ? sender.value : this.sender,
    mpesaCode: mpesaCode.present ? mpesaCode.value : this.mpesaCode,
    amount: amount.present ? amount.value : this.amount,
    counterparty: counterparty.present ? counterparty.value : this.counterparty,
    category: category.present ? category.value : this.category,
    semanticHash: semanticHash.present ? semanticHash.value : this.semanticHash,
    confidenceScore: confidenceScore ?? this.confidenceScore,
    parseRoute: parseRoute ?? this.parseRoute,
    enqueuedAt: enqueuedAt ?? this.enqueuedAt,
    reviewedAt: reviewedAt.present ? reviewedAt.value : this.reviewedAt,
    reviewDecision: reviewDecision.present
        ? reviewDecision.value
        : this.reviewDecision,
    reviewNotes: reviewNotes.present ? reviewNotes.value : this.reviewNotes,
  );
  SmsReviewQueueData copyWithCompanion(SmsReviewQueueCompanion data) {
    return SmsReviewQueueData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      rawMessage: data.rawMessage.present
          ? data.rawMessage.value
          : this.rawMessage,
      sender: data.sender.present ? data.sender.value : this.sender,
      mpesaCode: data.mpesaCode.present ? data.mpesaCode.value : this.mpesaCode,
      amount: data.amount.present ? data.amount.value : this.amount,
      counterparty: data.counterparty.present
          ? data.counterparty.value
          : this.counterparty,
      category: data.category.present ? data.category.value : this.category,
      semanticHash: data.semanticHash.present
          ? data.semanticHash.value
          : this.semanticHash,
      confidenceScore: data.confidenceScore.present
          ? data.confidenceScore.value
          : this.confidenceScore,
      parseRoute: data.parseRoute.present
          ? data.parseRoute.value
          : this.parseRoute,
      enqueuedAt: data.enqueuedAt.present
          ? data.enqueuedAt.value
          : this.enqueuedAt,
      reviewedAt: data.reviewedAt.present
          ? data.reviewedAt.value
          : this.reviewedAt,
      reviewDecision: data.reviewDecision.present
          ? data.reviewDecision.value
          : this.reviewDecision,
      reviewNotes: data.reviewNotes.present
          ? data.reviewNotes.value
          : this.reviewNotes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SmsReviewQueueData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('rawMessage: $rawMessage, ')
          ..write('sender: $sender, ')
          ..write('mpesaCode: $mpesaCode, ')
          ..write('amount: $amount, ')
          ..write('counterparty: $counterparty, ')
          ..write('category: $category, ')
          ..write('semanticHash: $semanticHash, ')
          ..write('confidenceScore: $confidenceScore, ')
          ..write('parseRoute: $parseRoute, ')
          ..write('enqueuedAt: $enqueuedAt, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('reviewDecision: $reviewDecision, ')
          ..write('reviewNotes: $reviewNotes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    rawMessage,
    sender,
    mpesaCode,
    amount,
    counterparty,
    category,
    semanticHash,
    confidenceScore,
    parseRoute,
    enqueuedAt,
    reviewedAt,
    reviewDecision,
    reviewNotes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SmsReviewQueueData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.rawMessage == this.rawMessage &&
          other.sender == this.sender &&
          other.mpesaCode == this.mpesaCode &&
          other.amount == this.amount &&
          other.counterparty == this.counterparty &&
          other.category == this.category &&
          other.semanticHash == this.semanticHash &&
          other.confidenceScore == this.confidenceScore &&
          other.parseRoute == this.parseRoute &&
          other.enqueuedAt == this.enqueuedAt &&
          other.reviewedAt == this.reviewedAt &&
          other.reviewDecision == this.reviewDecision &&
          other.reviewNotes == this.reviewNotes);
}

class SmsReviewQueueCompanion extends UpdateCompanion<SmsReviewQueueData> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> rawMessage;
  final Value<String?> sender;
  final Value<String?> mpesaCode;
  final Value<double?> amount;
  final Value<String?> counterparty;
  final Value<String?> category;
  final Value<String?> semanticHash;
  final Value<double> confidenceScore;
  final Value<String> parseRoute;
  final Value<int> enqueuedAt;
  final Value<int?> reviewedAt;
  final Value<String?> reviewDecision;
  final Value<String?> reviewNotes;
  const SmsReviewQueueCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.rawMessage = const Value.absent(),
    this.sender = const Value.absent(),
    this.mpesaCode = const Value.absent(),
    this.amount = const Value.absent(),
    this.counterparty = const Value.absent(),
    this.category = const Value.absent(),
    this.semanticHash = const Value.absent(),
    this.confidenceScore = const Value.absent(),
    this.parseRoute = const Value.absent(),
    this.enqueuedAt = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.reviewDecision = const Value.absent(),
    this.reviewNotes = const Value.absent(),
  });
  SmsReviewQueueCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String rawMessage,
    this.sender = const Value.absent(),
    this.mpesaCode = const Value.absent(),
    this.amount = const Value.absent(),
    this.counterparty = const Value.absent(),
    this.category = const Value.absent(),
    this.semanticHash = const Value.absent(),
    this.confidenceScore = const Value.absent(),
    this.parseRoute = const Value.absent(),
    required int enqueuedAt,
    this.reviewedAt = const Value.absent(),
    this.reviewDecision = const Value.absent(),
    this.reviewNotes = const Value.absent(),
  }) : userId = Value(userId),
       rawMessage = Value(rawMessage),
       enqueuedAt = Value(enqueuedAt);
  static Insertable<SmsReviewQueueData> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? rawMessage,
    Expression<String>? sender,
    Expression<String>? mpesaCode,
    Expression<double>? amount,
    Expression<String>? counterparty,
    Expression<String>? category,
    Expression<String>? semanticHash,
    Expression<double>? confidenceScore,
    Expression<String>? parseRoute,
    Expression<int>? enqueuedAt,
    Expression<int>? reviewedAt,
    Expression<String>? reviewDecision,
    Expression<String>? reviewNotes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (rawMessage != null) 'raw_message': rawMessage,
      if (sender != null) 'sender': sender,
      if (mpesaCode != null) 'mpesa_code': mpesaCode,
      if (amount != null) 'amount': amount,
      if (counterparty != null) 'counterparty': counterparty,
      if (category != null) 'category': category,
      if (semanticHash != null) 'semantic_hash': semanticHash,
      if (confidenceScore != null) 'confidence_score': confidenceScore,
      if (parseRoute != null) 'parse_route': parseRoute,
      if (enqueuedAt != null) 'enqueued_at': enqueuedAt,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (reviewDecision != null) 'review_decision': reviewDecision,
      if (reviewNotes != null) 'review_notes': reviewNotes,
    });
  }

  SmsReviewQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? rawMessage,
    Value<String?>? sender,
    Value<String?>? mpesaCode,
    Value<double?>? amount,
    Value<String?>? counterparty,
    Value<String?>? category,
    Value<String?>? semanticHash,
    Value<double>? confidenceScore,
    Value<String>? parseRoute,
    Value<int>? enqueuedAt,
    Value<int?>? reviewedAt,
    Value<String?>? reviewDecision,
    Value<String?>? reviewNotes,
  }) {
    return SmsReviewQueueCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      rawMessage: rawMessage ?? this.rawMessage,
      sender: sender ?? this.sender,
      mpesaCode: mpesaCode ?? this.mpesaCode,
      amount: amount ?? this.amount,
      counterparty: counterparty ?? this.counterparty,
      category: category ?? this.category,
      semanticHash: semanticHash ?? this.semanticHash,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      parseRoute: parseRoute ?? this.parseRoute,
      enqueuedAt: enqueuedAt ?? this.enqueuedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewDecision: reviewDecision ?? this.reviewDecision,
      reviewNotes: reviewNotes ?? this.reviewNotes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (rawMessage.present) {
      map['raw_message'] = Variable<String>(rawMessage.value);
    }
    if (sender.present) {
      map['sender'] = Variable<String>(sender.value);
    }
    if (mpesaCode.present) {
      map['mpesa_code'] = Variable<String>(mpesaCode.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (counterparty.present) {
      map['counterparty'] = Variable<String>(counterparty.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (semanticHash.present) {
      map['semantic_hash'] = Variable<String>(semanticHash.value);
    }
    if (confidenceScore.present) {
      map['confidence_score'] = Variable<double>(confidenceScore.value);
    }
    if (parseRoute.present) {
      map['parse_route'] = Variable<String>(parseRoute.value);
    }
    if (enqueuedAt.present) {
      map['enqueued_at'] = Variable<int>(enqueuedAt.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<int>(reviewedAt.value);
    }
    if (reviewDecision.present) {
      map['review_decision'] = Variable<String>(reviewDecision.value);
    }
    if (reviewNotes.present) {
      map['review_notes'] = Variable<String>(reviewNotes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SmsReviewQueueCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('rawMessage: $rawMessage, ')
          ..write('sender: $sender, ')
          ..write('mpesaCode: $mpesaCode, ')
          ..write('amount: $amount, ')
          ..write('counterparty: $counterparty, ')
          ..write('category: $category, ')
          ..write('semanticHash: $semanticHash, ')
          ..write('confidenceScore: $confidenceScore, ')
          ..write('parseRoute: $parseRoute, ')
          ..write('enqueuedAt: $enqueuedAt, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('reviewDecision: $reviewDecision, ')
          ..write('reviewNotes: $reviewNotes')
          ..write(')'))
        .toString();
  }
}

class $SmsQuarantineTable extends SmsQuarantine
    with TableInfo<$SmsQuarantineTable, SmsQuarantineData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SmsQuarantineTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawMessageMeta = const VerificationMeta(
    'rawMessage',
  );
  @override
  late final GeneratedColumn<String> rawMessage = GeneratedColumn<String>(
    'raw_message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderMeta = const VerificationMeta('sender');
  @override
  late final GeneratedColumn<String> sender = GeneratedColumn<String>(
    'sender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mpesaCodeMeta = const VerificationMeta(
    'mpesaCode',
  );
  @override
  late final GeneratedColumn<String> mpesaCode = GeneratedColumn<String>(
    'mpesa_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _counterpartyMeta = const VerificationMeta(
    'counterparty',
  );
  @override
  late final GeneratedColumn<String> counterparty = GeneratedColumn<String>(
    'counterparty',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceScoreMeta = const VerificationMeta(
    'confidenceScore',
  );
  @override
  late final GeneratedColumn<double> confidenceScore = GeneratedColumn<double>(
    'confidence_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _failureReasonMeta = const VerificationMeta(
    'failureReason',
  );
  @override
  late final GeneratedColumn<String> failureReason = GeneratedColumn<String>(
    'failure_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quarantinedAtMeta = const VerificationMeta(
    'quarantinedAt',
  );
  @override
  late final GeneratedColumn<int> quarantinedAt = GeneratedColumn<int>(
    'quarantined_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<int> resolvedAt = GeneratedColumn<int>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resolutionMeta = const VerificationMeta(
    'resolution',
  );
  @override
  late final GeneratedColumn<String> resolution = GeneratedColumn<String>(
    'resolution',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    rawMessage,
    sender,
    mpesaCode,
    amount,
    counterparty,
    category,
    confidenceScore,
    failureReason,
    quarantinedAt,
    resolvedAt,
    resolution,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sms_quarantine';
  @override
  VerificationContext validateIntegrity(
    Insertable<SmsQuarantineData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('raw_message')) {
      context.handle(
        _rawMessageMeta,
        rawMessage.isAcceptableOrUnknown(data['raw_message']!, _rawMessageMeta),
      );
    } else if (isInserting) {
      context.missing(_rawMessageMeta);
    }
    if (data.containsKey('sender')) {
      context.handle(
        _senderMeta,
        sender.isAcceptableOrUnknown(data['sender']!, _senderMeta),
      );
    }
    if (data.containsKey('mpesa_code')) {
      context.handle(
        _mpesaCodeMeta,
        mpesaCode.isAcceptableOrUnknown(data['mpesa_code']!, _mpesaCodeMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('counterparty')) {
      context.handle(
        _counterpartyMeta,
        counterparty.isAcceptableOrUnknown(
          data['counterparty']!,
          _counterpartyMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('confidence_score')) {
      context.handle(
        _confidenceScoreMeta,
        confidenceScore.isAcceptableOrUnknown(
          data['confidence_score']!,
          _confidenceScoreMeta,
        ),
      );
    }
    if (data.containsKey('failure_reason')) {
      context.handle(
        _failureReasonMeta,
        failureReason.isAcceptableOrUnknown(
          data['failure_reason']!,
          _failureReasonMeta,
        ),
      );
    }
    if (data.containsKey('quarantined_at')) {
      context.handle(
        _quarantinedAtMeta,
        quarantinedAt.isAcceptableOrUnknown(
          data['quarantined_at']!,
          _quarantinedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quarantinedAtMeta);
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    if (data.containsKey('resolution')) {
      context.handle(
        _resolutionMeta,
        resolution.isAcceptableOrUnknown(data['resolution']!, _resolutionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SmsQuarantineData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SmsQuarantineData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      rawMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_message'],
      )!,
      sender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender'],
      ),
      mpesaCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mpesa_code'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      ),
      counterparty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}counterparty'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      confidenceScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence_score'],
      )!,
      failureReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}failure_reason'],
      ),
      quarantinedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quarantined_at'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resolved_at'],
      ),
      resolution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution'],
      ),
    );
  }

  @override
  $SmsQuarantineTable createAlias(String alias) {
    return $SmsQuarantineTable(attachedDatabase, alias);
  }
}

class SmsQuarantineData extends DataClass
    implements Insertable<SmsQuarantineData> {
  final int id;
  final String userId;
  final String rawMessage;
  final String? sender;
  final String? mpesaCode;
  final double? amount;
  final String? counterparty;
  final String? category;
  final double confidenceScore;
  final String? failureReason;
  final int quarantinedAt;
  final int? resolvedAt;
  final String? resolution;
  const SmsQuarantineData({
    required this.id,
    required this.userId,
    required this.rawMessage,
    this.sender,
    this.mpesaCode,
    this.amount,
    this.counterparty,
    this.category,
    required this.confidenceScore,
    this.failureReason,
    required this.quarantinedAt,
    this.resolvedAt,
    this.resolution,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['raw_message'] = Variable<String>(rawMessage);
    if (!nullToAbsent || sender != null) {
      map['sender'] = Variable<String>(sender);
    }
    if (!nullToAbsent || mpesaCode != null) {
      map['mpesa_code'] = Variable<String>(mpesaCode);
    }
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<double>(amount);
    }
    if (!nullToAbsent || counterparty != null) {
      map['counterparty'] = Variable<String>(counterparty);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['confidence_score'] = Variable<double>(confidenceScore);
    if (!nullToAbsent || failureReason != null) {
      map['failure_reason'] = Variable<String>(failureReason);
    }
    map['quarantined_at'] = Variable<int>(quarantinedAt);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<int>(resolvedAt);
    }
    if (!nullToAbsent || resolution != null) {
      map['resolution'] = Variable<String>(resolution);
    }
    return map;
  }

  SmsQuarantineCompanion toCompanion(bool nullToAbsent) {
    return SmsQuarantineCompanion(
      id: Value(id),
      userId: Value(userId),
      rawMessage: Value(rawMessage),
      sender: sender == null && nullToAbsent
          ? const Value.absent()
          : Value(sender),
      mpesaCode: mpesaCode == null && nullToAbsent
          ? const Value.absent()
          : Value(mpesaCode),
      amount: amount == null && nullToAbsent
          ? const Value.absent()
          : Value(amount),
      counterparty: counterparty == null && nullToAbsent
          ? const Value.absent()
          : Value(counterparty),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      confidenceScore: Value(confidenceScore),
      failureReason: failureReason == null && nullToAbsent
          ? const Value.absent()
          : Value(failureReason),
      quarantinedAt: Value(quarantinedAt),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
      resolution: resolution == null && nullToAbsent
          ? const Value.absent()
          : Value(resolution),
    );
  }

  factory SmsQuarantineData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SmsQuarantineData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      rawMessage: serializer.fromJson<String>(json['rawMessage']),
      sender: serializer.fromJson<String?>(json['sender']),
      mpesaCode: serializer.fromJson<String?>(json['mpesaCode']),
      amount: serializer.fromJson<double?>(json['amount']),
      counterparty: serializer.fromJson<String?>(json['counterparty']),
      category: serializer.fromJson<String?>(json['category']),
      confidenceScore: serializer.fromJson<double>(json['confidenceScore']),
      failureReason: serializer.fromJson<String?>(json['failureReason']),
      quarantinedAt: serializer.fromJson<int>(json['quarantinedAt']),
      resolvedAt: serializer.fromJson<int?>(json['resolvedAt']),
      resolution: serializer.fromJson<String?>(json['resolution']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'rawMessage': serializer.toJson<String>(rawMessage),
      'sender': serializer.toJson<String?>(sender),
      'mpesaCode': serializer.toJson<String?>(mpesaCode),
      'amount': serializer.toJson<double?>(amount),
      'counterparty': serializer.toJson<String?>(counterparty),
      'category': serializer.toJson<String?>(category),
      'confidenceScore': serializer.toJson<double>(confidenceScore),
      'failureReason': serializer.toJson<String?>(failureReason),
      'quarantinedAt': serializer.toJson<int>(quarantinedAt),
      'resolvedAt': serializer.toJson<int?>(resolvedAt),
      'resolution': serializer.toJson<String?>(resolution),
    };
  }

  SmsQuarantineData copyWith({
    int? id,
    String? userId,
    String? rawMessage,
    Value<String?> sender = const Value.absent(),
    Value<String?> mpesaCode = const Value.absent(),
    Value<double?> amount = const Value.absent(),
    Value<String?> counterparty = const Value.absent(),
    Value<String?> category = const Value.absent(),
    double? confidenceScore,
    Value<String?> failureReason = const Value.absent(),
    int? quarantinedAt,
    Value<int?> resolvedAt = const Value.absent(),
    Value<String?> resolution = const Value.absent(),
  }) => SmsQuarantineData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    rawMessage: rawMessage ?? this.rawMessage,
    sender: sender.present ? sender.value : this.sender,
    mpesaCode: mpesaCode.present ? mpesaCode.value : this.mpesaCode,
    amount: amount.present ? amount.value : this.amount,
    counterparty: counterparty.present ? counterparty.value : this.counterparty,
    category: category.present ? category.value : this.category,
    confidenceScore: confidenceScore ?? this.confidenceScore,
    failureReason: failureReason.present
        ? failureReason.value
        : this.failureReason,
    quarantinedAt: quarantinedAt ?? this.quarantinedAt,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
    resolution: resolution.present ? resolution.value : this.resolution,
  );
  SmsQuarantineData copyWithCompanion(SmsQuarantineCompanion data) {
    return SmsQuarantineData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      rawMessage: data.rawMessage.present
          ? data.rawMessage.value
          : this.rawMessage,
      sender: data.sender.present ? data.sender.value : this.sender,
      mpesaCode: data.mpesaCode.present ? data.mpesaCode.value : this.mpesaCode,
      amount: data.amount.present ? data.amount.value : this.amount,
      counterparty: data.counterparty.present
          ? data.counterparty.value
          : this.counterparty,
      category: data.category.present ? data.category.value : this.category,
      confidenceScore: data.confidenceScore.present
          ? data.confidenceScore.value
          : this.confidenceScore,
      failureReason: data.failureReason.present
          ? data.failureReason.value
          : this.failureReason,
      quarantinedAt: data.quarantinedAt.present
          ? data.quarantinedAt.value
          : this.quarantinedAt,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
      resolution: data.resolution.present
          ? data.resolution.value
          : this.resolution,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SmsQuarantineData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('rawMessage: $rawMessage, ')
          ..write('sender: $sender, ')
          ..write('mpesaCode: $mpesaCode, ')
          ..write('amount: $amount, ')
          ..write('counterparty: $counterparty, ')
          ..write('category: $category, ')
          ..write('confidenceScore: $confidenceScore, ')
          ..write('failureReason: $failureReason, ')
          ..write('quarantinedAt: $quarantinedAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('resolution: $resolution')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    rawMessage,
    sender,
    mpesaCode,
    amount,
    counterparty,
    category,
    confidenceScore,
    failureReason,
    quarantinedAt,
    resolvedAt,
    resolution,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SmsQuarantineData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.rawMessage == this.rawMessage &&
          other.sender == this.sender &&
          other.mpesaCode == this.mpesaCode &&
          other.amount == this.amount &&
          other.counterparty == this.counterparty &&
          other.category == this.category &&
          other.confidenceScore == this.confidenceScore &&
          other.failureReason == this.failureReason &&
          other.quarantinedAt == this.quarantinedAt &&
          other.resolvedAt == this.resolvedAt &&
          other.resolution == this.resolution);
}

class SmsQuarantineCompanion extends UpdateCompanion<SmsQuarantineData> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> rawMessage;
  final Value<String?> sender;
  final Value<String?> mpesaCode;
  final Value<double?> amount;
  final Value<String?> counterparty;
  final Value<String?> category;
  final Value<double> confidenceScore;
  final Value<String?> failureReason;
  final Value<int> quarantinedAt;
  final Value<int?> resolvedAt;
  final Value<String?> resolution;
  const SmsQuarantineCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.rawMessage = const Value.absent(),
    this.sender = const Value.absent(),
    this.mpesaCode = const Value.absent(),
    this.amount = const Value.absent(),
    this.counterparty = const Value.absent(),
    this.category = const Value.absent(),
    this.confidenceScore = const Value.absent(),
    this.failureReason = const Value.absent(),
    this.quarantinedAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.resolution = const Value.absent(),
  });
  SmsQuarantineCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String rawMessage,
    this.sender = const Value.absent(),
    this.mpesaCode = const Value.absent(),
    this.amount = const Value.absent(),
    this.counterparty = const Value.absent(),
    this.category = const Value.absent(),
    this.confidenceScore = const Value.absent(),
    this.failureReason = const Value.absent(),
    required int quarantinedAt,
    this.resolvedAt = const Value.absent(),
    this.resolution = const Value.absent(),
  }) : userId = Value(userId),
       rawMessage = Value(rawMessage),
       quarantinedAt = Value(quarantinedAt);
  static Insertable<SmsQuarantineData> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? rawMessage,
    Expression<String>? sender,
    Expression<String>? mpesaCode,
    Expression<double>? amount,
    Expression<String>? counterparty,
    Expression<String>? category,
    Expression<double>? confidenceScore,
    Expression<String>? failureReason,
    Expression<int>? quarantinedAt,
    Expression<int>? resolvedAt,
    Expression<String>? resolution,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (rawMessage != null) 'raw_message': rawMessage,
      if (sender != null) 'sender': sender,
      if (mpesaCode != null) 'mpesa_code': mpesaCode,
      if (amount != null) 'amount': amount,
      if (counterparty != null) 'counterparty': counterparty,
      if (category != null) 'category': category,
      if (confidenceScore != null) 'confidence_score': confidenceScore,
      if (failureReason != null) 'failure_reason': failureReason,
      if (quarantinedAt != null) 'quarantined_at': quarantinedAt,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (resolution != null) 'resolution': resolution,
    });
  }

  SmsQuarantineCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? rawMessage,
    Value<String?>? sender,
    Value<String?>? mpesaCode,
    Value<double?>? amount,
    Value<String?>? counterparty,
    Value<String?>? category,
    Value<double>? confidenceScore,
    Value<String?>? failureReason,
    Value<int>? quarantinedAt,
    Value<int?>? resolvedAt,
    Value<String?>? resolution,
  }) {
    return SmsQuarantineCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      rawMessage: rawMessage ?? this.rawMessage,
      sender: sender ?? this.sender,
      mpesaCode: mpesaCode ?? this.mpesaCode,
      amount: amount ?? this.amount,
      counterparty: counterparty ?? this.counterparty,
      category: category ?? this.category,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      failureReason: failureReason ?? this.failureReason,
      quarantinedAt: quarantinedAt ?? this.quarantinedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolution: resolution ?? this.resolution,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (rawMessage.present) {
      map['raw_message'] = Variable<String>(rawMessage.value);
    }
    if (sender.present) {
      map['sender'] = Variable<String>(sender.value);
    }
    if (mpesaCode.present) {
      map['mpesa_code'] = Variable<String>(mpesaCode.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (counterparty.present) {
      map['counterparty'] = Variable<String>(counterparty.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (confidenceScore.present) {
      map['confidence_score'] = Variable<double>(confidenceScore.value);
    }
    if (failureReason.present) {
      map['failure_reason'] = Variable<String>(failureReason.value);
    }
    if (quarantinedAt.present) {
      map['quarantined_at'] = Variable<int>(quarantinedAt.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<int>(resolvedAt.value);
    }
    if (resolution.present) {
      map['resolution'] = Variable<String>(resolution.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SmsQuarantineCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('rawMessage: $rawMessage, ')
          ..write('sender: $sender, ')
          ..write('mpesaCode: $mpesaCode, ')
          ..write('amount: $amount, ')
          ..write('counterparty: $counterparty, ')
          ..write('category: $category, ')
          ..write('confidenceScore: $confidenceScore, ')
          ..write('failureReason: $failureReason, ')
          ..write('quarantinedAt: $quarantinedAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('resolution: $resolution')
          ..write(')'))
        .toString();
  }
}

class $ImportAuditTable extends ImportAudit
    with TableInfo<$ImportAuditTable, ImportAuditData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportAuditTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawMessageMeta = const VerificationMeta(
    'rawMessage',
  );
  @override
  late final GeneratedColumn<String> rawMessage = GeneratedColumn<String>(
    'raw_message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mpesaCodeMeta = const VerificationMeta(
    'mpesaCode',
  );
  @override
  late final GeneratedColumn<String> mpesaCode = GeneratedColumn<String>(
    'mpesa_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _merchantMeta = const VerificationMeta(
    'merchant',
  );
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
    'merchant',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _failureReasonMeta = const VerificationMeta(
    'failureReason',
  );
  @override
  late final GeneratedColumn<String> failureReason = GeneratedColumn<String>(
    'failure_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<int> importedAt = GeneratedColumn<int>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceScoreMeta = const VerificationMeta(
    'confidenceScore',
  );
  @override
  late final GeneratedColumn<double> confidenceScore = GeneratedColumn<double>(
    'confidence_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    rawMessage,
    mpesaCode,
    amount,
    merchant,
    outcome,
    failureReason,
    importedAt,
    createdAt,
    updatedAt,
    confidenceScore,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'import_audit';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportAuditData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('raw_message')) {
      context.handle(
        _rawMessageMeta,
        rawMessage.isAcceptableOrUnknown(data['raw_message']!, _rawMessageMeta),
      );
    } else if (isInserting) {
      context.missing(_rawMessageMeta);
    }
    if (data.containsKey('mpesa_code')) {
      context.handle(
        _mpesaCodeMeta,
        mpesaCode.isAcceptableOrUnknown(data['mpesa_code']!, _mpesaCodeMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('merchant')) {
      context.handle(
        _merchantMeta,
        merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta),
      );
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    } else if (isInserting) {
      context.missing(_outcomeMeta);
    }
    if (data.containsKey('failure_reason')) {
      context.handle(
        _failureReasonMeta,
        failureReason.isAcceptableOrUnknown(
          data['failure_reason']!,
          _failureReasonMeta,
        ),
      );
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('confidence_score')) {
      context.handle(
        _confidenceScoreMeta,
        confidenceScore.isAcceptableOrUnknown(
          data['confidence_score']!,
          _confidenceScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_confidenceScoreMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  ImportAuditData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportAuditData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      rawMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_message'],
      )!,
      mpesaCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mpesa_code'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      ),
      merchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant'],
      ),
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      )!,
      failureReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}failure_reason'],
      ),
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}imported_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      confidenceScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence_score'],
      )!,
    );
  }

  @override
  $ImportAuditTable createAlias(String alias) {
    return $ImportAuditTable(attachedDatabase, alias);
  }
}

class ImportAuditData extends DataClass implements Insertable<ImportAuditData> {
  final int id;
  final String userId;
  final String rawMessage;
  final String? mpesaCode;
  final double? amount;
  final String? merchant;
  final String outcome;
  final String? failureReason;
  final int importedAt;
  final int createdAt;
  final int updatedAt;
  final double confidenceScore;
  const ImportAuditData({
    required this.id,
    required this.userId,
    required this.rawMessage,
    this.mpesaCode,
    this.amount,
    this.merchant,
    required this.outcome,
    this.failureReason,
    required this.importedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.confidenceScore,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['raw_message'] = Variable<String>(rawMessage);
    if (!nullToAbsent || mpesaCode != null) {
      map['mpesa_code'] = Variable<String>(mpesaCode);
    }
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<double>(amount);
    }
    if (!nullToAbsent || merchant != null) {
      map['merchant'] = Variable<String>(merchant);
    }
    map['outcome'] = Variable<String>(outcome);
    if (!nullToAbsent || failureReason != null) {
      map['failure_reason'] = Variable<String>(failureReason);
    }
    map['imported_at'] = Variable<int>(importedAt);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['confidence_score'] = Variable<double>(confidenceScore);
    return map;
  }

  ImportAuditCompanion toCompanion(bool nullToAbsent) {
    return ImportAuditCompanion(
      id: Value(id),
      userId: Value(userId),
      rawMessage: Value(rawMessage),
      mpesaCode: mpesaCode == null && nullToAbsent
          ? const Value.absent()
          : Value(mpesaCode),
      amount: amount == null && nullToAbsent
          ? const Value.absent()
          : Value(amount),
      merchant: merchant == null && nullToAbsent
          ? const Value.absent()
          : Value(merchant),
      outcome: Value(outcome),
      failureReason: failureReason == null && nullToAbsent
          ? const Value.absent()
          : Value(failureReason),
      importedAt: Value(importedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      confidenceScore: Value(confidenceScore),
    );
  }

  factory ImportAuditData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportAuditData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      rawMessage: serializer.fromJson<String>(json['rawMessage']),
      mpesaCode: serializer.fromJson<String?>(json['mpesaCode']),
      amount: serializer.fromJson<double?>(json['amount']),
      merchant: serializer.fromJson<String?>(json['merchant']),
      outcome: serializer.fromJson<String>(json['outcome']),
      failureReason: serializer.fromJson<String?>(json['failureReason']),
      importedAt: serializer.fromJson<int>(json['importedAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      confidenceScore: serializer.fromJson<double>(json['confidenceScore']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'rawMessage': serializer.toJson<String>(rawMessage),
      'mpesaCode': serializer.toJson<String?>(mpesaCode),
      'amount': serializer.toJson<double?>(amount),
      'merchant': serializer.toJson<String?>(merchant),
      'outcome': serializer.toJson<String>(outcome),
      'failureReason': serializer.toJson<String?>(failureReason),
      'importedAt': serializer.toJson<int>(importedAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'confidenceScore': serializer.toJson<double>(confidenceScore),
    };
  }

  ImportAuditData copyWith({
    int? id,
    String? userId,
    String? rawMessage,
    Value<String?> mpesaCode = const Value.absent(),
    Value<double?> amount = const Value.absent(),
    Value<String?> merchant = const Value.absent(),
    String? outcome,
    Value<String?> failureReason = const Value.absent(),
    int? importedAt,
    int? createdAt,
    int? updatedAt,
    double? confidenceScore,
  }) => ImportAuditData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    rawMessage: rawMessage ?? this.rawMessage,
    mpesaCode: mpesaCode.present ? mpesaCode.value : this.mpesaCode,
    amount: amount.present ? amount.value : this.amount,
    merchant: merchant.present ? merchant.value : this.merchant,
    outcome: outcome ?? this.outcome,
    failureReason: failureReason.present
        ? failureReason.value
        : this.failureReason,
    importedAt: importedAt ?? this.importedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    confidenceScore: confidenceScore ?? this.confidenceScore,
  );
  ImportAuditData copyWithCompanion(ImportAuditCompanion data) {
    return ImportAuditData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      rawMessage: data.rawMessage.present
          ? data.rawMessage.value
          : this.rawMessage,
      mpesaCode: data.mpesaCode.present ? data.mpesaCode.value : this.mpesaCode,
      amount: data.amount.present ? data.amount.value : this.amount,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      failureReason: data.failureReason.present
          ? data.failureReason.value
          : this.failureReason,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      confidenceScore: data.confidenceScore.present
          ? data.confidenceScore.value
          : this.confidenceScore,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportAuditData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('rawMessage: $rawMessage, ')
          ..write('mpesaCode: $mpesaCode, ')
          ..write('amount: $amount, ')
          ..write('merchant: $merchant, ')
          ..write('outcome: $outcome, ')
          ..write('failureReason: $failureReason, ')
          ..write('importedAt: $importedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('confidenceScore: $confidenceScore')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    rawMessage,
    mpesaCode,
    amount,
    merchant,
    outcome,
    failureReason,
    importedAt,
    createdAt,
    updatedAt,
    confidenceScore,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportAuditData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.rawMessage == this.rawMessage &&
          other.mpesaCode == this.mpesaCode &&
          other.amount == this.amount &&
          other.merchant == this.merchant &&
          other.outcome == this.outcome &&
          other.failureReason == this.failureReason &&
          other.importedAt == this.importedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.confidenceScore == this.confidenceScore);
}

class ImportAuditCompanion extends UpdateCompanion<ImportAuditData> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> rawMessage;
  final Value<String?> mpesaCode;
  final Value<double?> amount;
  final Value<String?> merchant;
  final Value<String> outcome;
  final Value<String?> failureReason;
  final Value<int> importedAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<double> confidenceScore;
  final Value<int> rowid;
  const ImportAuditCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.rawMessage = const Value.absent(),
    this.mpesaCode = const Value.absent(),
    this.amount = const Value.absent(),
    this.merchant = const Value.absent(),
    this.outcome = const Value.absent(),
    this.failureReason = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.confidenceScore = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportAuditCompanion.insert({
    required int id,
    required String userId,
    required String rawMessage,
    this.mpesaCode = const Value.absent(),
    this.amount = const Value.absent(),
    this.merchant = const Value.absent(),
    required String outcome,
    this.failureReason = const Value.absent(),
    required int importedAt,
    required int createdAt,
    required int updatedAt,
    required double confidenceScore,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       rawMessage = Value(rawMessage),
       outcome = Value(outcome),
       importedAt = Value(importedAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       confidenceScore = Value(confidenceScore);
  static Insertable<ImportAuditData> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? rawMessage,
    Expression<String>? mpesaCode,
    Expression<double>? amount,
    Expression<String>? merchant,
    Expression<String>? outcome,
    Expression<String>? failureReason,
    Expression<int>? importedAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<double>? confidenceScore,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (rawMessage != null) 'raw_message': rawMessage,
      if (mpesaCode != null) 'mpesa_code': mpesaCode,
      if (amount != null) 'amount': amount,
      if (merchant != null) 'merchant': merchant,
      if (outcome != null) 'outcome': outcome,
      if (failureReason != null) 'failure_reason': failureReason,
      if (importedAt != null) 'imported_at': importedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (confidenceScore != null) 'confidence_score': confidenceScore,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportAuditCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? rawMessage,
    Value<String?>? mpesaCode,
    Value<double?>? amount,
    Value<String?>? merchant,
    Value<String>? outcome,
    Value<String?>? failureReason,
    Value<int>? importedAt,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<double>? confidenceScore,
    Value<int>? rowid,
  }) {
    return ImportAuditCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      rawMessage: rawMessage ?? this.rawMessage,
      mpesaCode: mpesaCode ?? this.mpesaCode,
      amount: amount ?? this.amount,
      merchant: merchant ?? this.merchant,
      outcome: outcome ?? this.outcome,
      failureReason: failureReason ?? this.failureReason,
      importedAt: importedAt ?? this.importedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (rawMessage.present) {
      map['raw_message'] = Variable<String>(rawMessage.value);
    }
    if (mpesaCode.present) {
      map['mpesa_code'] = Variable<String>(mpesaCode.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (failureReason.present) {
      map['failure_reason'] = Variable<String>(failureReason.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<int>(importedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (confidenceScore.present) {
      map['confidence_score'] = Variable<double>(confidenceScore.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportAuditCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('rawMessage: $rawMessage, ')
          ..write('mpesaCode: $mpesaCode, ')
          ..write('amount: $amount, ')
          ..write('merchant: $merchant, ')
          ..write('outcome: $outcome, ')
          ..write('failureReason: $failureReason, ')
          ..write('importedAt: $importedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('confidenceScore: $confidenceScore, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MlTrainingSamplesTable extends MlTrainingSamples
    with TableInfo<$MlTrainingSamplesTable, MlTrainingSample> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MlTrainingSamplesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _featuresMeta = const VerificationMeta(
    'features',
  );
  @override
  late final GeneratedColumn<String> features = GeneratedColumn<String>(
    'features',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<int> recordedAt = GeneratedColumn<int>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, features, label, recordedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ml_training_samples';
  @override
  VerificationContext validateIntegrity(
    Insertable<MlTrainingSample> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('features')) {
      context.handle(
        _featuresMeta,
        features.isAcceptableOrUnknown(data['features']!, _featuresMeta),
      );
    } else if (isInserting) {
      context.missing(_featuresMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MlTrainingSample map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MlTrainingSample(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      features: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}features'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recorded_at'],
      )!,
    );
  }

  @override
  $MlTrainingSamplesTable createAlias(String alias) {
    return $MlTrainingSamplesTable(attachedDatabase, alias);
  }
}

class MlTrainingSample extends DataClass
    implements Insertable<MlTrainingSample> {
  final int id;

  /// JSON array of feature doubles.
  final String features;
  final String label;
  final int recordedAt;
  const MlTrainingSample({
    required this.id,
    required this.features,
    required this.label,
    required this.recordedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['features'] = Variable<String>(features);
    map['label'] = Variable<String>(label);
    map['recorded_at'] = Variable<int>(recordedAt);
    return map;
  }

  MlTrainingSamplesCompanion toCompanion(bool nullToAbsent) {
    return MlTrainingSamplesCompanion(
      id: Value(id),
      features: Value(features),
      label: Value(label),
      recordedAt: Value(recordedAt),
    );
  }

  factory MlTrainingSample.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MlTrainingSample(
      id: serializer.fromJson<int>(json['id']),
      features: serializer.fromJson<String>(json['features']),
      label: serializer.fromJson<String>(json['label']),
      recordedAt: serializer.fromJson<int>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'features': serializer.toJson<String>(features),
      'label': serializer.toJson<String>(label),
      'recordedAt': serializer.toJson<int>(recordedAt),
    };
  }

  MlTrainingSample copyWith({
    int? id,
    String? features,
    String? label,
    int? recordedAt,
  }) => MlTrainingSample(
    id: id ?? this.id,
    features: features ?? this.features,
    label: label ?? this.label,
    recordedAt: recordedAt ?? this.recordedAt,
  );
  MlTrainingSample copyWithCompanion(MlTrainingSamplesCompanion data) {
    return MlTrainingSample(
      id: data.id.present ? data.id.value : this.id,
      features: data.features.present ? data.features.value : this.features,
      label: data.label.present ? data.label.value : this.label,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MlTrainingSample(')
          ..write('id: $id, ')
          ..write('features: $features, ')
          ..write('label: $label, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, features, label, recordedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MlTrainingSample &&
          other.id == this.id &&
          other.features == this.features &&
          other.label == this.label &&
          other.recordedAt == this.recordedAt);
}

class MlTrainingSamplesCompanion extends UpdateCompanion<MlTrainingSample> {
  final Value<int> id;
  final Value<String> features;
  final Value<String> label;
  final Value<int> recordedAt;
  const MlTrainingSamplesCompanion({
    this.id = const Value.absent(),
    this.features = const Value.absent(),
    this.label = const Value.absent(),
    this.recordedAt = const Value.absent(),
  });
  MlTrainingSamplesCompanion.insert({
    this.id = const Value.absent(),
    required String features,
    required String label,
    required int recordedAt,
  }) : features = Value(features),
       label = Value(label),
       recordedAt = Value(recordedAt);
  static Insertable<MlTrainingSample> custom({
    Expression<int>? id,
    Expression<String>? features,
    Expression<String>? label,
    Expression<int>? recordedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (features != null) 'features': features,
      if (label != null) 'label': label,
      if (recordedAt != null) 'recorded_at': recordedAt,
    });
  }

  MlTrainingSamplesCompanion copyWith({
    Value<int>? id,
    Value<String>? features,
    Value<String>? label,
    Value<int>? recordedAt,
  }) {
    return MlTrainingSamplesCompanion(
      id: id ?? this.id,
      features: features ?? this.features,
      label: label ?? this.label,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (features.present) {
      map['features'] = Variable<String>(features.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<int>(recordedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MlTrainingSamplesCompanion(')
          ..write('id: $id, ')
          ..write('features: $features, ')
          ..write('label: $label, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }
}

class $InsightCardsTable extends InsightCards
    with TableInfo<$InsightCardsTable, InsightCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InsightCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
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
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isAiGeneratedMeta = const VerificationMeta(
    'isAiGenerated',
  );
  @override
  late final GeneratedColumn<bool> isAiGenerated = GeneratedColumn<bool>(
    'is_ai_generated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_ai_generated" IN (0, 1))',
    ),
  );
  static const VerificationMeta _freshUntilMeta = const VerificationMeta(
    'freshUntil',
  );
  @override
  late final GeneratedColumn<int> freshUntil = GeneratedColumn<int>(
    'fresh_until',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordSourceMeta = const VerificationMeta(
    'recordSource',
  );
  @override
  late final GeneratedColumn<String> recordSource = GeneratedColumn<String>(
    'record_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    kind,
    title,
    body,
    confidence,
    isAiGenerated,
    freshUntil,
    createdAt,
    updatedAt,
    syncState,
    recordSource,
    deletedAt,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'insight_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<InsightCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('is_ai_generated')) {
      context.handle(
        _isAiGeneratedMeta,
        isAiGenerated.isAcceptableOrUnknown(
          data['is_ai_generated']!,
          _isAiGeneratedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isAiGeneratedMeta);
    }
    if (data.containsKey('fresh_until')) {
      context.handle(
        _freshUntilMeta,
        freshUntil.isAcceptableOrUnknown(data['fresh_until']!, _freshUntilMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStateMeta);
    }
    if (data.containsKey('record_source')) {
      context.handle(
        _recordSourceMeta,
        recordSource.isAcceptableOrUnknown(
          data['record_source']!,
          _recordSourceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordSourceMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  InsightCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InsightCard(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      isAiGenerated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_ai_generated'],
      )!,
      freshUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fresh_until'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      recordSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_source'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $InsightCardsTable createAlias(String alias) {
    return $InsightCardsTable(attachedDatabase, alias);
  }
}

class InsightCard extends DataClass implements Insertable<InsightCard> {
  final int id;
  final String userId;
  final String kind;
  final String title;
  final String body;
  final double? confidence;
  final bool isAiGenerated;
  final int? freshUntil;
  final int createdAt;
  final int updatedAt;
  final String syncState;
  final String recordSource;
  final int? deletedAt;
  final int revision;
  const InsightCard({
    required this.id,
    required this.userId,
    required this.kind,
    required this.title,
    required this.body,
    this.confidence,
    required this.isAiGenerated,
    this.freshUntil,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
    required this.recordSource,
    this.deletedAt,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['kind'] = Variable<String>(kind);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    map['is_ai_generated'] = Variable<bool>(isAiGenerated);
    if (!nullToAbsent || freshUntil != null) {
      map['fresh_until'] = Variable<int>(freshUntil);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    map['record_source'] = Variable<String>(recordSource);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['revision'] = Variable<int>(revision);
    return map;
  }

  InsightCardsCompanion toCompanion(bool nullToAbsent) {
    return InsightCardsCompanion(
      id: Value(id),
      userId: Value(userId),
      kind: Value(kind),
      title: Value(title),
      body: Value(body),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      isAiGenerated: Value(isAiGenerated),
      freshUntil: freshUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(freshUntil),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
      recordSource: Value(recordSource),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      revision: Value(revision),
    );
  }

  factory InsightCard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InsightCard(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      kind: serializer.fromJson<String>(json['kind']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      isAiGenerated: serializer.fromJson<bool>(json['isAiGenerated']),
      freshUntil: serializer.fromJson<int?>(json['freshUntil']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      recordSource: serializer.fromJson<String>(json['recordSource']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'kind': serializer.toJson<String>(kind),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'confidence': serializer.toJson<double?>(confidence),
      'isAiGenerated': serializer.toJson<bool>(isAiGenerated),
      'freshUntil': serializer.toJson<int?>(freshUntil),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
      'recordSource': serializer.toJson<String>(recordSource),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'revision': serializer.toJson<int>(revision),
    };
  }

  InsightCard copyWith({
    int? id,
    String? userId,
    String? kind,
    String? title,
    String? body,
    Value<double?> confidence = const Value.absent(),
    bool? isAiGenerated,
    Value<int?> freshUntil = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    String? syncState,
    String? recordSource,
    Value<int?> deletedAt = const Value.absent(),
    int? revision,
  }) => InsightCard(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    kind: kind ?? this.kind,
    title: title ?? this.title,
    body: body ?? this.body,
    confidence: confidence.present ? confidence.value : this.confidence,
    isAiGenerated: isAiGenerated ?? this.isAiGenerated,
    freshUntil: freshUntil.present ? freshUntil.value : this.freshUntil,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncState: syncState ?? this.syncState,
    recordSource: recordSource ?? this.recordSource,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    revision: revision ?? this.revision,
  );
  InsightCard copyWithCompanion(InsightCardsCompanion data) {
    return InsightCard(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      isAiGenerated: data.isAiGenerated.present
          ? data.isAiGenerated.value
          : this.isAiGenerated,
      freshUntil: data.freshUntil.present
          ? data.freshUntil.value
          : this.freshUntil,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      recordSource: data.recordSource.present
          ? data.recordSource.value
          : this.recordSource,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InsightCard(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('confidence: $confidence, ')
          ..write('isAiGenerated: $isAiGenerated, ')
          ..write('freshUntil: $freshUntil, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('recordSource: $recordSource, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    kind,
    title,
    body,
    confidence,
    isAiGenerated,
    freshUntil,
    createdAt,
    updatedAt,
    syncState,
    recordSource,
    deletedAt,
    revision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InsightCard &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.body == this.body &&
          other.confidence == this.confidence &&
          other.isAiGenerated == this.isAiGenerated &&
          other.freshUntil == this.freshUntil &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState &&
          other.recordSource == this.recordSource &&
          other.deletedAt == this.deletedAt &&
          other.revision == this.revision);
}

class InsightCardsCompanion extends UpdateCompanion<InsightCard> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> kind;
  final Value<String> title;
  final Value<String> body;
  final Value<double?> confidence;
  final Value<bool> isAiGenerated;
  final Value<int?> freshUntil;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> syncState;
  final Value<String> recordSource;
  final Value<int?> deletedAt;
  final Value<int> revision;
  final Value<int> rowid;
  const InsightCardsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.confidence = const Value.absent(),
    this.isAiGenerated = const Value.absent(),
    this.freshUntil = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.recordSource = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InsightCardsCompanion.insert({
    required int id,
    required String userId,
    required String kind,
    required String title,
    required String body,
    this.confidence = const Value.absent(),
    required bool isAiGenerated,
    this.freshUntil = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    required String syncState,
    required String recordSource,
    this.deletedAt = const Value.absent(),
    required int revision,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       kind = Value(kind),
       title = Value(title),
       body = Value(body),
       isAiGenerated = Value(isAiGenerated),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncState = Value(syncState),
       recordSource = Value(recordSource),
       revision = Value(revision);
  static Insertable<InsightCard> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<String>? body,
    Expression<double>? confidence,
    Expression<bool>? isAiGenerated,
    Expression<int>? freshUntil,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? syncState,
    Expression<String>? recordSource,
    Expression<int>? deletedAt,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (confidence != null) 'confidence': confidence,
      if (isAiGenerated != null) 'is_ai_generated': isAiGenerated,
      if (freshUntil != null) 'fresh_until': freshUntil,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (recordSource != null) 'record_source': recordSource,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InsightCardsCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? kind,
    Value<String>? title,
    Value<String>? body,
    Value<double?>? confidence,
    Value<bool>? isAiGenerated,
    Value<int?>? freshUntil,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? syncState,
    Value<String>? recordSource,
    Value<int?>? deletedAt,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return InsightCardsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      body: body ?? this.body,
      confidence: confidence ?? this.confidence,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
      freshUntil: freshUntil ?? this.freshUntil,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      recordSource: recordSource ?? this.recordSource,
      deletedAt: deletedAt ?? this.deletedAt,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (isAiGenerated.present) {
      map['is_ai_generated'] = Variable<bool>(isAiGenerated.value);
    }
    if (freshUntil.present) {
      map['fresh_until'] = Variable<int>(freshUntil.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (recordSource.present) {
      map['record_source'] = Variable<String>(recordSource.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InsightCardsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('confidence: $confidence, ')
          ..write('isAiGenerated: $isAiGenerated, ')
          ..write('freshUntil: $freshUntil, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('recordSource: $recordSource, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LearningSessionsTable extends LearningSessions
    with TableInfo<$LearningSessionsTable, LearningSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LearningSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
    'topic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<int> date = GeneratedColumn<int>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    topic,
    durationMinutes,
    notes,
    date,
    source,
    createdAt,
    syncState,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'learning_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LearningSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('topic')) {
      context.handle(
        _topicMeta,
        topic.isAcceptableOrUnknown(data['topic']!, _topicMeta),
      );
    } else if (isInserting) {
      context.missing(_topicMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationMinutesMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStateMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  LearningSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LearningSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      topic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $LearningSessionsTable createAlias(String alias) {
    return $LearningSessionsTable(attachedDatabase, alias);
  }
}

class LearningSession extends DataClass implements Insertable<LearningSession> {
  final int id;
  final String userId;
  final String topic;
  final int durationMinutes;
  final String notes;
  final int date;
  final String source;
  final int createdAt;
  final String syncState;
  final int? deletedAt;
  const LearningSession({
    required this.id,
    required this.userId,
    required this.topic,
    required this.durationMinutes,
    required this.notes,
    required this.date,
    required this.source,
    required this.createdAt,
    required this.syncState,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['topic'] = Variable<String>(topic);
    map['duration_minutes'] = Variable<int>(durationMinutes);
    map['notes'] = Variable<String>(notes);
    map['date'] = Variable<int>(date);
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<int>(createdAt);
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  LearningSessionsCompanion toCompanion(bool nullToAbsent) {
    return LearningSessionsCompanion(
      id: Value(id),
      userId: Value(userId),
      topic: Value(topic),
      durationMinutes: Value(durationMinutes),
      notes: Value(notes),
      date: Value(date),
      source: Value(source),
      createdAt: Value(createdAt),
      syncState: Value(syncState),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory LearningSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LearningSession(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      topic: serializer.fromJson<String>(json['topic']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      notes: serializer.fromJson<String>(json['notes']),
      date: serializer.fromJson<int>(json['date']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'topic': serializer.toJson<String>(topic),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'notes': serializer.toJson<String>(notes),
      'date': serializer.toJson<int>(date),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<int>(createdAt),
      'syncState': serializer.toJson<String>(syncState),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  LearningSession copyWith({
    int? id,
    String? userId,
    String? topic,
    int? durationMinutes,
    String? notes,
    int? date,
    String? source,
    int? createdAt,
    String? syncState,
    Value<int?> deletedAt = const Value.absent(),
  }) => LearningSession(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    topic: topic ?? this.topic,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    notes: notes ?? this.notes,
    date: date ?? this.date,
    source: source ?? this.source,
    createdAt: createdAt ?? this.createdAt,
    syncState: syncState ?? this.syncState,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  LearningSession copyWithCompanion(LearningSessionsCompanion data) {
    return LearningSession(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      topic: data.topic.present ? data.topic.value : this.topic,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      notes: data.notes.present ? data.notes.value : this.notes,
      date: data.date.present ? data.date.value : this.date,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LearningSession(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('topic: $topic, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('notes: $notes, ')
          ..write('date: $date, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncState: $syncState, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    topic,
    durationMinutes,
    notes,
    date,
    source,
    createdAt,
    syncState,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LearningSession &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.topic == this.topic &&
          other.durationMinutes == this.durationMinutes &&
          other.notes == this.notes &&
          other.date == this.date &&
          other.source == this.source &&
          other.createdAt == this.createdAt &&
          other.syncState == this.syncState &&
          other.deletedAt == this.deletedAt);
}

class LearningSessionsCompanion extends UpdateCompanion<LearningSession> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> topic;
  final Value<int> durationMinutes;
  final Value<String> notes;
  final Value<int> date;
  final Value<String> source;
  final Value<int> createdAt;
  final Value<String> syncState;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const LearningSessionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.topic = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.notes = const Value.absent(),
    this.date = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LearningSessionsCompanion.insert({
    required int id,
    required String userId,
    required String topic,
    required int durationMinutes,
    required String notes,
    required int date,
    required String source,
    required int createdAt,
    required String syncState,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       topic = Value(topic),
       durationMinutes = Value(durationMinutes),
       notes = Value(notes),
       date = Value(date),
       source = Value(source),
       createdAt = Value(createdAt),
       syncState = Value(syncState);
  static Insertable<LearningSession> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? topic,
    Expression<int>? durationMinutes,
    Expression<String>? notes,
    Expression<int>? date,
    Expression<String>? source,
    Expression<int>? createdAt,
    Expression<String>? syncState,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (topic != null) 'topic': topic,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (notes != null) 'notes': notes,
      if (date != null) 'date': date,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (syncState != null) 'sync_state': syncState,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LearningSessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? topic,
    Value<int>? durationMinutes,
    Value<String>? notes,
    Value<int>? date,
    Value<String>? source,
    Value<int>? createdAt,
    Value<String>? syncState,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return LearningSessionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      topic: topic ?? this.topic,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      syncState: syncState ?? this.syncState,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (date.present) {
      map['date'] = Variable<int>(date.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LearningSessionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('topic: $topic, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('notes: $notes, ')
          ..write('date: $date, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncState: $syncState, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReviewSnapshotsTable extends ReviewSnapshots
    with TableInfo<$ReviewSnapshotsTable, ReviewSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodStartMeta = const VerificationMeta(
    'periodStart',
  );
  @override
  late final GeneratedColumn<int> periodStart = GeneratedColumn<int>(
    'period_start',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodEndMeta = const VerificationMeta(
    'periodEnd',
  );
  @override
  late final GeneratedColumn<int> periodEnd = GeneratedColumn<int>(
    'period_end',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordSourceMeta = const VerificationMeta(
    'recordSource',
  );
  @override
  late final GeneratedColumn<String> recordSource = GeneratedColumn<String>(
    'record_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    periodStart,
    periodEnd,
    payload,
    createdAt,
    updatedAt,
    syncState,
    recordSource,
    deletedAt,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('period_start')) {
      context.handle(
        _periodStartMeta,
        periodStart.isAcceptableOrUnknown(
          data['period_start']!,
          _periodStartMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_periodStartMeta);
    }
    if (data.containsKey('period_end')) {
      context.handle(
        _periodEndMeta,
        periodEnd.isAcceptableOrUnknown(data['period_end']!, _periodEndMeta),
      );
    } else if (isInserting) {
      context.missing(_periodEndMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStateMeta);
    }
    if (data.containsKey('record_source')) {
      context.handle(
        _recordSourceMeta,
        recordSource.isAcceptableOrUnknown(
          data['record_source']!,
          _recordSourceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordSourceMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  ReviewSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      periodStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_start'],
      )!,
      periodEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_end'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      recordSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_source'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $ReviewSnapshotsTable createAlias(String alias) {
    return $ReviewSnapshotsTable(attachedDatabase, alias);
  }
}

class ReviewSnapshot extends DataClass implements Insertable<ReviewSnapshot> {
  final int id;
  final String userId;
  final int periodStart;
  final int periodEnd;
  final String payload;
  final int createdAt;
  final int updatedAt;
  final String syncState;
  final String recordSource;
  final int? deletedAt;
  final int revision;
  const ReviewSnapshot({
    required this.id,
    required this.userId,
    required this.periodStart,
    required this.periodEnd,
    required this.payload,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
    required this.recordSource,
    this.deletedAt,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['period_start'] = Variable<int>(periodStart);
    map['period_end'] = Variable<int>(periodEnd);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    map['record_source'] = Variable<String>(recordSource);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['revision'] = Variable<int>(revision);
    return map;
  }

  ReviewSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return ReviewSnapshotsCompanion(
      id: Value(id),
      userId: Value(userId),
      periodStart: Value(periodStart),
      periodEnd: Value(periodEnd),
      payload: Value(payload),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
      recordSource: Value(recordSource),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      revision: Value(revision),
    );
  }

  factory ReviewSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewSnapshot(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      periodStart: serializer.fromJson<int>(json['periodStart']),
      periodEnd: serializer.fromJson<int>(json['periodEnd']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      recordSource: serializer.fromJson<String>(json['recordSource']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'periodStart': serializer.toJson<int>(periodStart),
      'periodEnd': serializer.toJson<int>(periodEnd),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
      'recordSource': serializer.toJson<String>(recordSource),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'revision': serializer.toJson<int>(revision),
    };
  }

  ReviewSnapshot copyWith({
    int? id,
    String? userId,
    int? periodStart,
    int? periodEnd,
    String? payload,
    int? createdAt,
    int? updatedAt,
    String? syncState,
    String? recordSource,
    Value<int?> deletedAt = const Value.absent(),
    int? revision,
  }) => ReviewSnapshot(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    periodStart: periodStart ?? this.periodStart,
    periodEnd: periodEnd ?? this.periodEnd,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncState: syncState ?? this.syncState,
    recordSource: recordSource ?? this.recordSource,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    revision: revision ?? this.revision,
  );
  ReviewSnapshot copyWithCompanion(ReviewSnapshotsCompanion data) {
    return ReviewSnapshot(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      periodStart: data.periodStart.present
          ? data.periodStart.value
          : this.periodStart,
      periodEnd: data.periodEnd.present ? data.periodEnd.value : this.periodEnd,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      recordSource: data.recordSource.present
          ? data.recordSource.value
          : this.recordSource,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewSnapshot(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('recordSource: $recordSource, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    periodStart,
    periodEnd,
    payload,
    createdAt,
    updatedAt,
    syncState,
    recordSource,
    deletedAt,
    revision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewSnapshot &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.periodStart == this.periodStart &&
          other.periodEnd == this.periodEnd &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState &&
          other.recordSource == this.recordSource &&
          other.deletedAt == this.deletedAt &&
          other.revision == this.revision);
}

class ReviewSnapshotsCompanion extends UpdateCompanion<ReviewSnapshot> {
  final Value<int> id;
  final Value<String> userId;
  final Value<int> periodStart;
  final Value<int> periodEnd;
  final Value<String> payload;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> syncState;
  final Value<String> recordSource;
  final Value<int?> deletedAt;
  final Value<int> revision;
  final Value<int> rowid;
  const ReviewSnapshotsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.periodEnd = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.recordSource = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReviewSnapshotsCompanion.insert({
    required int id,
    required String userId,
    required int periodStart,
    required int periodEnd,
    required String payload,
    required int createdAt,
    required int updatedAt,
    required String syncState,
    required String recordSource,
    this.deletedAt = const Value.absent(),
    required int revision,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       periodStart = Value(periodStart),
       periodEnd = Value(periodEnd),
       payload = Value(payload),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncState = Value(syncState),
       recordSource = Value(recordSource),
       revision = Value(revision);
  static Insertable<ReviewSnapshot> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<int>? periodStart,
    Expression<int>? periodEnd,
    Expression<String>? payload,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? syncState,
    Expression<String>? recordSource,
    Expression<int>? deletedAt,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (periodStart != null) 'period_start': periodStart,
      if (periodEnd != null) 'period_end': periodEnd,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (recordSource != null) 'record_source': recordSource,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReviewSnapshotsCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<int>? periodStart,
    Value<int>? periodEnd,
    Value<String>? payload,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? syncState,
    Value<String>? recordSource,
    Value<int?>? deletedAt,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return ReviewSnapshotsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      recordSource: recordSource ?? this.recordSource,
      deletedAt: deletedAt ?? this.deletedAt,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (periodStart.present) {
      map['period_start'] = Variable<int>(periodStart.value);
    }
    if (periodEnd.present) {
      map['period_end'] = Variable<int>(periodEnd.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (recordSource.present) {
      map['record_source'] = Variable<String>(recordSource.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('recordSource: $recordSource, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssistantConversationsTable extends AssistantConversations
    with TableInfo<$AssistantConversationsTable, AssistantConversation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssistantConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordSourceMeta = const VerificationMeta(
    'recordSource',
  );
  @override
  late final GeneratedColumn<String> recordSource = GeneratedColumn<String>(
    'record_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    title,
    createdAt,
    updatedAt,
    syncState,
    recordSource,
    deletedAt,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assistant_conversations';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssistantConversation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStateMeta);
    }
    if (data.containsKey('record_source')) {
      context.handle(
        _recordSourceMeta,
        recordSource.isAcceptableOrUnknown(
          data['record_source']!,
          _recordSourceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordSourceMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  AssistantConversation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssistantConversation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      recordSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_source'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $AssistantConversationsTable createAlias(String alias) {
    return $AssistantConversationsTable(attachedDatabase, alias);
  }
}

class AssistantConversation extends DataClass
    implements Insertable<AssistantConversation> {
  final int id;
  final String userId;
  final String title;
  final int createdAt;
  final int updatedAt;
  final String syncState;
  final String recordSource;
  final int? deletedAt;
  final int revision;
  const AssistantConversation({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
    required this.recordSource,
    this.deletedAt,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    map['record_source'] = Variable<String>(recordSource);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['revision'] = Variable<int>(revision);
    return map;
  }

  AssistantConversationsCompanion toCompanion(bool nullToAbsent) {
    return AssistantConversationsCompanion(
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
      recordSource: Value(recordSource),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      revision: Value(revision),
    );
  }

  factory AssistantConversation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssistantConversation(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      recordSource: serializer.fromJson<String>(json['recordSource']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
      'recordSource': serializer.toJson<String>(recordSource),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'revision': serializer.toJson<int>(revision),
    };
  }

  AssistantConversation copyWith({
    int? id,
    String? userId,
    String? title,
    int? createdAt,
    int? updatedAt,
    String? syncState,
    String? recordSource,
    Value<int?> deletedAt = const Value.absent(),
    int? revision,
  }) => AssistantConversation(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncState: syncState ?? this.syncState,
    recordSource: recordSource ?? this.recordSource,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    revision: revision ?? this.revision,
  );
  AssistantConversation copyWithCompanion(
    AssistantConversationsCompanion data,
  ) {
    return AssistantConversation(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      recordSource: data.recordSource.present
          ? data.recordSource.value
          : this.recordSource,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssistantConversation(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('recordSource: $recordSource, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    title,
    createdAt,
    updatedAt,
    syncState,
    recordSource,
    deletedAt,
    revision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssistantConversation &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState &&
          other.recordSource == this.recordSource &&
          other.deletedAt == this.deletedAt &&
          other.revision == this.revision);
}

class AssistantConversationsCompanion
    extends UpdateCompanion<AssistantConversation> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> title;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> syncState;
  final Value<String> recordSource;
  final Value<int?> deletedAt;
  final Value<int> revision;
  final Value<int> rowid;
  const AssistantConversationsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.recordSource = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssistantConversationsCompanion.insert({
    required int id,
    required String userId,
    required String title,
    required int createdAt,
    required int updatedAt,
    required String syncState,
    required String recordSource,
    this.deletedAt = const Value.absent(),
    required int revision,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncState = Value(syncState),
       recordSource = Value(recordSource),
       revision = Value(revision);
  static Insertable<AssistantConversation> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? syncState,
    Expression<String>? recordSource,
    Expression<int>? deletedAt,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (recordSource != null) 'record_source': recordSource,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssistantConversationsCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? title,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? syncState,
    Value<String>? recordSource,
    Value<int?>? deletedAt,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return AssistantConversationsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      recordSource: recordSource ?? this.recordSource,
      deletedAt: deletedAt ?? this.deletedAt,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (recordSource.present) {
      map['record_source'] = Variable<String>(recordSource.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssistantConversationsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('recordSource: $recordSource, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssistantMessagesTable extends AssistantMessages
    with TableInfo<$AssistantMessagesTable, AssistantMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssistantMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<int> conversationId = GeneratedColumn<int>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionPayloadMeta = const VerificationMeta(
    'actionPayload',
  );
  @override
  late final GeneratedColumn<String> actionPayload = GeneratedColumn<String>(
    'action_payload',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPreviewMeta = const VerificationMeta(
    'isPreview',
  );
  @override
  late final GeneratedColumn<bool> isPreview = GeneratedColumn<bool>(
    'is_preview',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_preview" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordSourceMeta = const VerificationMeta(
    'recordSource',
  );
  @override
  late final GeneratedColumn<String> recordSource = GeneratedColumn<String>(
    'record_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    conversationId,
    role,
    content,
    actionPayload,
    isPreview,
    createdAt,
    updatedAt,
    syncState,
    recordSource,
    deletedAt,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assistant_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssistantMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('action_payload')) {
      context.handle(
        _actionPayloadMeta,
        actionPayload.isAcceptableOrUnknown(
          data['action_payload']!,
          _actionPayloadMeta,
        ),
      );
    }
    if (data.containsKey('is_preview')) {
      context.handle(
        _isPreviewMeta,
        isPreview.isAcceptableOrUnknown(data['is_preview']!, _isPreviewMeta),
      );
    } else if (isInserting) {
      context.missing(_isPreviewMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStateMeta);
    }
    if (data.containsKey('record_source')) {
      context.handle(
        _recordSourceMeta,
        recordSource.isAcceptableOrUnknown(
          data['record_source']!,
          _recordSourceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordSourceMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  AssistantMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssistantMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conversation_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      actionPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_payload'],
      ),
      isPreview: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_preview'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      recordSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_source'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $AssistantMessagesTable createAlias(String alias) {
    return $AssistantMessagesTable(attachedDatabase, alias);
  }
}

class AssistantMessage extends DataClass
    implements Insertable<AssistantMessage> {
  final int id;
  final String userId;
  final int conversationId;
  final String role;
  final String content;
  final String? actionPayload;
  final bool isPreview;
  final int createdAt;
  final int updatedAt;
  final String syncState;
  final String recordSource;
  final int? deletedAt;
  final int revision;
  const AssistantMessage({
    required this.id,
    required this.userId,
    required this.conversationId,
    required this.role,
    required this.content,
    this.actionPayload,
    required this.isPreview,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
    required this.recordSource,
    this.deletedAt,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['conversation_id'] = Variable<int>(conversationId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || actionPayload != null) {
      map['action_payload'] = Variable<String>(actionPayload);
    }
    map['is_preview'] = Variable<bool>(isPreview);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    map['record_source'] = Variable<String>(recordSource);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['revision'] = Variable<int>(revision);
    return map;
  }

  AssistantMessagesCompanion toCompanion(bool nullToAbsent) {
    return AssistantMessagesCompanion(
      id: Value(id),
      userId: Value(userId),
      conversationId: Value(conversationId),
      role: Value(role),
      content: Value(content),
      actionPayload: actionPayload == null && nullToAbsent
          ? const Value.absent()
          : Value(actionPayload),
      isPreview: Value(isPreview),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
      recordSource: Value(recordSource),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      revision: Value(revision),
    );
  }

  factory AssistantMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssistantMessage(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      conversationId: serializer.fromJson<int>(json['conversationId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      actionPayload: serializer.fromJson<String?>(json['actionPayload']),
      isPreview: serializer.fromJson<bool>(json['isPreview']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      recordSource: serializer.fromJson<String>(json['recordSource']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'conversationId': serializer.toJson<int>(conversationId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'actionPayload': serializer.toJson<String?>(actionPayload),
      'isPreview': serializer.toJson<bool>(isPreview),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
      'recordSource': serializer.toJson<String>(recordSource),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'revision': serializer.toJson<int>(revision),
    };
  }

  AssistantMessage copyWith({
    int? id,
    String? userId,
    int? conversationId,
    String? role,
    String? content,
    Value<String?> actionPayload = const Value.absent(),
    bool? isPreview,
    int? createdAt,
    int? updatedAt,
    String? syncState,
    String? recordSource,
    Value<int?> deletedAt = const Value.absent(),
    int? revision,
  }) => AssistantMessage(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    conversationId: conversationId ?? this.conversationId,
    role: role ?? this.role,
    content: content ?? this.content,
    actionPayload: actionPayload.present
        ? actionPayload.value
        : this.actionPayload,
    isPreview: isPreview ?? this.isPreview,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncState: syncState ?? this.syncState,
    recordSource: recordSource ?? this.recordSource,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    revision: revision ?? this.revision,
  );
  AssistantMessage copyWithCompanion(AssistantMessagesCompanion data) {
    return AssistantMessage(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      actionPayload: data.actionPayload.present
          ? data.actionPayload.value
          : this.actionPayload,
      isPreview: data.isPreview.present ? data.isPreview.value : this.isPreview,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      recordSource: data.recordSource.present
          ? data.recordSource.value
          : this.recordSource,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssistantMessage(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('actionPayload: $actionPayload, ')
          ..write('isPreview: $isPreview, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('recordSource: $recordSource, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    conversationId,
    role,
    content,
    actionPayload,
    isPreview,
    createdAt,
    updatedAt,
    syncState,
    recordSource,
    deletedAt,
    revision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssistantMessage &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.conversationId == this.conversationId &&
          other.role == this.role &&
          other.content == this.content &&
          other.actionPayload == this.actionPayload &&
          other.isPreview == this.isPreview &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState &&
          other.recordSource == this.recordSource &&
          other.deletedAt == this.deletedAt &&
          other.revision == this.revision);
}

class AssistantMessagesCompanion extends UpdateCompanion<AssistantMessage> {
  final Value<int> id;
  final Value<String> userId;
  final Value<int> conversationId;
  final Value<String> role;
  final Value<String> content;
  final Value<String?> actionPayload;
  final Value<bool> isPreview;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> syncState;
  final Value<String> recordSource;
  final Value<int?> deletedAt;
  final Value<int> revision;
  final Value<int> rowid;
  const AssistantMessagesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.actionPayload = const Value.absent(),
    this.isPreview = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.recordSource = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssistantMessagesCompanion.insert({
    required int id,
    required String userId,
    required int conversationId,
    required String role,
    required String content,
    this.actionPayload = const Value.absent(),
    required bool isPreview,
    required int createdAt,
    required int updatedAt,
    required String syncState,
    required String recordSource,
    this.deletedAt = const Value.absent(),
    required int revision,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       conversationId = Value(conversationId),
       role = Value(role),
       content = Value(content),
       isPreview = Value(isPreview),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncState = Value(syncState),
       recordSource = Value(recordSource),
       revision = Value(revision);
  static Insertable<AssistantMessage> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<int>? conversationId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<String>? actionPayload,
    Expression<bool>? isPreview,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? syncState,
    Expression<String>? recordSource,
    Expression<int>? deletedAt,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (conversationId != null) 'conversation_id': conversationId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (actionPayload != null) 'action_payload': actionPayload,
      if (isPreview != null) 'is_preview': isPreview,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (recordSource != null) 'record_source': recordSource,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssistantMessagesCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<int>? conversationId,
    Value<String>? role,
    Value<String>? content,
    Value<String?>? actionPayload,
    Value<bool>? isPreview,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? syncState,
    Value<String>? recordSource,
    Value<int?>? deletedAt,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return AssistantMessagesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      actionPayload: actionPayload ?? this.actionPayload,
      isPreview: isPreview ?? this.isPreview,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      recordSource: recordSource ?? this.recordSource,
      deletedAt: deletedAt ?? this.deletedAt,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<int>(conversationId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (actionPayload.present) {
      map['action_payload'] = Variable<String>(actionPayload.value);
    }
    if (isPreview.present) {
      map['is_preview'] = Variable<bool>(isPreview.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (recordSource.present) {
      map['record_source'] = Variable<String>(recordSource.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssistantMessagesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('actionPayload: $actionPayload, ')
          ..write('isPreview: $isPreview, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('recordSource: $recordSource, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExportHistoryTable extends ExportHistory
    with TableInfo<$ExportHistoryTable, ExportHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExportHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _domainScopeMeta = const VerificationMeta(
    'domainScope',
  );
  @override
  late final GeneratedColumn<String> domainScope = GeneratedColumn<String>(
    'domain_scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateFromMeta = const VerificationMeta(
    'dateFrom',
  );
  @override
  late final GeneratedColumn<int> dateFrom = GeneratedColumn<int>(
    'date_from',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateToMeta = const VerificationMeta('dateTo');
  @override
  late final GeneratedColumn<int> dateTo = GeneratedColumn<int>(
    'date_to',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _itemCountMeta = const VerificationMeta(
    'itemCount',
  );
  @override
  late final GeneratedColumn<int> itemCount = GeneratedColumn<int>(
    'item_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isEncryptedMeta = const VerificationMeta(
    'isEncrypted',
  );
  @override
  late final GeneratedColumn<bool> isEncrypted = GeneratedColumn<bool>(
    'is_encrypted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_encrypted" IN (0, 1))',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exportedAtMeta = const VerificationMeta(
    'exportedAt',
  );
  @override
  late final GeneratedColumn<int> exportedAt = GeneratedColumn<int>(
    'exported_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    format,
    domainScope,
    dateFrom,
    dateTo,
    filePath,
    itemCount,
    isEncrypted,
    status,
    errorMessage,
    exportedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'export_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExportHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    if (data.containsKey('domain_scope')) {
      context.handle(
        _domainScopeMeta,
        domainScope.isAcceptableOrUnknown(
          data['domain_scope']!,
          _domainScopeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_domainScopeMeta);
    }
    if (data.containsKey('date_from')) {
      context.handle(
        _dateFromMeta,
        dateFrom.isAcceptableOrUnknown(data['date_from']!, _dateFromMeta),
      );
    }
    if (data.containsKey('date_to')) {
      context.handle(
        _dateToMeta,
        dateTo.isAcceptableOrUnknown(data['date_to']!, _dateToMeta),
      );
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    }
    if (data.containsKey('item_count')) {
      context.handle(
        _itemCountMeta,
        itemCount.isAcceptableOrUnknown(data['item_count']!, _itemCountMeta),
      );
    } else if (isInserting) {
      context.missing(_itemCountMeta);
    }
    if (data.containsKey('is_encrypted')) {
      context.handle(
        _isEncryptedMeta,
        isEncrypted.isAcceptableOrUnknown(
          data['is_encrypted']!,
          _isEncryptedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isEncryptedMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('exported_at')) {
      context.handle(
        _exportedAtMeta,
        exportedAt.isAcceptableOrUnknown(data['exported_at']!, _exportedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_exportedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  ExportHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExportHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
      domainScope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain_scope'],
      )!,
      dateFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_from'],
      ),
      dateTo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_to'],
      ),
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      ),
      itemCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_count'],
      )!,
      isEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_encrypted'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      exportedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exported_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ExportHistoryTable createAlias(String alias) {
    return $ExportHistoryTable(attachedDatabase, alias);
  }
}

class ExportHistoryData extends DataClass
    implements Insertable<ExportHistoryData> {
  final int id;
  final String userId;
  final String format;
  final String domainScope;
  final int? dateFrom;
  final int? dateTo;
  final String? filePath;
  final int itemCount;
  final bool isEncrypted;
  final String status;
  final String? errorMessage;
  final int exportedAt;
  final int createdAt;
  final int updatedAt;
  const ExportHistoryData({
    required this.id,
    required this.userId,
    required this.format,
    required this.domainScope,
    this.dateFrom,
    this.dateTo,
    this.filePath,
    required this.itemCount,
    required this.isEncrypted,
    required this.status,
    this.errorMessage,
    required this.exportedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['format'] = Variable<String>(format);
    map['domain_scope'] = Variable<String>(domainScope);
    if (!nullToAbsent || dateFrom != null) {
      map['date_from'] = Variable<int>(dateFrom);
    }
    if (!nullToAbsent || dateTo != null) {
      map['date_to'] = Variable<int>(dateTo);
    }
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    map['item_count'] = Variable<int>(itemCount);
    map['is_encrypted'] = Variable<bool>(isEncrypted);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['exported_at'] = Variable<int>(exportedAt);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  ExportHistoryCompanion toCompanion(bool nullToAbsent) {
    return ExportHistoryCompanion(
      id: Value(id),
      userId: Value(userId),
      format: Value(format),
      domainScope: Value(domainScope),
      dateFrom: dateFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(dateFrom),
      dateTo: dateTo == null && nullToAbsent
          ? const Value.absent()
          : Value(dateTo),
      filePath: filePath == null && nullToAbsent
          ? const Value.absent()
          : Value(filePath),
      itemCount: Value(itemCount),
      isEncrypted: Value(isEncrypted),
      status: Value(status),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      exportedAt: Value(exportedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ExportHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExportHistoryData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      format: serializer.fromJson<String>(json['format']),
      domainScope: serializer.fromJson<String>(json['domainScope']),
      dateFrom: serializer.fromJson<int?>(json['dateFrom']),
      dateTo: serializer.fromJson<int?>(json['dateTo']),
      filePath: serializer.fromJson<String?>(json['filePath']),
      itemCount: serializer.fromJson<int>(json['itemCount']),
      isEncrypted: serializer.fromJson<bool>(json['isEncrypted']),
      status: serializer.fromJson<String>(json['status']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      exportedAt: serializer.fromJson<int>(json['exportedAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'format': serializer.toJson<String>(format),
      'domainScope': serializer.toJson<String>(domainScope),
      'dateFrom': serializer.toJson<int?>(dateFrom),
      'dateTo': serializer.toJson<int?>(dateTo),
      'filePath': serializer.toJson<String?>(filePath),
      'itemCount': serializer.toJson<int>(itemCount),
      'isEncrypted': serializer.toJson<bool>(isEncrypted),
      'status': serializer.toJson<String>(status),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'exportedAt': serializer.toJson<int>(exportedAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  ExportHistoryData copyWith({
    int? id,
    String? userId,
    String? format,
    String? domainScope,
    Value<int?> dateFrom = const Value.absent(),
    Value<int?> dateTo = const Value.absent(),
    Value<String?> filePath = const Value.absent(),
    int? itemCount,
    bool? isEncrypted,
    String? status,
    Value<String?> errorMessage = const Value.absent(),
    int? exportedAt,
    int? createdAt,
    int? updatedAt,
  }) => ExportHistoryData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    format: format ?? this.format,
    domainScope: domainScope ?? this.domainScope,
    dateFrom: dateFrom.present ? dateFrom.value : this.dateFrom,
    dateTo: dateTo.present ? dateTo.value : this.dateTo,
    filePath: filePath.present ? filePath.value : this.filePath,
    itemCount: itemCount ?? this.itemCount,
    isEncrypted: isEncrypted ?? this.isEncrypted,
    status: status ?? this.status,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    exportedAt: exportedAt ?? this.exportedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ExportHistoryData copyWithCompanion(ExportHistoryCompanion data) {
    return ExportHistoryData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      format: data.format.present ? data.format.value : this.format,
      domainScope: data.domainScope.present
          ? data.domainScope.value
          : this.domainScope,
      dateFrom: data.dateFrom.present ? data.dateFrom.value : this.dateFrom,
      dateTo: data.dateTo.present ? data.dateTo.value : this.dateTo,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      itemCount: data.itemCount.present ? data.itemCount.value : this.itemCount,
      isEncrypted: data.isEncrypted.present
          ? data.isEncrypted.value
          : this.isEncrypted,
      status: data.status.present ? data.status.value : this.status,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      exportedAt: data.exportedAt.present
          ? data.exportedAt.value
          : this.exportedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExportHistoryData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('format: $format, ')
          ..write('domainScope: $domainScope, ')
          ..write('dateFrom: $dateFrom, ')
          ..write('dateTo: $dateTo, ')
          ..write('filePath: $filePath, ')
          ..write('itemCount: $itemCount, ')
          ..write('isEncrypted: $isEncrypted, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('exportedAt: $exportedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    format,
    domainScope,
    dateFrom,
    dateTo,
    filePath,
    itemCount,
    isEncrypted,
    status,
    errorMessage,
    exportedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExportHistoryData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.format == this.format &&
          other.domainScope == this.domainScope &&
          other.dateFrom == this.dateFrom &&
          other.dateTo == this.dateTo &&
          other.filePath == this.filePath &&
          other.itemCount == this.itemCount &&
          other.isEncrypted == this.isEncrypted &&
          other.status == this.status &&
          other.errorMessage == this.errorMessage &&
          other.exportedAt == this.exportedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ExportHistoryCompanion extends UpdateCompanion<ExportHistoryData> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> format;
  final Value<String> domainScope;
  final Value<int?> dateFrom;
  final Value<int?> dateTo;
  final Value<String?> filePath;
  final Value<int> itemCount;
  final Value<bool> isEncrypted;
  final Value<String> status;
  final Value<String?> errorMessage;
  final Value<int> exportedAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const ExportHistoryCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.format = const Value.absent(),
    this.domainScope = const Value.absent(),
    this.dateFrom = const Value.absent(),
    this.dateTo = const Value.absent(),
    this.filePath = const Value.absent(),
    this.itemCount = const Value.absent(),
    this.isEncrypted = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.exportedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExportHistoryCompanion.insert({
    required int id,
    required String userId,
    required String format,
    required String domainScope,
    this.dateFrom = const Value.absent(),
    this.dateTo = const Value.absent(),
    this.filePath = const Value.absent(),
    required int itemCount,
    required bool isEncrypted,
    required String status,
    this.errorMessage = const Value.absent(),
    required int exportedAt,
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       format = Value(format),
       domainScope = Value(domainScope),
       itemCount = Value(itemCount),
       isEncrypted = Value(isEncrypted),
       status = Value(status),
       exportedAt = Value(exportedAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ExportHistoryData> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? format,
    Expression<String>? domainScope,
    Expression<int>? dateFrom,
    Expression<int>? dateTo,
    Expression<String>? filePath,
    Expression<int>? itemCount,
    Expression<bool>? isEncrypted,
    Expression<String>? status,
    Expression<String>? errorMessage,
    Expression<int>? exportedAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (format != null) 'format': format,
      if (domainScope != null) 'domain_scope': domainScope,
      if (dateFrom != null) 'date_from': dateFrom,
      if (dateTo != null) 'date_to': dateTo,
      if (filePath != null) 'file_path': filePath,
      if (itemCount != null) 'item_count': itemCount,
      if (isEncrypted != null) 'is_encrypted': isEncrypted,
      if (status != null) 'status': status,
      if (errorMessage != null) 'error_message': errorMessage,
      if (exportedAt != null) 'exported_at': exportedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExportHistoryCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? format,
    Value<String>? domainScope,
    Value<int?>? dateFrom,
    Value<int?>? dateTo,
    Value<String?>? filePath,
    Value<int>? itemCount,
    Value<bool>? isEncrypted,
    Value<String>? status,
    Value<String?>? errorMessage,
    Value<int>? exportedAt,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return ExportHistoryCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      format: format ?? this.format,
      domainScope: domainScope ?? this.domainScope,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      filePath: filePath ?? this.filePath,
      itemCount: itemCount ?? this.itemCount,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      exportedAt: exportedAt ?? this.exportedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (domainScope.present) {
      map['domain_scope'] = Variable<String>(domainScope.value);
    }
    if (dateFrom.present) {
      map['date_from'] = Variable<int>(dateFrom.value);
    }
    if (dateTo.present) {
      map['date_to'] = Variable<int>(dateTo.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (itemCount.present) {
      map['item_count'] = Variable<int>(itemCount.value);
    }
    if (isEncrypted.present) {
      map['is_encrypted'] = Variable<bool>(isEncrypted.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (exportedAt.present) {
      map['exported_at'] = Variable<int>(exportedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExportHistoryCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('format: $format, ')
          ..write('domainScope: $domainScope, ')
          ..write('dateFrom: $dateFrom, ')
          ..write('dateTo: $dateTo, ')
          ..write('filePath: $filePath, ')
          ..write('itemCount: $itemCount, ')
          ..write('isEncrypted: $isEncrypted, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('exportedAt: $exportedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppUpdateInfoTable extends AppUpdateInfo
    with TableInfo<$AppUpdateInfoTable, AppUpdateInfoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppUpdateInfoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionCodeMeta = const VerificationMeta(
    'versionCode',
  );
  @override
  late final GeneratedColumn<int> versionCode = GeneratedColumn<int>(
    'version_code',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionNameMeta = const VerificationMeta(
    'versionName',
  );
  @override
  late final GeneratedColumn<String> versionName = GeneratedColumn<String>(
    'version_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isRequiredMeta = const VerificationMeta(
    'isRequired',
  );
  @override
  late final GeneratedColumn<bool> isRequired = GeneratedColumn<bool>(
    'is_required',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_required" IN (0, 1))',
    ),
  );
  static const VerificationMeta _downloadUrlMeta = const VerificationMeta(
    'downloadUrl',
  );
  @override
  late final GeneratedColumn<String> downloadUrl = GeneratedColumn<String>(
    'download_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checksumSha256Meta = const VerificationMeta(
    'checksumSha256',
  );
  @override
  late final GeneratedColumn<String> checksumSha256 = GeneratedColumn<String>(
    'checksum_sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checkedAtMeta = const VerificationMeta(
    'checkedAt',
  );
  @override
  late final GeneratedColumn<int> checkedAt = GeneratedColumn<int>(
    'checked_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    versionCode,
    versionName,
    isRequired,
    downloadUrl,
    checksumSha256,
    checkedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_update_info';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppUpdateInfoData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('version_code')) {
      context.handle(
        _versionCodeMeta,
        versionCode.isAcceptableOrUnknown(
          data['version_code']!,
          _versionCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_versionCodeMeta);
    }
    if (data.containsKey('version_name')) {
      context.handle(
        _versionNameMeta,
        versionName.isAcceptableOrUnknown(
          data['version_name']!,
          _versionNameMeta,
        ),
      );
    }
    if (data.containsKey('is_required')) {
      context.handle(
        _isRequiredMeta,
        isRequired.isAcceptableOrUnknown(data['is_required']!, _isRequiredMeta),
      );
    } else if (isInserting) {
      context.missing(_isRequiredMeta);
    }
    if (data.containsKey('download_url')) {
      context.handle(
        _downloadUrlMeta,
        downloadUrl.isAcceptableOrUnknown(
          data['download_url']!,
          _downloadUrlMeta,
        ),
      );
    }
    if (data.containsKey('checksum_sha256')) {
      context.handle(
        _checksumSha256Meta,
        checksumSha256.isAcceptableOrUnknown(
          data['checksum_sha256']!,
          _checksumSha256Meta,
        ),
      );
    }
    if (data.containsKey('checked_at')) {
      context.handle(
        _checkedAtMeta,
        checkedAt.isAcceptableOrUnknown(data['checked_at']!, _checkedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_checkedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  AppUpdateInfoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppUpdateInfoData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      versionCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version_code'],
      )!,
      versionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version_name'],
      ),
      isRequired: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_required'],
      )!,
      downloadUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}download_url'],
      ),
      checksumSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checksum_sha256'],
      ),
      checkedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}checked_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppUpdateInfoTable createAlias(String alias) {
    return $AppUpdateInfoTable(attachedDatabase, alias);
  }
}

class AppUpdateInfoData extends DataClass
    implements Insertable<AppUpdateInfoData> {
  final int id;
  final String userId;
  final int versionCode;
  final String? versionName;
  final bool isRequired;
  final String? downloadUrl;
  final String? checksumSha256;
  final int checkedAt;
  final int createdAt;
  final int updatedAt;
  const AppUpdateInfoData({
    required this.id,
    required this.userId,
    required this.versionCode,
    this.versionName,
    required this.isRequired,
    this.downloadUrl,
    this.checksumSha256,
    required this.checkedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['version_code'] = Variable<int>(versionCode);
    if (!nullToAbsent || versionName != null) {
      map['version_name'] = Variable<String>(versionName);
    }
    map['is_required'] = Variable<bool>(isRequired);
    if (!nullToAbsent || downloadUrl != null) {
      map['download_url'] = Variable<String>(downloadUrl);
    }
    if (!nullToAbsent || checksumSha256 != null) {
      map['checksum_sha256'] = Variable<String>(checksumSha256);
    }
    map['checked_at'] = Variable<int>(checkedAt);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  AppUpdateInfoCompanion toCompanion(bool nullToAbsent) {
    return AppUpdateInfoCompanion(
      id: Value(id),
      userId: Value(userId),
      versionCode: Value(versionCode),
      versionName: versionName == null && nullToAbsent
          ? const Value.absent()
          : Value(versionName),
      isRequired: Value(isRequired),
      downloadUrl: downloadUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(downloadUrl),
      checksumSha256: checksumSha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(checksumSha256),
      checkedAt: Value(checkedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppUpdateInfoData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppUpdateInfoData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      versionCode: serializer.fromJson<int>(json['versionCode']),
      versionName: serializer.fromJson<String?>(json['versionName']),
      isRequired: serializer.fromJson<bool>(json['isRequired']),
      downloadUrl: serializer.fromJson<String?>(json['downloadUrl']),
      checksumSha256: serializer.fromJson<String?>(json['checksumSha256']),
      checkedAt: serializer.fromJson<int>(json['checkedAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'versionCode': serializer.toJson<int>(versionCode),
      'versionName': serializer.toJson<String?>(versionName),
      'isRequired': serializer.toJson<bool>(isRequired),
      'downloadUrl': serializer.toJson<String?>(downloadUrl),
      'checksumSha256': serializer.toJson<String?>(checksumSha256),
      'checkedAt': serializer.toJson<int>(checkedAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  AppUpdateInfoData copyWith({
    int? id,
    String? userId,
    int? versionCode,
    Value<String?> versionName = const Value.absent(),
    bool? isRequired,
    Value<String?> downloadUrl = const Value.absent(),
    Value<String?> checksumSha256 = const Value.absent(),
    int? checkedAt,
    int? createdAt,
    int? updatedAt,
  }) => AppUpdateInfoData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    versionCode: versionCode ?? this.versionCode,
    versionName: versionName.present ? versionName.value : this.versionName,
    isRequired: isRequired ?? this.isRequired,
    downloadUrl: downloadUrl.present ? downloadUrl.value : this.downloadUrl,
    checksumSha256: checksumSha256.present
        ? checksumSha256.value
        : this.checksumSha256,
    checkedAt: checkedAt ?? this.checkedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppUpdateInfoData copyWithCompanion(AppUpdateInfoCompanion data) {
    return AppUpdateInfoData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      versionCode: data.versionCode.present
          ? data.versionCode.value
          : this.versionCode,
      versionName: data.versionName.present
          ? data.versionName.value
          : this.versionName,
      isRequired: data.isRequired.present
          ? data.isRequired.value
          : this.isRequired,
      downloadUrl: data.downloadUrl.present
          ? data.downloadUrl.value
          : this.downloadUrl,
      checksumSha256: data.checksumSha256.present
          ? data.checksumSha256.value
          : this.checksumSha256,
      checkedAt: data.checkedAt.present ? data.checkedAt.value : this.checkedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppUpdateInfoData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('versionCode: $versionCode, ')
          ..write('versionName: $versionName, ')
          ..write('isRequired: $isRequired, ')
          ..write('downloadUrl: $downloadUrl, ')
          ..write('checksumSha256: $checksumSha256, ')
          ..write('checkedAt: $checkedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    versionCode,
    versionName,
    isRequired,
    downloadUrl,
    checksumSha256,
    checkedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppUpdateInfoData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.versionCode == this.versionCode &&
          other.versionName == this.versionName &&
          other.isRequired == this.isRequired &&
          other.downloadUrl == this.downloadUrl &&
          other.checksumSha256 == this.checksumSha256 &&
          other.checkedAt == this.checkedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AppUpdateInfoCompanion extends UpdateCompanion<AppUpdateInfoData> {
  final Value<int> id;
  final Value<String> userId;
  final Value<int> versionCode;
  final Value<String?> versionName;
  final Value<bool> isRequired;
  final Value<String?> downloadUrl;
  final Value<String?> checksumSha256;
  final Value<int> checkedAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const AppUpdateInfoCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.versionCode = const Value.absent(),
    this.versionName = const Value.absent(),
    this.isRequired = const Value.absent(),
    this.downloadUrl = const Value.absent(),
    this.checksumSha256 = const Value.absent(),
    this.checkedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppUpdateInfoCompanion.insert({
    required int id,
    required String userId,
    required int versionCode,
    this.versionName = const Value.absent(),
    required bool isRequired,
    this.downloadUrl = const Value.absent(),
    this.checksumSha256 = const Value.absent(),
    required int checkedAt,
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       versionCode = Value(versionCode),
       isRequired = Value(isRequired),
       checkedAt = Value(checkedAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AppUpdateInfoData> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<int>? versionCode,
    Expression<String>? versionName,
    Expression<bool>? isRequired,
    Expression<String>? downloadUrl,
    Expression<String>? checksumSha256,
    Expression<int>? checkedAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (versionCode != null) 'version_code': versionCode,
      if (versionName != null) 'version_name': versionName,
      if (isRequired != null) 'is_required': isRequired,
      if (downloadUrl != null) 'download_url': downloadUrl,
      if (checksumSha256 != null) 'checksum_sha256': checksumSha256,
      if (checkedAt != null) 'checked_at': checkedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppUpdateInfoCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<int>? versionCode,
    Value<String?>? versionName,
    Value<bool>? isRequired,
    Value<String?>? downloadUrl,
    Value<String?>? checksumSha256,
    Value<int>? checkedAt,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppUpdateInfoCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      versionCode: versionCode ?? this.versionCode,
      versionName: versionName ?? this.versionName,
      isRequired: isRequired ?? this.isRequired,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      checksumSha256: checksumSha256 ?? this.checksumSha256,
      checkedAt: checkedAt ?? this.checkedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (versionCode.present) {
      map['version_code'] = Variable<int>(versionCode.value);
    }
    if (versionName.present) {
      map['version_name'] = Variable<String>(versionName.value);
    }
    if (isRequired.present) {
      map['is_required'] = Variable<bool>(isRequired.value);
    }
    if (downloadUrl.present) {
      map['download_url'] = Variable<String>(downloadUrl.value);
    }
    if (checksumSha256.present) {
      map['checksum_sha256'] = Variable<String>(checksumSha256.value);
    }
    if (checkedAt.present) {
      map['checked_at'] = Variable<int>(checkedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppUpdateInfoCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('versionCode: $versionCode, ')
          ..write('versionName: $versionName, ')
          ..write('isRequired: $isRequired, ')
          ..write('downloadUrl: $downloadUrl, ')
          ..write('checksumSha256: $checksumSha256, ')
          ..write('checkedAt: $checkedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategorySummaryTable extends CategorySummary
    with TableInfo<$CategorySummaryTable, CategorySummaryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategorySummaryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodKeyMeta = const VerificationMeta(
    'periodKey',
  );
  @override
  late final GeneratedColumn<String> periodKey = GeneratedColumn<String>(
    'period_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _txCountMeta = const VerificationMeta(
    'txCount',
  );
  @override
  late final GeneratedColumn<int> txCount = GeneratedColumn<int>(
    'tx_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    periodKey,
    category,
    totalAmount,
    txCount,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_summary';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategorySummaryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('period_key')) {
      context.handle(
        _periodKeyMeta,
        periodKey.isAcceptableOrUnknown(data['period_key']!, _periodKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_periodKeyMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('tx_count')) {
      context.handle(
        _txCountMeta,
        txCount.isAcceptableOrUnknown(data['tx_count']!, _txCountMeta),
      );
    } else if (isInserting) {
      context.missing(_txCountMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, periodKey, category};
  @override
  CategorySummaryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategorySummaryData(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      periodKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_key'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      txCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tx_count'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CategorySummaryTable createAlias(String alias) {
    return $CategorySummaryTable(attachedDatabase, alias);
  }
}

class CategorySummaryData extends DataClass
    implements Insertable<CategorySummaryData> {
  final String userId;
  final String periodKey;
  final String category;
  final double totalAmount;
  final int txCount;
  final int updatedAt;
  const CategorySummaryData({
    required this.userId,
    required this.periodKey,
    required this.category,
    required this.totalAmount,
    required this.txCount,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['period_key'] = Variable<String>(periodKey);
    map['category'] = Variable<String>(category);
    map['total_amount'] = Variable<double>(totalAmount);
    map['tx_count'] = Variable<int>(txCount);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  CategorySummaryCompanion toCompanion(bool nullToAbsent) {
    return CategorySummaryCompanion(
      userId: Value(userId),
      periodKey: Value(periodKey),
      category: Value(category),
      totalAmount: Value(totalAmount),
      txCount: Value(txCount),
      updatedAt: Value(updatedAt),
    );
  }

  factory CategorySummaryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategorySummaryData(
      userId: serializer.fromJson<String>(json['userId']),
      periodKey: serializer.fromJson<String>(json['periodKey']),
      category: serializer.fromJson<String>(json['category']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      txCount: serializer.fromJson<int>(json['txCount']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'periodKey': serializer.toJson<String>(periodKey),
      'category': serializer.toJson<String>(category),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'txCount': serializer.toJson<int>(txCount),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  CategorySummaryData copyWith({
    String? userId,
    String? periodKey,
    String? category,
    double? totalAmount,
    int? txCount,
    int? updatedAt,
  }) => CategorySummaryData(
    userId: userId ?? this.userId,
    periodKey: periodKey ?? this.periodKey,
    category: category ?? this.category,
    totalAmount: totalAmount ?? this.totalAmount,
    txCount: txCount ?? this.txCount,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CategorySummaryData copyWithCompanion(CategorySummaryCompanion data) {
    return CategorySummaryData(
      userId: data.userId.present ? data.userId.value : this.userId,
      periodKey: data.periodKey.present ? data.periodKey.value : this.periodKey,
      category: data.category.present ? data.category.value : this.category,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      txCount: data.txCount.present ? data.txCount.value : this.txCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategorySummaryData(')
          ..write('userId: $userId, ')
          ..write('periodKey: $periodKey, ')
          ..write('category: $category, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('txCount: $txCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(userId, periodKey, category, totalAmount, txCount, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategorySummaryData &&
          other.userId == this.userId &&
          other.periodKey == this.periodKey &&
          other.category == this.category &&
          other.totalAmount == this.totalAmount &&
          other.txCount == this.txCount &&
          other.updatedAt == this.updatedAt);
}

class CategorySummaryCompanion extends UpdateCompanion<CategorySummaryData> {
  final Value<String> userId;
  final Value<String> periodKey;
  final Value<String> category;
  final Value<double> totalAmount;
  final Value<int> txCount;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const CategorySummaryCompanion({
    this.userId = const Value.absent(),
    this.periodKey = const Value.absent(),
    this.category = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.txCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategorySummaryCompanion.insert({
    required String userId,
    required String periodKey,
    required String category,
    required double totalAmount,
    required int txCount,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       periodKey = Value(periodKey),
       category = Value(category),
       totalAmount = Value(totalAmount),
       txCount = Value(txCount),
       updatedAt = Value(updatedAt);
  static Insertable<CategorySummaryData> custom({
    Expression<String>? userId,
    Expression<String>? periodKey,
    Expression<String>? category,
    Expression<double>? totalAmount,
    Expression<int>? txCount,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (periodKey != null) 'period_key': periodKey,
      if (category != null) 'category': category,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (txCount != null) 'tx_count': txCount,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategorySummaryCompanion copyWith({
    Value<String>? userId,
    Value<String>? periodKey,
    Value<String>? category,
    Value<double>? totalAmount,
    Value<int>? txCount,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return CategorySummaryCompanion(
      userId: userId ?? this.userId,
      periodKey: periodKey ?? this.periodKey,
      category: category ?? this.category,
      totalAmount: totalAmount ?? this.totalAmount,
      txCount: txCount ?? this.txCount,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (periodKey.present) {
      map['period_key'] = Variable<String>(periodKey.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (txCount.present) {
      map['tx_count'] = Variable<int>(txCount.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategorySummaryCompanion(')
          ..write('userId: $userId, ')
          ..write('periodKey: $periodKey, ')
          ..write('category: $category, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('txCount: $txCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FinanceSummaryTable extends FinanceSummary
    with TableInfo<$FinanceSummaryTable, FinanceSummaryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FinanceSummaryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodTypeMeta = const VerificationMeta(
    'periodType',
  );
  @override
  late final GeneratedColumn<String> periodType = GeneratedColumn<String>(
    'period_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodKeyMeta = const VerificationMeta(
    'periodKey',
  );
  @override
  late final GeneratedColumn<String> periodKey = GeneratedColumn<String>(
    'period_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalIncomeMeta = const VerificationMeta(
    'totalIncome',
  );
  @override
  late final GeneratedColumn<double> totalIncome = GeneratedColumn<double>(
    'total_income',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalExpenseMeta = const VerificationMeta(
    'totalExpense',
  );
  @override
  late final GeneratedColumn<double> totalExpense = GeneratedColumn<double>(
    'total_expense',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _txCountMeta = const VerificationMeta(
    'txCount',
  );
  @override
  late final GeneratedColumn<int> txCount = GeneratedColumn<int>(
    'tx_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    periodType,
    periodKey,
    totalIncome,
    totalExpense,
    txCount,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'finance_summary';
  @override
  VerificationContext validateIntegrity(
    Insertable<FinanceSummaryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('period_type')) {
      context.handle(
        _periodTypeMeta,
        periodType.isAcceptableOrUnknown(data['period_type']!, _periodTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_periodTypeMeta);
    }
    if (data.containsKey('period_key')) {
      context.handle(
        _periodKeyMeta,
        periodKey.isAcceptableOrUnknown(data['period_key']!, _periodKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_periodKeyMeta);
    }
    if (data.containsKey('total_income')) {
      context.handle(
        _totalIncomeMeta,
        totalIncome.isAcceptableOrUnknown(
          data['total_income']!,
          _totalIncomeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalIncomeMeta);
    }
    if (data.containsKey('total_expense')) {
      context.handle(
        _totalExpenseMeta,
        totalExpense.isAcceptableOrUnknown(
          data['total_expense']!,
          _totalExpenseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalExpenseMeta);
    }
    if (data.containsKey('tx_count')) {
      context.handle(
        _txCountMeta,
        txCount.isAcceptableOrUnknown(data['tx_count']!, _txCountMeta),
      );
    } else if (isInserting) {
      context.missing(_txCountMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, periodType, periodKey};
  @override
  FinanceSummaryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FinanceSummaryData(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      periodType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_type'],
      )!,
      periodKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_key'],
      )!,
      totalIncome: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_income'],
      )!,
      totalExpense: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_expense'],
      )!,
      txCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tx_count'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FinanceSummaryTable createAlias(String alias) {
    return $FinanceSummaryTable(attachedDatabase, alias);
  }
}

class FinanceSummaryData extends DataClass
    implements Insertable<FinanceSummaryData> {
  final String userId;
  final String periodType;
  final String periodKey;
  final double totalIncome;
  final double totalExpense;
  final int txCount;
  final int updatedAt;
  const FinanceSummaryData({
    required this.userId,
    required this.periodType,
    required this.periodKey,
    required this.totalIncome,
    required this.totalExpense,
    required this.txCount,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['period_type'] = Variable<String>(periodType);
    map['period_key'] = Variable<String>(periodKey);
    map['total_income'] = Variable<double>(totalIncome);
    map['total_expense'] = Variable<double>(totalExpense);
    map['tx_count'] = Variable<int>(txCount);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  FinanceSummaryCompanion toCompanion(bool nullToAbsent) {
    return FinanceSummaryCompanion(
      userId: Value(userId),
      periodType: Value(periodType),
      periodKey: Value(periodKey),
      totalIncome: Value(totalIncome),
      totalExpense: Value(totalExpense),
      txCount: Value(txCount),
      updatedAt: Value(updatedAt),
    );
  }

  factory FinanceSummaryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FinanceSummaryData(
      userId: serializer.fromJson<String>(json['userId']),
      periodType: serializer.fromJson<String>(json['periodType']),
      periodKey: serializer.fromJson<String>(json['periodKey']),
      totalIncome: serializer.fromJson<double>(json['totalIncome']),
      totalExpense: serializer.fromJson<double>(json['totalExpense']),
      txCount: serializer.fromJson<int>(json['txCount']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'periodType': serializer.toJson<String>(periodType),
      'periodKey': serializer.toJson<String>(periodKey),
      'totalIncome': serializer.toJson<double>(totalIncome),
      'totalExpense': serializer.toJson<double>(totalExpense),
      'txCount': serializer.toJson<int>(txCount),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  FinanceSummaryData copyWith({
    String? userId,
    String? periodType,
    String? periodKey,
    double? totalIncome,
    double? totalExpense,
    int? txCount,
    int? updatedAt,
  }) => FinanceSummaryData(
    userId: userId ?? this.userId,
    periodType: periodType ?? this.periodType,
    periodKey: periodKey ?? this.periodKey,
    totalIncome: totalIncome ?? this.totalIncome,
    totalExpense: totalExpense ?? this.totalExpense,
    txCount: txCount ?? this.txCount,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FinanceSummaryData copyWithCompanion(FinanceSummaryCompanion data) {
    return FinanceSummaryData(
      userId: data.userId.present ? data.userId.value : this.userId,
      periodType: data.periodType.present
          ? data.periodType.value
          : this.periodType,
      periodKey: data.periodKey.present ? data.periodKey.value : this.periodKey,
      totalIncome: data.totalIncome.present
          ? data.totalIncome.value
          : this.totalIncome,
      totalExpense: data.totalExpense.present
          ? data.totalExpense.value
          : this.totalExpense,
      txCount: data.txCount.present ? data.txCount.value : this.txCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FinanceSummaryData(')
          ..write('userId: $userId, ')
          ..write('periodType: $periodType, ')
          ..write('periodKey: $periodKey, ')
          ..write('totalIncome: $totalIncome, ')
          ..write('totalExpense: $totalExpense, ')
          ..write('txCount: $txCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    periodType,
    periodKey,
    totalIncome,
    totalExpense,
    txCount,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FinanceSummaryData &&
          other.userId == this.userId &&
          other.periodType == this.periodType &&
          other.periodKey == this.periodKey &&
          other.totalIncome == this.totalIncome &&
          other.totalExpense == this.totalExpense &&
          other.txCount == this.txCount &&
          other.updatedAt == this.updatedAt);
}

class FinanceSummaryCompanion extends UpdateCompanion<FinanceSummaryData> {
  final Value<String> userId;
  final Value<String> periodType;
  final Value<String> periodKey;
  final Value<double> totalIncome;
  final Value<double> totalExpense;
  final Value<int> txCount;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const FinanceSummaryCompanion({
    this.userId = const Value.absent(),
    this.periodType = const Value.absent(),
    this.periodKey = const Value.absent(),
    this.totalIncome = const Value.absent(),
    this.totalExpense = const Value.absent(),
    this.txCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FinanceSummaryCompanion.insert({
    required String userId,
    required String periodType,
    required String periodKey,
    required double totalIncome,
    required double totalExpense,
    required int txCount,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       periodType = Value(periodType),
       periodKey = Value(periodKey),
       totalIncome = Value(totalIncome),
       totalExpense = Value(totalExpense),
       txCount = Value(txCount),
       updatedAt = Value(updatedAt);
  static Insertable<FinanceSummaryData> custom({
    Expression<String>? userId,
    Expression<String>? periodType,
    Expression<String>? periodKey,
    Expression<double>? totalIncome,
    Expression<double>? totalExpense,
    Expression<int>? txCount,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (periodType != null) 'period_type': periodType,
      if (periodKey != null) 'period_key': periodKey,
      if (totalIncome != null) 'total_income': totalIncome,
      if (totalExpense != null) 'total_expense': totalExpense,
      if (txCount != null) 'tx_count': txCount,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FinanceSummaryCompanion copyWith({
    Value<String>? userId,
    Value<String>? periodType,
    Value<String>? periodKey,
    Value<double>? totalIncome,
    Value<double>? totalExpense,
    Value<int>? txCount,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return FinanceSummaryCompanion(
      userId: userId ?? this.userId,
      periodType: periodType ?? this.periodType,
      periodKey: periodKey ?? this.periodKey,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      txCount: txCount ?? this.txCount,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (periodType.present) {
      map['period_type'] = Variable<String>(periodType.value);
    }
    if (periodKey.present) {
      map['period_key'] = Variable<String>(periodKey.value);
    }
    if (totalIncome.present) {
      map['total_income'] = Variable<double>(totalIncome.value);
    }
    if (totalExpense.present) {
      map['total_expense'] = Variable<double>(totalExpense.value);
    }
    if (txCount.present) {
      map['tx_count'] = Variable<int>(txCount.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FinanceSummaryCompanion(')
          ..write('userId: $userId, ')
          ..write('periodType: $periodType, ')
          ..write('periodKey: $periodKey, ')
          ..write('totalIncome: $totalIncome, ')
          ..write('totalExpense: $totalExpense, ')
          ..write('txCount: $txCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LifeOsDatabase extends GeneratedDatabase {
  _$LifeOsDatabase(QueryExecutor e) : super(e);
  $LifeOsDatabaseManager get managers => $LifeOsDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $TaskTimeEntriesTable taskTimeEntries = $TaskTimeEntriesTable(
    this,
  );
  late final $EventsTable events = $EventsTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $IncomesTable incomes = $IncomesTable(this);
  late final $BillsTable bills = $BillsTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $RecurringRulesTable recurringRules = $RecurringRulesTable(this);
  late final $FulizaLoansTable fulizaLoans = $FulizaLoansTable(this);
  late final $FulizaEventsTable fulizaEvents = $FulizaEventsTable(this);
  late final $PaybillRegistryTable paybillRegistry = $PaybillRegistryTable(
    this,
  );
  late final $MerchantCategoriesTable merchantCategories =
      $MerchantCategoriesTable(this);
  late final $SmsIngestQueueTable smsIngestQueue = $SmsIngestQueueTable(this);
  late final $SmsReviewQueueTable smsReviewQueue = $SmsReviewQueueTable(this);
  late final $SmsQuarantineTable smsQuarantine = $SmsQuarantineTable(this);
  late final $ImportAuditTable importAudit = $ImportAuditTable(this);
  late final $MlTrainingSamplesTable mlTrainingSamples =
      $MlTrainingSamplesTable(this);
  late final $InsightCardsTable insightCards = $InsightCardsTable(this);
  late final $LearningSessionsTable learningSessions = $LearningSessionsTable(
    this,
  );
  late final $ReviewSnapshotsTable reviewSnapshots = $ReviewSnapshotsTable(
    this,
  );
  late final $AssistantConversationsTable assistantConversations =
      $AssistantConversationsTable(this);
  late final $AssistantMessagesTable assistantMessages =
      $AssistantMessagesTable(this);
  late final $ExportHistoryTable exportHistory = $ExportHistoryTable(this);
  late final $AppUpdateInfoTable appUpdateInfo = $AppUpdateInfoTable(this);
  late final $CategorySummaryTable categorySummary = $CategorySummaryTable(
    this,
  );
  late final $FinanceSummaryTable financeSummary = $FinanceSummaryTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    transactions,
    tasks,
    taskTimeEntries,
    events,
    budgets,
    incomes,
    bills,
    goals,
    recurringRules,
    fulizaLoans,
    fulizaEvents,
    paybillRegistry,
    merchantCategories,
    smsIngestQueue,
    smsReviewQueue,
    smsQuarantine,
    importAudit,
    mlTrainingSamples,
    insightCards,
    learningSessions,
    reviewSnapshots,
    assistantConversations,
    assistantMessages,
    exportHistory,
    appUpdateInfo,
    categorySummary,
    financeSummary,
  ];
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> email,
      Value<String> username,
      required int createdAt,
      Value<String> avatarUrl,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> email,
      Value<String> username,
      Value<int> createdAt,
      Value<String> avatarUrl,
    });

class $$UsersTableFilterComposer
    extends Composer<_$LifeOsDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, BaseReferences<_$LifeOsDatabase, $UsersTable, User>),
          User,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$LifeOsDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> avatarUrl = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                name: name,
                email: email,
                username: username,
                createdAt: createdAt,
                avatarUrl: avatarUrl,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> email = const Value.absent(),
                Value<String> username = const Value.absent(),
                required int createdAt,
                Value<String> avatarUrl = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                name: name,
                email: email,
                username: username,
                createdAt: createdAt,
                avatarUrl: avatarUrl,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, BaseReferences<_$LifeOsDatabase, $UsersTable, User>),
      User,
      PrefetchHooks Function()
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required int id,
      required String userId,
      required double amount,
      required String merchant,
      required String category,
      required int date,
      required String source,
      required String transactionType,
      Value<String?> mpesaCode,
      Value<String?> sourceHash,
      Value<String?> rawSms,
      required int createdAt,
      required int updatedAt,
      required String syncState,
      required String recordSource,
      Value<int?> deletedAt,
      required int revision,
      Value<String?> inferredCategory,
      Value<String?> inferenceSource,
      Value<String?> semanticHash,
      Value<double> confidence,
      Value<String> parseRoute,
      Value<String?> description,
      Value<String?> notes,
      Value<double> fee,
      Value<double?> balanceAfter,
      Value<String> status,
      Value<String> institutionId,
      Value<String?> externalRef,
      Value<String?> rawSender,
      Value<String?> crossRefMpesaCode,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<double> amount,
      Value<String> merchant,
      Value<String> category,
      Value<int> date,
      Value<String> source,
      Value<String> transactionType,
      Value<String?> mpesaCode,
      Value<String?> sourceHash,
      Value<String?> rawSms,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String> syncState,
      Value<String> recordSource,
      Value<int?> deletedAt,
      Value<int> revision,
      Value<String?> inferredCategory,
      Value<String?> inferenceSource,
      Value<String?> semanticHash,
      Value<double> confidence,
      Value<String> parseRoute,
      Value<String?> description,
      Value<String?> notes,
      Value<double> fee,
      Value<double?> balanceAfter,
      Value<String> status,
      Value<String> institutionId,
      Value<String?> externalRef,
      Value<String?> rawSender,
      Value<String?> crossRefMpesaCode,
      Value<int> rowid,
    });

class $$TransactionsTableFilterComposer
    extends Composer<_$LifeOsDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mpesaCode => $composableBuilder(
    column: $table.mpesaCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceHash => $composableBuilder(
    column: $table.sourceHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawSms => $composableBuilder(
    column: $table.rawSms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inferredCategory => $composableBuilder(
    column: $table.inferredCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inferenceSource => $composableBuilder(
    column: $table.inferenceSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get semanticHash => $composableBuilder(
    column: $table.semanticHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parseRoute => $composableBuilder(
    column: $table.parseRoute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fee => $composableBuilder(
    column: $table.fee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalRef => $composableBuilder(
    column: $table.externalRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawSender => $composableBuilder(
    column: $table.rawSender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get crossRefMpesaCode => $composableBuilder(
    column: $table.crossRefMpesaCode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mpesaCode => $composableBuilder(
    column: $table.mpesaCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceHash => $composableBuilder(
    column: $table.sourceHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawSms => $composableBuilder(
    column: $table.rawSms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inferredCategory => $composableBuilder(
    column: $table.inferredCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inferenceSource => $composableBuilder(
    column: $table.inferenceSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get semanticHash => $composableBuilder(
    column: $table.semanticHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parseRoute => $composableBuilder(
    column: $table.parseRoute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fee => $composableBuilder(
    column: $table.fee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalRef => $composableBuilder(
    column: $table.externalRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawSender => $composableBuilder(
    column: $table.rawSender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get crossRefMpesaCode => $composableBuilder(
    column: $table.crossRefMpesaCode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mpesaCode =>
      $composableBuilder(column: $table.mpesaCode, builder: (column) => column);

  GeneratedColumn<String> get sourceHash => $composableBuilder(
    column: $table.sourceHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawSms =>
      $composableBuilder(column: $table.rawSms, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get inferredCategory => $composableBuilder(
    column: $table.inferredCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get inferenceSource => $composableBuilder(
    column: $table.inferenceSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get semanticHash => $composableBuilder(
    column: $table.semanticHash,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parseRoute => $composableBuilder(
    column: $table.parseRoute,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<double> get fee =>
      $composableBuilder(column: $table.fee, builder: (column) => column);

  GeneratedColumn<double> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get externalRef => $composableBuilder(
    column: $table.externalRef,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawSender =>
      $composableBuilder(column: $table.rawSender, builder: (column) => column);

  GeneratedColumn<String> get crossRefMpesaCode => $composableBuilder(
    column: $table.crossRefMpesaCode,
    builder: (column) => column,
  );
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (
            Transaction,
            BaseReferences<_$LifeOsDatabase, $TransactionsTable, Transaction>,
          ),
          Transaction,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableManager(_$LifeOsDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> merchant = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> date = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> transactionType = const Value.absent(),
                Value<String?> mpesaCode = const Value.absent(),
                Value<String?> sourceHash = const Value.absent(),
                Value<String?> rawSms = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String> recordSource = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String?> inferredCategory = const Value.absent(),
                Value<String?> inferenceSource = const Value.absent(),
                Value<String?> semanticHash = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<String> parseRoute = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<double> fee = const Value.absent(),
                Value<double?> balanceAfter = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> institutionId = const Value.absent(),
                Value<String?> externalRef = const Value.absent(),
                Value<String?> rawSender = const Value.absent(),
                Value<String?> crossRefMpesaCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                userId: userId,
                amount: amount,
                merchant: merchant,
                category: category,
                date: date,
                source: source,
                transactionType: transactionType,
                mpesaCode: mpesaCode,
                sourceHash: sourceHash,
                rawSms: rawSms,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncState: syncState,
                recordSource: recordSource,
                deletedAt: deletedAt,
                revision: revision,
                inferredCategory: inferredCategory,
                inferenceSource: inferenceSource,
                semanticHash: semanticHash,
                confidence: confidence,
                parseRoute: parseRoute,
                description: description,
                notes: notes,
                fee: fee,
                balanceAfter: balanceAfter,
                status: status,
                institutionId: institutionId,
                externalRef: externalRef,
                rawSender: rawSender,
                crossRefMpesaCode: crossRefMpesaCode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String userId,
                required double amount,
                required String merchant,
                required String category,
                required int date,
                required String source,
                required String transactionType,
                Value<String?> mpesaCode = const Value.absent(),
                Value<String?> sourceHash = const Value.absent(),
                Value<String?> rawSms = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                required String syncState,
                required String recordSource,
                Value<int?> deletedAt = const Value.absent(),
                required int revision,
                Value<String?> inferredCategory = const Value.absent(),
                Value<String?> inferenceSource = const Value.absent(),
                Value<String?> semanticHash = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<String> parseRoute = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<double> fee = const Value.absent(),
                Value<double?> balanceAfter = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> institutionId = const Value.absent(),
                Value<String?> externalRef = const Value.absent(),
                Value<String?> rawSender = const Value.absent(),
                Value<String?> crossRefMpesaCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                userId: userId,
                amount: amount,
                merchant: merchant,
                category: category,
                date: date,
                source: source,
                transactionType: transactionType,
                mpesaCode: mpesaCode,
                sourceHash: sourceHash,
                rawSms: rawSms,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncState: syncState,
                recordSource: recordSource,
                deletedAt: deletedAt,
                revision: revision,
                inferredCategory: inferredCategory,
                inferenceSource: inferenceSource,
                semanticHash: semanticHash,
                confidence: confidence,
                parseRoute: parseRoute,
                description: description,
                notes: notes,
                fee: fee,
                balanceAfter: balanceAfter,
                status: status,
                institutionId: institutionId,
                externalRef: externalRef,
                rawSender: rawSender,
                crossRefMpesaCode: crossRefMpesaCode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (
        Transaction,
        BaseReferences<_$LifeOsDatabase, $TransactionsTable, Transaction>,
      ),
      Transaction,
      PrefetchHooks Function()
    >;
typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      required int id,
      required String userId,
      required String title,
      required String description,
      required String priority,
      Value<int?> deadline,
      required String status,
      Value<int?> completedAt,
      required int createdAt,
      required int updatedAt,
      Value<String> reminderOffsets,
      Value<bool> alarmEnabled,
      required String syncState,
      required String recordSource,
      Value<int?> deletedAt,
      required int revision,
      Value<int> rowid,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> title,
      Value<String> description,
      Value<String> priority,
      Value<int?> deadline,
      Value<String> status,
      Value<int?> completedAt,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String> reminderOffsets,
      Value<bool> alarmEnabled,
      Value<String> syncState,
      Value<String> recordSource,
      Value<int?> deletedAt,
      Value<int> revision,
      Value<int> rowid,
    });

class $$TasksTableFilterComposer
    extends Composer<_$LifeOsDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderOffsets => $composableBuilder(
    column: $table.reminderOffsets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get alarmEnabled => $composableBuilder(
    column: $table.alarmEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasksTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderOffsets => $composableBuilder(
    column: $table.reminderOffsets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get alarmEnabled => $composableBuilder(
    column: $table.alarmEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get reminderOffsets => $composableBuilder(
    column: $table.reminderOffsets,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get alarmEnabled => $composableBuilder(
    column: $table.alarmEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, BaseReferences<_$LifeOsDatabase, $TasksTable, Task>),
          Task,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$LifeOsDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<int?> deadline = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> reminderOffsets = const Value.absent(),
                Value<bool> alarmEnabled = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String> recordSource = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                userId: userId,
                title: title,
                description: description,
                priority: priority,
                deadline: deadline,
                status: status,
                completedAt: completedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                reminderOffsets: reminderOffsets,
                alarmEnabled: alarmEnabled,
                syncState: syncState,
                recordSource: recordSource,
                deletedAt: deletedAt,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String userId,
                required String title,
                required String description,
                required String priority,
                Value<int?> deadline = const Value.absent(),
                required String status,
                Value<int?> completedAt = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<String> reminderOffsets = const Value.absent(),
                Value<bool> alarmEnabled = const Value.absent(),
                required String syncState,
                required String recordSource,
                Value<int?> deletedAt = const Value.absent(),
                required int revision,
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                userId: userId,
                title: title,
                description: description,
                priority: priority,
                deadline: deadline,
                status: status,
                completedAt: completedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                reminderOffsets: reminderOffsets,
                alarmEnabled: alarmEnabled,
                syncState: syncState,
                recordSource: recordSource,
                deletedAt: deletedAt,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, BaseReferences<_$LifeOsDatabase, $TasksTable, Task>),
      Task,
      PrefetchHooks Function()
    >;
typedef $$TaskTimeEntriesTableCreateCompanionBuilder =
    TaskTimeEntriesCompanion Function({
      required int id,
      required String userId,
      required int taskId,
      required int startedAt,
      Value<int?> endedAt,
      required int durationMinutes,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$TaskTimeEntriesTableUpdateCompanionBuilder =
    TaskTimeEntriesCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<int> taskId,
      Value<int> startedAt,
      Value<int?> endedAt,
      Value<int> durationMinutes,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$TaskTimeEntriesTableFilterComposer
    extends Composer<_$LifeOsDatabase, $TaskTimeEntriesTable> {
  $$TaskTimeEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaskTimeEntriesTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $TaskTimeEntriesTable> {
  $$TaskTimeEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaskTimeEntriesTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $TaskTimeEntriesTable> {
  $$TaskTimeEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TaskTimeEntriesTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $TaskTimeEntriesTable,
          TaskTimeEntry,
          $$TaskTimeEntriesTableFilterComposer,
          $$TaskTimeEntriesTableOrderingComposer,
          $$TaskTimeEntriesTableAnnotationComposer,
          $$TaskTimeEntriesTableCreateCompanionBuilder,
          $$TaskTimeEntriesTableUpdateCompanionBuilder,
          (
            TaskTimeEntry,
            BaseReferences<
              _$LifeOsDatabase,
              $TaskTimeEntriesTable,
              TaskTimeEntry
            >,
          ),
          TaskTimeEntry,
          PrefetchHooks Function()
        > {
  $$TaskTimeEntriesTableTableManager(
    _$LifeOsDatabase db,
    $TaskTimeEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskTimeEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskTimeEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskTimeEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> taskId = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int?> endedAt = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskTimeEntriesCompanion(
                id: id,
                userId: userId,
                taskId: taskId,
                startedAt: startedAt,
                endedAt: endedAt,
                durationMinutes: durationMinutes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String userId,
                required int taskId,
                required int startedAt,
                Value<int?> endedAt = const Value.absent(),
                required int durationMinutes,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TaskTimeEntriesCompanion.insert(
                id: id,
                userId: userId,
                taskId: taskId,
                startedAt: startedAt,
                endedAt: endedAt,
                durationMinutes: durationMinutes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaskTimeEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $TaskTimeEntriesTable,
      TaskTimeEntry,
      $$TaskTimeEntriesTableFilterComposer,
      $$TaskTimeEntriesTableOrderingComposer,
      $$TaskTimeEntriesTableAnnotationComposer,
      $$TaskTimeEntriesTableCreateCompanionBuilder,
      $$TaskTimeEntriesTableUpdateCompanionBuilder,
      (
        TaskTimeEntry,
        BaseReferences<_$LifeOsDatabase, $TaskTimeEntriesTable, TaskTimeEntry>,
      ),
      TaskTimeEntry,
      PrefetchHooks Function()
    >;
typedef $$EventsTableCreateCompanionBuilder =
    EventsCompanion Function({
      required int id,
      required String userId,
      required String title,
      required String description,
      required int date,
      Value<int?> endDate,
      required String type,
      required String importance,
      required String status,
      required bool hasReminder,
      required int reminderMinutesBefore,
      required int createdAt,
      Value<String> kind,
      Value<bool> allDay,
      Value<String> repeatRule,
      Value<String> reminderOffsets,
      Value<bool> alarmEnabled,
      Value<String> guests,
      Value<String> timeZoneId,
      Value<int> reminderTimeOfDayMinutes,
      required int updatedAt,
      required String syncState,
      required String recordSource,
      Value<int?> deletedAt,
      required int revision,
      Value<int> rowid,
    });
typedef $$EventsTableUpdateCompanionBuilder =
    EventsCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> title,
      Value<String> description,
      Value<int> date,
      Value<int?> endDate,
      Value<String> type,
      Value<String> importance,
      Value<String> status,
      Value<bool> hasReminder,
      Value<int> reminderMinutesBefore,
      Value<int> createdAt,
      Value<String> kind,
      Value<bool> allDay,
      Value<String> repeatRule,
      Value<String> reminderOffsets,
      Value<bool> alarmEnabled,
      Value<String> guests,
      Value<String> timeZoneId,
      Value<int> reminderTimeOfDayMinutes,
      Value<int> updatedAt,
      Value<String> syncState,
      Value<String> recordSource,
      Value<int?> deletedAt,
      Value<int> revision,
      Value<int> rowid,
    });

class $$EventsTableFilterComposer
    extends Composer<_$LifeOsDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get importance => $composableBuilder(
    column: $table.importance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasReminder => $composableBuilder(
    column: $table.hasReminder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderMinutesBefore => $composableBuilder(
    column: $table.reminderMinutesBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allDay => $composableBuilder(
    column: $table.allDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderOffsets => $composableBuilder(
    column: $table.reminderOffsets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get alarmEnabled => $composableBuilder(
    column: $table.alarmEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guests => $composableBuilder(
    column: $table.guests,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeZoneId => $composableBuilder(
    column: $table.timeZoneId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderTimeOfDayMinutes => $composableBuilder(
    column: $table.reminderTimeOfDayMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EventsTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get importance => $composableBuilder(
    column: $table.importance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasReminder => $composableBuilder(
    column: $table.hasReminder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderMinutesBefore => $composableBuilder(
    column: $table.reminderMinutesBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allDay => $composableBuilder(
    column: $table.allDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderOffsets => $composableBuilder(
    column: $table.reminderOffsets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get alarmEnabled => $composableBuilder(
    column: $table.alarmEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guests => $composableBuilder(
    column: $table.guests,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeZoneId => $composableBuilder(
    column: $table.timeZoneId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderTimeOfDayMinutes => $composableBuilder(
    column: $table.reminderTimeOfDayMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventsTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get importance => $composableBuilder(
    column: $table.importance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get hasReminder => $composableBuilder(
    column: $table.hasReminder,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderMinutesBefore => $composableBuilder(
    column: $table.reminderMinutesBefore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<bool> get allDay =>
      $composableBuilder(column: $table.allDay, builder: (column) => column);

  GeneratedColumn<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reminderOffsets => $composableBuilder(
    column: $table.reminderOffsets,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get alarmEnabled => $composableBuilder(
    column: $table.alarmEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get guests =>
      $composableBuilder(column: $table.guests, builder: (column) => column);

  GeneratedColumn<String> get timeZoneId => $composableBuilder(
    column: $table.timeZoneId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderTimeOfDayMinutes => $composableBuilder(
    column: $table.reminderTimeOfDayMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$EventsTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $EventsTable,
          Event,
          $$EventsTableFilterComposer,
          $$EventsTableOrderingComposer,
          $$EventsTableAnnotationComposer,
          $$EventsTableCreateCompanionBuilder,
          $$EventsTableUpdateCompanionBuilder,
          (Event, BaseReferences<_$LifeOsDatabase, $EventsTable, Event>),
          Event,
          PrefetchHooks Function()
        > {
  $$EventsTableTableManager(_$LifeOsDatabase db, $EventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> date = const Value.absent(),
                Value<int?> endDate = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> importance = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> hasReminder = const Value.absent(),
                Value<int> reminderMinutesBefore = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<bool> allDay = const Value.absent(),
                Value<String> repeatRule = const Value.absent(),
                Value<String> reminderOffsets = const Value.absent(),
                Value<bool> alarmEnabled = const Value.absent(),
                Value<String> guests = const Value.absent(),
                Value<String> timeZoneId = const Value.absent(),
                Value<int> reminderTimeOfDayMinutes = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String> recordSource = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventsCompanion(
                id: id,
                userId: userId,
                title: title,
                description: description,
                date: date,
                endDate: endDate,
                type: type,
                importance: importance,
                status: status,
                hasReminder: hasReminder,
                reminderMinutesBefore: reminderMinutesBefore,
                createdAt: createdAt,
                kind: kind,
                allDay: allDay,
                repeatRule: repeatRule,
                reminderOffsets: reminderOffsets,
                alarmEnabled: alarmEnabled,
                guests: guests,
                timeZoneId: timeZoneId,
                reminderTimeOfDayMinutes: reminderTimeOfDayMinutes,
                updatedAt: updatedAt,
                syncState: syncState,
                recordSource: recordSource,
                deletedAt: deletedAt,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String userId,
                required String title,
                required String description,
                required int date,
                Value<int?> endDate = const Value.absent(),
                required String type,
                required String importance,
                required String status,
                required bool hasReminder,
                required int reminderMinutesBefore,
                required int createdAt,
                Value<String> kind = const Value.absent(),
                Value<bool> allDay = const Value.absent(),
                Value<String> repeatRule = const Value.absent(),
                Value<String> reminderOffsets = const Value.absent(),
                Value<bool> alarmEnabled = const Value.absent(),
                Value<String> guests = const Value.absent(),
                Value<String> timeZoneId = const Value.absent(),
                Value<int> reminderTimeOfDayMinutes = const Value.absent(),
                required int updatedAt,
                required String syncState,
                required String recordSource,
                Value<int?> deletedAt = const Value.absent(),
                required int revision,
                Value<int> rowid = const Value.absent(),
              }) => EventsCompanion.insert(
                id: id,
                userId: userId,
                title: title,
                description: description,
                date: date,
                endDate: endDate,
                type: type,
                importance: importance,
                status: status,
                hasReminder: hasReminder,
                reminderMinutesBefore: reminderMinutesBefore,
                createdAt: createdAt,
                kind: kind,
                allDay: allDay,
                repeatRule: repeatRule,
                reminderOffsets: reminderOffsets,
                alarmEnabled: alarmEnabled,
                guests: guests,
                timeZoneId: timeZoneId,
                reminderTimeOfDayMinutes: reminderTimeOfDayMinutes,
                updatedAt: updatedAt,
                syncState: syncState,
                recordSource: recordSource,
                deletedAt: deletedAt,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EventsTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $EventsTable,
      Event,
      $$EventsTableFilterComposer,
      $$EventsTableOrderingComposer,
      $$EventsTableAnnotationComposer,
      $$EventsTableCreateCompanionBuilder,
      $$EventsTableUpdateCompanionBuilder,
      (Event, BaseReferences<_$LifeOsDatabase, $EventsTable, Event>),
      Event,
      PrefetchHooks Function()
    >;
typedef $$BudgetsTableCreateCompanionBuilder =
    BudgetsCompanion Function({
      required int id,
      required String userId,
      required String category,
      required double limitAmount,
      required String period,
      Value<double?> alertThreshold,
      required int createdAt,
      required int updatedAt,
      required String syncState,
      required String recordSource,
      Value<int?> deletedAt,
      required int revision,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$BudgetsTableUpdateCompanionBuilder =
    BudgetsCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> category,
      Value<double> limitAmount,
      Value<String> period,
      Value<double?> alertThreshold,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String> syncState,
      Value<String> recordSource,
      Value<int?> deletedAt,
      Value<int> revision,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$BudgetsTableFilterComposer
    extends Composer<_$LifeOsDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get limitAmount => $composableBuilder(
    column: $table.limitAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get alertThreshold => $composableBuilder(
    column: $table.alertThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get limitAmount => $composableBuilder(
    column: $table.limitAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get alertThreshold => $composableBuilder(
    column: $table.alertThreshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get limitAmount => $composableBuilder(
    column: $table.limitAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<double> get alertThreshold => $composableBuilder(
    column: $table.alertThreshold,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$BudgetsTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $BudgetsTable,
          Budget,
          $$BudgetsTableFilterComposer,
          $$BudgetsTableOrderingComposer,
          $$BudgetsTableAnnotationComposer,
          $$BudgetsTableCreateCompanionBuilder,
          $$BudgetsTableUpdateCompanionBuilder,
          (Budget, BaseReferences<_$LifeOsDatabase, $BudgetsTable, Budget>),
          Budget,
          PrefetchHooks Function()
        > {
  $$BudgetsTableTableManager(_$LifeOsDatabase db, $BudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> limitAmount = const Value.absent(),
                Value<String> period = const Value.absent(),
                Value<double?> alertThreshold = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String> recordSource = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion(
                id: id,
                userId: userId,
                category: category,
                limitAmount: limitAmount,
                period: period,
                alertThreshold: alertThreshold,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncState: syncState,
                recordSource: recordSource,
                deletedAt: deletedAt,
                revision: revision,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String userId,
                required String category,
                required double limitAmount,
                required String period,
                Value<double?> alertThreshold = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                required String syncState,
                required String recordSource,
                Value<int?> deletedAt = const Value.absent(),
                required int revision,
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion.insert(
                id: id,
                userId: userId,
                category: category,
                limitAmount: limitAmount,
                period: period,
                alertThreshold: alertThreshold,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncState: syncState,
                recordSource: recordSource,
                deletedAt: deletedAt,
                revision: revision,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $BudgetsTable,
      Budget,
      $$BudgetsTableFilterComposer,
      $$BudgetsTableOrderingComposer,
      $$BudgetsTableAnnotationComposer,
      $$BudgetsTableCreateCompanionBuilder,
      $$BudgetsTableUpdateCompanionBuilder,
      (Budget, BaseReferences<_$LifeOsDatabase, $BudgetsTable, Budget>),
      Budget,
      PrefetchHooks Function()
    >;
typedef $$IncomesTableCreateCompanionBuilder =
    IncomesCompanion Function({
      required int id,
      required String userId,
      required double amount,
      required String source,
      required int date,
      required String note,
      required bool isRecurring,
      Value<String?> frequency,
      required int createdAt,
      required int updatedAt,
      required String syncState,
      required String recordSource,
      Value<int?> deletedAt,
      required int revision,
      Value<int> rowid,
    });
typedef $$IncomesTableUpdateCompanionBuilder =
    IncomesCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<double> amount,
      Value<String> source,
      Value<int> date,
      Value<String> note,
      Value<bool> isRecurring,
      Value<String?> frequency,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String> syncState,
      Value<String> recordSource,
      Value<int?> deletedAt,
      Value<int> revision,
      Value<int> rowid,
    });

class $$IncomesTableFilterComposer
    extends Composer<_$LifeOsDatabase, $IncomesTable> {
  $$IncomesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IncomesTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $IncomesTable> {
  $$IncomesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IncomesTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $IncomesTable> {
  $$IncomesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => column,
  );

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$IncomesTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $IncomesTable,
          Income,
          $$IncomesTableFilterComposer,
          $$IncomesTableOrderingComposer,
          $$IncomesTableAnnotationComposer,
          $$IncomesTableCreateCompanionBuilder,
          $$IncomesTableUpdateCompanionBuilder,
          (Income, BaseReferences<_$LifeOsDatabase, $IncomesTable, Income>),
          Income,
          PrefetchHooks Function()
        > {
  $$IncomesTableTableManager(_$LifeOsDatabase db, $IncomesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IncomesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IncomesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IncomesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> date = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<bool> isRecurring = const Value.absent(),
                Value<String?> frequency = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String> recordSource = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IncomesCompanion(
                id: id,
                userId: userId,
                amount: amount,
                source: source,
                date: date,
                note: note,
                isRecurring: isRecurring,
                frequency: frequency,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncState: syncState,
                recordSource: recordSource,
                deletedAt: deletedAt,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String userId,
                required double amount,
                required String source,
                required int date,
                required String note,
                required bool isRecurring,
                Value<String?> frequency = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                required String syncState,
                required String recordSource,
                Value<int?> deletedAt = const Value.absent(),
                required int revision,
                Value<int> rowid = const Value.absent(),
              }) => IncomesCompanion.insert(
                id: id,
                userId: userId,
                amount: amount,
                source: source,
                date: date,
                note: note,
                isRecurring: isRecurring,
                frequency: frequency,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncState: syncState,
                recordSource: recordSource,
                deletedAt: deletedAt,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IncomesTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $IncomesTable,
      Income,
      $$IncomesTableFilterComposer,
      $$IncomesTableOrderingComposer,
      $$IncomesTableAnnotationComposer,
      $$IncomesTableCreateCompanionBuilder,
      $$IncomesTableUpdateCompanionBuilder,
      (Income, BaseReferences<_$LifeOsDatabase, $IncomesTable, Income>),
      Income,
      PrefetchHooks Function()
    >;
typedef $$BillsTableCreateCompanionBuilder =
    BillsCompanion Function({
      required int id,
      required String userId,
      required String title,
      required double amount,
      required String cycle,
      required int nextDueDate,
      Value<int?> lastPaidAt,
      required String notes,
      required bool isActive,
      Value<bool> paidStatus,
      required int createdAt,
      required int updatedAt,
      required String syncState,
      Value<int?> deletedAt,
      Value<int> rowid,
    });
typedef $$BillsTableUpdateCompanionBuilder =
    BillsCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> title,
      Value<double> amount,
      Value<String> cycle,
      Value<int> nextDueDate,
      Value<int?> lastPaidAt,
      Value<String> notes,
      Value<bool> isActive,
      Value<bool> paidStatus,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String> syncState,
      Value<int?> deletedAt,
      Value<int> rowid,
    });

class $$BillsTableFilterComposer
    extends Composer<_$LifeOsDatabase, $BillsTable> {
  $$BillsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cycle => $composableBuilder(
    column: $table.cycle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPaidAt => $composableBuilder(
    column: $table.lastPaidAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get paidStatus => $composableBuilder(
    column: $table.paidStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BillsTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $BillsTable> {
  $$BillsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cycle => $composableBuilder(
    column: $table.cycle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPaidAt => $composableBuilder(
    column: $table.lastPaidAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get paidStatus => $composableBuilder(
    column: $table.paidStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BillsTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $BillsTable> {
  $$BillsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get cycle =>
      $composableBuilder(column: $table.cycle, builder: (column) => column);

  GeneratedColumn<int> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastPaidAt => $composableBuilder(
    column: $table.lastPaidAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get paidStatus => $composableBuilder(
    column: $table.paidStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$BillsTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $BillsTable,
          Bill,
          $$BillsTableFilterComposer,
          $$BillsTableOrderingComposer,
          $$BillsTableAnnotationComposer,
          $$BillsTableCreateCompanionBuilder,
          $$BillsTableUpdateCompanionBuilder,
          (Bill, BaseReferences<_$LifeOsDatabase, $BillsTable, Bill>),
          Bill,
          PrefetchHooks Function()
        > {
  $$BillsTableTableManager(_$LifeOsDatabase db, $BillsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BillsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BillsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BillsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> cycle = const Value.absent(),
                Value<int> nextDueDate = const Value.absent(),
                Value<int?> lastPaidAt = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> paidStatus = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BillsCompanion(
                id: id,
                userId: userId,
                title: title,
                amount: amount,
                cycle: cycle,
                nextDueDate: nextDueDate,
                lastPaidAt: lastPaidAt,
                notes: notes,
                isActive: isActive,
                paidStatus: paidStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncState: syncState,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String userId,
                required String title,
                required double amount,
                required String cycle,
                required int nextDueDate,
                Value<int?> lastPaidAt = const Value.absent(),
                required String notes,
                required bool isActive,
                Value<bool> paidStatus = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                required String syncState,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BillsCompanion.insert(
                id: id,
                userId: userId,
                title: title,
                amount: amount,
                cycle: cycle,
                nextDueDate: nextDueDate,
                lastPaidAt: lastPaidAt,
                notes: notes,
                isActive: isActive,
                paidStatus: paidStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncState: syncState,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BillsTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $BillsTable,
      Bill,
      $$BillsTableFilterComposer,
      $$BillsTableOrderingComposer,
      $$BillsTableAnnotationComposer,
      $$BillsTableCreateCompanionBuilder,
      $$BillsTableUpdateCompanionBuilder,
      (Bill, BaseReferences<_$LifeOsDatabase, $BillsTable, Bill>),
      Bill,
      PrefetchHooks Function()
    >;
typedef $$GoalsTableCreateCompanionBuilder =
    GoalsCompanion Function({
      required int id,
      required String userId,
      required String title,
      required String description,
      required double targetValue,
      required double currentValue,
      required String unit,
      required String category,
      Value<int?> deadline,
      required String status,
      required int createdAt,
      required int updatedAt,
      required String syncState,
      Value<int?> deletedAt,
      required int revision,
      Value<int> rowid,
    });
typedef $$GoalsTableUpdateCompanionBuilder =
    GoalsCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> title,
      Value<String> description,
      Value<double> targetValue,
      Value<double> currentValue,
      Value<String> unit,
      Value<String> category,
      Value<int?> deadline,
      Value<String> status,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String> syncState,
      Value<int?> deletedAt,
      Value<int> revision,
      Value<int> rowid,
    });

class $$GoalsTableFilterComposer
    extends Composer<_$LifeOsDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GoalsTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$GoalsTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $GoalsTable,
          Goal,
          $$GoalsTableFilterComposer,
          $$GoalsTableOrderingComposer,
          $$GoalsTableAnnotationComposer,
          $$GoalsTableCreateCompanionBuilder,
          $$GoalsTableUpdateCompanionBuilder,
          (Goal, BaseReferences<_$LifeOsDatabase, $GoalsTable, Goal>),
          Goal,
          PrefetchHooks Function()
        > {
  $$GoalsTableTableManager(_$LifeOsDatabase db, $GoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<double> targetValue = const Value.absent(),
                Value<double> currentValue = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int?> deadline = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion(
                id: id,
                userId: userId,
                title: title,
                description: description,
                targetValue: targetValue,
                currentValue: currentValue,
                unit: unit,
                category: category,
                deadline: deadline,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncState: syncState,
                deletedAt: deletedAt,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String userId,
                required String title,
                required String description,
                required double targetValue,
                required double currentValue,
                required String unit,
                required String category,
                Value<int?> deadline = const Value.absent(),
                required String status,
                required int createdAt,
                required int updatedAt,
                required String syncState,
                Value<int?> deletedAt = const Value.absent(),
                required int revision,
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion.insert(
                id: id,
                userId: userId,
                title: title,
                description: description,
                targetValue: targetValue,
                currentValue: currentValue,
                unit: unit,
                category: category,
                deadline: deadline,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncState: syncState,
                deletedAt: deletedAt,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $GoalsTable,
      Goal,
      $$GoalsTableFilterComposer,
      $$GoalsTableOrderingComposer,
      $$GoalsTableAnnotationComposer,
      $$GoalsTableCreateCompanionBuilder,
      $$GoalsTableUpdateCompanionBuilder,
      (Goal, BaseReferences<_$LifeOsDatabase, $GoalsTable, Goal>),
      Goal,
      PrefetchHooks Function()
    >;
typedef $$RecurringRulesTableCreateCompanionBuilder =
    RecurringRulesCompanion Function({
      required int id,
      required String userId,
      required String title,
      required String type,
      required String cadence,
      required int nextRunAt,
      Value<double?> amount,
      Value<String> category,
      required bool enabled,
      required int createdAt,
      required int updatedAt,
      required String syncState,
      required String recordSource,
      Value<int?> deletedAt,
      required int revision,
      Value<int> rowid,
    });
typedef $$RecurringRulesTableUpdateCompanionBuilder =
    RecurringRulesCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> title,
      Value<String> type,
      Value<String> cadence,
      Value<int> nextRunAt,
      Value<double?> amount,
      Value<String> category,
      Value<bool> enabled,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String> syncState,
      Value<String> recordSource,
      Value<int?> deletedAt,
      Value<int> revision,
      Value<int> rowid,
    });

class $$RecurringRulesTableFilterComposer
    extends Composer<_$LifeOsDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cadence => $composableBuilder(
    column: $table.cadence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextRunAt => $composableBuilder(
    column: $table.nextRunAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecurringRulesTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cadence => $composableBuilder(
    column: $table.cadence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextRunAt => $composableBuilder(
    column: $table.nextRunAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecurringRulesTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get cadence =>
      $composableBuilder(column: $table.cadence, builder: (column) => column);

  GeneratedColumn<int> get nextRunAt =>
      $composableBuilder(column: $table.nextRunAt, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$RecurringRulesTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $RecurringRulesTable,
          RecurringRule,
          $$RecurringRulesTableFilterComposer,
          $$RecurringRulesTableOrderingComposer,
          $$RecurringRulesTableAnnotationComposer,
          $$RecurringRulesTableCreateCompanionBuilder,
          $$RecurringRulesTableUpdateCompanionBuilder,
          (
            RecurringRule,
            BaseReferences<
              _$LifeOsDatabase,
              $RecurringRulesTable,
              RecurringRule
            >,
          ),
          RecurringRule,
          PrefetchHooks Function()
        > {
  $$RecurringRulesTableTableManager(
    _$LifeOsDatabase db,
    $RecurringRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> cadence = const Value.absent(),
                Value<int> nextRunAt = const Value.absent(),
                Value<double?> amount = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String> recordSource = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringRulesCompanion(
                id: id,
                userId: userId,
                title: title,
                type: type,
                cadence: cadence,
                nextRunAt: nextRunAt,
                amount: amount,
                category: category,
                enabled: enabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncState: syncState,
                recordSource: recordSource,
                deletedAt: deletedAt,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String userId,
                required String title,
                required String type,
                required String cadence,
                required int nextRunAt,
                Value<double?> amount = const Value.absent(),
                Value<String> category = const Value.absent(),
                required bool enabled,
                required int createdAt,
                required int updatedAt,
                required String syncState,
                required String recordSource,
                Value<int?> deletedAt = const Value.absent(),
                required int revision,
                Value<int> rowid = const Value.absent(),
              }) => RecurringRulesCompanion.insert(
                id: id,
                userId: userId,
                title: title,
                type: type,
                cadence: cadence,
                nextRunAt: nextRunAt,
                amount: amount,
                category: category,
                enabled: enabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncState: syncState,
                recordSource: recordSource,
                deletedAt: deletedAt,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecurringRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $RecurringRulesTable,
      RecurringRule,
      $$RecurringRulesTableFilterComposer,
      $$RecurringRulesTableOrderingComposer,
      $$RecurringRulesTableAnnotationComposer,
      $$RecurringRulesTableCreateCompanionBuilder,
      $$RecurringRulesTableUpdateCompanionBuilder,
      (
        RecurringRule,
        BaseReferences<_$LifeOsDatabase, $RecurringRulesTable, RecurringRule>,
      ),
      RecurringRule,
      PrefetchHooks Function()
    >;
typedef $$FulizaLoansTableCreateCompanionBuilder =
    FulizaLoansCompanion Function({
      required int id,
      required String userId,
      required String drawCode,
      required double drawAmountKes,
      required double totalRepaidKes,
      required String status,
      required int drawDate,
      Value<int?> lastRepaymentDate,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$FulizaLoansTableUpdateCompanionBuilder =
    FulizaLoansCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> drawCode,
      Value<double> drawAmountKes,
      Value<double> totalRepaidKes,
      Value<String> status,
      Value<int> drawDate,
      Value<int?> lastRepaymentDate,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$FulizaLoansTableFilterComposer
    extends Composer<_$LifeOsDatabase, $FulizaLoansTable> {
  $$FulizaLoansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get drawCode => $composableBuilder(
    column: $table.drawCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get drawAmountKes => $composableBuilder(
    column: $table.drawAmountKes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalRepaidKes => $composableBuilder(
    column: $table.totalRepaidKes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get drawDate => $composableBuilder(
    column: $table.drawDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastRepaymentDate => $composableBuilder(
    column: $table.lastRepaymentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FulizaLoansTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $FulizaLoansTable> {
  $$FulizaLoansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get drawCode => $composableBuilder(
    column: $table.drawCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get drawAmountKes => $composableBuilder(
    column: $table.drawAmountKes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalRepaidKes => $composableBuilder(
    column: $table.totalRepaidKes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get drawDate => $composableBuilder(
    column: $table.drawDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastRepaymentDate => $composableBuilder(
    column: $table.lastRepaymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FulizaLoansTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $FulizaLoansTable> {
  $$FulizaLoansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get drawCode =>
      $composableBuilder(column: $table.drawCode, builder: (column) => column);

  GeneratedColumn<double> get drawAmountKes => $composableBuilder(
    column: $table.drawAmountKes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalRepaidKes => $composableBuilder(
    column: $table.totalRepaidKes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get drawDate =>
      $composableBuilder(column: $table.drawDate, builder: (column) => column);

  GeneratedColumn<int> get lastRepaymentDate => $composableBuilder(
    column: $table.lastRepaymentDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FulizaLoansTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $FulizaLoansTable,
          FulizaLoan,
          $$FulizaLoansTableFilterComposer,
          $$FulizaLoansTableOrderingComposer,
          $$FulizaLoansTableAnnotationComposer,
          $$FulizaLoansTableCreateCompanionBuilder,
          $$FulizaLoansTableUpdateCompanionBuilder,
          (
            FulizaLoan,
            BaseReferences<_$LifeOsDatabase, $FulizaLoansTable, FulizaLoan>,
          ),
          FulizaLoan,
          PrefetchHooks Function()
        > {
  $$FulizaLoansTableTableManager(_$LifeOsDatabase db, $FulizaLoansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FulizaLoansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FulizaLoansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FulizaLoansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> drawCode = const Value.absent(),
                Value<double> drawAmountKes = const Value.absent(),
                Value<double> totalRepaidKes = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> drawDate = const Value.absent(),
                Value<int?> lastRepaymentDate = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FulizaLoansCompanion(
                id: id,
                userId: userId,
                drawCode: drawCode,
                drawAmountKes: drawAmountKes,
                totalRepaidKes: totalRepaidKes,
                status: status,
                drawDate: drawDate,
                lastRepaymentDate: lastRepaymentDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String userId,
                required String drawCode,
                required double drawAmountKes,
                required double totalRepaidKes,
                required String status,
                required int drawDate,
                Value<int?> lastRepaymentDate = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FulizaLoansCompanion.insert(
                id: id,
                userId: userId,
                drawCode: drawCode,
                drawAmountKes: drawAmountKes,
                totalRepaidKes: totalRepaidKes,
                status: status,
                drawDate: drawDate,
                lastRepaymentDate: lastRepaymentDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FulizaLoansTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $FulizaLoansTable,
      FulizaLoan,
      $$FulizaLoansTableFilterComposer,
      $$FulizaLoansTableOrderingComposer,
      $$FulizaLoansTableAnnotationComposer,
      $$FulizaLoansTableCreateCompanionBuilder,
      $$FulizaLoansTableUpdateCompanionBuilder,
      (
        FulizaLoan,
        BaseReferences<_$LifeOsDatabase, $FulizaLoansTable, FulizaLoan>,
      ),
      FulizaLoan,
      PrefetchHooks Function()
    >;
typedef $$FulizaEventsTableCreateCompanionBuilder =
    FulizaEventsCompanion Function({
      Value<int> id,
      required String userId,
      required String eventType,
      required String mpesaCode,
      required double amountKes,
      Value<double> outstandingAfter,
      required int eventAt,
      required int createdAt,
    });
typedef $$FulizaEventsTableUpdateCompanionBuilder =
    FulizaEventsCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> eventType,
      Value<String> mpesaCode,
      Value<double> amountKes,
      Value<double> outstandingAfter,
      Value<int> eventAt,
      Value<int> createdAt,
    });

class $$FulizaEventsTableFilterComposer
    extends Composer<_$LifeOsDatabase, $FulizaEventsTable> {
  $$FulizaEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mpesaCode => $composableBuilder(
    column: $table.mpesaCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountKes => $composableBuilder(
    column: $table.amountKes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get outstandingAfter => $composableBuilder(
    column: $table.outstandingAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eventAt => $composableBuilder(
    column: $table.eventAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FulizaEventsTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $FulizaEventsTable> {
  $$FulizaEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mpesaCode => $composableBuilder(
    column: $table.mpesaCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountKes => $composableBuilder(
    column: $table.amountKes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get outstandingAfter => $composableBuilder(
    column: $table.outstandingAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eventAt => $composableBuilder(
    column: $table.eventAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FulizaEventsTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $FulizaEventsTable> {
  $$FulizaEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get mpesaCode =>
      $composableBuilder(column: $table.mpesaCode, builder: (column) => column);

  GeneratedColumn<double> get amountKes =>
      $composableBuilder(column: $table.amountKes, builder: (column) => column);

  GeneratedColumn<double> get outstandingAfter => $composableBuilder(
    column: $table.outstandingAfter,
    builder: (column) => column,
  );

  GeneratedColumn<int> get eventAt =>
      $composableBuilder(column: $table.eventAt, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FulizaEventsTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $FulizaEventsTable,
          FulizaEvent,
          $$FulizaEventsTableFilterComposer,
          $$FulizaEventsTableOrderingComposer,
          $$FulizaEventsTableAnnotationComposer,
          $$FulizaEventsTableCreateCompanionBuilder,
          $$FulizaEventsTableUpdateCompanionBuilder,
          (
            FulizaEvent,
            BaseReferences<_$LifeOsDatabase, $FulizaEventsTable, FulizaEvent>,
          ),
          FulizaEvent,
          PrefetchHooks Function()
        > {
  $$FulizaEventsTableTableManager(_$LifeOsDatabase db, $FulizaEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FulizaEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FulizaEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FulizaEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String> mpesaCode = const Value.absent(),
                Value<double> amountKes = const Value.absent(),
                Value<double> outstandingAfter = const Value.absent(),
                Value<int> eventAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => FulizaEventsCompanion(
                id: id,
                userId: userId,
                eventType: eventType,
                mpesaCode: mpesaCode,
                amountKes: amountKes,
                outstandingAfter: outstandingAfter,
                eventAt: eventAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required String eventType,
                required String mpesaCode,
                required double amountKes,
                Value<double> outstandingAfter = const Value.absent(),
                required int eventAt,
                required int createdAt,
              }) => FulizaEventsCompanion.insert(
                id: id,
                userId: userId,
                eventType: eventType,
                mpesaCode: mpesaCode,
                amountKes: amountKes,
                outstandingAfter: outstandingAfter,
                eventAt: eventAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FulizaEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $FulizaEventsTable,
      FulizaEvent,
      $$FulizaEventsTableFilterComposer,
      $$FulizaEventsTableOrderingComposer,
      $$FulizaEventsTableAnnotationComposer,
      $$FulizaEventsTableCreateCompanionBuilder,
      $$FulizaEventsTableUpdateCompanionBuilder,
      (
        FulizaEvent,
        BaseReferences<_$LifeOsDatabase, $FulizaEventsTable, FulizaEvent>,
      ),
      FulizaEvent,
      PrefetchHooks Function()
    >;
typedef $$PaybillRegistryTableCreateCompanionBuilder =
    PaybillRegistryCompanion Function({
      required String paybillNumber,
      required String userId,
      required String displayName,
      required int lastSeenAt,
      required int usageCount,
      required double lastAmountKes,
      Value<int> rowid,
    });
typedef $$PaybillRegistryTableUpdateCompanionBuilder =
    PaybillRegistryCompanion Function({
      Value<String> paybillNumber,
      Value<String> userId,
      Value<String> displayName,
      Value<int> lastSeenAt,
      Value<int> usageCount,
      Value<double> lastAmountKes,
      Value<int> rowid,
    });

class $$PaybillRegistryTableFilterComposer
    extends Composer<_$LifeOsDatabase, $PaybillRegistryTable> {
  $$PaybillRegistryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get paybillNumber => $composableBuilder(
    column: $table.paybillNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lastAmountKes => $composableBuilder(
    column: $table.lastAmountKes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PaybillRegistryTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $PaybillRegistryTable> {
  $$PaybillRegistryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get paybillNumber => $composableBuilder(
    column: $table.paybillNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lastAmountKes => $composableBuilder(
    column: $table.lastAmountKes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PaybillRegistryTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $PaybillRegistryTable> {
  $$PaybillRegistryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get paybillNumber => $composableBuilder(
    column: $table.paybillNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lastAmountKes => $composableBuilder(
    column: $table.lastAmountKes,
    builder: (column) => column,
  );
}

class $$PaybillRegistryTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $PaybillRegistryTable,
          PaybillRegistryData,
          $$PaybillRegistryTableFilterComposer,
          $$PaybillRegistryTableOrderingComposer,
          $$PaybillRegistryTableAnnotationComposer,
          $$PaybillRegistryTableCreateCompanionBuilder,
          $$PaybillRegistryTableUpdateCompanionBuilder,
          (
            PaybillRegistryData,
            BaseReferences<
              _$LifeOsDatabase,
              $PaybillRegistryTable,
              PaybillRegistryData
            >,
          ),
          PaybillRegistryData,
          PrefetchHooks Function()
        > {
  $$PaybillRegistryTableTableManager(
    _$LifeOsDatabase db,
    $PaybillRegistryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaybillRegistryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaybillRegistryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaybillRegistryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> paybillNumber = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<int> lastSeenAt = const Value.absent(),
                Value<int> usageCount = const Value.absent(),
                Value<double> lastAmountKes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaybillRegistryCompanion(
                paybillNumber: paybillNumber,
                userId: userId,
                displayName: displayName,
                lastSeenAt: lastSeenAt,
                usageCount: usageCount,
                lastAmountKes: lastAmountKes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String paybillNumber,
                required String userId,
                required String displayName,
                required int lastSeenAt,
                required int usageCount,
                required double lastAmountKes,
                Value<int> rowid = const Value.absent(),
              }) => PaybillRegistryCompanion.insert(
                paybillNumber: paybillNumber,
                userId: userId,
                displayName: displayName,
                lastSeenAt: lastSeenAt,
                usageCount: usageCount,
                lastAmountKes: lastAmountKes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PaybillRegistryTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $PaybillRegistryTable,
      PaybillRegistryData,
      $$PaybillRegistryTableFilterComposer,
      $$PaybillRegistryTableOrderingComposer,
      $$PaybillRegistryTableAnnotationComposer,
      $$PaybillRegistryTableCreateCompanionBuilder,
      $$PaybillRegistryTableUpdateCompanionBuilder,
      (
        PaybillRegistryData,
        BaseReferences<
          _$LifeOsDatabase,
          $PaybillRegistryTable,
          PaybillRegistryData
        >,
      ),
      PaybillRegistryData,
      PrefetchHooks Function()
    >;
typedef $$MerchantCategoriesTableCreateCompanionBuilder =
    MerchantCategoriesCompanion Function({
      required int id,
      required String userId,
      required String merchant,
      required String category,
      required double confidence,
      required bool userCorrected,
      required int createdAt,
      required int updatedAt,
      required String syncState,
      required String recordSource,
      Value<int?> deletedAt,
      required int revision,
      Value<int> rowid,
    });
typedef $$MerchantCategoriesTableUpdateCompanionBuilder =
    MerchantCategoriesCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> merchant,
      Value<String> category,
      Value<double> confidence,
      Value<bool> userCorrected,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String> syncState,
      Value<String> recordSource,
      Value<int?> deletedAt,
      Value<int> revision,
      Value<int> rowid,
    });

class $$MerchantCategoriesTableFilterComposer
    extends Composer<_$LifeOsDatabase, $MerchantCategoriesTable> {
  $$MerchantCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get userCorrected => $composableBuilder(
    column: $table.userCorrected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MerchantCategoriesTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $MerchantCategoriesTable> {
  $$MerchantCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get userCorrected => $composableBuilder(
    column: $table.userCorrected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MerchantCategoriesTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $MerchantCategoriesTable> {
  $$MerchantCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get userCorrected => $composableBuilder(
    column: $table.userCorrected,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$MerchantCategoriesTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $MerchantCategoriesTable,
          MerchantCategory,
          $$MerchantCategoriesTableFilterComposer,
          $$MerchantCategoriesTableOrderingComposer,
          $$MerchantCategoriesTableAnnotationComposer,
          $$MerchantCategoriesTableCreateCompanionBuilder,
          $$MerchantCategoriesTableUpdateCompanionBuilder,
          (
            MerchantCategory,
            BaseReferences<
              _$LifeOsDatabase,
              $MerchantCategoriesTable,
              MerchantCategory
            >,
          ),
          MerchantCategory,
          PrefetchHooks Function()
        > {
  $$MerchantCategoriesTableTableManager(
    _$LifeOsDatabase db,
    $MerchantCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MerchantCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MerchantCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MerchantCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> merchant = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<bool> userCorrected = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String> recordSource = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MerchantCategoriesCompanion(
                id: id,
                userId: userId,
                merchant: merchant,
                category: category,
                confidence: confidence,
                userCorrected: userCorrected,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncState: syncState,
                recordSource: recordSource,
                deletedAt: deletedAt,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String userId,
                required String merchant,
                required String category,
                required double confidence,
                required bool userCorrected,
                required int createdAt,
                required int updatedAt,
                required String syncState,
                required String recordSource,
                Value<int?> deletedAt = const Value.absent(),
                required int revision,
                Value<int> rowid = const Value.absent(),
              }) => MerchantCategoriesCompanion.insert(
                id: id,
                userId: userId,
                merchant: merchant,
                category: category,
                confidence: confidence,
                userCorrected: userCorrected,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncState: syncState,
                recordSource: recordSource,
                deletedAt: deletedAt,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MerchantCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $MerchantCategoriesTable,
      MerchantCategory,
      $$MerchantCategoriesTableFilterComposer,
      $$MerchantCategoriesTableOrderingComposer,
      $$MerchantCategoriesTableAnnotationComposer,
      $$MerchantCategoriesTableCreateCompanionBuilder,
      $$MerchantCategoriesTableUpdateCompanionBuilder,
      (
        MerchantCategory,
        BaseReferences<
          _$LifeOsDatabase,
          $MerchantCategoriesTable,
          MerchantCategory
        >,
      ),
      MerchantCategory,
      PrefetchHooks Function()
    >;
typedef $$SmsIngestQueueTableCreateCompanionBuilder =
    SmsIngestQueueCompanion Function({
      Value<int> id,
      required String userId,
      required String rawMessage,
      required String sender,
      required int timestampMs,
      required int enqueuedAt,
      Value<String> state,
      Value<int> retryCount,
      Value<String?> lastError,
    });
typedef $$SmsIngestQueueTableUpdateCompanionBuilder =
    SmsIngestQueueCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> rawMessage,
      Value<String> sender,
      Value<int> timestampMs,
      Value<int> enqueuedAt,
      Value<String> state,
      Value<int> retryCount,
      Value<String?> lastError,
    });

class $$SmsIngestQueueTableFilterComposer
    extends Composer<_$LifeOsDatabase, $SmsIngestQueueTable> {
  $$SmsIngestQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawMessage => $composableBuilder(
    column: $table.rawMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get enqueuedAt => $composableBuilder(
    column: $table.enqueuedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SmsIngestQueueTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $SmsIngestQueueTable> {
  $$SmsIngestQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawMessage => $composableBuilder(
    column: $table.rawMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get enqueuedAt => $composableBuilder(
    column: $table.enqueuedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SmsIngestQueueTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $SmsIngestQueueTable> {
  $$SmsIngestQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get rawMessage => $composableBuilder(
    column: $table.rawMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sender =>
      $composableBuilder(column: $table.sender, builder: (column) => column);

  GeneratedColumn<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get enqueuedAt => $composableBuilder(
    column: $table.enqueuedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SmsIngestQueueTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $SmsIngestQueueTable,
          SmsIngestQueueData,
          $$SmsIngestQueueTableFilterComposer,
          $$SmsIngestQueueTableOrderingComposer,
          $$SmsIngestQueueTableAnnotationComposer,
          $$SmsIngestQueueTableCreateCompanionBuilder,
          $$SmsIngestQueueTableUpdateCompanionBuilder,
          (
            SmsIngestQueueData,
            BaseReferences<
              _$LifeOsDatabase,
              $SmsIngestQueueTable,
              SmsIngestQueueData
            >,
          ),
          SmsIngestQueueData,
          PrefetchHooks Function()
        > {
  $$SmsIngestQueueTableTableManager(
    _$LifeOsDatabase db,
    $SmsIngestQueueTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SmsIngestQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SmsIngestQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SmsIngestQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> rawMessage = const Value.absent(),
                Value<String> sender = const Value.absent(),
                Value<int> timestampMs = const Value.absent(),
                Value<int> enqueuedAt = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => SmsIngestQueueCompanion(
                id: id,
                userId: userId,
                rawMessage: rawMessage,
                sender: sender,
                timestampMs: timestampMs,
                enqueuedAt: enqueuedAt,
                state: state,
                retryCount: retryCount,
                lastError: lastError,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required String rawMessage,
                required String sender,
                required int timestampMs,
                required int enqueuedAt,
                Value<String> state = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => SmsIngestQueueCompanion.insert(
                id: id,
                userId: userId,
                rawMessage: rawMessage,
                sender: sender,
                timestampMs: timestampMs,
                enqueuedAt: enqueuedAt,
                state: state,
                retryCount: retryCount,
                lastError: lastError,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SmsIngestQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $SmsIngestQueueTable,
      SmsIngestQueueData,
      $$SmsIngestQueueTableFilterComposer,
      $$SmsIngestQueueTableOrderingComposer,
      $$SmsIngestQueueTableAnnotationComposer,
      $$SmsIngestQueueTableCreateCompanionBuilder,
      $$SmsIngestQueueTableUpdateCompanionBuilder,
      (
        SmsIngestQueueData,
        BaseReferences<
          _$LifeOsDatabase,
          $SmsIngestQueueTable,
          SmsIngestQueueData
        >,
      ),
      SmsIngestQueueData,
      PrefetchHooks Function()
    >;
typedef $$SmsReviewQueueTableCreateCompanionBuilder =
    SmsReviewQueueCompanion Function({
      Value<int> id,
      required String userId,
      required String rawMessage,
      Value<String?> sender,
      Value<String?> mpesaCode,
      Value<double?> amount,
      Value<String?> counterparty,
      Value<String?> category,
      Value<String?> semanticHash,
      Value<double> confidenceScore,
      Value<String> parseRoute,
      required int enqueuedAt,
      Value<int?> reviewedAt,
      Value<String?> reviewDecision,
      Value<String?> reviewNotes,
    });
typedef $$SmsReviewQueueTableUpdateCompanionBuilder =
    SmsReviewQueueCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> rawMessage,
      Value<String?> sender,
      Value<String?> mpesaCode,
      Value<double?> amount,
      Value<String?> counterparty,
      Value<String?> category,
      Value<String?> semanticHash,
      Value<double> confidenceScore,
      Value<String> parseRoute,
      Value<int> enqueuedAt,
      Value<int?> reviewedAt,
      Value<String?> reviewDecision,
      Value<String?> reviewNotes,
    });

class $$SmsReviewQueueTableFilterComposer
    extends Composer<_$LifeOsDatabase, $SmsReviewQueueTable> {
  $$SmsReviewQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawMessage => $composableBuilder(
    column: $table.rawMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mpesaCode => $composableBuilder(
    column: $table.mpesaCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get counterparty => $composableBuilder(
    column: $table.counterparty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get semanticHash => $composableBuilder(
    column: $table.semanticHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidenceScore => $composableBuilder(
    column: $table.confidenceScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parseRoute => $composableBuilder(
    column: $table.parseRoute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get enqueuedAt => $composableBuilder(
    column: $table.enqueuedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewDecision => $composableBuilder(
    column: $table.reviewDecision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewNotes => $composableBuilder(
    column: $table.reviewNotes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SmsReviewQueueTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $SmsReviewQueueTable> {
  $$SmsReviewQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawMessage => $composableBuilder(
    column: $table.rawMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mpesaCode => $composableBuilder(
    column: $table.mpesaCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get counterparty => $composableBuilder(
    column: $table.counterparty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get semanticHash => $composableBuilder(
    column: $table.semanticHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidenceScore => $composableBuilder(
    column: $table.confidenceScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parseRoute => $composableBuilder(
    column: $table.parseRoute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get enqueuedAt => $composableBuilder(
    column: $table.enqueuedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewDecision => $composableBuilder(
    column: $table.reviewDecision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewNotes => $composableBuilder(
    column: $table.reviewNotes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SmsReviewQueueTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $SmsReviewQueueTable> {
  $$SmsReviewQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get rawMessage => $composableBuilder(
    column: $table.rawMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sender =>
      $composableBuilder(column: $table.sender, builder: (column) => column);

  GeneratedColumn<String> get mpesaCode =>
      $composableBuilder(column: $table.mpesaCode, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get counterparty => $composableBuilder(
    column: $table.counterparty,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get semanticHash => $composableBuilder(
    column: $table.semanticHash,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidenceScore => $composableBuilder(
    column: $table.confidenceScore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parseRoute => $composableBuilder(
    column: $table.parseRoute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get enqueuedAt => $composableBuilder(
    column: $table.enqueuedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewDecision => $composableBuilder(
    column: $table.reviewDecision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewNotes => $composableBuilder(
    column: $table.reviewNotes,
    builder: (column) => column,
  );
}

class $$SmsReviewQueueTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $SmsReviewQueueTable,
          SmsReviewQueueData,
          $$SmsReviewQueueTableFilterComposer,
          $$SmsReviewQueueTableOrderingComposer,
          $$SmsReviewQueueTableAnnotationComposer,
          $$SmsReviewQueueTableCreateCompanionBuilder,
          $$SmsReviewQueueTableUpdateCompanionBuilder,
          (
            SmsReviewQueueData,
            BaseReferences<
              _$LifeOsDatabase,
              $SmsReviewQueueTable,
              SmsReviewQueueData
            >,
          ),
          SmsReviewQueueData,
          PrefetchHooks Function()
        > {
  $$SmsReviewQueueTableTableManager(
    _$LifeOsDatabase db,
    $SmsReviewQueueTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SmsReviewQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SmsReviewQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SmsReviewQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> rawMessage = const Value.absent(),
                Value<String?> sender = const Value.absent(),
                Value<String?> mpesaCode = const Value.absent(),
                Value<double?> amount = const Value.absent(),
                Value<String?> counterparty = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> semanticHash = const Value.absent(),
                Value<double> confidenceScore = const Value.absent(),
                Value<String> parseRoute = const Value.absent(),
                Value<int> enqueuedAt = const Value.absent(),
                Value<int?> reviewedAt = const Value.absent(),
                Value<String?> reviewDecision = const Value.absent(),
                Value<String?> reviewNotes = const Value.absent(),
              }) => SmsReviewQueueCompanion(
                id: id,
                userId: userId,
                rawMessage: rawMessage,
                sender: sender,
                mpesaCode: mpesaCode,
                amount: amount,
                counterparty: counterparty,
                category: category,
                semanticHash: semanticHash,
                confidenceScore: confidenceScore,
                parseRoute: parseRoute,
                enqueuedAt: enqueuedAt,
                reviewedAt: reviewedAt,
                reviewDecision: reviewDecision,
                reviewNotes: reviewNotes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required String rawMessage,
                Value<String?> sender = const Value.absent(),
                Value<String?> mpesaCode = const Value.absent(),
                Value<double?> amount = const Value.absent(),
                Value<String?> counterparty = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> semanticHash = const Value.absent(),
                Value<double> confidenceScore = const Value.absent(),
                Value<String> parseRoute = const Value.absent(),
                required int enqueuedAt,
                Value<int?> reviewedAt = const Value.absent(),
                Value<String?> reviewDecision = const Value.absent(),
                Value<String?> reviewNotes = const Value.absent(),
              }) => SmsReviewQueueCompanion.insert(
                id: id,
                userId: userId,
                rawMessage: rawMessage,
                sender: sender,
                mpesaCode: mpesaCode,
                amount: amount,
                counterparty: counterparty,
                category: category,
                semanticHash: semanticHash,
                confidenceScore: confidenceScore,
                parseRoute: parseRoute,
                enqueuedAt: enqueuedAt,
                reviewedAt: reviewedAt,
                reviewDecision: reviewDecision,
                reviewNotes: reviewNotes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SmsReviewQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $SmsReviewQueueTable,
      SmsReviewQueueData,
      $$SmsReviewQueueTableFilterComposer,
      $$SmsReviewQueueTableOrderingComposer,
      $$SmsReviewQueueTableAnnotationComposer,
      $$SmsReviewQueueTableCreateCompanionBuilder,
      $$SmsReviewQueueTableUpdateCompanionBuilder,
      (
        SmsReviewQueueData,
        BaseReferences<
          _$LifeOsDatabase,
          $SmsReviewQueueTable,
          SmsReviewQueueData
        >,
      ),
      SmsReviewQueueData,
      PrefetchHooks Function()
    >;
typedef $$SmsQuarantineTableCreateCompanionBuilder =
    SmsQuarantineCompanion Function({
      Value<int> id,
      required String userId,
      required String rawMessage,
      Value<String?> sender,
      Value<String?> mpesaCode,
      Value<double?> amount,
      Value<String?> counterparty,
      Value<String?> category,
      Value<double> confidenceScore,
      Value<String?> failureReason,
      required int quarantinedAt,
      Value<int?> resolvedAt,
      Value<String?> resolution,
    });
typedef $$SmsQuarantineTableUpdateCompanionBuilder =
    SmsQuarantineCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> rawMessage,
      Value<String?> sender,
      Value<String?> mpesaCode,
      Value<double?> amount,
      Value<String?> counterparty,
      Value<String?> category,
      Value<double> confidenceScore,
      Value<String?> failureReason,
      Value<int> quarantinedAt,
      Value<int?> resolvedAt,
      Value<String?> resolution,
    });

class $$SmsQuarantineTableFilterComposer
    extends Composer<_$LifeOsDatabase, $SmsQuarantineTable> {
  $$SmsQuarantineTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawMessage => $composableBuilder(
    column: $table.rawMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mpesaCode => $composableBuilder(
    column: $table.mpesaCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get counterparty => $composableBuilder(
    column: $table.counterparty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidenceScore => $composableBuilder(
    column: $table.confidenceScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quarantinedAt => $composableBuilder(
    column: $table.quarantinedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SmsQuarantineTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $SmsQuarantineTable> {
  $$SmsQuarantineTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawMessage => $composableBuilder(
    column: $table.rawMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mpesaCode => $composableBuilder(
    column: $table.mpesaCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get counterparty => $composableBuilder(
    column: $table.counterparty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidenceScore => $composableBuilder(
    column: $table.confidenceScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quarantinedAt => $composableBuilder(
    column: $table.quarantinedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SmsQuarantineTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $SmsQuarantineTable> {
  $$SmsQuarantineTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get rawMessage => $composableBuilder(
    column: $table.rawMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sender =>
      $composableBuilder(column: $table.sender, builder: (column) => column);

  GeneratedColumn<String> get mpesaCode =>
      $composableBuilder(column: $table.mpesaCode, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get counterparty => $composableBuilder(
    column: $table.counterparty,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get confidenceScore => $composableBuilder(
    column: $table.confidenceScore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quarantinedAt => $composableBuilder(
    column: $table.quarantinedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => column,
  );
}

class $$SmsQuarantineTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $SmsQuarantineTable,
          SmsQuarantineData,
          $$SmsQuarantineTableFilterComposer,
          $$SmsQuarantineTableOrderingComposer,
          $$SmsQuarantineTableAnnotationComposer,
          $$SmsQuarantineTableCreateCompanionBuilder,
          $$SmsQuarantineTableUpdateCompanionBuilder,
          (
            SmsQuarantineData,
            BaseReferences<
              _$LifeOsDatabase,
              $SmsQuarantineTable,
              SmsQuarantineData
            >,
          ),
          SmsQuarantineData,
          PrefetchHooks Function()
        > {
  $$SmsQuarantineTableTableManager(
    _$LifeOsDatabase db,
    $SmsQuarantineTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SmsQuarantineTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SmsQuarantineTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SmsQuarantineTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> rawMessage = const Value.absent(),
                Value<String?> sender = const Value.absent(),
                Value<String?> mpesaCode = const Value.absent(),
                Value<double?> amount = const Value.absent(),
                Value<String?> counterparty = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<double> confidenceScore = const Value.absent(),
                Value<String?> failureReason = const Value.absent(),
                Value<int> quarantinedAt = const Value.absent(),
                Value<int?> resolvedAt = const Value.absent(),
                Value<String?> resolution = const Value.absent(),
              }) => SmsQuarantineCompanion(
                id: id,
                userId: userId,
                rawMessage: rawMessage,
                sender: sender,
                mpesaCode: mpesaCode,
                amount: amount,
                counterparty: counterparty,
                category: category,
                confidenceScore: confidenceScore,
                failureReason: failureReason,
                quarantinedAt: quarantinedAt,
                resolvedAt: resolvedAt,
                resolution: resolution,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required String rawMessage,
                Value<String?> sender = const Value.absent(),
                Value<String?> mpesaCode = const Value.absent(),
                Value<double?> amount = const Value.absent(),
                Value<String?> counterparty = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<double> confidenceScore = const Value.absent(),
                Value<String?> failureReason = const Value.absent(),
                required int quarantinedAt,
                Value<int?> resolvedAt = const Value.absent(),
                Value<String?> resolution = const Value.absent(),
              }) => SmsQuarantineCompanion.insert(
                id: id,
                userId: userId,
                rawMessage: rawMessage,
                sender: sender,
                mpesaCode: mpesaCode,
                amount: amount,
                counterparty: counterparty,
                category: category,
                confidenceScore: confidenceScore,
                failureReason: failureReason,
                quarantinedAt: quarantinedAt,
                resolvedAt: resolvedAt,
                resolution: resolution,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SmsQuarantineTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $SmsQuarantineTable,
      SmsQuarantineData,
      $$SmsQuarantineTableFilterComposer,
      $$SmsQuarantineTableOrderingComposer,
      $$SmsQuarantineTableAnnotationComposer,
      $$SmsQuarantineTableCreateCompanionBuilder,
      $$SmsQuarantineTableUpdateCompanionBuilder,
      (
        SmsQuarantineData,
        BaseReferences<
          _$LifeOsDatabase,
          $SmsQuarantineTable,
          SmsQuarantineData
        >,
      ),
      SmsQuarantineData,
      PrefetchHooks Function()
    >;
typedef $$ImportAuditTableCreateCompanionBuilder =
    ImportAuditCompanion Function({
      required int id,
      required String userId,
      required String rawMessage,
      Value<String?> mpesaCode,
      Value<double?> amount,
      Value<String?> merchant,
      required String outcome,
      Value<String?> failureReason,
      required int importedAt,
      required int createdAt,
      required int updatedAt,
      required double confidenceScore,
      Value<int> rowid,
    });
typedef $$ImportAuditTableUpdateCompanionBuilder =
    ImportAuditCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> rawMessage,
      Value<String?> mpesaCode,
      Value<double?> amount,
      Value<String?> merchant,
      Value<String> outcome,
      Value<String?> failureReason,
      Value<int> importedAt,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<double> confidenceScore,
      Value<int> rowid,
    });

class $$ImportAuditTableFilterComposer
    extends Composer<_$LifeOsDatabase, $ImportAuditTable> {
  $$ImportAuditTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawMessage => $composableBuilder(
    column: $table.rawMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mpesaCode => $composableBuilder(
    column: $table.mpesaCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidenceScore => $composableBuilder(
    column: $table.confidenceScore,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImportAuditTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $ImportAuditTable> {
  $$ImportAuditTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawMessage => $composableBuilder(
    column: $table.rawMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mpesaCode => $composableBuilder(
    column: $table.mpesaCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidenceScore => $composableBuilder(
    column: $table.confidenceScore,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImportAuditTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $ImportAuditTable> {
  $$ImportAuditTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get rawMessage => $composableBuilder(
    column: $table.rawMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mpesaCode =>
      $composableBuilder(column: $table.mpesaCode, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => column,
  );

  GeneratedColumn<int> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<double> get confidenceScore => $composableBuilder(
    column: $table.confidenceScore,
    builder: (column) => column,
  );
}

class $$ImportAuditTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $ImportAuditTable,
          ImportAuditData,
          $$ImportAuditTableFilterComposer,
          $$ImportAuditTableOrderingComposer,
          $$ImportAuditTableAnnotationComposer,
          $$ImportAuditTableCreateCompanionBuilder,
          $$ImportAuditTableUpdateCompanionBuilder,
          (
            ImportAuditData,
            BaseReferences<
              _$LifeOsDatabase,
              $ImportAuditTable,
              ImportAuditData
            >,
          ),
          ImportAuditData,
          PrefetchHooks Function()
        > {
  $$ImportAuditTableTableManager(_$LifeOsDatabase db, $ImportAuditTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportAuditTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportAuditTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportAuditTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> rawMessage = const Value.absent(),
                Value<String?> mpesaCode = const Value.absent(),
                Value<double?> amount = const Value.absent(),
                Value<String?> merchant = const Value.absent(),
                Value<String> outcome = const Value.absent(),
                Value<String?> failureReason = const Value.absent(),
                Value<int> importedAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<double> confidenceScore = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportAuditCompanion(
                id: id,
                userId: userId,
                rawMessage: rawMessage,
                mpesaCode: mpesaCode,
                amount: amount,
                merchant: merchant,
                outcome: outcome,
                failureReason: failureReason,
                importedAt: importedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                confidenceScore: confidenceScore,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String userId,
                required String rawMessage,
                Value<String?> mpesaCode = const Value.absent(),
                Value<double?> amount = const Value.absent(),
                Value<String?> merchant = const Value.absent(),
                required String outcome,
                Value<String?> failureReason = const Value.absent(),
                required int importedAt,
                required int createdAt,
                required int updatedAt,
                required double confidenceScore,
                Value<int> rowid = const Value.absent(),
              }) => ImportAuditCompanion.insert(
                id: id,
                userId: userId,
                rawMessage: rawMessage,
                mpesaCode: mpesaCode,
                amount: amount,
                merchant: merchant,
                outcome: outcome,
                failureReason: failureReason,
                importedAt: importedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                confidenceScore: confidenceScore,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ImportAuditTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $ImportAuditTable,
      ImportAuditData,
      $$ImportAuditTableFilterComposer,
      $$ImportAuditTableOrderingComposer,
      $$ImportAuditTableAnnotationComposer,
      $$ImportAuditTableCreateCompanionBuilder,
      $$ImportAuditTableUpdateCompanionBuilder,
      (
        ImportAuditData,
        BaseReferences<_$LifeOsDatabase, $ImportAuditTable, ImportAuditData>,
      ),
      ImportAuditData,
      PrefetchHooks Function()
    >;
typedef $$MlTrainingSamplesTableCreateCompanionBuilder =
    MlTrainingSamplesCompanion Function({
      Value<int> id,
      required String features,
      required String label,
      required int recordedAt,
    });
typedef $$MlTrainingSamplesTableUpdateCompanionBuilder =
    MlTrainingSamplesCompanion Function({
      Value<int> id,
      Value<String> features,
      Value<String> label,
      Value<int> recordedAt,
    });

class $$MlTrainingSamplesTableFilterComposer
    extends Composer<_$LifeOsDatabase, $MlTrainingSamplesTable> {
  $$MlTrainingSamplesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get features => $composableBuilder(
    column: $table.features,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MlTrainingSamplesTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $MlTrainingSamplesTable> {
  $$MlTrainingSamplesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get features => $composableBuilder(
    column: $table.features,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MlTrainingSamplesTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $MlTrainingSamplesTable> {
  $$MlTrainingSamplesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get features =>
      $composableBuilder(column: $table.features, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );
}

class $$MlTrainingSamplesTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $MlTrainingSamplesTable,
          MlTrainingSample,
          $$MlTrainingSamplesTableFilterComposer,
          $$MlTrainingSamplesTableOrderingComposer,
          $$MlTrainingSamplesTableAnnotationComposer,
          $$MlTrainingSamplesTableCreateCompanionBuilder,
          $$MlTrainingSamplesTableUpdateCompanionBuilder,
          (
            MlTrainingSample,
            BaseReferences<
              _$LifeOsDatabase,
              $MlTrainingSamplesTable,
              MlTrainingSample
            >,
          ),
          MlTrainingSample,
          PrefetchHooks Function()
        > {
  $$MlTrainingSamplesTableTableManager(
    _$LifeOsDatabase db,
    $MlTrainingSamplesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MlTrainingSamplesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MlTrainingSamplesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MlTrainingSamplesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> features = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> recordedAt = const Value.absent(),
              }) => MlTrainingSamplesCompanion(
                id: id,
                features: features,
                label: label,
                recordedAt: recordedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String features,
                required String label,
                required int recordedAt,
              }) => MlTrainingSamplesCompanion.insert(
                id: id,
                features: features,
                label: label,
                recordedAt: recordedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MlTrainingSamplesTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $MlTrainingSamplesTable,
      MlTrainingSample,
      $$MlTrainingSamplesTableFilterComposer,
      $$MlTrainingSamplesTableOrderingComposer,
      $$MlTrainingSamplesTableAnnotationComposer,
      $$MlTrainingSamplesTableCreateCompanionBuilder,
      $$MlTrainingSamplesTableUpdateCompanionBuilder,
      (
        MlTrainingSample,
        BaseReferences<
          _$LifeOsDatabase,
          $MlTrainingSamplesTable,
          MlTrainingSample
        >,
      ),
      MlTrainingSample,
      PrefetchHooks Function()
    >;
typedef $$InsightCardsTableCreateCompanionBuilder =
    InsightCardsCompanion Function({
      required int id,
      required String userId,
      required String kind,
      required String title,
      required String body,
      Value<double?> confidence,
      required bool isAiGenerated,
      Value<int?> freshUntil,
      required int createdAt,
      required int updatedAt,
      required String syncState,
      required String recordSource,
      Value<int?> deletedAt,
      required int revision,
      Value<int> rowid,
    });
typedef $$InsightCardsTableUpdateCompanionBuilder =
    InsightCardsCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> kind,
      Value<String> title,
      Value<String> body,
      Value<double?> confidence,
      Value<bool> isAiGenerated,
      Value<int?> freshUntil,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String> syncState,
      Value<String> recordSource,
      Value<int?> deletedAt,
      Value<int> revision,
      Value<int> rowid,
    });

class $$InsightCardsTableFilterComposer
    extends Composer<_$LifeOsDatabase, $InsightCardsTable> {
  $$InsightCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAiGenerated => $composableBuilder(
    column: $table.isAiGenerated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get freshUntil => $composableBuilder(
    column: $table.freshUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InsightCardsTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $InsightCardsTable> {
  $$InsightCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAiGenerated => $composableBuilder(
    column: $table.isAiGenerated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get freshUntil => $composableBuilder(
    column: $table.freshUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InsightCardsTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $InsightCardsTable> {
  $$InsightCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAiGenerated => $composableBuilder(
    column: $table.isAiGenerated,
    builder: (column) => column,
  );

  GeneratedColumn<int> get freshUntil => $composableBuilder(
    column: $table.freshUntil,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$InsightCardsTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $InsightCardsTable,
          InsightCard,
          $$InsightCardsTableFilterComposer,
          $$InsightCardsTableOrderingComposer,
          $$InsightCardsTableAnnotationComposer,
          $$InsightCardsTableCreateCompanionBuilder,
          $$InsightCardsTableUpdateCompanionBuilder,
          (
            InsightCard,
            BaseReferences<_$LifeOsDatabase, $InsightCardsTable, InsightCard>,
          ),
          InsightCard,
          PrefetchHooks Function()
        > {
  $$InsightCardsTableTableManager(_$LifeOsDatabase db, $InsightCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InsightCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InsightCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InsightCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<bool> isAiGenerated = const Value.absent(),
                Value<int?> freshUntil = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String> recordSource = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InsightCardsCompanion(
                id: id,
                userId: userId,
                kind: kind,
                title: title,
                body: body,
                confidence: confidence,
                isAiGenerated: isAiGenerated,
                freshUntil: freshUntil,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncState: syncState,
                recordSource: recordSource,
                deletedAt: deletedAt,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String userId,
                required String kind,
                required String title,
                required String body,
                Value<double?> confidence = const Value.absent(),
                required bool isAiGenerated,
                Value<int?> freshUntil = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                required String syncState,
                required String recordSource,
                Value<int?> deletedAt = const Value.absent(),
                required int revision,
                Value<int> rowid = const Value.absent(),
              }) => InsightCardsCompanion.insert(
                id: id,
                userId: userId,
                kind: kind,
                title: title,
                body: body,
                confidence: confidence,
                isAiGenerated: isAiGenerated,
                freshUntil: freshUntil,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncState: syncState,
                recordSource: recordSource,
                deletedAt: deletedAt,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InsightCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $InsightCardsTable,
      InsightCard,
      $$InsightCardsTableFilterComposer,
      $$InsightCardsTableOrderingComposer,
      $$InsightCardsTableAnnotationComposer,
      $$InsightCardsTableCreateCompanionBuilder,
      $$InsightCardsTableUpdateCompanionBuilder,
      (
        InsightCard,
        BaseReferences<_$LifeOsDatabase, $InsightCardsTable, InsightCard>,
      ),
      InsightCard,
      PrefetchHooks Function()
    >;
typedef $$LearningSessionsTableCreateCompanionBuilder =
    LearningSessionsCompanion Function({
      required int id,
      required String userId,
      required String topic,
      required int durationMinutes,
      required String notes,
      required int date,
      required String source,
      required int createdAt,
      required String syncState,
      Value<int?> deletedAt,
      Value<int> rowid,
    });
typedef $$LearningSessionsTableUpdateCompanionBuilder =
    LearningSessionsCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> topic,
      Value<int> durationMinutes,
      Value<String> notes,
      Value<int> date,
      Value<String> source,
      Value<int> createdAt,
      Value<String> syncState,
      Value<int?> deletedAt,
      Value<int> rowid,
    });

class $$LearningSessionsTableFilterComposer
    extends Composer<_$LifeOsDatabase, $LearningSessionsTable> {
  $$LearningSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LearningSessionsTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $LearningSessionsTable> {
  $$LearningSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LearningSessionsTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $LearningSessionsTable> {
  $$LearningSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$LearningSessionsTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $LearningSessionsTable,
          LearningSession,
          $$LearningSessionsTableFilterComposer,
          $$LearningSessionsTableOrderingComposer,
          $$LearningSessionsTableAnnotationComposer,
          $$LearningSessionsTableCreateCompanionBuilder,
          $$LearningSessionsTableUpdateCompanionBuilder,
          (
            LearningSession,
            BaseReferences<
              _$LifeOsDatabase,
              $LearningSessionsTable,
              LearningSession
            >,
          ),
          LearningSession,
          PrefetchHooks Function()
        > {
  $$LearningSessionsTableTableManager(
    _$LifeOsDatabase db,
    $LearningSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LearningSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LearningSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LearningSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> topic = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> date = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LearningSessionsCompanion(
                id: id,
                userId: userId,
                topic: topic,
                durationMinutes: durationMinutes,
                notes: notes,
                date: date,
                source: source,
                createdAt: createdAt,
                syncState: syncState,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String userId,
                required String topic,
                required int durationMinutes,
                required String notes,
                required int date,
                required String source,
                required int createdAt,
                required String syncState,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LearningSessionsCompanion.insert(
                id: id,
                userId: userId,
                topic: topic,
                durationMinutes: durationMinutes,
                notes: notes,
                date: date,
                source: source,
                createdAt: createdAt,
                syncState: syncState,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LearningSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $LearningSessionsTable,
      LearningSession,
      $$LearningSessionsTableFilterComposer,
      $$LearningSessionsTableOrderingComposer,
      $$LearningSessionsTableAnnotationComposer,
      $$LearningSessionsTableCreateCompanionBuilder,
      $$LearningSessionsTableUpdateCompanionBuilder,
      (
        LearningSession,
        BaseReferences<
          _$LifeOsDatabase,
          $LearningSessionsTable,
          LearningSession
        >,
      ),
      LearningSession,
      PrefetchHooks Function()
    >;
typedef $$ReviewSnapshotsTableCreateCompanionBuilder =
    ReviewSnapshotsCompanion Function({
      required int id,
      required String userId,
      required int periodStart,
      required int periodEnd,
      required String payload,
      required int createdAt,
      required int updatedAt,
      required String syncState,
      required String recordSource,
      Value<int?> deletedAt,
      required int revision,
      Value<int> rowid,
    });
typedef $$ReviewSnapshotsTableUpdateCompanionBuilder =
    ReviewSnapshotsCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<int> periodStart,
      Value<int> periodEnd,
      Value<String> payload,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String> syncState,
      Value<String> recordSource,
      Value<int?> deletedAt,
      Value<int> revision,
      Value<int> rowid,
    });

class $$ReviewSnapshotsTableFilterComposer
    extends Composer<_$LifeOsDatabase, $ReviewSnapshotsTable> {
  $$ReviewSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get periodEnd => $composableBuilder(
    column: $table.periodEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReviewSnapshotsTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $ReviewSnapshotsTable> {
  $$ReviewSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get periodEnd => $composableBuilder(
    column: $table.periodEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReviewSnapshotsTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $ReviewSnapshotsTable> {
  $$ReviewSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => column,
  );

  GeneratedColumn<int> get periodEnd =>
      $composableBuilder(column: $table.periodEnd, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$ReviewSnapshotsTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $ReviewSnapshotsTable,
          ReviewSnapshot,
          $$ReviewSnapshotsTableFilterComposer,
          $$ReviewSnapshotsTableOrderingComposer,
          $$ReviewSnapshotsTableAnnotationComposer,
          $$ReviewSnapshotsTableCreateCompanionBuilder,
          $$ReviewSnapshotsTableUpdateCompanionBuilder,
          (
            ReviewSnapshot,
            BaseReferences<
              _$LifeOsDatabase,
              $ReviewSnapshotsTable,
              ReviewSnapshot
            >,
          ),
          ReviewSnapshot,
          PrefetchHooks Function()
        > {
  $$ReviewSnapshotsTableTableManager(
    _$LifeOsDatabase db,
    $ReviewSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> periodStart = const Value.absent(),
                Value<int> periodEnd = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String> recordSource = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReviewSnapshotsCompanion(
                id: id,
                userId: userId,
                periodStart: periodStart,
                periodEnd: periodEnd,
                payload: payload,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncState: syncState,
                recordSource: recordSource,
                deletedAt: deletedAt,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String userId,
                required int periodStart,
                required int periodEnd,
                required String payload,
                required int createdAt,
                required int updatedAt,
                required String syncState,
                required String recordSource,
                Value<int?> deletedAt = const Value.absent(),
                required int revision,
                Value<int> rowid = const Value.absent(),
              }) => ReviewSnapshotsCompanion.insert(
                id: id,
                userId: userId,
                periodStart: periodStart,
                periodEnd: periodEnd,
                payload: payload,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncState: syncState,
                recordSource: recordSource,
                deletedAt: deletedAt,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReviewSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $ReviewSnapshotsTable,
      ReviewSnapshot,
      $$ReviewSnapshotsTableFilterComposer,
      $$ReviewSnapshotsTableOrderingComposer,
      $$ReviewSnapshotsTableAnnotationComposer,
      $$ReviewSnapshotsTableCreateCompanionBuilder,
      $$ReviewSnapshotsTableUpdateCompanionBuilder,
      (
        ReviewSnapshot,
        BaseReferences<_$LifeOsDatabase, $ReviewSnapshotsTable, ReviewSnapshot>,
      ),
      ReviewSnapshot,
      PrefetchHooks Function()
    >;
typedef $$AssistantConversationsTableCreateCompanionBuilder =
    AssistantConversationsCompanion Function({
      required int id,
      required String userId,
      required String title,
      required int createdAt,
      required int updatedAt,
      required String syncState,
      required String recordSource,
      Value<int?> deletedAt,
      required int revision,
      Value<int> rowid,
    });
typedef $$AssistantConversationsTableUpdateCompanionBuilder =
    AssistantConversationsCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> title,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String> syncState,
      Value<String> recordSource,
      Value<int?> deletedAt,
      Value<int> revision,
      Value<int> rowid,
    });

class $$AssistantConversationsTableFilterComposer
    extends Composer<_$LifeOsDatabase, $AssistantConversationsTable> {
  $$AssistantConversationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AssistantConversationsTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $AssistantConversationsTable> {
  $$AssistantConversationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssistantConversationsTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $AssistantConversationsTable> {
  $$AssistantConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$AssistantConversationsTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $AssistantConversationsTable,
          AssistantConversation,
          $$AssistantConversationsTableFilterComposer,
          $$AssistantConversationsTableOrderingComposer,
          $$AssistantConversationsTableAnnotationComposer,
          $$AssistantConversationsTableCreateCompanionBuilder,
          $$AssistantConversationsTableUpdateCompanionBuilder,
          (
            AssistantConversation,
            BaseReferences<
              _$LifeOsDatabase,
              $AssistantConversationsTable,
              AssistantConversation
            >,
          ),
          AssistantConversation,
          PrefetchHooks Function()
        > {
  $$AssistantConversationsTableTableManager(
    _$LifeOsDatabase db,
    $AssistantConversationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssistantConversationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AssistantConversationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AssistantConversationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String> recordSource = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssistantConversationsCompanion(
                id: id,
                userId: userId,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncState: syncState,
                recordSource: recordSource,
                deletedAt: deletedAt,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String userId,
                required String title,
                required int createdAt,
                required int updatedAt,
                required String syncState,
                required String recordSource,
                Value<int?> deletedAt = const Value.absent(),
                required int revision,
                Value<int> rowid = const Value.absent(),
              }) => AssistantConversationsCompanion.insert(
                id: id,
                userId: userId,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncState: syncState,
                recordSource: recordSource,
                deletedAt: deletedAt,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AssistantConversationsTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $AssistantConversationsTable,
      AssistantConversation,
      $$AssistantConversationsTableFilterComposer,
      $$AssistantConversationsTableOrderingComposer,
      $$AssistantConversationsTableAnnotationComposer,
      $$AssistantConversationsTableCreateCompanionBuilder,
      $$AssistantConversationsTableUpdateCompanionBuilder,
      (
        AssistantConversation,
        BaseReferences<
          _$LifeOsDatabase,
          $AssistantConversationsTable,
          AssistantConversation
        >,
      ),
      AssistantConversation,
      PrefetchHooks Function()
    >;
typedef $$AssistantMessagesTableCreateCompanionBuilder =
    AssistantMessagesCompanion Function({
      required int id,
      required String userId,
      required int conversationId,
      required String role,
      required String content,
      Value<String?> actionPayload,
      required bool isPreview,
      required int createdAt,
      required int updatedAt,
      required String syncState,
      required String recordSource,
      Value<int?> deletedAt,
      required int revision,
      Value<int> rowid,
    });
typedef $$AssistantMessagesTableUpdateCompanionBuilder =
    AssistantMessagesCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<int> conversationId,
      Value<String> role,
      Value<String> content,
      Value<String?> actionPayload,
      Value<bool> isPreview,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String> syncState,
      Value<String> recordSource,
      Value<int?> deletedAt,
      Value<int> revision,
      Value<int> rowid,
    });

class $$AssistantMessagesTableFilterComposer
    extends Composer<_$LifeOsDatabase, $AssistantMessagesTable> {
  $$AssistantMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionPayload => $composableBuilder(
    column: $table.actionPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPreview => $composableBuilder(
    column: $table.isPreview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AssistantMessagesTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $AssistantMessagesTable> {
  $$AssistantMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionPayload => $composableBuilder(
    column: $table.actionPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPreview => $composableBuilder(
    column: $table.isPreview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssistantMessagesTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $AssistantMessagesTable> {
  $$AssistantMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get actionPayload => $composableBuilder(
    column: $table.actionPayload,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPreview =>
      $composableBuilder(column: $table.isPreview, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get recordSource => $composableBuilder(
    column: $table.recordSource,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$AssistantMessagesTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $AssistantMessagesTable,
          AssistantMessage,
          $$AssistantMessagesTableFilterComposer,
          $$AssistantMessagesTableOrderingComposer,
          $$AssistantMessagesTableAnnotationComposer,
          $$AssistantMessagesTableCreateCompanionBuilder,
          $$AssistantMessagesTableUpdateCompanionBuilder,
          (
            AssistantMessage,
            BaseReferences<
              _$LifeOsDatabase,
              $AssistantMessagesTable,
              AssistantMessage
            >,
          ),
          AssistantMessage,
          PrefetchHooks Function()
        > {
  $$AssistantMessagesTableTableManager(
    _$LifeOsDatabase db,
    $AssistantMessagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssistantMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssistantMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssistantMessagesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> conversationId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> actionPayload = const Value.absent(),
                Value<bool> isPreview = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String> recordSource = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssistantMessagesCompanion(
                id: id,
                userId: userId,
                conversationId: conversationId,
                role: role,
                content: content,
                actionPayload: actionPayload,
                isPreview: isPreview,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncState: syncState,
                recordSource: recordSource,
                deletedAt: deletedAt,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String userId,
                required int conversationId,
                required String role,
                required String content,
                Value<String?> actionPayload = const Value.absent(),
                required bool isPreview,
                required int createdAt,
                required int updatedAt,
                required String syncState,
                required String recordSource,
                Value<int?> deletedAt = const Value.absent(),
                required int revision,
                Value<int> rowid = const Value.absent(),
              }) => AssistantMessagesCompanion.insert(
                id: id,
                userId: userId,
                conversationId: conversationId,
                role: role,
                content: content,
                actionPayload: actionPayload,
                isPreview: isPreview,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncState: syncState,
                recordSource: recordSource,
                deletedAt: deletedAt,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AssistantMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $AssistantMessagesTable,
      AssistantMessage,
      $$AssistantMessagesTableFilterComposer,
      $$AssistantMessagesTableOrderingComposer,
      $$AssistantMessagesTableAnnotationComposer,
      $$AssistantMessagesTableCreateCompanionBuilder,
      $$AssistantMessagesTableUpdateCompanionBuilder,
      (
        AssistantMessage,
        BaseReferences<
          _$LifeOsDatabase,
          $AssistantMessagesTable,
          AssistantMessage
        >,
      ),
      AssistantMessage,
      PrefetchHooks Function()
    >;
typedef $$ExportHistoryTableCreateCompanionBuilder =
    ExportHistoryCompanion Function({
      required int id,
      required String userId,
      required String format,
      required String domainScope,
      Value<int?> dateFrom,
      Value<int?> dateTo,
      Value<String?> filePath,
      required int itemCount,
      required bool isEncrypted,
      required String status,
      Value<String?> errorMessage,
      required int exportedAt,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$ExportHistoryTableUpdateCompanionBuilder =
    ExportHistoryCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> format,
      Value<String> domainScope,
      Value<int?> dateFrom,
      Value<int?> dateTo,
      Value<String?> filePath,
      Value<int> itemCount,
      Value<bool> isEncrypted,
      Value<String> status,
      Value<String?> errorMessage,
      Value<int> exportedAt,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$ExportHistoryTableFilterComposer
    extends Composer<_$LifeOsDatabase, $ExportHistoryTable> {
  $$ExportHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domainScope => $composableBuilder(
    column: $table.domainScope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateFrom => $composableBuilder(
    column: $table.dateFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateTo => $composableBuilder(
    column: $table.dateTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemCount => $composableBuilder(
    column: $table.itemCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEncrypted => $composableBuilder(
    column: $table.isEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get exportedAt => $composableBuilder(
    column: $table.exportedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExportHistoryTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $ExportHistoryTable> {
  $$ExportHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domainScope => $composableBuilder(
    column: $table.domainScope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateFrom => $composableBuilder(
    column: $table.dateFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateTo => $composableBuilder(
    column: $table.dateTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemCount => $composableBuilder(
    column: $table.itemCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEncrypted => $composableBuilder(
    column: $table.isEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get exportedAt => $composableBuilder(
    column: $table.exportedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExportHistoryTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $ExportHistoryTable> {
  $$ExportHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get domainScope => $composableBuilder(
    column: $table.domainScope,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dateFrom =>
      $composableBuilder(column: $table.dateFrom, builder: (column) => column);

  GeneratedColumn<int> get dateTo =>
      $composableBuilder(column: $table.dateTo, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get itemCount =>
      $composableBuilder(column: $table.itemCount, builder: (column) => column);

  GeneratedColumn<bool> get isEncrypted => $composableBuilder(
    column: $table.isEncrypted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get exportedAt => $composableBuilder(
    column: $table.exportedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ExportHistoryTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $ExportHistoryTable,
          ExportHistoryData,
          $$ExportHistoryTableFilterComposer,
          $$ExportHistoryTableOrderingComposer,
          $$ExportHistoryTableAnnotationComposer,
          $$ExportHistoryTableCreateCompanionBuilder,
          $$ExportHistoryTableUpdateCompanionBuilder,
          (
            ExportHistoryData,
            BaseReferences<
              _$LifeOsDatabase,
              $ExportHistoryTable,
              ExportHistoryData
            >,
          ),
          ExportHistoryData,
          PrefetchHooks Function()
        > {
  $$ExportHistoryTableTableManager(
    _$LifeOsDatabase db,
    $ExportHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExportHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExportHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExportHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<String> domainScope = const Value.absent(),
                Value<int?> dateFrom = const Value.absent(),
                Value<int?> dateTo = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<int> itemCount = const Value.absent(),
                Value<bool> isEncrypted = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int> exportedAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExportHistoryCompanion(
                id: id,
                userId: userId,
                format: format,
                domainScope: domainScope,
                dateFrom: dateFrom,
                dateTo: dateTo,
                filePath: filePath,
                itemCount: itemCount,
                isEncrypted: isEncrypted,
                status: status,
                errorMessage: errorMessage,
                exportedAt: exportedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String userId,
                required String format,
                required String domainScope,
                Value<int?> dateFrom = const Value.absent(),
                Value<int?> dateTo = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                required int itemCount,
                required bool isEncrypted,
                required String status,
                Value<String?> errorMessage = const Value.absent(),
                required int exportedAt,
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ExportHistoryCompanion.insert(
                id: id,
                userId: userId,
                format: format,
                domainScope: domainScope,
                dateFrom: dateFrom,
                dateTo: dateTo,
                filePath: filePath,
                itemCount: itemCount,
                isEncrypted: isEncrypted,
                status: status,
                errorMessage: errorMessage,
                exportedAt: exportedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExportHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $ExportHistoryTable,
      ExportHistoryData,
      $$ExportHistoryTableFilterComposer,
      $$ExportHistoryTableOrderingComposer,
      $$ExportHistoryTableAnnotationComposer,
      $$ExportHistoryTableCreateCompanionBuilder,
      $$ExportHistoryTableUpdateCompanionBuilder,
      (
        ExportHistoryData,
        BaseReferences<
          _$LifeOsDatabase,
          $ExportHistoryTable,
          ExportHistoryData
        >,
      ),
      ExportHistoryData,
      PrefetchHooks Function()
    >;
typedef $$AppUpdateInfoTableCreateCompanionBuilder =
    AppUpdateInfoCompanion Function({
      required int id,
      required String userId,
      required int versionCode,
      Value<String?> versionName,
      required bool isRequired,
      Value<String?> downloadUrl,
      Value<String?> checksumSha256,
      required int checkedAt,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$AppUpdateInfoTableUpdateCompanionBuilder =
    AppUpdateInfoCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<int> versionCode,
      Value<String?> versionName,
      Value<bool> isRequired,
      Value<String?> downloadUrl,
      Value<String?> checksumSha256,
      Value<int> checkedAt,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$AppUpdateInfoTableFilterComposer
    extends Composer<_$LifeOsDatabase, $AppUpdateInfoTable> {
  $$AppUpdateInfoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versionCode => $composableBuilder(
    column: $table.versionCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get versionName => $composableBuilder(
    column: $table.versionName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRequired => $composableBuilder(
    column: $table.isRequired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get downloadUrl => $composableBuilder(
    column: $table.downloadUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checksumSha256 => $composableBuilder(
    column: $table.checksumSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get checkedAt => $composableBuilder(
    column: $table.checkedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppUpdateInfoTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $AppUpdateInfoTable> {
  $$AppUpdateInfoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versionCode => $composableBuilder(
    column: $table.versionCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get versionName => $composableBuilder(
    column: $table.versionName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRequired => $composableBuilder(
    column: $table.isRequired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get downloadUrl => $composableBuilder(
    column: $table.downloadUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checksumSha256 => $composableBuilder(
    column: $table.checksumSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get checkedAt => $composableBuilder(
    column: $table.checkedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppUpdateInfoTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $AppUpdateInfoTable> {
  $$AppUpdateInfoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get versionCode => $composableBuilder(
    column: $table.versionCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get versionName => $composableBuilder(
    column: $table.versionName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRequired => $composableBuilder(
    column: $table.isRequired,
    builder: (column) => column,
  );

  GeneratedColumn<String> get downloadUrl => $composableBuilder(
    column: $table.downloadUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get checksumSha256 => $composableBuilder(
    column: $table.checksumSha256,
    builder: (column) => column,
  );

  GeneratedColumn<int> get checkedAt =>
      $composableBuilder(column: $table.checkedAt, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppUpdateInfoTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $AppUpdateInfoTable,
          AppUpdateInfoData,
          $$AppUpdateInfoTableFilterComposer,
          $$AppUpdateInfoTableOrderingComposer,
          $$AppUpdateInfoTableAnnotationComposer,
          $$AppUpdateInfoTableCreateCompanionBuilder,
          $$AppUpdateInfoTableUpdateCompanionBuilder,
          (
            AppUpdateInfoData,
            BaseReferences<
              _$LifeOsDatabase,
              $AppUpdateInfoTable,
              AppUpdateInfoData
            >,
          ),
          AppUpdateInfoData,
          PrefetchHooks Function()
        > {
  $$AppUpdateInfoTableTableManager(
    _$LifeOsDatabase db,
    $AppUpdateInfoTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppUpdateInfoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppUpdateInfoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppUpdateInfoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> versionCode = const Value.absent(),
                Value<String?> versionName = const Value.absent(),
                Value<bool> isRequired = const Value.absent(),
                Value<String?> downloadUrl = const Value.absent(),
                Value<String?> checksumSha256 = const Value.absent(),
                Value<int> checkedAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppUpdateInfoCompanion(
                id: id,
                userId: userId,
                versionCode: versionCode,
                versionName: versionName,
                isRequired: isRequired,
                downloadUrl: downloadUrl,
                checksumSha256: checksumSha256,
                checkedAt: checkedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String userId,
                required int versionCode,
                Value<String?> versionName = const Value.absent(),
                required bool isRequired,
                Value<String?> downloadUrl = const Value.absent(),
                Value<String?> checksumSha256 = const Value.absent(),
                required int checkedAt,
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppUpdateInfoCompanion.insert(
                id: id,
                userId: userId,
                versionCode: versionCode,
                versionName: versionName,
                isRequired: isRequired,
                downloadUrl: downloadUrl,
                checksumSha256: checksumSha256,
                checkedAt: checkedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppUpdateInfoTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $AppUpdateInfoTable,
      AppUpdateInfoData,
      $$AppUpdateInfoTableFilterComposer,
      $$AppUpdateInfoTableOrderingComposer,
      $$AppUpdateInfoTableAnnotationComposer,
      $$AppUpdateInfoTableCreateCompanionBuilder,
      $$AppUpdateInfoTableUpdateCompanionBuilder,
      (
        AppUpdateInfoData,
        BaseReferences<
          _$LifeOsDatabase,
          $AppUpdateInfoTable,
          AppUpdateInfoData
        >,
      ),
      AppUpdateInfoData,
      PrefetchHooks Function()
    >;
typedef $$CategorySummaryTableCreateCompanionBuilder =
    CategorySummaryCompanion Function({
      required String userId,
      required String periodKey,
      required String category,
      required double totalAmount,
      required int txCount,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$CategorySummaryTableUpdateCompanionBuilder =
    CategorySummaryCompanion Function({
      Value<String> userId,
      Value<String> periodKey,
      Value<String> category,
      Value<double> totalAmount,
      Value<int> txCount,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$CategorySummaryTableFilterComposer
    extends Composer<_$LifeOsDatabase, $CategorySummaryTable> {
  $$CategorySummaryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get periodKey => $composableBuilder(
    column: $table.periodKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get txCount => $composableBuilder(
    column: $table.txCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategorySummaryTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $CategorySummaryTable> {
  $$CategorySummaryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodKey => $composableBuilder(
    column: $table.periodKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get txCount => $composableBuilder(
    column: $table.txCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategorySummaryTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $CategorySummaryTable> {
  $$CategorySummaryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get periodKey =>
      $composableBuilder(column: $table.periodKey, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get txCount =>
      $composableBuilder(column: $table.txCount, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CategorySummaryTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $CategorySummaryTable,
          CategorySummaryData,
          $$CategorySummaryTableFilterComposer,
          $$CategorySummaryTableOrderingComposer,
          $$CategorySummaryTableAnnotationComposer,
          $$CategorySummaryTableCreateCompanionBuilder,
          $$CategorySummaryTableUpdateCompanionBuilder,
          (
            CategorySummaryData,
            BaseReferences<
              _$LifeOsDatabase,
              $CategorySummaryTable,
              CategorySummaryData
            >,
          ),
          CategorySummaryData,
          PrefetchHooks Function()
        > {
  $$CategorySummaryTableTableManager(
    _$LifeOsDatabase db,
    $CategorySummaryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategorySummaryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategorySummaryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategorySummaryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> periodKey = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<int> txCount = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategorySummaryCompanion(
                userId: userId,
                periodKey: periodKey,
                category: category,
                totalAmount: totalAmount,
                txCount: txCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String periodKey,
                required String category,
                required double totalAmount,
                required int txCount,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CategorySummaryCompanion.insert(
                userId: userId,
                periodKey: periodKey,
                category: category,
                totalAmount: totalAmount,
                txCount: txCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategorySummaryTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $CategorySummaryTable,
      CategorySummaryData,
      $$CategorySummaryTableFilterComposer,
      $$CategorySummaryTableOrderingComposer,
      $$CategorySummaryTableAnnotationComposer,
      $$CategorySummaryTableCreateCompanionBuilder,
      $$CategorySummaryTableUpdateCompanionBuilder,
      (
        CategorySummaryData,
        BaseReferences<
          _$LifeOsDatabase,
          $CategorySummaryTable,
          CategorySummaryData
        >,
      ),
      CategorySummaryData,
      PrefetchHooks Function()
    >;
typedef $$FinanceSummaryTableCreateCompanionBuilder =
    FinanceSummaryCompanion Function({
      required String userId,
      required String periodType,
      required String periodKey,
      required double totalIncome,
      required double totalExpense,
      required int txCount,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$FinanceSummaryTableUpdateCompanionBuilder =
    FinanceSummaryCompanion Function({
      Value<String> userId,
      Value<String> periodType,
      Value<String> periodKey,
      Value<double> totalIncome,
      Value<double> totalExpense,
      Value<int> txCount,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$FinanceSummaryTableFilterComposer
    extends Composer<_$LifeOsDatabase, $FinanceSummaryTable> {
  $$FinanceSummaryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get periodType => $composableBuilder(
    column: $table.periodType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get periodKey => $composableBuilder(
    column: $table.periodKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalIncome => $composableBuilder(
    column: $table.totalIncome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalExpense => $composableBuilder(
    column: $table.totalExpense,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get txCount => $composableBuilder(
    column: $table.txCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FinanceSummaryTableOrderingComposer
    extends Composer<_$LifeOsDatabase, $FinanceSummaryTable> {
  $$FinanceSummaryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodType => $composableBuilder(
    column: $table.periodType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodKey => $composableBuilder(
    column: $table.periodKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalIncome => $composableBuilder(
    column: $table.totalIncome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalExpense => $composableBuilder(
    column: $table.totalExpense,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get txCount => $composableBuilder(
    column: $table.txCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FinanceSummaryTableAnnotationComposer
    extends Composer<_$LifeOsDatabase, $FinanceSummaryTable> {
  $$FinanceSummaryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get periodType => $composableBuilder(
    column: $table.periodType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get periodKey =>
      $composableBuilder(column: $table.periodKey, builder: (column) => column);

  GeneratedColumn<double> get totalIncome => $composableBuilder(
    column: $table.totalIncome,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalExpense => $composableBuilder(
    column: $table.totalExpense,
    builder: (column) => column,
  );

  GeneratedColumn<int> get txCount =>
      $composableBuilder(column: $table.txCount, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FinanceSummaryTableTableManager
    extends
        RootTableManager<
          _$LifeOsDatabase,
          $FinanceSummaryTable,
          FinanceSummaryData,
          $$FinanceSummaryTableFilterComposer,
          $$FinanceSummaryTableOrderingComposer,
          $$FinanceSummaryTableAnnotationComposer,
          $$FinanceSummaryTableCreateCompanionBuilder,
          $$FinanceSummaryTableUpdateCompanionBuilder,
          (
            FinanceSummaryData,
            BaseReferences<
              _$LifeOsDatabase,
              $FinanceSummaryTable,
              FinanceSummaryData
            >,
          ),
          FinanceSummaryData,
          PrefetchHooks Function()
        > {
  $$FinanceSummaryTableTableManager(
    _$LifeOsDatabase db,
    $FinanceSummaryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FinanceSummaryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FinanceSummaryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FinanceSummaryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> periodType = const Value.absent(),
                Value<String> periodKey = const Value.absent(),
                Value<double> totalIncome = const Value.absent(),
                Value<double> totalExpense = const Value.absent(),
                Value<int> txCount = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FinanceSummaryCompanion(
                userId: userId,
                periodType: periodType,
                periodKey: periodKey,
                totalIncome: totalIncome,
                totalExpense: totalExpense,
                txCount: txCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String periodType,
                required String periodKey,
                required double totalIncome,
                required double totalExpense,
                required int txCount,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FinanceSummaryCompanion.insert(
                userId: userId,
                periodType: periodType,
                periodKey: periodKey,
                totalIncome: totalIncome,
                totalExpense: totalExpense,
                txCount: txCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FinanceSummaryTableProcessedTableManager =
    ProcessedTableManager<
      _$LifeOsDatabase,
      $FinanceSummaryTable,
      FinanceSummaryData,
      $$FinanceSummaryTableFilterComposer,
      $$FinanceSummaryTableOrderingComposer,
      $$FinanceSummaryTableAnnotationComposer,
      $$FinanceSummaryTableCreateCompanionBuilder,
      $$FinanceSummaryTableUpdateCompanionBuilder,
      (
        FinanceSummaryData,
        BaseReferences<
          _$LifeOsDatabase,
          $FinanceSummaryTable,
          FinanceSummaryData
        >,
      ),
      FinanceSummaryData,
      PrefetchHooks Function()
    >;

class $LifeOsDatabaseManager {
  final _$LifeOsDatabase _db;
  $LifeOsDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$TaskTimeEntriesTableTableManager get taskTimeEntries =>
      $$TaskTimeEntriesTableTableManager(_db, _db.taskTimeEntries);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$IncomesTableTableManager get incomes =>
      $$IncomesTableTableManager(_db, _db.incomes);
  $$BillsTableTableManager get bills =>
      $$BillsTableTableManager(_db, _db.bills);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$RecurringRulesTableTableManager get recurringRules =>
      $$RecurringRulesTableTableManager(_db, _db.recurringRules);
  $$FulizaLoansTableTableManager get fulizaLoans =>
      $$FulizaLoansTableTableManager(_db, _db.fulizaLoans);
  $$FulizaEventsTableTableManager get fulizaEvents =>
      $$FulizaEventsTableTableManager(_db, _db.fulizaEvents);
  $$PaybillRegistryTableTableManager get paybillRegistry =>
      $$PaybillRegistryTableTableManager(_db, _db.paybillRegistry);
  $$MerchantCategoriesTableTableManager get merchantCategories =>
      $$MerchantCategoriesTableTableManager(_db, _db.merchantCategories);
  $$SmsIngestQueueTableTableManager get smsIngestQueue =>
      $$SmsIngestQueueTableTableManager(_db, _db.smsIngestQueue);
  $$SmsReviewQueueTableTableManager get smsReviewQueue =>
      $$SmsReviewQueueTableTableManager(_db, _db.smsReviewQueue);
  $$SmsQuarantineTableTableManager get smsQuarantine =>
      $$SmsQuarantineTableTableManager(_db, _db.smsQuarantine);
  $$ImportAuditTableTableManager get importAudit =>
      $$ImportAuditTableTableManager(_db, _db.importAudit);
  $$MlTrainingSamplesTableTableManager get mlTrainingSamples =>
      $$MlTrainingSamplesTableTableManager(_db, _db.mlTrainingSamples);
  $$InsightCardsTableTableManager get insightCards =>
      $$InsightCardsTableTableManager(_db, _db.insightCards);
  $$LearningSessionsTableTableManager get learningSessions =>
      $$LearningSessionsTableTableManager(_db, _db.learningSessions);
  $$ReviewSnapshotsTableTableManager get reviewSnapshots =>
      $$ReviewSnapshotsTableTableManager(_db, _db.reviewSnapshots);
  $$AssistantConversationsTableTableManager get assistantConversations =>
      $$AssistantConversationsTableTableManager(
        _db,
        _db.assistantConversations,
      );
  $$AssistantMessagesTableTableManager get assistantMessages =>
      $$AssistantMessagesTableTableManager(_db, _db.assistantMessages);
  $$ExportHistoryTableTableManager get exportHistory =>
      $$ExportHistoryTableTableManager(_db, _db.exportHistory);
  $$AppUpdateInfoTableTableManager get appUpdateInfo =>
      $$AppUpdateInfoTableTableManager(_db, _db.appUpdateInfo);
  $$CategorySummaryTableTableManager get categorySummary =>
      $$CategorySummaryTableTableManager(_db, _db.categorySummary);
  $$FinanceSummaryTableTableManager get financeSummary =>
      $$FinanceSummaryTableTableManager(_db, _db.financeSummary);
}
