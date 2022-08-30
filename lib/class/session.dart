import 'dart:convert';

import 'package:http/http.dart';
import 'package:ttrss_client/class/articles.dart';
import 'package:ttrss_client/class/feed.dart';
import 'package:ttrss_client/http/api/login.dart';

class Session {
  final Token token;
  Uri instance;

  Session(this.token, String instance)
      : instance = Uri.parse(instance + "/api/");

  Future<List<Feed>?> getFeeds({int catid = -3}) async {
    List<Feed> result = [];
    var e = await post(instance,
        body: jsonEncode({
          "sid": token.token,
          "op": "getFeeds",
          "cat_id": catid.toString()
        }));

    for (var item in jsonDecode(e.body)["content"]) {
      var value = Feed.fromJson(item);
      if (value != null) {
        result.add(value);
      }
    }

    if (result.isNotEmpty) {
      return result;
    }

    return null;
  }

  Future<List<Articles>> getArticles(Feed feed) async {
    List<Articles> result = [];
    var res = await post(instance,
        body: jsonEncode({
          "sid": token.token,
          "op": "getHeadlines",
          "feed_id": feed.id,
        }));
    var articles = jsonDecode(res.body)["content"];
    for (var article in articles) {
      result.add(Articles.fromJson(article));
    }
    return result;
  }

  void getUnread() {}

  void getCategories() {}

  void getHeadlines() {}

  void updateArticle() {}

  bool updateFeed() {
    return false;
  }

  void getCounter() {}

  void getLabels() {}

  void subscribeToFeed() {}

  void unsubscribetFeed() {}

  Future<void> getFeedTree() async {
    var e = await post(instance,
        body: jsonEncode({
          "sid": token.token,
          "op": "getFeedTree",
        }));
    jsonDecode(e.body);

    return;
  }
}
