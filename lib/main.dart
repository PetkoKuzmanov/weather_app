import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/Strings.dart';
import 'dart:convert' as convert;
import 'dart:developer' as developer;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: WeatherForecast());
  }
}

class WeatherForecast extends StatefulWidget {
  const WeatherForecast({Key? key}) : super(key: key);

  @override
  _WeatherForecastState createState() => _WeatherForecastState();
}

class _WeatherForecastState extends State<WeatherForecast> {
  var currentWeather = new Map<String, dynamic>();
  List hourlyWeather = [];
  List dailyWeather = [];

  var currentWeatherContainer = Container();
  var hourlyWeatherContainer = Container();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 75.0, horizontal: 25.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Plovdiv",
                style: TextStyle(fontSize: 30.0),
              ),
              Icon(Icons.search)
            ],
          ),
        ),
        currentWeatherContainer,
        hourlyWeatherContainer,
        Container(
          margin: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 25.0),
          child: Column(
            children: [
              Padding(
                child: Text(
                  "Daily Forecast",
                  style: TextStyle(fontSize: 20.0),
                ),
                padding: EdgeInsets.all(10.0),
              ),
              Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 10.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        DailyForecastWidget(),
                        DailyForecastWidget(),
                        DailyForecastWidget(),
                        DailyForecastWidget(),
                        DailyForecastWidget(),
                        DailyForecastWidget(),
                      ],
                    ),
                  ))
            ],
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent),
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
        ),
      ]),
    );
  }

  Future<void> loadData() async {
    var url = Uri.parse(Strings.plovdivCall);
    var response = await http.get(url);

    setState(() {
      if (response.statusCode == 200) {
        var responseBody =
            convert.jsonDecode(response.body) as Map<String, dynamic>;

        currentWeather = responseBody["current"];
        hourlyWeather = responseBody["hourly"];
        dailyWeather = responseBody["daily"];

        currentWeatherContainer = getCurrentWeather();
        hourlyWeatherContainer = getHourlyForecast();

        print('Request completed');
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    });
  }

  Container getCurrentWeather() {
    return Container(
      child: Column(
        children: [
          Text(
            currentWeather["temp"].toString().substring(0, 2),
            style: TextStyle(fontSize: 125.0),
          ),
          Text(
            currentWeather["weather"][0]["main"].toString(),
            style: TextStyle(fontSize: 50.0),
          ),
        ],
      ),
    );
  }

  Container getHourlyForecast() {
    List<Widget> hourWidgetList = [];
    for (int i = 0; i < 24; i++) {
      hourWidgetList.add(HourlyForecastWidget(hourlyWeather[i], i));
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 25.0),
      child: Column(
        children: [
          Padding(
            child: Text(
              "Hourly Forecast",
              style: TextStyle(fontSize: 20.0),
            ),
            padding: EdgeInsets.all(15.0),
          ),
          Container(
              margin: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: hourWidgetList,
                ),
              ))
        ],
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
    );
  }
}

class HourlyForecastWidget extends StatefulWidget {
  const HourlyForecastWidget(this.hourlyForecast, this.position, {Key? key})
      : super(key: key);

  final Map<String, dynamic> hourlyForecast;
  final position;

  @override
  _HourlyForecastWidgetState createState() => _HourlyForecastWidgetState();
}

class _HourlyForecastWidgetState extends State<HourlyForecastWidget> {
  @override
  Widget build(BuildContext context) {
    var time = "Now";
    String image;

    if (widget.position != 0) {
      var dateTime = DateTime.fromMillisecondsSinceEpoch(
          widget.hourlyForecast["dt"] * 1000);
      time = dateTime.hour.toString() + ":00";
    }

    image = widget.hourlyForecast["weather"][0]["icon"].toString();

    return Padding(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time,
            style: TextStyle(fontSize: 15.0),
          ),
          SizedBox(height: 10),
          Image.asset(
            "assets/images/$image.png",
            width: 50,
            height: 50,
          ),
          SizedBox(height: 10),
          Text(
            widget.hourlyForecast["temp"].toString().substring(0, 2) + "°",
            style: TextStyle(fontSize: 15.0),
          ),
          SizedBox(height: 10),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.0),
    );
  }
}

class DailyForecastWidget extends StatelessWidget {
  const DailyForecastWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Today",
            style: TextStyle(fontSize: 15.0),
          ),
          SizedBox(height: 10),
          Icon(Icons.wb_sunny_outlined),
          SizedBox(height: 10),
          Row(
            children: [
              Text(
                "30°",
                style: TextStyle(fontSize: 15.0),
              ),
              Icon(Icons.arrow_upward_rounded)
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text(
                "25°",
                style: TextStyle(fontSize: 15.0),
              ),
              Icon(Icons.arrow_downward_rounded)
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.0),
    );
  }
}
