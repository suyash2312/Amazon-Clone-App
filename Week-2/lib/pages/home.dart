import 'package:flutter/material.dart';
import 'package:world_time_app/services/world_time.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map data = {};
  WorldTime? currentTimeInstance;

  Future<void> refreshTime() async {
    if (currentTimeInstance != null) {
      await currentTimeInstance!.getTime();
      setState(() {
        data['time'] = currentTimeInstance!.time;
        data['isDaytime'] = currentTimeInstance!.isDaytime;
        data['date'] = currentTimeInstance!.date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty
        ? data
        : (ModalRoute.of(context)?.settings.arguments as Map?) ?? {
      'time': 'Loading...',
      'location': 'Unknown',
      'isDaytime': true,
      'date': 'Unknown date',
      'flag': 'default.png',
      'url': 'Europe/London',
    };

    String bgImage = data['isDaytime'] ? 'day.png' : 'night.png';
    Color? bgColor = data['isDaytime'] ? Colors.blue : Colors.indigo[700];

    return Scaffold(
      backgroundColor: bgColor,
      body: RefreshIndicator(
        onRefresh: refreshTime,
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/$bgImage'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(0, 120.0, 0, 0),
                    physics: AlwaysScrollableScrollPhysics(),
                    children: [
                      Center(
                        child: Column(
                          children: <Widget>[
                            TextButton.icon(
                              onPressed: () async {
                                dynamic result = await Navigator.pushNamed(
                                    context, '/location');
                                if (result != null) {
                                  setState(() {
                                    data = result;
                                    currentTimeInstance = WorldTime(
                                      location: data['location'],
                                      flag: data['flag'],
                                      url: data['url'],
                                    );
                                  });
                                }
                              },
                              icon: Icon(
                                Icons.edit_location,
                                color: Colors.grey[300],
                              ),
                              label: Text(
                                'Edit Location',
                                style: TextStyle(color: Colors.grey[300]),
                              ),
                            ),
                            SizedBox(height: 20.0),
                            Text(
                              data['location'],
                              style: TextStyle(
                                fontSize: 28.0,
                                letterSpacing: 2.0,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 20.0),
                            Text(
                              data['time'],
                              style: TextStyle(
                                fontSize: 66.0,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              data['date'] ?? '',
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.white70,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
