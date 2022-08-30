import 'package:ttrss_client/class/feed.dart';

class Categories {
  String id;
  String name;
  String type;
  int unread;
  int bareId;
  List<Feed> items;

  Categories(
      this.id, this.name, this.type, this.unread, this.bareId, this.items);
}
