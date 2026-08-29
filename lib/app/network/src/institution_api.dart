part of '../api.dart';

class _InstitutionApi {
  /// Expose typed query — callers can apply .where/.orderBy as needed.
  Query<InstitutionEntity> institutionQuery() => ApiPaths.institutions();

  Future<Result<List<InstitutionEntity>?>> listInstitutions({
    String? country,
  }) =>
      Result.tryRunAsync(() async {
        Query<InstitutionEntity> q =
            ApiPaths.institutions().orderBy('name');
        if (country != null) q = q.where('country', isEqualTo: country);
        final snapshot = await q.get();
        return snapshot.docs.map((d) => d.data()).toList();
      });

  Future<Result<InstitutionEntity?>> getInstitution(String id) =>
      Result.tryRunAsync(() async {
        final doc = await ApiPaths.institution(id).get();
        return doc.data();
      });

  /// Expose typed query for catalog — callers can paginate, filter by institution.
  Query<CatalogEntity> catalogQuery({String? institutionId}) {
    Query<CatalogEntity> q = ApiPaths.catalog().orderBy('title');
    if (institutionId != null) {
      q = q.where('institutionId', isEqualTo: institutionId);
    }
    return q;
  }

  Future<Result<List<CatalogEntity>?>> listCatalog({
    String? institutionId,
    int limit = 50,
    DocumentSnapshot<CatalogEntity>? startAfter,
  }) =>
      Result.tryRunAsync(() async {
        Query<CatalogEntity> q =
            catalogQuery(institutionId: institutionId).limit(limit);
        if (startAfter != null) q = q.startAfterDocument(startAfter);
        final snapshot = await q.get();
        return snapshot.docs.map((d) => d.data()).toList();
      });

  Future<Result<CatalogEntity?>> getCatalogEntry(String id) =>
      Result.tryRunAsync(() async {
        final doc = await ApiPaths.catalogEntry(id).get();
        return doc.data();
      });
}
