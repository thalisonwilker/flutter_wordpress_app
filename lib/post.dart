import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Post extends StatefulWidget {
  var html;
  Post({this.html});

  @override
  _PostState createState() => _PostState();
}



class _PostState extends State<Post> {

  String authorName = '';
String authorGravatar = '';


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }
  @override
  Widget build(BuildContext context) {


    return Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: 12.0,
                  ),
                  Text(
                    widget.html["title"]["rendered"],
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 12.0,
                  ),
                  HtmlWidget(
                    widget.html["excerpt"]["rendered"],
                    webView: false,
                  ),
                  HtmlWidget(
                    widget.html["content"]["rendered"],
                    webView: false,
                  ),
                ],
              )),
        ),
        floatingActionButton: IconButton(
          onPressed: () {},
          icon: Icon(Icons.share, color: Theme.of(context).primaryColor),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Image.network((authorGravatar)),
              Text(authorName)
            ],
          ),
        ));
  }

  getData() async {
    await getAuthorData();

  }

  getAuthorData() async {
    print(widget.html["_links"]["author"]);
    http.Response response = await http.get(widget.html["_links"]["author"][0]["href"]);
    var authorData = jsonDecode(response.body);

    setState(() {
      authorName = authorData["name"];
      authorGravatar = authorData["avatar_urls"]["48"];
    });
  }
}
