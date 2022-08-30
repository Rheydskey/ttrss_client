import 'dart:convert';

import 'package:http/http.dart' as http;

class Server {
  String uri;

  Server(this.uri);

  Future<bool> isTtrssServer() async {
    var uri = Uri.parse(
        this.uri.endsWith("/") ? this.uri + "api/" : this.uri + "/api/");
    var res = await http.post(uri, body: '{"op": ""}');
    if (res.statusCode == 200) {
      try {
        jsonDecode(res.body);
        return true;
      } catch (_) {}
    }

    return false;
  }
}
