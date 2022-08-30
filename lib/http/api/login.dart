import 'dart:convert';

import 'package:ttrss_client/http/server.dart';
import 'package:http/http.dart' as http;

class Login {
  String name;
  String password;
  Server instance;

  Login(this.name, this.password, this.instance);

  Future<Token?> send() async {
    var res = await http.post(Uri.parse(instance.uri + "/api/"),
        body: jsonEncode({"op": "login", "user": name, "password": password}));
    try {
      return Token(jsonDecode(res.body)["content"]["session_id"]);
    } catch (_) {
      return null;
    }
  }
}

class Token {
  String token;
  Token(this.token);
}
