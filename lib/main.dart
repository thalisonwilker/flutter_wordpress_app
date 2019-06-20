import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import './post.dart';
/*
  Referência: https://demo.wp-api.org/wp-json/wp/v2
  Url demo: https://demo.wp-api.org/wp-json/wp/v2
 */
final String baseUrl = 'magroodontologia.com.br';

void main() {
  runApp(MaterialApp(
    title: "Flutter WordPress App",
    home: MyApp(),
    theme: ThemeData(primaryColor: Color.fromRGBO(25, 42, 86, 1.0)),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List posts = [];
  List categories = [];
  List authors = [];

  String startUrl = 'https://$baseUrl/wp-json/wp/v2/posts';
  String url;
  int page = 1;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    getPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        centerTitle: true,
        elevation: 10.0,
      ),
      drawer: Drawer(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 40.0,
              ),
              Text(
                "Categorias",
                textAlign: TextAlign.center,
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, i) {
                      return ListTile(
                        title: Text(categories[i]["name"]),
                        subtitle: Text(categories[i]["description"]),
                        onTap: () {
                          print(categories[i]["id"]);
                        },
                      );
                    }),
              )
            ],
          ),
        ),
      ),
      body: loading
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: CircularProgressIndicator(),
                )
              ],
            )
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (BuildContext context, int i){
                print(posts[i]["source_img"]);

                return GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context){
                        return new Post(html: posts[i],);
                      }
                    ));
                  },
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            posts[i]["title"]["rendered"],
                            style: TextStyle(fontSize: 22.0),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          HtmlWidget(
                            posts[i]["excerpt"]["rendered"],
                            webView: false,
                          ),
                          posts[i]["_links"]["wp:featuredmedia"] != null
                          ? Image.network(posts[i]["source_img"] ?? 'http://placehold.it/100x100')
                              : Container()
                        ],
                      ),
                    ),
                  ),
                );
              }),
    );
  }

  getPosts() async {
    url = startUrl;

    setState(() {
      loading = true;
    });
    await getCategories();
    List l = [];
    http.Response postRequest = await http.get(url);
    List jsonResp = jsonDecode(postRequest.body);

    for (int x = 0; x < jsonResp.length; x++) {
      if(jsonResp[x]["_links"]["wp:featuredmedia"] !=null){
        String sourceImageUrl = await getImageFeatured(jsonResp[x]["_links"]["wp:featuredmedia"][0]["href"]);
        jsonResp[x]["source_img"] = sourceImageUrl;
      }
      l.add(jsonResp[x]);
    }
    setState(() {
      loading = false;
      posts = l;
    });
  }

  getCategories() async {
    List l = [];
    http.Response categoriesResponse =
        await http.get('https://$baseUrl/wp-json/wp/v2/categories');
    List jsonResp = jsonDecode(categoriesResponse.body);

    for (int x = 0; x < jsonResp.length; x++) {
      l.add(jsonResp[x]);
    }
    setState(() {
      categories = l;
    });
  }

  Future getImageFeatured(var link) async {
    http.Response response = await http.get(link);
    return jsonDecode(response.body)["source_url"].toString();
  }
}
