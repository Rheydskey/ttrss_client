class Feed {
  String feedUrl;
  String title;
  int id;
  int unread;
  bool hasIcon;
  int catId;
  int lastUpdated;
  int orderId;

  Feed(this.id, this.title, this.feedUrl, this.unread, this.catId,
      this.lastUpdated, this.hasIcon, this.orderId);

  static Feed? fromJson(Map json) {
    try {
      return Feed(
          json["id"],
          json["title"],
          json["feed_url"],
          json["unread"],
          json["cat_id"],
          json["last_updated"],
          json["has_icon"],
          json["order_id"]);
    } catch (e) {
      return null;
    }
  }
}
