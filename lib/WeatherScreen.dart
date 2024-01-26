import 'dart:convert';
import 'dart:ui';

import 'package:app_weather/additionalInfoItem.dart';
import 'package:flutter/material.dart';

import 'package:app_weather/hourly_Forecast_Weather_App.dart';
import 'package:app_weather/secrets.dart';
import 'package:http/http.dart' as http;


class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {

  Future<Map<String,dynamic>> getCurrentWeather() async {
    try {

      String cityName = 'London';
      final res = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=$cityName,uk&APPID=$openWeatherAPIkey'),
      );
      final data = jsonDecode(res.body);
      if (data['cod'] !='200'){
        throw 'An Unexpected Error Occurred';
      }
       return data;
        //data['list'][0]['main']['temp'].toDouble();


      } catch (e) {
        throw e.toString();
      }
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App', style: TextStyle(
          fontWeight: FontWeight.bold
        ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: (){
            },
           icon : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context,snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          if(snapshot.hasError){
            return Center(
                child: Text(snapshot.error.toString())) ;
          }

          final data = snapshot.data!;
          final currentWeatherData = data['list'][0];
          final currentTemp =  currentWeatherData['main']['temp'].toDouble();
          final currentSky =  currentWeatherData['weather'][0]['main'];
          final currentPressure = currentWeatherData['main']['Pressure'];
          final currentWindSpeed = currentWeatherData['wind']['speed'];
          final currentHumidity = currentWeatherData['main']['humidity'];
          return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //main card
              SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10) ,
                      child:   Padding(
                        padding:const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text('$currentTemp K' , style:  const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold
                            ),
                            ),
                            const SizedBox(height: 16),
                            Icon(
                              currentSky == 'Clouds' || currentSky == 'Rain'
                                  ? Icons.cloud
                                  : Icons.sunny,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                             Text(currentSky, style: const TextStyle(
                              fontSize: 20,
                            ),)
                          ],
                        ),
                      ),
                    ),
                  ),

                ),
              ),
              const SizedBox(height: 20),
              const Text('Weather Forecast', style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                ),
              SizedBox(
                height: 120,
                child: ListView.builder(
                    itemCount:5,
                    scrollDirection: Axis.horizontal,
                    itemBuilder:(context , index){
                      final hourlyForecast = data['list'][index];
                      final hourlySky =  data['list'][index]['weather'][0]['main'];
                      final hourlyTemp = hourlyForecast['main']['temp'].toString();
                      return HourlyForecastItem(
                          icons: hourlySky == 'Clouds' || hourlySky == 'Rains'
                          ? Icons.cloud
                          : Icons.sunny,
                          time: hourlyForecast['dt_txt'].toString(),
                          temperature:hourlyTemp);
                    }
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Additional Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16,),
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  additionalInfoItem(
                    icon: Icons.water_drop,
                    label: 'Humidity',
                    value: currentHumidity.toString(),
                  ),
                  additionalInfoItem(
                    icon: Icons.air,
                    label: 'Wind Speed',
                    value: currentWindSpeed.toString(),
                  ),
                  additionalInfoItem(
                    icon: Icons.beach_access,
                    label: 'Pressure',
                    value: currentPressure.toString(),
                  ),

                ],
              ),
            ],
          ),
        );
        },
      ),
    );
  }
}




