import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SearchLocation extends StatefulWidget {
  const SearchLocation({Key? key}) : super(key: key);

  @override
  _SearchLocationState createState() => _SearchLocationState();
}

class _SearchLocationState extends State<SearchLocation> {
  final fieldText = TextEditingController();
  List<Widget> cityWidgets = [];

  void clearText() {
    fieldText.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(Icons.arrow_back_ios),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        fetchData(value).then((result) {
                          setState(() {
                            cityWidgets.clear();
                            for (var city in result["results"]) {
                              var cityWidget = CityWidget(
                                city: city["name"],
                                country: city["country"]["name"],
                                latitude:
                                    city["location"]["latitude"].toString(),
                                longitude:
                                    city["location"]["longitude"].toString(),
                              );
                              cityWidgets.add(cityWidget);
                            }
                          });
                        });
                      },
                      controller: fieldText,
                      decoration: InputDecoration(
                        hintText: 'Input the city name',
                        suffixIcon: IconButton(
                          // Icon to
                          icon: Icon(Icons.clear), // clear text
                          onPressed: clearText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: cityWidgets,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CityWidget extends StatelessWidget {
  const CityWidget(
      {Key? key,
      required this.city,
      required this.country,
      required this.latitude,
      required this.longitude})
      : super(key: key);

  final String city;
  final String country;
  final String latitude;
  final String longitude;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _addLocationDataToSharedPreferences(
                double.parse(latitude), double.parse(longitude), city)
            .then((value) => Navigator.of(context).pushNamed('/mainScreen'));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              city,
              style: TextStyle(
                fontSize: 17.0,
              ),
            ),
            SizedBox(
              height: 3.0,
            ),
            Text(
              country,
              style: TextStyle(
                fontSize: 13.0,
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>> fetchData(String city) async {
  final where = Uri.encodeQueryComponent(jsonEncode({
    "name": {"\$regex": city.capitalize()}
  }));
  final response = await http.get(
      Uri.parse(
          'https://parseapi.back4app.com/classes/Continentscountriescities_City?limit=100&order=name&include=country&keys=name,country,country.name,location&where=$where'),
      headers: {
        "X-Parse-Application-Id": "8FzuXtgi7Utm9YavAlvD1hlYG6PAxzulkU0nua7N",
        // This is your app's application id
        "X-Parse-REST-API-Key": "gAH61EEcr81SqcvNxkNX5PMg6drGiIVdREG0EDnV"
        // This is your app's REST API key
      });
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to fetch data');
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

Future<void> _addLocationDataToSharedPreferences(
    double latitude, double longitude, String city) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.setDouble('latitude', latitude);
  await prefs.setDouble('longitude', longitude);
  await prefs.setString('city', city);
}