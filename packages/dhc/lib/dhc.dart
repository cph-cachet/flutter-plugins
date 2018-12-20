import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DHC extends StatelessWidget {
  void sendRequest() async {
    var url = "http://localhost:80/index.php";
    http.post(url, body: {"content": "Heyyyy"}).then((response) {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
    });

//    http.read("http://example.com/foobar.txt").then(print);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Welcome to Flutter'),
        ),
        body: Center(
          child: Row(
            children: <Widget>[
              FlatButton(
                  onPressed: sendRequest, child: Text('BUTTON'))
            ],
          ),
        ),
      ),
    );
  }
}
