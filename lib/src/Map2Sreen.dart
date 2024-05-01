import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class Map2Screen extends StatelessWidget {
  late String position;

  Map2Screen (String position) {
    this.position = position;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: InAppWebViewPage(position),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Icon(Icons.arrow_back),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class InAppWebViewPage extends StatefulWidget {
  late String position;

  InAppWebViewPage (String position) {
    this.position = position;
  }

  @override
  _InAppWebViewPageState createState() => _InAppWebViewPageState(position);
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  late String position;
  // InAppWebViewController? webViewController;

  _InAppWebViewPageState (String position) {
    this.position = position;
  }

  Future<List<List<dynamic>>> loadCsvData() async {
    final csv1 = await rootBundle.loadString('assets/csv/login_20240217.csv');
    final csv2 = await rootBundle.loadString('assets/csv/login_addr.csv');
    List<List<dynamic>> row1 = const CsvToListConverter().convert(csv1);
    List<List<dynamic>> row2 = const CsvToListConverter().convert(csv2);

    List<List<dynamic>> rowsAsListOfValues = [];
    Loop:
    for (List list in row2) {
      for (List list2 in row1) {
        if (list[1] == position && list2[4] == position) {
          List<dynamic> newList = [];
          newList.add(list2[2]);
          newList.add(list[2]);
          newList.add(list[3]);
          rowsAsListOfValues.add(newList);
          break Loop;
        }
      }
    }
    return rowsAsListOfValues;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<List<dynamic>>>(
        future: loadCsvData(),
        builder: (BuildContext context, AsyncSnapshot<List<List<dynamic>>> snapshot) {
          if (snapshot.hasData) {
            String queryString = '';
            // queryString += 'l0=${snapshot.data?[i][0]}&
            for (int i = 0; i < (snapshot.data?.length ?? 0); i++) {
              queryString += 'x${i+1}=${snapshot.data?[i][0]}&y${i+1}=${snapshot.data?[i][1]}&z${i+1}=${snapshot.data?[i][2]}&';
            }
            if (queryString.isNotEmpty) {
              queryString = queryString.substring(0, queryString.length - 1);
            } else {
              Navigator.pop(context);
              return Container();
            }

            String url = "http://localhost:8080/assets/web/kakaomap.html?$queryString";

            return
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(url)),
                onWebViewCreated: (InAppWebViewController controller) {
                  controller.clearCache();
                  // webViewController = controller;
                },
              );
          } else {
            return Center(
              child: SizedBox(
                width: 100.0,
                height: 100.0,
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}