import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ttrss_client/class/articles.dart';
import 'package:ttrss_client/class/feed.dart';
import 'package:ttrss_client/class/session.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Logged extends StatefulWidget {
  final Session session;

  const Logged({
    required this.session,
    Key? key,
  }) : super(key: key);

  Session getSession() {
    return session;
  }

  @override
  LoggedState createState() => LoggedState();
}

class LoggedState extends State<Logged> with SingleTickerProviderStateMixin {
  late Session session = widget.getSession();
  List<Feed> feeds = [];
  List<Widget> tabFeed = [];
  StreamSubscription<List>? feedLoading;
  Widget? viewArticles;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();

    refresh();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
  }

  Future<void> refresh() async {
    session.getFeeds().then((value) {
      setFeeds(value);
    });
  }

  void setArticles(List<Articles> articles) {
    setState(() {
      List<Widget> articlesList = [];
      for (var article in articles) {
        articlesList.add(articlesCard(article.title, article.link, context));
      }

      viewArticles = ListView(
        children: articlesList,
      );
    });
  }

  void setArticlesOfFeedIndex(int index) {
    setState(() {
      viewArticles = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [Center(child: CircularProgressIndicator())]);

      feedLoading =
          session.getArticles(feeds[index]).asStream().listen(setArticles);
    });
  }

  void setArticlesOfCurrentIndex() {
    if (feedLoading != null) {
      feedLoading?.cancel();
    }

    setArticlesOfFeedIndex(_tabController!.index);
  }

  void setFeeds(List<Feed>? gettedfeeds) {
    if (gettedfeeds == null) {
      return;
    }

    setState(() {
      for (var feed in gettedfeeds) {
        feeds.add(feed);
        tabFeed.add(Tab(child: Text(feed.title)));
      }

      _tabController = TabController(length: tabFeed.length, vsync: this);

      _tabController?.addListener(setArticlesOfCurrentIndex);

      setArticlesOfFeedIndex(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("Loading feeds"),
              SizedBox(height: 15),
              CircularProgressIndicator()
            ],
          ),
        ),
      );
    }
    return Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          title: const Text("TinyTinyRss"),
          centerTitle: true,
          backgroundColor: Colors.purple,
          bottom: _tabController!.length == 0
              ? null
              : TabBar(
                  isScrollable: true,
                  controller: _tabController,
                  unselectedLabelColor: Colors.white.withOpacity(0.3),
                  indicatorColor: Colors.white,
                  tabs: tabFeed,
                ),
        ),
        body: viewArticles);
  }
}

Card articlesCard(String title, String link, BuildContext context) {
  return Card(
    child: Container(
        margin: const EdgeInsets.all(10.0),
        child: TextButton(
          child: Text(
            title,
            style: const TextStyle(fontSize: 19.0),
          ),
          onPressed: () => {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(title),
                ),
                body: WebView(
                  initialUrl: link,
                ),
              );
            }))
          },
        )),
  );
}
