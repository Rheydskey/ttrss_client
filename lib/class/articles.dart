import 'package:html_unescape/html_unescape.dart';

class Articles {
  int id;
  bool unread;
  bool marked;
  bool published;
  int updated;
  bool isUpdated;
  String title;
  String link;
  int feedId;
  List<dynamic> tags;
  List<dynamic> label;
  String feedTitle;
  int commentsCount;
  String commentsLink;
  bool alwaysDisplayAttachment;
  String author;
  int score;
  String? note;
  String lang;

  Articles(
      this.id,
      this.title,
      this.link,
      this.commentsLink,
      this.commentsCount,
      this.author,
      this.feedId,
      this.feedTitle,
      this.label,
      this.isUpdated,
      this.updated,
      this.unread,
      this.alwaysDisplayAttachment,
      this.marked,
      this.note,
      this.published,
      this.lang,
      this.score,
      this.tags);

  static Articles fromJson(Map json) {
    return Articles(
        json["id"],
        HtmlUnescape().convert(json["title"]),
        json["link"],
        json["comments_link"],
        json["comments_count"],
        json["author"],
        json["feed_id"],
        json["feed_title"],
        json["labels"],
        json["is_updated"],
        json["updated"],
        json["unread"],
        json["always_display_attachments"],
        json["marked"],
        json["note"],
        json["published"],
        json["lang"],
        json["score"],
        json["tags"]);
  }
}
