// dart format width=80
// GENERATED CODE, DO NOT EDIT BY HAND.
// ignore_for_file: type=lint
import 'package:drift/drift.dart';

class Login extends Table with TableInfo<Login, LoginData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Login(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> userUid = GeneratedColumn<String>(
    'user_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> regraUsuarioItem = GeneratedColumn<String>(
    'regra_usuario_item',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 70,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [userUid, regraUsuarioItem, email];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'login';
  @override
  Set<GeneratedColumn> get $primaryKey => {userUid};
  @override
  LoginData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoginData(
      userUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_uid'],
      )!,
      regraUsuarioItem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}regra_usuario_item'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
    );
  }

  @override
  Login createAlias(String alias) {
    return Login(attachedDatabase, alias);
  }
}

class LoginData extends DataClass implements Insertable<LoginData> {
  final String userUid;
  final String regraUsuarioItem;
  final String email;
  const LoginData({
    required this.userUid,
    required this.regraUsuarioItem,
    required this.email,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_uid'] = Variable<String>(userUid);
    map['regra_usuario_item'] = Variable<String>(regraUsuarioItem);
    map['email'] = Variable<String>(email);
    return map;
  }

  LoginCompanion toCompanion(bool nullToAbsent) {
    return LoginCompanion(
      userUid: Value(userUid),
      regraUsuarioItem: Value(regraUsuarioItem),
      email: Value(email),
    );
  }

  factory LoginData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoginData(
      userUid: serializer.fromJson<String>(json['userUid']),
      regraUsuarioItem: serializer.fromJson<String>(json['regraUsuarioItem']),
      email: serializer.fromJson<String>(json['email']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userUid': serializer.toJson<String>(userUid),
      'regraUsuarioItem': serializer.toJson<String>(regraUsuarioItem),
      'email': serializer.toJson<String>(email),
    };
  }

  LoginData copyWith({
    String? userUid,
    String? regraUsuarioItem,
    String? email,
  }) => LoginData(
    userUid: userUid ?? this.userUid,
    regraUsuarioItem: regraUsuarioItem ?? this.regraUsuarioItem,
    email: email ?? this.email,
  );
  LoginData copyWithCompanion(LoginCompanion data) {
    return LoginData(
      userUid: data.userUid.present ? data.userUid.value : this.userUid,
      regraUsuarioItem: data.regraUsuarioItem.present
          ? data.regraUsuarioItem.value
          : this.regraUsuarioItem,
      email: data.email.present ? data.email.value : this.email,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoginData(')
          ..write('userUid: $userUid, ')
          ..write('regraUsuarioItem: $regraUsuarioItem, ')
          ..write('email: $email')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userUid, regraUsuarioItem, email);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoginData &&
          other.userUid == this.userUid &&
          other.regraUsuarioItem == this.regraUsuarioItem &&
          other.email == this.email);
}

class LoginCompanion extends UpdateCompanion<LoginData> {
  final Value<String> userUid;
  final Value<String> regraUsuarioItem;
  final Value<String> email;
  final Value<int> rowid;
  const LoginCompanion({
    this.userUid = const Value.absent(),
    this.regraUsuarioItem = const Value.absent(),
    this.email = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LoginCompanion.insert({
    required String userUid,
    required String regraUsuarioItem,
    required String email,
    this.rowid = const Value.absent(),
  }) : userUid = Value(userUid),
       regraUsuarioItem = Value(regraUsuarioItem),
       email = Value(email);
  static Insertable<LoginData> custom({
    Expression<String>? userUid,
    Expression<String>? regraUsuarioItem,
    Expression<String>? email,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userUid != null) 'user_uid': userUid,
      if (regraUsuarioItem != null) 'regra_usuario_item': regraUsuarioItem,
      if (email != null) 'email': email,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LoginCompanion copyWith({
    Value<String>? userUid,
    Value<String>? regraUsuarioItem,
    Value<String>? email,
    Value<int>? rowid,
  }) {
    return LoginCompanion(
      userUid: userUid ?? this.userUid,
      regraUsuarioItem: regraUsuarioItem ?? this.regraUsuarioItem,
      email: email ?? this.email,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userUid.present) {
      map['user_uid'] = Variable<String>(userUid.value);
    }
    if (regraUsuarioItem.present) {
      map['regra_usuario_item'] = Variable<String>(regraUsuarioItem.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoginCompanion(')
          ..write('userUid: $userUid, ')
          ..write('regraUsuarioItem: $regraUsuarioItem, ')
          ..write('email: $email, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class DatabaseAtV3 extends GeneratedDatabase {
  DatabaseAtV3(QueryExecutor e) : super(e);
  late final Login login = Login(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [login];
  @override
  int get schemaVersion => 3;
}
