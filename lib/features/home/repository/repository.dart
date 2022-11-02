import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final updateBookmarkProvider =
    Provider.family<void, int>((ref, id) => GetFeedsRepo(ref).bookmark(id));

final getFeedsRepoProvider = Provider((ref) => GetFeedsRepo(ref));

class GetFeedsRepo {
  final ProviderRef ref;

  GetFeedsRepo(this.ref);

  /// Fetch all Feeds
  Future<Map<String, dynamic>> fetchFeeds() async {
    http.Response res = await http.get(
      Uri.parse('https://read.rusi.me/v1/entries'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': '-5YfpcHn8F__jMhC0MFA-AaMrqLl5ehBaesPuvjCOzg=',
      },
    );

    Map<String, dynamic> decodedData = jsonDecode(res.body);

    return decodedData;
  }

  /// Bookmark Feeds
  void bookmark(int id) async {
    http.Response res = await http.put(
      Uri.parse('https://read.rusi.me/v1/entries/$id/bookmark'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': '-5YfpcHn8F__jMhC0MFA-AaMrqLl5ehBaesPuvjCOzg=',
      },
    );

    log(res.body.toString());
    log(res.statusCode.toString());
  }

  /// Bookmark Status
  Future<Map<String, dynamic>> bookmarkStatus(int id) async {
    http.Response res = await http.get(
      Uri.parse('https://read.rusi.me/v1/entries/$id/bookmark'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': '-5YfpcHn8F__jMhC0MFA-AaMrqLl5ehBaesPuvjCOzg=',
      },
    );

    Map<String, dynamic> decodedData = jsonDecode(res.body);
    log('GET BOOK STATUS: $decodedData');

    return decodedData;
  }

  /// Get Feed
  void getFeed() async {
    // try
    http.Response res = await http.get(
      // Uri.parse('https://read.rusi.me/v1/feeds/759/entries/150340'),
      Uri.parse('https://read.rusi.me/v1/feeds/759'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Auth-Token': '-5YfpcHn8F__jMhC0MFA-AaMrqLl5ehBaesPuvjCOzg=',
      },
    );

    Map<String, dynamic> decodedData = jsonDecode(res.body);
    log('GET FEED: ${decodedData}');
    // log(res.body.toString());
  }
}

final feedsFutureProvider = FutureProvider((ref) {
  final getFeedsRepo = ref.watch(getFeedsRepoProvider);
  return getFeedsRepo.fetchFeeds();
});

final bookmarkStatusProvider = FutureProvider.family<void, int>((ref, id) {
  final getFeedsRepo = ref.watch(getFeedsRepoProvider);
  return getFeedsRepo.bookmarkStatus(id);
});

// final streamBookmarkProvider =
//     StreamProvider.family<http.Response, int>((ref, id) async* {
//   http.Response res = await http.get(
//     Uri.parse('https://read.rusi.me/v1/entries/$id/bookmark'),
//     headers: {
//       'Content-Type': 'application/json; charset=UTF-8',
//       'X-Auth-Token': '-5YfpcHn8F__jMhC0MFA-AaMrqLl5ehBaesPuvjCOzg=',
//     },
//   );
//
//   Map<String, dynamic> decodedData = jsonDecode(res.body);
//
//   log('STREAM RES: ${decodedData['entries'].toString()}');
//   yield res;
// });
