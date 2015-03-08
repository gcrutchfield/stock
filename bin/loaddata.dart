import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

void main() {
  String companyQueued;
  File exchangesFile;
  List exchanges;
  File fileExchange;
  String contentExchange;
  int companyNumber;
  int companyNumberQueued = -1;
  //String companyQueued;
  List companies;
  String company;
  File companyFile;
  Directory exchangeDir;
  String companyContents;
  var companyHistory;
  String companyContentsProvider;
  var companyHistoryProvider;
  List companyHistories = new List();
  File fileTemp;
  var client = new http.Client();

  void handleSuccess(http.Response response) {
    //print('handleSuccess executing');
    //print('response.body' + response.body);
    companyNumberQueued = companyNumberQueued + 1;
    companyQueued = companies[companyNumberQueued];
    // print('handSuccess companyQueued = ' + companyQueued);
    if (response.body.contains('{"error":"Requested entity does not exist."}')) {
      print('company ' + companies[companyNumberQueued] + ' skipped, does not exist in quandl');
      return;
    } else if (response.body.isEmpty) {
      print('company ' + companies[companyNumberQueued] + ' skipped, empty');
      return;
    } else if (response.body.contains('quickly')) {
      print('company ' + companies[companyNumberQueued] + ' skipped, too busy');
      return;
    } else if (response.body.contains('Unavailable')) {
      print('company ' + companies[companyNumberQueued] + ' skipped, Unavailable');
      return;
    } else if (response.body.contains('maintenance')) {
      print('company ' + companies[companyNumberQueued] + ' skipped, Quandl under maintenance');
      return;
    } else {
      // print('preparing to write ' + 'data/NASDAQ/' + companyQueued);
      fileTemp = new File('/home/gcrutchfield/mydart/stock/data/NASDAQ/' + companyQueued);

      var sink = fileTemp.openWrite();
      // sink.writeAsStringSync(response.body);
      sink.write(response.body);
      sink.close();
      print('company ' + companies[companyNumberQueued] + ' created from quandl');
    }
  } //  handleSuccess

  void getCloses() {
    // Get exchanges
    exchangesFile = new File('/home/gcrutchfield/mydart/stock/data/exchanges.txt');
    print('getting contentsExchanges');
    String contentsExchanges = exchangesFile.readAsStringSync();
    print('got contentsExchanges');
    exchanges = JSON.decode(contentsExchanges);
    print('Stock Processing for Exchange ' + exchanges[0]);
    fileExchange = new File('/home/gcrutchfield/mydart/stock/data/' + exchanges[0] + '.json');
    contentExchange = fileExchange.readAsStringSync();
    //print('contentExchange = ' + contentExchange);
    companies = JSON.decode(contentExchange);
    companies.sort();
    int calls = 0;
    for (company in companies) {
      calls = calls + 1;
      // if (calls > 3) break;
      sleep(new Duration(seconds: 1));
      print('reading ' + company + ' ' + (new DateTime.now()).toString());
      client.get("https://www.quandl.com/api/v1/datasets/WIKI/" + company + 
          ".json?auth_token=snEduoy_yXx5H3iHwgyu&trim_start=2015-02-09&trim_end=2015-02-13")
          .then((response) {handleSuccess(response);})
          //  .whenComplete(client.close)
          .catchError((error) => print('company ' + company + " error because:\n$error"));
    } // for
    print('Total Calls  = ${calls -1}');
  } //  getCloses()

  getCloses();
} // main()
