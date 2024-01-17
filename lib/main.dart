import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

void main() {
  print('hello');
  runApp(MaterialApp(
    theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor:Colors.blue),
    ),
    home: MyApp()
  ));
}


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
    String result = 'Click to find latest OnePiece Chapter';
    String result1 = '';
    String result2 = '';
    bool isLoading = false;

    Future<List<String>> extractData() async {
      var chapter_url = Uri.parse('https://tcbscans.com/mangas/5/one-piece?date=11-1-2024-14');
      final response = await http.Client().get(chapter_url);
      var release_url = Uri.parse('https://claystage.com/one-piece-chapter-release-schedule-for-2024');
      final release_response = await http.Client().get(release_url);
      var responseString;
      var releaseString;
      var count = 1;
      final dateTD = DateTime.now(); //Todays date
      String chapter_number;
      if (response.statusCode == 200){ //status code 200 means response has been received
        var document = parser.parse(response.body);
        try { // Get Latest Chapter 
          responseString = document
            .getElementsByClassName('col-span-2')[0]
            .children[1]
            .children[0];
          //Extract chpater number to be used to find release date
          chapter_number = responseString.text.trim().replaceAll(new RegExp(r'[^0-9]'),''); 
          print(chapter_number);
          print(responseString.text.trim());
          //return [responseString.text.trim()];
      
        }
        catch (e){
          return ['','','ERROR!'];
        }
      }
      else {
        return ['','','ERROR: ${response.statusCode}.'];
      }

    if (release_response.statusCode == 200) {
      var release_document = parser.parse(release_response.body);
      print("hi");
      //Find the release date of chapter
      //Need to clean this up
      try {
        releaseString = release_document
            .getElementsByTagName('tr')[1]
            .children[1];
       while (releaseString.text.trim() != chapter_number){
         // print(releaseString.text.trim());
          releaseString = release_document
            .getElementsByTagName('tr')[count]
            .children[1];
          //print(releaseString.text.trim());
          count++;
       }
       releaseString = release_document
       .getElementsByTagName('tr')[count-1]
       .children[2];
      }
      catch (e){
          return ['','','ERROR!'];
        }
    }

    DateTime parseDt = DateTime.parse(convertDate(releaseString.text.trim()));
    print(parseDt);
    final diffDate = dateTD.difference(parseDt).inDays;

    return[responseString.text.trim(), releaseString.text.trim(),'Released $diffDate days ago'];

    }

//Function to present date in proper format to parse into actual date object
    String convertDate(String releaseString){
      releaseString = releaseString.replaceAll(RegExp(','), '');
      List<String> listString = releaseString.split(' ');
      //print(listString);
      String month = listString[0];
      String year = listString[2];
      String day = listString[1];

      switch (month) {
        case 'January':
        month = '01';
        break;

        case 'February':
        month = '02';
        break;

        case 'March':
        month = '03';
        break;

        case 'April':
        month = '04';
        break;

        case 'May':
        month = '05';
        break;

        case 'June':
        month = '06';
        break;

        case 'July':
        month = '07';
        break;

        case 'August':
        month = '08';
        break;

        case 'September':
        month = '09';
        break;

        case 'October':
        month = '10';
        break;

        case 'November':
        month = '11';
        break;

        case 'December':
        month = '12';
        break;

      }

      return '$year-$month-$day';
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: AppBar(title: Text('Latest OnePiece Chapter')), 
      body: Padding( 
        padding: const EdgeInsets.all(16.0), 
        child: Center( 
            child: Column( 
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [ 
            isLoading 
                ? CircularProgressIndicator() 
                : Column( 
                    children: [ 
                      Text(result, 
                          style: TextStyle( 
                              fontSize: 20, fontWeight: FontWeight.bold)), 
                      SizedBox( 
                        height: MediaQuery.of(context).size.height * 0.05, 
                      ), 
                      Text(result1,
                        style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05,
                          ),
                      Text(result2,
                          style:TextStyle(
                              fontSize:20, fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: MediaQuery.of(context).size.height *0.05,
                        ),
                        
                    ], 
                  ), 
            SizedBox(height: MediaQuery.of(context).size.height * 0.08), 
            MaterialButton( 
             onPressed: () async { 
                setState(() { 
                  isLoading = true; 
                }); 
                  
                final response = await extractData(); 
                setState(() { 
                  result = response[0];
                  result1 = response[1]; 
                  result2 = response[2];
                  isLoading = false; 
                }); 
              }, 
              child: Text( 
                'Scrap Data', 
                style: TextStyle(color: Colors.white), 
              ), 
              color: Colors.green, 
            ) 
          ], 
        )), 
      ), 
    ); 
  }

}
