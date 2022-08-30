import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttrss_client/class/session.dart';
import 'package:ttrss_client/http/api/login.dart';
import 'package:ttrss_client/http/server.dart';
import 'package:ttrss_client/page.dart';

void main() {
  runApp(const TTRssApp());
}

class TTRssApp extends StatelessWidget {
  const TTRssApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
          appBar: AppBar(
            title: const Text("TTRSS"),
            centerTitle: true,
          ),
          body: const Home()),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  HomeState createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  Container newInput(TextEditingController controller, String name,
      {String type = "Text"}) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: TextFormField(
          obscureText: type == "Password" ? true : false,
          validator: (value) {
            return value == null || value.isEmpty
                ? 'Please enter some text'
                : null;
          },
          controller: controller,
          decoration: InputDecoration(
              hintText: name,
              border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2.0))),
        ));
  }

  final _formKey = GlobalKey<FormState>();
  final instanceController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  bool disabled = false;

  Future<Map<String, String>> getPreferences() async {
    final instance = await SharedPreferences.getInstance();
    Map<String, String> prefs = {};
    try {
      prefs.addAll({"name": instance.getString("name")!});
      prefs.addAll({"url": instance.getString("url")!});
      prefs.addAll({"password": instance.getString("password")!});
    } catch (_) {
      return {};
    }

    return prefs;
  }

  @override
  void initState() {
    getPreferences().then((value) {
      instanceController.text = value["url"] ?? "";
      nameController.text = value["name"] ?? "";
      passwordController.text = value["password"] ?? "";
    });

    super.initState();
  }

  @override
  void dispose() {
    instanceController.dispose();
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(5.0),
        child: createForm(),
      ),
    );
  }

  Widget createForm() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        newInput(instanceController, "url"),
        newInput(nameController, "Name"),
        newInput(passwordController, "Password", type: "Password"),
        Container(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            child: ElevatedButton(
              child: const Text("Login"),
              onPressed: () {
                if (disabled) {
                  return;
                }
                sendFormAndChangeViewIfValid();
              },
            )),
      ],
    );
  }

  Future<void> savePrefs(String name, String password, String url) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('name', name);
    await prefs.setString('password', password);
    await prefs.setString('url', url);
  }

  void sendFormAndChangeViewIfValid() {
    if (_formKey.currentState!.validate()) {
      disabled = true;
      Login(nameController.text, passwordController.text,
              Server(instanceController.text))
          .send()
          .then((value) {
        savePrefs(nameController.text, passwordController.text,
                instanceController.text)
            .then((_) => changeViewIfValid(value));
      });
    }
  }

  void changeViewIfValid(Token? value) {
    if (value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
          'Password or User is incorrect',
          style: TextStyle(color: Colors.red),
        )),
      );
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) =>
              Logged(session: Session(value, instanceController.text))));
    }
  }
}
