/*
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: InAppWebViewPage(),
    );
  }
}

class InAppWebViewPage extends StatefulWidget {
  @override
  _InAppWebViewPageState createState() => _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('InAppWebView Example'),
      ),
      body: Container(
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri("https://map.kakao.com/?nil_profile=title&nil_src=local")),
        ),
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:untitled/src/Map2Sreen.dart';
import 'package:untitled/src/MapScreen.dart';
//import 'package:flutter_kakao_map_sample/src/home.dart';

InAppLocalhostServer server = InAppLocalhostServer(port: 8080);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await server.start();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
// This widget is the root of your application.
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<List<dynamic>>> loadCsvData() async {
    final csvData = await rootBundle.loadString(
        'assets/csv/login_20240217.csv');
    List<List<dynamic>> rowsAsListOfValues =
    const CsvToListConverter().convert(csvData);

    return rowsAsListOfValues;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Theme
        //       .of(context)
        //       .colorScheme
        //       .inversePrimary,
        //   title: Text(widget.title),
        // ),
        body: Stack(
          children: <Widget>[
            FutureBuilder<List<List<dynamic>>>(
              future: loadCsvData(),
              builder: (BuildContext context, AsyncSnapshot<List<List<dynamic>>> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Map2Screen(snapshot
                                .data?[index][4])),
                          );
                        },
                        child: Card(
                          child: Container(
                            padding: EdgeInsets.all(20.0),
                            margin: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 20.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border:
                              Border.all(color: Colors.black, width: 2.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Text(
                                '취급 업종 : ${snapshot
                                    .data?[index][1]}\n업체명 : ${snapshot
                                    .data?[index][2]}\n전화번호 : ${snapshot
                                    .data?[index][3]}\n소재지 : ${snapshot
                                    .data?[index][4]}',
                                style: TextStyle(color: Colors.black)),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            Positioned(
              bottom: 50.0,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.center,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MapScreen()),
                    );
                    // 여기에 지도 화면으로 이동하는 코드를 작성하세요.
                  },
                  child: Icon(Icons.map),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

