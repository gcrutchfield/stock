import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';

/// Downloads stock market data for last Monday through Friday from Quandl.

void main() {
  
  Future getCloses() async {
    String contentExchange;
    List companies = new List();
    String company;
    int calls = 0;
    var client = new http.Client();
    File fileExchange = new File('/home/gcrutchfield/mydart/stock/data/NASDAQ.json');
    String trimStart;
    int companyNumberProcessed = -1;
    List companiesProcessed = new List();
    
    void handleSuccess(http.Response response) {
      var historyQuandl;
      var historyData;
      var tradingDay;
      int closeIndex;
      DateTime dateTime;
      int startDay;
      double close;
      List closes;
      String companyProcessed;
      String companyContents;
      File fileTemp;
     
      bool validateBody() {
        bool returnValue;
        if (response.body.contains('{"error":"Requested entity does not exist."}')) {
          print('company ' + companies[companyNumberProcessed] + ' skipped, does not exist in quandl');
          returnValue = false;
        } else if (response.body.isEmpty) {
          print('company ${companies[companyNumberProcessed]} skipped, empty');
          returnValue = false;
        } else if (response.body.contains('quickly')) {
          print('company ${companies[companyNumberProcessed]} skipped, too busy');
          returnValue = false;
        } else if (response.body.contains('Unavailable')) {
          print('company ${companies[companyNumberProcessed]} skipped, Unavailable');
          returnValue = false;
        } else if (response.body.contains('maintenance')) {
          print('company ${companies[companyNumberProcessed]} skipped, Quandl under maintenance');
          returnValue = false;
        } else {
          returnValue = true;
        }
        return returnValue;
      } // validateBody()
        
      if (!validateBody()) {
        print('validation failed for body');
        return; // error reading, skip company
      }
      historyQuandl = JSON.decode(response.body);
      companyNumberProcessed = companyNumberProcessed + 1;
      companyProcessed = historyQuandl["code"];
      companiesProcessed.add(companyProcessed);
      
      fileTemp = new File('/home/gcrutchfield/mydart/stock/data/NASDAQ/lasttenyears/' + companiesProcessed[companyNumberProcessed]);
      var sink = fileTemp.openWrite();
      sink.write(response.body);
      sink.close();
    } //  handleSuccess

    print('Last Ten Years Stock Processing');
    contentExchange = fileExchange.readAsStringSync();
    companies = JSON.decode(contentExchange);
    companies.sort();
    for (company in companies) {
      calls = calls + 1;
      // sleep(new Duration(seconds: 1));
      print('reading $calls ' + company + ' ' + (new DateTime.now()).toString());
      await client.get("https://www.quandl.com/api/v1/datasets/WIKI/" + company + 
          ".json?auth_token=snEduoy_yXx5H3iHwgyu&trim_start=2005-01-02")
          .then((response) {handleSuccess(response); })   
          .catchError((error) => print('error because:\n${error}'));
      // if (calls > 5) break;
    } // for
    print('Total Calls  = ${calls}');
    return 'getCloses() completed';
  } //  getCloses()

  getCloses().then((x) {print('${x.toString()}');});
} // main()
