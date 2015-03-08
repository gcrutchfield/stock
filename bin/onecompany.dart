import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';

String companyQueued;
void main(List<String> args) {
  String company;
  File fileTemp;
  var client = new http.Client();
  
  void handleSuccess(http.Response response) {
    if (response.body.contains('{"error":"Requested entity does not exist."}')) {
      print('company ' + company + ' skipped, does not exist in quandl');
      return;
    } else if (response.body.isEmpty) {
         print('company ' + company + ' skipped, empty');
         return;
    } else if (response.body.contains('quickly')) {
         print('company ' + company + ' skipped, too busy');
         return;
    } else if (response.body.contains('Unavailable')) {
         print('company ' + company + ' skipped, Unavailable');
         return;
    } else if (response.body.contains('maintenance')) {
         print('company ' + company + ' skipped, Quandl under maintenance');    
         return;
    } else {
      fileTemp = new File('/home/gcrutchfield/mydart/stock/data/NASDAQ/' + company);
      var sink = fileTemp.openWrite();
      //sink.write(response.body);
      sink.close();
      print('company ' + company + ' created from quandl');
    }
  }  //  handleSuccess
  
  company = args[0];
  sleep(new Duration(seconds:1));
  client.get("https://www.quandl.com/api/v1/datasets/WIKI/" + company + 
      ".json?auth_token=snEduoy_yXx5H3iHwgyu&trim_start=2005-01-01")
      .then(handleSuccess)
      .whenComplete(client.close)
      .catchError((error) =>             // Handle failure.
        print('company ' + company + " error, no history today. Here's why:\n$error")); 
}  // main()
