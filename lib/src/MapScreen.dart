import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Map Screen'),
      // ),
      body: Center(
        child: InAppWebViewPage(),
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
  @override
  _InAppWebViewPageState createState() => _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  Future<List<List<dynamic>>> loadCsvData() async {
    final csv1 = await rootBundle.loadString('assets/csv/login_20240217.csv');
    final csv2 = await rootBundle.loadString('assets/csv/login_addr.csv');
    List<List<dynamic>> row1 = const CsvToListConverter().convert(csv1);
    List<List<dynamic>> row2 = const CsvToListConverter().convert(csv2);

    List<List<dynamic>> rowsAsListOfValues = [];
    for (List list in row2) {
      for (List list2 in row1) {
        if (list[1] == list2[4]) {
          List<dynamic> newList = [];
          newList.add(list2[2]);
          newList.add(list[2]);
          newList.add(list[3]);
          rowsAsListOfValues.add(newList);
        }
      }
    }
    return rowsAsListOfValues;
  }

  Future<List<dynamic>> _getCurrentLocation() async {
    List<dynamic> list = [];
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    list.add(position);
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<List<dynamic>>>(
        future: Future.wait([
          loadCsvData(),
          _getCurrentLocation(),
        ]),
        builder: (BuildContext context, AsyncSnapshot<List<List<dynamic>>> snapshot) {
          if (snapshot.hasData) {
            List<dynamic>? csvData = snapshot.data?[0];
            List<dynamic>? posData = snapshot.data?[1];
            Position position = posData?[0];

            String queryString = '';
            queryString += 'l0=${'my_position'}&l1=${position.longitude}&l2=${position.latitude}&';
            for (int i = 0; i < (csvData?.length ?? 0); i++) {
              queryString += 'x${i+1}=${csvData?[i][0]}&y${i+1}=${csvData?[i][1]}&z${i+1}=${csvData?[i][2]}&';
            }
            queryString = queryString.substring(0, queryString.length - 1);

            String url = "http://localhost:8080/assets/web/kakaomap.html?$queryString";

            return InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(url)),
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