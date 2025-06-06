import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class WorldTime {
  String location; // location name for UI
  String time = ''; // the time in that location
  String flag; // asset flag icon path
  String url; // location url for API endpoint (e.g., "Europe/Berlin")
  bool isDaytime = true;// true or false if daytime or not
  String date='';

  WorldTime({required this.location, required this.flag, required this.url});

  Future<void> getTime() async {
    try {
      // Use the new API endpoint
      final uri = Uri.parse('https://timeapi.io/api/Time/current/zone?timeZone=$url');
      http.Response response = await http.get(uri);
      Map data = jsonDecode(response.body);

      // The timeapi.io returns JSON with fields like 'dateTime' in ISO8601 format
      String datetime = data['dateTime']; // e.g., "2025-06-04T15:34:21.1234567"

      DateTime now = DateTime.parse(datetime);

      // Determine if daytime between 6 AM and 8 PM
      isDaytime = now.hour >= 6 && now.hour < 20;

      // Format time nicely e.g. 3:34 PM
      time = DateFormat.jm().format(now);
    } catch (e) {
      print('Error getting time: $e');
      time = 'Could not get time';
      isDaytime = true;
    }
  }
}
