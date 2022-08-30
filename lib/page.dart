import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ttrss_client/class/articles.dart';
import 'package:ttrss_client/class/feed.dart';
import 'package:ttrss_client/class/session.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FeedPage {
  List<Articles>? articles;

  void setArticles(List<Articles> listArticles) {
    articles ??= listArticles;
  }

  Widget toWidget(BuildContext context) {
    if (articles == null || articles!.isEmpty) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [Center(child: CircularProgressIndicator())]);
    }

    return ListView(
        children: articles!
            .map((e) => articlesCard(e.title, e.link, context))
            .toList());
  }
}

class FeedPages {
  List<FeedPage> pages = [];

  void setArticles(int index, List<Articles> articles) {
    getPage(index)?.setArticles(articles);
  }

  void addPage(FeedPage page) {
    pages.add(page);
  }

  FeedPage? getPage(int index) {
    return pages[index];
  }

  List<Widget> getWidgets(BuildContext context, Function(int) refresh) {
    return pages.map((e) => e.toWidget(context)).toList();
  }
}

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
  final PageController _pageController = PageController(keepPage: false);
  List<Feed> feeds = [];
  List<Widget> tabFeed = [];
  FeedPages pageFeed = FeedPages();
  List<Widget> viewArticles = [];
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
    _pageController.dispose();
  }

  Future<void> refresh() async {
    session.getFeeds().then((value) {
      setFeeds(value);
    });
  }

  void tabPageListener(String from, int index) {
    if (from == "tab") {
      _pageController.jumpToPage(index);
    }

    if (from == "page") {
      _tabController?.animateTo(index);
    }

    setArticles(index);
  }

  Future<void> setArticles(int index, {bool showSnackbar = false}) async {
    List<Articles> articles = await session.getArticles(feeds[index]);

    pageFeed.setArticles(index, articles);
    setState(() {
      viewArticles =
          pageFeed.getWidgets(context, (index) => setArticles(index));
    });

    if (showSnackbar) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feeds Refreshed'),
        ),
      );
    }
  }

  void setFeeds(List<Feed>? gettedfeeds) {
    if (gettedfeeds == null) {
      return;
    }

    setState(() {
      for (var feed in gettedfeeds) {
        feeds.add(feed);
        tabFeed.add(Tab(child: Text(feed.title)));
        pageFeed.addPage(FeedPage());
      }
      viewArticles =
          pageFeed.getWidgets(context, (index) => setArticles(index));

      _tabController = TabController(length: tabFeed.length, vsync: this);

      _tabController
          ?.addListener(() => tabPageListener("tab", _tabController!.index));

      setArticles(0);
    });
  }

  PreferredSizeWidget? buildTabBar() {
    return _tabController!.length == 0
        ? null
        : TabBar(
            isScrollable: true,
            controller: _tabController,
            unselectedLabelColor: Colors.white.withOpacity(0.3),
            indicatorColor: Colors.white,
            tabs: tabFeed,
          );
  }

  Widget? buildDrawer() {
    return Drawer(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
                height: MediaQuery.of(context).padding.top + 30,
                child: const DrawerHeader(
                    padding: EdgeInsets.zero,
                    margin: EdgeInsets.zero,
                    child: Text("TTRss Client",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20.0)))),
            Expanded(
                child: ListView.builder(
              padding: EdgeInsets.zero,
              primary: false,
              itemCount: feeds.length,
              itemBuilder: (BuildContext context, index) => Container(
                margin: const EdgeInsets.only(top: .0, bottom: 8.0),
                child: TextButton(
                    onPressed: () {
                      _tabController?.index = index;
                      Navigator.pop(context);
                    },
                    child: SizedBox(
                        width: double.maxFinite,
                        child: Text(
                          feeds[index].title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ))),
              ),
            ))
          ]),
    );
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
        drawer: buildDrawer(),
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          leading: Builder(builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          }),
          title:
              const Text("TinyTinyRss", style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.purple.shade900,
          bottom: buildTabBar(),
        ),
        body: PageView(
          controller: _pageController,
          children: viewArticles
              .asMap()
              .map((index, value) => MapEntry(
                  index,
                  RefreshIndicator(
                    child: value,
                    onRefresh: () => setArticles(index, showSnackbar: true),
                  )))
              .values
              .toList(),
          onPageChanged: (index) => tabPageListener(
            "page",
            index,
          ),
        ));
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
