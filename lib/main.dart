// ignore_for_file: sized_box_for_whitespace, prefer_interpolation_to_compose_strings, non_constant_identifier_names, avoid_print, unnecessary_new
import 'dart:async';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/%20Module/CurrentCityDataModel.dart';
import 'package:flutter_app/%20Module/ForecastDaysModel.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:intl/intl.dart';

// A library for Implementation of various widgets for ui

//MaterialApp for example ->title - structure of material => Follow the rules of material design - ui -> introduce to attribute home -> first one thing that needs to be implemented in MaterialApp -> home for
//      Container -> a widget that hold another widget ->Implementation of components (buttons) and widgets in its subset
//  Getting t he red color from the Color class and give to attribute color of container

void main() {
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAPPState();
}

class _MyAPPState extends State<MyApp> {
  late Future<CurrentCityDataModel> currentweatherFuture;
  late StreamController<List<ForecastDaysModel>> StreamForecastDaysModel;
  var cityname = "tehran";
  var lat;
  var lon;

  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentweatherFuture = SendRequestCurrentWeather(cityname);
    StreamForecastDaysModel = StreamController<List<ForecastDaysModel>>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather App"),
        elevation: 15,
        actions: <Widget>[
          PopupMenuButton<String>(
              itemBuilder: (BuildContext context) {
                return {'setting', 'profile', 'logout'}.map((String Choice) {
                  return PopupMenuItem(value: Choice, child: Text(Choice),);
                }).toList();
              }
          )

        ],

      ),
      body: FutureBuilder<CurrentCityDataModel>(
        future: currentweatherFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            CurrentCityDataModel? cityDataModel = snapshot.data;
             SendRequest7DaysForecast( lat, lon);

            final formatter = DateFormat.jm();
            var sunrise = formatter.format(
                new DateTime.fromMicrosecondsSinceEpoch(
                    cityDataModel!.sunrise * 1000,
                    isUtc: true));

            var sunset = formatter.format(
                new DateTime.fromMicrosecondsSinceEpoch(
                    cityDataModel!.sunset * 1000,
                    isUtc: true));

            return Container(
              // decoration:  BoxDecoration(
              //     image: DecorationImage(
              //         fit: BoxFit.cover,
              //         image: AssetImage('images/pic_bg.jpeg')
              //     )
              // ),
                color: Colors.black,
              child: Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: ElevatedButton(onPressed: () {
                              setState(() {
                               currentweatherFuture =  SendRequestCurrentWeather(textEditingController.text);
                              });


                            }, child: const Text("find")),
                          ),
                          Expanded(child: TextField(
                            controller: textEditingController,
                            decoration: const InputDecoration(
                              hintText: "enter a city name",
                              hintStyle: TextStyle(color: Colors.white),
                              border: UnderlineInputBorder(),
                            ),
                            style: TextStyle(color:Colors.white),
                          )),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Text(
                        cityDataModel!.cityname,
                        style: const TextStyle(color: Colors.white,
                            fontSize: 35),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        cityDataModel.description,
                        style: const TextStyle(color: Colors.white,
                            fontSize: 20),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: Icon(
                        Icons.sunny,
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(
                        cityDataModel.temp.toString() + "\u00B0",
                        style: const TextStyle(color: Colors.white,
                            fontSize: 20),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            const Text(
                              "Max",
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 20),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                cityDataModel.temp_max.toString() + "\u00B0",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Container(
                            width: 1,
                            height: 40,
                            color: Colors.white,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            children: [
                              const Text(
                                "Min",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 20),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  cityDataModel.temp_min.toString() + "\u00B0",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        color: Colors.grey,
                        height: 1,
                        width: double.infinity,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 100,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Center(
                          child: StreamBuilder<List<ForecastDaysModel>>(
                            stream: StreamForecastDaysModel.stream,
                            builder: (context,snapshot){
                              if(snapshot.hasData){
                                List<ForecastDaysModel>? forecastdays = snapshot.data;
                                return ListView.builder(
                                    shrinkWrap: true,
                                     scrollDirection: Axis.horizontal,
                                    itemCount: 6,
                                    itemBuilder: (BuildContext context, int pos) {
                                      return listViewItem(forecastdays![ pos + 1]);
                                    });
                              }else {
                              return Center(
                                child: JumpingDotsProgressIndicator(
                                  color: Colors.black,
                                  fontSize: 60,
                                  dotSpacing: 2,
                                ),
                              );
                              }
                            },



                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Container(
                        color: Colors.grey,
                        height: 1,
                        width: double.infinity,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              const Text(
                                "wind speed",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 15),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(

                                  cityDataModel.windSpeed.toString() + "m/s",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Container(
                              width: 1,
                              height: 40,
                              color: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Column(
                              children: [
                                const Text(
                                  "sunrise",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 15),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    sunrise,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),

                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Container(
                              width: 1,
                              height: 40,
                              color: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Column(
                              children: [
                                const Text(
                                  "sunset",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 15),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    sunset,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),

                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Container(
                              width: 1,
                              height: 40,
                              color: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Column(
                              children: [
                                const Text(
                                  "humidity",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 15),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    cityDataModel.humidity.toString() + "%",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center(
              child: JumpingDotsProgressIndicator(
                color: Colors.black,
                fontSize: 60,
                dotSpacing: 2,
              ),
            );
          }
        },

      ),
    );
  }
 Container listViewItem(ForecastDaysModel forecastdays){
  return Container(
    height: 50,
    width: 70,
    child:  Card(
      elevation: 0,
      color: Colors.transparent,
      child: Column(
        children: [
          Text(forecastdays.dataTime, style: TextStyle(color: Colors.grey, fontSize: 15),),
          Icon(Icons.cloud, color: Colors.white,),
          Text(forecastdays.temp.round().toString() + "\u00B0", style: TextStyle(color: Colors.grey, fontSize: 20),),
        ],
      ),
    ),
  );
 }
  Future<CurrentCityDataModel> SendRequestCurrentWeather(
      String cityname) async {
    var apikey = 'a405cca30f992a979a56a85c7f0cc8ae';

    var response = await Dio().get(
        "https://api.openweathermap.org/data/2.5/weather",
        queryParameters: {'q': cityname, 'appid': apikey, 'units': 'metric'}
    );
    lat = response.data["coord"]["lat"];
    lon = response.data["coord"]["lon"];



    var datamodel = CurrentCityDataModel(
        response.data["name"],
        response.data["coord"]["lon"],
        response.data["coord"]["lat"],
        response.data["weather"][0]["main"],
        response.data["weather"][0]["description"],
        response.data["main"]["temp"],
        response.data["main"]["temp_min"],
        response.data["main"]["temp_max"],
        response.data["main"]["pressure"],
        response.data["main"]["humidity"],
        response.data["wind"]["speed"],
        response.data["dt"],
        response.data["sys"]["country"],
        response.data["sys"]["sunrise"],
        response.data["sys"]["sunset"]);
    return datamodel;
  }

  void SendRequest7DaysForecast(lat, lon) async {
    List<ForecastDaysModel> list = [];
    var apikey = 'a405cca30f992a979a56a85c7f0cc8ae';


   try {
     var response = await Dio().get(
         "https://api.openweathermap.org/data/3.0/onecall",
         queryParameters: {
           'lat': lat,
           'lon': lon,
           'exclude': 'minutely,hourly',
           'appid': apikey,
           'units': 'metric'
         }
     );
     final formatter = DateFormat.MMMd();
     for (int i = 0; i < 8; i++) {
       var model = response.data['daily'][i];
       var dt = formatter.format(new DateTime.fromMillisecondsSinceEpoch(
           model['dt'] * 1000,
           isUtc: true));

       ForecastDaysModel forecastDaysModel = ForecastDaysModel(
           dt, model['temp']['day'], model['weather'][0]['main'],
           model['weather'][0]['description']);
       list.add(forecastDaysModel);
     }
     StreamForecastDaysModel.add(list);
   } on DioException catch (e){
     print(e.response?.statusCode);
     print(e.message);
     ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text("there is an 401 error ")));
   }






  }
}