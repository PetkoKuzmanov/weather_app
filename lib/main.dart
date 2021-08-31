import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(children: [
          Container(
            margin:
                const EdgeInsets.symmetric(vertical: 75.0, horizontal: 25.0),
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
          Container(
            child: Column(
              children: [
                Text(
                  "30°",
                  style: TextStyle(fontSize: 150.0),
                ),
                Text(
                  "Sunny",
                  style: TextStyle(fontSize: 50.0),
                ),
              ],
            ),
          ),
          Container(
            margin:
                const EdgeInsets.symmetric(vertical: 25.0, horizontal: 25.0),
            child: Column(
              children: [
                Padding(
                  child: Text(
                    "Hourly Forecast",
                    style: TextStyle(fontSize: 20.0),
                  ),
                  padding: EdgeInsets.all(10.0),
                ),
                Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 0, horizontal: 10.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          HourlyForecastWidget(),
                          HourlyForecastWidget(),
                          HourlyForecastWidget(),
                          HourlyForecastWidget(),
                          HourlyForecastWidget(),
                          HourlyForecastWidget(),
                          HourlyForecastWidget(),
                          HourlyForecastWidget(),
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
                    margin: const EdgeInsets.symmetric(
                        vertical: 0, horizontal: 10.0),
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
      ),
    );
  }
}

class HourlyForecastWidget extends StatelessWidget {
  const HourlyForecastWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Now",
            style: TextStyle(fontSize: 15.0),
          ),
          SizedBox(height: 10),
          Icon(Icons.wb_sunny_outlined),
          SizedBox(height: 10),
          Text(
            "30°",
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
