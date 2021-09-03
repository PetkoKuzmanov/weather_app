import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Strings.dart';
import 'main.dart';

class ChooseLocation extends StatefulWidget {
  const ChooseLocation({Key? key, required this.citiesListOfDynamics})
      : super(key: key);

  final List<dynamic> citiesListOfDynamics;

  @override
  _ChooseLocationState createState() => _ChooseLocationState();
}

class _ChooseLocationState extends State<ChooseLocation> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    List<Widget> cityWidgets = [];

    for (var i = 0; i < widget.citiesListOfDynamics.length; i++) {
      var city = widget.citiesListOfDynamics[i];
      Map<String, dynamic> currentWeather = city["forecast"]["current"];

      late String backgroundImage;
      switch (city["forecast"]["current"]["weather"][0]["main"]) {
        case "Thunderstorm":
        case "Drizzle":
        case "Rain":
          if (_isDay(currentWeather)) {
            backgroundImage = "day_drizzle";
          } else {
            backgroundImage = "night_drizzle";
          }
          break;
        case "Clear":
          if (_isDay(currentWeather)) {
            backgroundImage = "day_clear";
          } else {
            backgroundImage = "night_clear";
          }
          break;
        case "Clouds":
          if (_isDay(currentWeather)) {
            backgroundImage = "day_cloudy";
          } else {
            backgroundImage = "night_cloudy";
          }
          break;
      }

      var cityWidget = new CityWidget(
        name: city["name"],
        temperature: currentWeather["temp"].toString(),
        description: currentWeather["weather"][0]["main"],
        image: backgroundImage,
        index: i,
        listOfDynamics: widget.citiesListOfDynamics,
        listOfWidgets: cityWidgets,
      );

      cityWidgets.add(cityWidget);
    }

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
                  Text(
                    "Select city",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: cityWidgets.length,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  itemBuilder: (BuildContext context, int index) {
                    return cityWidgets[index];
                  }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/searchLocation');

          print("List of dynamics: " +
              widget.citiesListOfDynamics.length.toString());
          print("List of Widgets: " + cityWidgets.length.toString());
        },
        child: const Icon(Icons.add_outlined),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}

// class CityWidget extends StatefulWidget {
//   const CityWidget({
//     Key? key,
//     required this.name,
//     required this.temperature,
//     required this.description,
//     required this.image,
//     required this.index,
//     required this.listOfDynamics,
//     required this.listOfWidgets,
//   }) : super(key: key);
//
//   final String name;
//   final String temperature;
//   final String description;
//   final String image;
//   final int index;
//   final List listOfDynamics;
//   final List listOfWidgets;
//
//   @override
//   _CityWidgetState createState() => _CityWidgetState();
// }

// class _CityWidgetState extends State<CityWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return Dismissible(
//       key: UniqueKey(),
//       onDismissed: (direction) {
//         removeCityFromSharedPreferences();
//         print(widget.listOfDynamics.length);
//       },
//       child: GestureDetector(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => WeatherForecast(
//                 currentCityNumber: widget.index,
//               ),
//             ),
//           );
//         },
//         child: Container(
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage(
//                   Strings.backgroundImagesUrl + widget.image + ".png"),
//               fit: BoxFit.cover,
//             ),
//           ),
//           padding: EdgeInsets.fromLTRB(20.0, 20.0, 0.0, 10.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Text(
//                 widget.name,
//                 style: TextStyle(fontSize: 17.0),
//               ),
//               SizedBox(height: 10.0),
//               Text(
//                 double.parse(widget.temperature).round().toString() + "°",
//                 style: TextStyle(fontSize: 17.0),
//               ),
//               SizedBox(height: 5.0),
//               Text(
//                 widget.description,
//                 style: TextStyle(fontSize: 14.0),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> removeCityFromSharedPreferences() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//
//     widget.listOfWidgets.removeAt(widget.index);
//     widget.listOfDynamics.removeAt(widget.index);
//
//     List<String> newCitiesListOfStrings = [];
//     for (var city in widget.listOfDynamics) {
//       newCitiesListOfStrings.add(jsonEncode(city));
//     }
//
//     prefs.setStringList("cities", newCitiesListOfStrings);
//   }
// }

class CityWidget extends StatelessWidget {
  const CityWidget({
    Key? key,
    required this.name,
    required this.temperature,
    required this.description,
    required this.image,
    required this.index,
    required this.listOfDynamics,
    required this.listOfWidgets,
  }) : super(key: key);

  final String name;
  final String temperature;
  final String description;
  final String image;
  final int index;
  final List listOfDynamics;
  final List listOfWidgets;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      background: Container(color: Colors.red.withOpacity(0.5)),
      onDismissed: (direction) {
        removeCityFromSharedPreferences();
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WeatherForecast(
                currentCityNumber: index,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(Strings.backgroundImagesUrl + "$image.png"),
              fit: BoxFit.cover,
            ),
          ),
          padding: EdgeInsets.fromLTRB(20.0, 20.0, 0.0, 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                name,
                style: TextStyle(fontSize: 17.0),
              ),
              SizedBox(height: 10.0),
              Text(
                double.parse(temperature).round().toString() + "°",
                style: TextStyle(fontSize: 17.0),
              ),
              SizedBox(height: 5.0),
              Text(
                description,
                style: TextStyle(fontSize: 14.0),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> removeCityFromSharedPreferences() async {
    listOfDynamics.removeAt(index);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> newCitiesListOfStrings = [];
    for (var city in listOfDynamics) {
      newCitiesListOfStrings.add(jsonEncode(city));
    }

    prefs.setStringList("cities", newCitiesListOfStrings);
  }
}

bool _isDay(Map<String, dynamic> currentWeather) {
  var currentTimeInSeconds = DateTime.now().millisecondsSinceEpoch / 1000;
  return currentWeather["sunrise"] < currentTimeInSeconds &&
      currentTimeInSeconds < currentWeather["sunset"];
}
