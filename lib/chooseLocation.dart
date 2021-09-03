import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Strings.dart';

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

    for (Map<String, dynamic> city in widget.citiesListOfDynamics) {
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/searchLocation');
        },
        child: const Icon(Icons.add_outlined),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}

class CityWidget extends StatelessWidget {
  const CityWidget(
      {Key? key,
      required this.name,
      required this.temperature,
      required this.description,
      required this.image})
      : super(key: key);

  final String name;
  final String temperature;
  final String description;
  final String image;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
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
              double.parse(temperature)
                  .round()
                  .toString() + "°",
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
    );
  }
}

bool _isDay(Map<String, dynamic> currentWeather) {
  var currentTimeInSeconds = DateTime.now().millisecondsSinceEpoch / 1000;
  return currentWeather["sunrise"] < currentTimeInSeconds &&
      currentTimeInSeconds < currentWeather["sunset"];
}
