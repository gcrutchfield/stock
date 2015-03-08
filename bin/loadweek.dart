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
    String trimEnd;
    List fingerPrints = new List(16);
    int fingerPrint;
    var aFingerPrint;
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
      historyData = historyQuandl["data"];
      closeIndex = 0;
      closes = new List();
      for (tradingDay in historyData) {
        // print('inside tradingDay');
        if (tradingDay[0] == null || tradingDay[4] == null) {
          print('null date or close skipped');
          break; //  skip date and close nulls
        }
        close = tradingDay[4];
        if (close < 25.0 || close > 75.0) {
          // print('handleSuccess:  $close FAILED '
          //    '${companiesProcessed[companyNumberProcessed]}[${companyNumberProcessed}] '
          //    'close < 25.0 or > 75.0');
          return; // skip the little and big guys
        }
        closes.add(close);
        dateTime = DateTime.parse(tradingDay[0] + ' 00:00:00');
        startDay = dateTime.weekday;   
        if (startDay == DateTime.MONDAY) {
          // print('startDay = $startDay closeIndex = $closeIndex');
          if (closeIndex >= 4) {
            fingerPrint = 0;
            if (closes[closeIndex - 4] > closes[closeIndex - 3]) // Friday close > Thursday close
              fingerPrint = fingerPrint + 8;
            if (closes[closeIndex - 3] > closes[closeIndex - 2]) // Thursday close > Wednesday close
              fingerPrint = fingerPrint + 4;
            if (closes[closeIndex - 2] > closes[closeIndex - 1]) // Wednesday close > Tuesday close
              fingerPrint = fingerPrint + 2;
            if (closes[closeIndex - 1] > closes[closeIndex]) // Tuesday close > Monday close
              fingerPrint = fingerPrint + 1;  
            if (fingerPrints[fingerPrint] == null) {
              fingerPrints[fingerPrint] = new Set();
              fingerPrints[fingerPrint].add('$fingerPrint');
            }
            // fingerPrints[fingerPrint].add(companyProcessed);
            fingerPrints[fingerPrint]
              .add('$companyProcessed'
                  '(${((closes[closeIndex - 4] - closes[closeIndex]) / closes[closeIndex]).toStringAsFixed(2)})');
            // print('handleSuccess:  $fingerPrint for ${companyProcessed}[${companyNumberProcessed}]');  
          } // if
        } // if  
        closeIndex = closeIndex + 1;
      } // for tradingDay
      fileTemp = new File('/home/gcrutchfield/mydart/stock/data/NASDAQ/lastweek/' + companiesProcessed[companyNumberProcessed]);
      var sink = fileTemp.openWrite();
      sink.write(response.body);
      sink.close();
    } //  handleSuccess

    void getTrims() {
      DateTime lastFriday;
      DateTime mondayBeforeFriday;
      DateTime today = new DateTime.now();
      DateTime trimsWork = today;
      Duration oneDay = new Duration(days:1);
      while (trimsWork.weekday != DateTime.FRIDAY) {
        trimsWork = trimsWork.subtract(oneDay);
      }
      lastFriday = trimsWork;
      trimEnd = lastFriday.toString().substring(0, 11);
      while (trimsWork.weekday != DateTime.MONDAY) {
        trimsWork = trimsWork.subtract(oneDay);
      }
      mondayBeforeFriday = trimsWork;
      trimStart = mondayBeforeFriday.toString().substring(0, 11);
      print('trimStart = $trimStart trimEnd = $trimEnd');
    } // getTrims()
    
    print('Stock Processing');
    contentExchange = fileExchange.readAsStringSync();
    companies = JSON.decode(contentExchange);
    companies.sort();
    getTrims();
    for (company in companies) {
      calls = calls + 1;
      // sleep(new Duration(seconds: 1));
      // print('reading $calls ' + company + ' ' + (new DateTime.now()).toString());
      await client.get("https://www.quandl.com/api/v1/datasets/WIKI/" + company + 
          ".json?auth_token=snEduoy_yXx5H3iHwgyu&trim_start=$trimStart&trim_end=$trimEnd")
          .then((response) {handleSuccess(response); })   
          .catchError((error) => print('error because:\n${error}'));
      // if (calls > 5) break;
    } // for
    fingerPrints.forEach((aFingerPrint) => print('$aFingerPrint'));
    print('Total Calls  = ${calls}');
    return 'getCloses() completed';
  } //  getCloses()

  getCloses().then((x) {print('${x.toString()}');});
} // main()
