import 'dart:convert';
import 'dart:io';
// finger11.dart
int totalTrades = 0;
double totalGain = 0.0;
Set usedDates = new Set();
void main(List<String> args) {
  File fileExchange;
  String contentExchange;
  List companies;
  String company;
  File companyFile;
  String companyContents;
  var historyQuandl;
  var historyData;
  var tradingDay;
  int closeIndex;
  int ups;
  int downs;
  int equals;
  int weeks;
  List closes;
  int nulls;
  int numberCompanies;
  DateTime dateTime;
  int sellDay;
  int startDay;
  int totalCloses;
  int fingerPrint;
  List fingerPrints = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  List buy = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  List sell = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  fileExchange = new File('/home/gcrutchfield/mydart/stock/data/NASDAQ.json');
  contentExchange = fileExchange.readAsStringSync();
  companies = JSON.decode(contentExchange);
  ups = 0;
  downs = 0;
  equals = 0;
  weeks = 0;
  nulls = 0;
  numberCompanies = 0;
  totalCloses = 0;
  String lastCompany = '';
  for (company in companies) {
    numberCompanies++;
    companyFile = new File('/home/gcrutchfield/mydart/stock/data/NASDAQ/' + company);
    companyContents = companyFile.readAsStringSync();
    historyQuandl = JSON.decode(companyContents);
    historyData = historyQuandl["data"];
    closes = new List();
    closeIndex = 0;
    for (tradingDay in historyData) {
      if (tradingDay[0] == null || tradingDay[4] == null) {  //  skip nulls
        nulls = nulls + 1;
        continue;
      }
      if (tradingDay[4] > 75.0) continue;  // skip the big guys
      if (tradingDay[4] < 25.0) continue;  // skip the little guys
      closes.add(tradingDay[4]);
      dateTime = DateTime.parse(tradingDay[0] + ' 00:00:00');
      startDay = dateTime.weekday;
      if (startDay == DateTime.MONDAY) {
        weeks++;
        if (closeIndex > 10) {       
          fingerPrint = 0;
          if (closes[closeIndex - 4] > closes[closeIndex - 3]) // Friday close > Thursday close
            fingerPrint = fingerPrint + 8;
          if (closes[closeIndex - 3] > closes[closeIndex - 2]) // Thursday close > Wednesday close
            fingerPrint = fingerPrint + 4;
          if (closes[closeIndex - 2] > closes[closeIndex - 1]) // Wednesday close > Tuesday close
            fingerPrint = fingerPrint + 2;
          if (closes[closeIndex - 1] > closes[closeIndex - 0]) // Tuesday close > Monday close
            fingerPrint = fingerPrint + 1;
          fingerPrints[fingerPrint] = fingerPrints[fingerPrint] + 1;
          if(fingerPrint == 2) { 
            trade(company, dateTime.toString(), closes[closeIndex -5], closes[closeIndex -9]);
            lastCompany = company;
          }
          if (closes[closeIndex -9] > closes[closeIndex -5]) {  //  Friday close > Monday close
            ups++;
            buy[fingerPrint] = buy[fingerPrint] + 1;
          }
          else if (closes[closeIndex - 9] < closes[closeIndex - 5]) {
            downs++;
            sell[fingerPrint] = sell[fingerPrint] + 1;
          }
          else if (closes[closeIndex - 9] == closes[closeIndex - 5])
            equals++;
        }
      } // if
      closeIndex = closeIndex + 1;
    } // for tradingDay
    totalCloses = totalCloses + closeIndex;
  } // for company
  print('Buy Monday, Sell Friday');
  print('Companies = ' + numberCompanies.toString());
  print('ups = ' + ups.toString() + ' downs = ' + downs.toString() + ' equals = ' + equals.toString());
  print('ups + downs + equals = ' + (ups + downs + equals).toString());
  print('weeks = ' + weeks.toString());
  print('days (closes) = ' + totalCloses.toString());
  print('ups probability = ' + (ups / (ups + downs + equals)).toString() + 
      ' downs probability = ' + (downs / (ups + downs + equals)).toString() + 
      ' equals probability = ' + (equals / (ups + downs + equals)).toString());
  for (int indexFingerPrint = 0; indexFingerPrint < 16; indexFingerPrint++) {
    print('fingerPrints[' + indexFingerPrint.toString() + '] = ' + fingerPrints[indexFingerPrint].toString());
    print('buy [' + indexFingerPrint.toString() + '] = ' + buy[indexFingerPrint].toString() +
        ' ' + (buy[indexFingerPrint] / (buy[indexFingerPrint] + sell[indexFingerPrint])).toString());
    print('sell[' + indexFingerPrint.toString() + '] = ' + sell[indexFingerPrint].toString());
  }  // for
  tradeSummary();
} // main()
trade(String company, String dateTime, double closesMonday, double closesFriday) {
  double gain = 0.0;
  if (usedDates.contains(dateTime))
    return;
  else 
    usedDates.add(dateTime);
  totalTrades++;
  // if (totalTrades > 52) return;
  if (closesMonday != 0.0) gain = (closesFriday - closesMonday) / closesMonday * 1000.00;
  totalGain = totalGain + gain;
  // print('company = ' + company + ' dateTime = ' +
  //    dateTime + ' Monday = ' + closesMonday.toString() + ' Friday =' + closesFriday.toString() +
  //   ' gain = ' + gain.toString() + ' totalGain = ' + totalGain.toString() + ' trades ' + 
  //        totalTrades.toString());
}
tradeSummary() {
  print('totalTrades ' + totalTrades.toString());
  print('totalGain ' + totalGain.toString());
}
void handleFailure(error) {
  print('handleFailure');
} // handleFailure()
