import 'dart:convert';
import 'dart:io';
import 'dart:async';

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
  fileExchange = new File('/home/gcrutchfield/mydart/stock/data/NASDAQ.json');
  contentExchange = fileExchange.readAsStringSync(); 
  companies = JSON.decode(contentExchange);
  ups = 0;
  downs = 0;
  equals = 0;
  weeks = 0;
  nulls = 0;
  numberCompanies = 0;
  for (company in companies) { 
    numberCompanies++;
    companyFile = new File('/home/gcrutchfield/mydart/stock/data/NASDAQ/' + company);
    companyContents = companyFile.readAsStringSync(); 
    historyQuandl = JSON.decode(companyContents);
    historyData = historyQuandl["data"];
    
    closes = new List();
    closeIndex = 0;   
    for (tradingDay in historyData) {
      if (tradingDay[0] == null || tradingDay[4] == null)
      {
        nulls = nulls + 1;
        continue;
      }
      closes.add(tradingDay[4]);
      dateTime = DateTime.parse(tradingDay[0] + ' 00:00:00');
      sellDay = dateTime.weekday;
      
      if (sellDay == 5) {
        if (closeIndex > sellDay - 2) {
          weeks++;
            if (closes[closeIndex] > closes[closeIndex - sellDay + 1]) 
              ups = ups + 1;
            else if (closes[closeIndex] < closes[closeIndex - sellDay + 1])
              downs = downs + 1;
            else
              equals = equals + 1;
        }  // if
      }  // if
      
      closeIndex = closeIndex + 1;
    }  // for tradingDay
    //  break;
  }  // for company
  print('Buy Monday, Sell Friday');
  print('Companies = ' + numberCompanies.toString());
  print('ups = ' + ups.toString() + ' downs = ' + downs.toString() + ' equals = ' + equals.toString()); 
  print('ups + downs + equals = ' + (ups + downs + equals).toString());
  print('ups probability = ' + (ups / (ups + downs + equals)).toString() + 
      ' downs probability = ' + (downs /(ups + downs + equals)).toString() + 
      ' equals probability = ' + (equals / (ups + downs + equals)).toString());

}  // main()

void handleFailure(error) {
  print('handleFailure');
}  // handleFailure()
