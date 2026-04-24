import 'package:isar_community/isar.dart';

abstract class IsarDataAccess<T> {
  Isar get isarInstance;

  /// Store or update a single object.
  Future<int> store(T object) async => await isarInstance.writeTxn(() => isarInstance.collection<T>().put(object));

  /// Store or update multiple objects.
  Future<List<int>> storeAll(List<T> objects) async =>
      await isarInstance.writeTxn(() => isarInstance.collection<T>().putAll(objects));

  /// Retrieve an object by its ID.
  Future<T?> getById(int id) async => await isarInstance.collection<T>().get(id);

  Future<T?> get(int id) => getById(id);

  /// Retrieve all objects in the collection.
  Future<List<T>> getAll() async => await isarInstance.collection<T>().where().findAll();

  /// Delete an object by its ID.
  Future<bool> deleteById(int id) async => await isarInstance.writeTxn(() => isarInstance.collection<T>().delete(id));

  Future<bool> delete(int id) => deleteById(id);

  /// Delete multiple objects by their IDs.
  Future<int> deleteByIds(List<int> ids) async =>
      await isarInstance.writeTxn(() => isarInstance.collection<T>().deleteAll(ids));

  /// Query builder: run a custom Isar Query.
  Future<QueryBuilder<T, R, QAfterWhereClause>> query<R>(
    QueryBuilder<T, R, QAfterWhereClause> Function(QueryBuilder<T, R, QWhereClause>) builder,
  ) async {
    final queryBuilder = isarInstance.collection<T>().where() as QueryBuilder<T, R, QWhereClause>;
    return builder(queryBuilder);
  }

  /// Stream all objects in the collection in real-time.
  Stream<List<T>> watchAll({bool fireImmediately = true}) async* {
    yield* isarInstance.collection<T>().where().watch(fireImmediately: fireImmediately);
  }

  Future<Stream<void>> watchForChanges({bool fireImmediately = true}) async =>
      isarInstance.collection<T>().where().watchLazy(fireImmediately: fireImmediately);

  /// Stream specific object by ID in real-time.
  Stream<T?> watchById(int id, {bool fireImmediately = true}) async* {
    yield* isarInstance.collection<T>().watchObject(id, fireImmediately: fireImmediately);
  }

  Stream<T?> watch(int id, {bool fireImmediately = true}) => watchById(id, fireImmediately: fireImmediately);

  /// Stream query results in real-time.
  Stream<List<T>> watchByQuery(
    QueryBuilder<T, T, QAfterWhereClause> Function(QueryBuilder<T, T, QWhereClause>) builder,
  ) async* {
    final queryBuilder = isarInstance.collection<T>().where();
    yield* builder(queryBuilder).watch(fireImmediately: true);
  }
}
