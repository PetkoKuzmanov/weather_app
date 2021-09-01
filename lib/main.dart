import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/Strings.dart';
import 'dart:convert' as convert;
import 'dart:developer' as developer;
import 'package:intl/intl.dart';

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

  var topBarContainer = Container();
  var currentWeatherContainer = Container();
  var hourlyWeatherContainer = Container();
  var dailyWeatherContainer = Container();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        getTopBarContainer(),
        Expanded(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom: 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                currentWeatherContainer,
                SizedBox(height: 10.0),
                Center(
                  child: hourlyWeatherContainer,
                ),
                Center(
                  child: dailyWeatherContainer,
                )
              ],
            ),
          ),
        )
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
        dailyWeatherContainer = getDailyForecast();

        print('Request completed');
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    });
  }

  Container getTopBarContainer() {
    return Container(
      margin: const EdgeInsets.fromLTRB(25.0, 60.0, 15.0, 25.0),
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
    );
  }

  Container getCurrentWeather() {
    return Container(
      padding: EdgeInsets.fromLTRB(25.0, 125.0, 25.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                double.parse(currentWeather["temp"].toString())
                        .round()
                        .toString() +
                    "°",
                style: TextStyle(fontSize: 125.0),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 80.0,
                    padding:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(Icons.cloud_outlined, size: 20.0),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                            double.parse(currentWeather["clouds"].toString())
                                    .round()
                                    .toString() +
                                "%",
                            style: TextStyle(fontSize: 15.0)),
                      ],
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent),
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    width: 80.0,
                    padding:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(Icons.face_outlined, size: 20.0),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                            double.parse(
                                        currentWeather["feels_like"].toString())
                                    .round()
                                    .toString() +
                                "°",
                            style: TextStyle(fontSize: 15.0)),
                      ],
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent),
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            currentWeather["weather"][0]["main"].toString(),
            style: TextStyle(fontSize: 30.0),
          ),
          SizedBox(height: 10.0),
          Row(
            children: [
              Row(children: [
                Icon(Icons.arrow_upward_rounded),
                Text(
                  double.parse(dailyWeather[0]["temp"]["max"].toString())
                          .round()
                          .toString() +
                      "°C",
                  style: TextStyle(fontSize: 20.0),
                ),
              ]),
              SizedBox(width: 20),
              Row(children: [
                Icon(Icons.arrow_downward_rounded),
                Text(
                  double.parse(dailyWeather[0]["temp"]["min"].toString())
                      .round()
                      .toString() +
                      "°C",
                  style: TextStyle(fontSize: 20.0),
                ),
              ])
            ],
          )
        ],
      ),
    );
  }

  Container getHourlyForecast() {
    List<Widget> hourWidgetList = [];
    for (int i = 0; i < 25; i++) {
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
              margin: const EdgeInsets.only(right: 10.0),
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

  Container getDailyForecast() {
    List<Widget> dayWidgetList = [];
    for (int i = 0; i < 8; i++) {
      dayWidgetList.add(DailyForecastWidget(dailyWeather[i], i));
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 25.0),
      child: Column(
        children: [
          Padding(
            child: Text(
              "Daily Forecast",
              style: TextStyle(fontSize: 20.0),
            ),
            padding: EdgeInsets.all(15.0),
          ),
          Container(
              margin: const EdgeInsets.only(right: 10.0),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: dayWidgetList,
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
      time = DateFormat.Hm().format(dateTime);
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
            double.parse(widget.hourlyForecast["temp"].toString())
                .round()
                .toString() +
                "°",
            style: TextStyle(fontSize: 15.0),
          ),
          SizedBox(height: 10),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.0),
    );
  }
}

class DailyForecastWidget extends StatefulWidget {
  const DailyForecastWidget(this.dailyForecast, this.position, {Key? key})
      : super(key: key);

  final Map<String, dynamic> dailyForecast;
  final position;

  @override
  _DailyForecastWidgetState createState() => _DailyForecastWidgetState();
}

class _DailyForecastWidgetState extends State<DailyForecastWidget> {
  @override
  Widget build(BuildContext context) {
    var date = "Today";
    String image;

    if (widget.position != 0) {
      var dateTime = DateTime.fromMillisecondsSinceEpoch(
          widget.dailyForecast["dt"] * 1000);
      date = DateFormat.MMMd().format(dateTime);
    }

    image = widget.dailyForecast["weather"][0]["icon"].toString();

    return Padding(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            date,
            style: TextStyle(fontSize: 15.0),
          ),
          SizedBox(height: 10),
          Image.asset(
            "assets/images/$image.png",
            width: 50,
            height: 50,
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text(
                double.parse(widget.dailyForecast["temp"]["max"].toString())
                    .round()
                    .toString() +
                    "°",
                style: TextStyle(fontSize: 15.0),
              ),
              Icon(Icons.arrow_upward_rounded)
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text(
                double.parse(widget.dailyForecast["temp"]["min"].toString())
                    .round()
                    .toString() +
                    "°",
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
