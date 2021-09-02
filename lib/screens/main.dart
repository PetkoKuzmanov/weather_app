import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/Strings.dart';
import 'dart:convert' as convert;
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';

import 'chooseLocation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Color.fromRGBO(255, 255, 255, 0.0),
        statusBarColor: Color.fromRGBO(255, 255, 255, 0.0)));

    return MaterialApp(
      home: WeatherForecast(),
      routes: <String, WidgetBuilder>{
        '/chooseLocation': (BuildContext context) => ChooseLocation(),
      },
    );
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
  var detailsContainer = Container();

  var currentTimeInSeconds = DateTime.now().millisecondsSinceEpoch / 1000;

  var backgroundImage = "day_clear";

  late double latitude;
  late double longitude;
  late String city;

  @override
  void initState() {
    super.initState();
    _getWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
    );
  }

  Widget getBody() {
    bool showLoadingDialog = hourlyWeather.isEmpty;
    if (showLoadingDialog) {
      return getProgressDialog();
    } else {
      return getWeatherWidget();
    }
  }

  Widget getWeatherWidget() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage(
                Strings.backgroundImagesUrl + "$backgroundImage.png"),
            fit: BoxFit.cover),
      ),
      child: Column(children: <Widget>[
        topBarContainer,
        Expanded(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom: 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                currentWeatherContainer,
                SizedBox(height: 25.0),
                Center(
                  child: hourlyWeatherContainer,
                ),
                SizedBox(height: 25.0),
                Center(
                  child: dailyWeatherContainer,
                ),
                SizedBox(height: 25.0),
                Center(
                  child: detailsContainer,
                ),
              ],
            ),
          ),
        )
      ]),
    );
  }

  Widget getProgressDialog() {
    return Center(child: CircularProgressIndicator());
  }

  void _getWeatherData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var lastLatitude = prefs.getDouble('latitude');
    if (lastLatitude == null) {
      _determinePosition().then((position) {
        _addLocationDataToSharedPreferences(position.latitude, position.longitude);
        _loadData();
      });
    } else {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    latitude = prefs.getDouble('latitude')!;
    longitude = prefs.getDouble('longitude')!;
    city = prefs.getString('city')!;

    print(latitude);
    print(longitude);
    print(city);

    var url = Uri.http(Strings.weatherUri, "/data/2.5/onecall", {"lat" : latitude.toString(), "lon" : longitude.toString(), "exclude" : "minutely,alerts", "units" : "metric", "appid" : Strings.apiKey});
    var response = await http.get(url);

    setState(() {
      if (response.statusCode == 200) {
        var responseBody =
            convert.jsonDecode(response.body) as Map<String, dynamic>;

        currentWeather = responseBody["current"];
        hourlyWeather = responseBody["hourly"];
        dailyWeather = responseBody["daily"];

        topBarContainer = _getTopBarContainer();
        currentWeatherContainer = _getCurrentWeather();
        hourlyWeatherContainer = _getHourlyForecast();
        dailyWeatherContainer = _getDailyForecast();
        detailsContainer = _getDetails();

        switch (currentWeather["weather"][0]["main"]) {
          case "Thunderstorm":
            break;
          case "Drizzle":
            if (_isDay()) {
              backgroundImage = "day_drizzle";
            } else {
              backgroundImage = "night_drizzle";
            }
            break;
          case "Rain":
            break;
          case "Clear":
            if (_isDay()) {
              backgroundImage = "day_clear";
            } else {
              backgroundImage = "night_clear";
            }
            break;
          case "Clouds":
            if (_isDay()) {
              backgroundImage = "day_cloudy";
            } else {
              backgroundImage = "night_cloudy";
            }
            break;
        }

        print('Request completed');
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    });
  }


  bool _isDay() {
    return currentWeather["sunrise"] < currentTimeInSeconds &&
        currentTimeInSeconds < currentWeather["sunset"];
  }

  Container _getTopBarContainer() {
    return Container(
      margin: const EdgeInsets.fromLTRB(25.0, 60.0, 15.0, 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            city,
            style: TextStyle(fontSize: 30.0),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed('/chooseLocation');
            },
            child: Icon(Icons.home_outlined),
          ),
        ],
      ),
    );
  }

  Container _getCurrentWeather() {
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
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      color: Color.fromRGBO(128, 128, 128, 0.33),
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
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      color: Color.fromRGBO(128, 128, 128, 0.33),
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

  Container _getHourlyForecast() {
    List<Widget> hourWidgetList = [];
    for (int i = 0; i < 25; i++) {
      hourWidgetList.add(HourlyForecastWidget(hourlyWeather[i], i));
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            child: Text(
              "Hourly Forecast",
              style: TextStyle(fontSize: 17.0),
            ),
            padding: EdgeInsets.all(20.0),
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
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        color: Color.fromRGBO(255, 255, 255, 0.33),
      ),
    );
  }

  Container _getDailyForecast() {
    List<Widget> dayWidgetList = [];
    for (int i = 0; i < 8; i++) {
      dayWidgetList.add(DailyForecastWidget(dailyWeather[i], i));
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            child: Text(
              "Daily Forecast",
              style: TextStyle(fontSize: 17.0),
            ),
            padding: EdgeInsets.all(20.0),
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
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        color: Color.fromRGBO(255, 255, 255, 0.33),
      ),
    );
  }

  Container _getDetails() {
    return Container(
      padding: EdgeInsets.all(20.0),
      margin: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 25.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          child: Text(
            "Details",
            style: TextStyle(fontSize: 17.0),
          ),
          padding: EdgeInsets.only(bottom: 20.0),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Precipitation",
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.black.withOpacity(0.5),
                          )),
                      SizedBox(height: 10.0),
                      Text(hourlyWeather[0]["pop"].toString() + " mm",
                          style: TextStyle(
                            fontSize: 15.0,
                          )),
                    ],
                  ),
                  SizedBox(height: 30.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Humidity",
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.black.withOpacity(0.5),
                          )),
                      SizedBox(height: 10.0),
                      Text(currentWeather["humidity"].toString() + "%",
                          style: TextStyle(
                            fontSize: 15.0,
                          )),
                    ],
                  ),
                  SizedBox(height: 30.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("UV",
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.black.withOpacity(0.5),
                          )),
                      SizedBox(height: 10.0),
                      Text(currentWeather["uvi"].toString(),
                          style: TextStyle(
                            fontSize: 15.0,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Wind",
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.black.withOpacity(0.5),
                          )),
                      SizedBox(height: 10.0),
                      Text(currentWeather["wind_speed"].toString() + " km/h",
                          style: TextStyle(
                            fontSize: 15.0,
                          )),
                    ],
                  ),
                  SizedBox(height: 30.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Visibility",
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.black.withOpacity(0.5),
                          )),
                      SizedBox(height: 10.0),
                      Text(
                          (currentWeather["visibility"] / 1000).toString() +
                              " km",
                          style: TextStyle(
                            fontSize: 15.0,
                          )),
                    ],
                  ),
                  SizedBox(height: 30.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Pressure",
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.black.withOpacity(0.5),
                          )),
                      SizedBox(height: 10.0),
                      Text(currentWeather["pressure"].toString() + " hPa",
                          style: TextStyle(
                            fontSize: 15.0,
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ]),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        color: Color.fromRGBO(255, 255, 255, 0.33),
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
          Image.asset(
            "assets/images/$image.png",
            width: 50,
            height: 50,
          ),
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
    var dateTime =
        DateTime.fromMillisecondsSinceEpoch(widget.dailyForecast["dt"] * 1000);
    var date = DateFormat.MMMd().format(dateTime);

    var dayOfWeek = DateFormat.E().format(dateTime);

    if (widget.position == 0) {
      dayOfWeek = "Today";
    }

    String image;

    image = widget.dailyForecast["weather"][0]["icon"].toString();

    return Padding(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dayOfWeek,
            style: TextStyle(fontSize: 15.0),
          ),
          SizedBox(height: 5.0),
          Text(
            date,
            style: TextStyle(
              fontSize: 15.0,
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          Image.asset(
            "assets/images/$image.png",
            width: 50,
            height: 50,
          ),
          Text(
            widget.dailyForecast["weather"][0]["main"].toString(),
            style: TextStyle(
              fontSize: 15.0,
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 15.0),
          Row(
            children: [
              Text(
                double.parse(widget.dailyForecast["temp"]["max"].toString())
                        .round()
                        .toString() +
                    "°",
                style: TextStyle(fontSize: 15.0),
              ),
              Icon(
                Icons.arrow_upward_rounded,
                size: 20.0,
              )
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Text(
                double.parse(widget.dailyForecast["temp"]["min"].toString())
                        .round()
                        .toString() +
                    "°",
                style: TextStyle(fontSize: 15.0),
              ),
              Icon(
                Icons.arrow_downward_rounded,
                size: 20.0,
              )
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.0),
    );
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

void _addLocationDataToSharedPreferences(double latitude, double longitude) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List<Placemark> placemark = await placemarkFromCoordinates(latitude, longitude);

  await prefs.setDouble('latitude', latitude);
  await prefs.setDouble('longitude', longitude);
  await prefs.setString('city', placemark.first.locality ?? "City");

  print(prefs.getDouble('latitude'));
  print(prefs.getDouble('longitude'));
  print(prefs.getString('city'));
  print("Got location data");
}

