import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
// updown.dart

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
  String lastCompany = '';
  int totalTrades;
  double gain;
  double totalGain;
  double gainPerTrade;
  Set usedDates;
  int daysUntilSell;
  int tradeFingerPrint;

  trade(String company, String dateTime, double closesMonday, double closesFriday) {
    // if (usedDates.contains(dateTime)) return; else usedDates.add(dateTime);
    totalTrades++;
    if (closesMonday != 0.0) gain = (closesFriday - closesMonday) / closesMonday * 1000.00;
    totalGain = totalGain + gain;
  }

  fileExchange = new File('/home/gcrutchfield/mydart/stock/data/NASDAQ.json');
  contentExchange = fileExchange.readAsStringSync();
  companies = JSON.decode(contentExchange);
  print('Buy Monday Based Upon Prior Week Daily Closes');
  for (daysUntilSell = 4; daysUntilSell <= 39; daysUntilSell = daysUntilSell + 5) {
    for (tradeFingerPrint = 0; tradeFingerPrint < 16; tradeFingerPrint++) {
    fingerPrints = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    buy = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    sell = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    ups = 0;
    downs = 0;
    equals = 0;
    weeks = 0;
    nulls = 0;
    numberCompanies = 0;
    totalCloses = 0;
    totalTrades = 0;
    gain = 0.0;
    totalGain = 0.0;
    usedDates = new Set();
    
    for (company in companies) {
      numberCompanies++;
      companyFile = new File('/home/gcrutchfield/mydart/stock/data/NASDAQ/' + company);
      companyContents = companyFile.readAsStringSync();
      historyQuandl = JSON.decode(companyContents);
      historyData = historyQuandl["data"];
      closes = new List();
      closeIndex = 0;
      for (tradingDay in historyData) {
        if (tradingDay[0] == null || tradingDay[4] == null) { //  skip nulls
          nulls = nulls + 1;
          continue;
        }
        if (tradingDay[4] > 75.0) continue; // skip the big guys
        if (tradingDay[4] < 25.0) continue; // skip the little guys
        closes.add(tradingDay[4]);
        dateTime = DateTime.parse(tradingDay[0] + ' 00:00:00');
        startDay = dateTime.weekday;
        if (startDay == DateTime.MONDAY) {
          weeks++;
          if (closeIndex >= 39 + 5) {
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
            if (fingerPrint == tradeFingerPrint) {
              trade(company, dateTime.toString(), closes[closeIndex - 5], 
                  closes[closeIndex - 5 - daysUntilSell]);
              lastCompany = company;
            }
            if (closes[closeIndex - 5 - daysUntilSell] > closes[closeIndex - 5]) { //  Friday close > Monday close
              ups++;
              buy[fingerPrint] = buy[fingerPrint] + 1;
            } else if (closes[closeIndex - 5 - daysUntilSell] < closes[closeIndex - 5]) {
              downs++;
              sell[fingerPrint] = sell[fingerPrint] + 1;
            } else if (closes[closeIndex - daysUntilSell] == closes[closeIndex - 5]) equals++;
          } // if
        } // if
        closeIndex = closeIndex + 1;
      } // for tradingDay
      totalCloses = totalCloses + closeIndex;
    } // for company
    
    print('Companies = $numberCompanies Weeks = $weeks Closes = $totalCloses');
    print('ups = $ups downs = $downs equals = $equals total = ${ups + downs + equals}');
    print('ups probability = ${ups / (ups + downs + equals)} downs probability = ${downs / (ups + downs + equals)} ');
    gainPerTrade = totalGain / totalTrades;
    print('tradeFingerPrint = $tradeFingerPrint daysUntilSell = $daysUntilSell');
    
    int maxSuccessIndex = -1;
    double maxSuccess = 0.0;
    for (int indexFingerPrint = 0; indexFingerPrint < 16; indexFingerPrint++) {
      if(buy[indexFingerPrint] / (buy[indexFingerPrint] + sell[indexFingerPrint]) > maxSuccess) {
        maxSuccessIndex = indexFingerPrint;
        maxSuccess = buy[indexFingerPrint] / (buy[indexFingerPrint] + sell[indexFingerPrint]);
      }
    } // for indexFingerPrint
    
    print('max fingerPrint = $maxSuccessIndex '
                  'buy[$maxSuccessIndex] = ${buy[maxSuccessIndex]} '
                  'success probability = $maxSuccess');
    print('totalTrades = $totalTrades totalGain = $totalGain Gain per Trade = $gainPerTrade '
            'Rate Return = ${new NumberFormat("##0.00").format(gainPerTrade * 365.0 / (daysUntilSell * (7.0 / 5.0)) / 1000.0)}');
    
    print('');
    } // for tradeFingerPrint
  } // for daysUntilSell
} // main()

void handleFailure(error) {
  print('handleFailure');
} // handleFailure()
