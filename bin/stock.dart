import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';

void main() {
  File exchangesFile;
  List exchanges;
  File fileExchange;
  String contentExchange;
  int companyNumber;
  int companyNumberQueued = -1;
  String companyQueued;
  List companies;
  String company;
  File companyFile;
  Directory exchangeDir;
  String companyContents;
  var companyHistory; 
  String companyContentsProvider;
  var companyHistoryProvider;
  List companyHistories = new List();
  
  void handleSuccess(http.Response response) {
  print('quandl OK');  
  companyNumberQueued = companyNumberQueued + 1;
  companyQueued = companies[companyNumberQueued];
  companyHistoryProvider = JSON.decode(response.body);
  print('companyHistoryProvider code = ' + companyHistoryProvider["code"]);
  if (response.body.contains('{"error":"Requested entity does not exist."}')) {
    print('company does not exist on quandl:  ' + companyQueued + ' deleting');
    File file = new File('data/NASDAQ/' + companyQueued);
    file.deleteSync();
    
    companies[companyNumberQueued] = 'SKIP';
    
    contentExchange = JSON.encode(companies);
    fileExchange.writeAsStringSync(contentExchange);
    return;
  }
  print((companyHistoryProvider["data"])[0]);
  if(((companyHistories[companyNumberQueued])[1]).length == 0) {
    print('(companyHistories[companyNumberQueued])[1].length == 0 ' + 'true');
    (companyHistories[companyNumberQueued])[1] = companyHistoryProvider["data"];
    File file = new File('data/NASDAQ/' + companyQueued);
    String temp = JSON.encode(companyHistories[companyNumberQueued]);
    print('temp = ' + temp);
    file.writeAsStringSync(temp);
  } else {
    print('(companyHistories[companyNumberQueued])[1].length == 0 ' + 'false');
  }
  //print(companyHistories[companyNumberQueued]);
  
  //companyContentsProvider = response.body;
  // sdd companyHistoryProvider into companyHistory and rewrite
  //print('companyHistories.length = ' + toString(companyHistories.length));
  //print('companyHistoryQueued = ' + toString(companyHistories[companyNumberQueued]));
  
  //companyHistoryProvider.forEach((key, value) => print("$key=$value"));
  // invoke algoritms
  analyze();
  }  //  handleSuccess
   
  // Get exchanges 
  exchangesFile = new File('data/exchanges.txt');
  print('getting contentsExchanges');
  String contentsExchanges = exchangesFile.readAsStringSync();
  print('got contentsExchanges');
  exchanges = JSON.decode(contentsExchanges);
  print('Stock Processing for Exchange ' + exchanges[0]);
  // create exchange directory if does not exist
  exchangeDir = new Directory('data/' + exchanges[0]);
  exchangeDir.createSync(recursive: false);
  fileExchange = new File('data/' + exchanges[0] + '.json');
  contentExchange = fileExchange.readAsStringSync(); 
  print('contentExchange = ' + contentExchange);
  companies = JSON.decode(contentExchange);
      // create company with empty history if needed
      companyNumber = -1;
      for (company in companies) { 
        companyNumber = companyNumber + 1; 
        print('company = ' + company);
        if (company.contains('SKIP')) {
          continue;
        }
        File companyFile = new File('data/NASDAQ/' + company);
        // read contents of company or prime with empty if does not exist
        if (companyFile.existsSync()) {
          print('company = ' + company + ' exists'); 
          companyContents = companyFile.readAsStringSync();
          print('company ' + company + ' history = ' + companyContents);
          companyHistory = JSON.decode(companyContents);
        } else {
          print('company ' + company + ' created with empty history');
          companyContents= '["' + company + '",[]]';
          File file = new File('data/NASDAQ/' + company);
          file.writeAsStringSync(companyContents);
          print('company ' + company + ' history = ' + companyContents);
          companyHistory = JSON.decode(companyContents);
        }  // if-else
        companyHistories.add(companyHistory);
        // get fresh company history from quandl and rewrite if found
        print('getting company history from quandl for ' + company);
        
        http.get("http://www.quandl.com/api/v1/datasets/WIKI/" + company + ".json?auth_token=snEduoy_yXx5H3iHwgyu")
            .then(handleSuccess)
            .catchError(handleFailure);     
      }  // for  
}  // main()

void analyze() {
  print('Running analysis algoritms');
}  // analyze()

void handleFailure(error) {
  print('quandl failed.');
  print(error);
}  // handleFailure()
