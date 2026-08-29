part of '../api.dart';

class _SearchApi {
  // Replace these before shipping — safe client-side (search-only key).
  static const _host = 'YOUR_TYPESENSE_HOST';
  static const _searchKey = 'YOUR_SEARCH_ONLY_API_KEY';
  static const _collection = 'courses';

  final _client = http.Client();

  /// Returns courseIds ordered by Typesense relevance.
  /// Caller fetches full docs from Firestore using the returned ids.
  Future<Result<SearchResult?>> searchCourses({
    required String query,
    String? institutionId,
    String? catalogId,
    int page = 1,
    int perPage = 20,
  }) =>
      Result.tryRunAsync(() async {
        final filters = <String>[];
        if (institutionId != null) filters.add('institutionId:=$institutionId');
        if (catalogId != null) filters.add('catalogId:=$catalogId');

        final uri = Uri.parse(
                'https://$_host/collections/$_collection/documents/search')
            .replace(queryParameters: {
          'q': query,
          'query_by': 'courseTitle',
          'per_page': '$perPage',
          'page': '$page',
          if (filters.isNotEmpty) 'filter_by': filters.join(' && '),
        });

        final response = await _client.get(uri, headers: {
          'X-TYPESENSE-API-KEY': _searchKey,
        });

        if (response.statusCode != 200) {
          throw Exception('Typesense error ${response.statusCode}: ${response.body}');
        }

        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final hits = body['hits'] as List<dynamic>;
        final found = body['found'] as int;

        return SearchResult(
          courseIds: hits
              .map((h) => (h['document'] as Map<String, dynamic>)['courseId']
                  as String)
              .toList(),
          totalFound: found,
          page: page,
          perPage: perPage,
        );
      });
}

class SearchResult {
  final List<String> courseIds;
  final int totalFound;
  final int page;
  final int perPage;

  bool get hasMore => (page * perPage) < totalFound;

  const SearchResult({
    required this.courseIds,
    required this.totalFound,
    required this.page,
    required this.perPage,
  });
}
