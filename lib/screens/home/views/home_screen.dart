import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:flutter_app/services/user_data_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth/blocs/sign_in_block/sign_in_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String heartRateData = '';
  String heartRateRangeData = '';
  String _averageHeartRate = '0.0';
  int _minHeartRate = 0;
  int _maxHeartRate = 0;
  String _averageRangeHeartRate = '0.0';
  int _minRangeHeartRate = 0;
  int _maxRangeHeartRate = 0;

  String restingHeartRateData = '';
  String restingHeartRateRangeData = '';
  String _averageRestingRangeHeartRate = '0.0';
  int _minRestingRangeHeartRate = 0;
  int _maxRestingRangeHeartRate = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final user = context.read<AuthenticationBloc>().state.user;
    final statusCode = await UserDataService.authorize();
    if (statusCode == 200) {
      final data = await UserDataService.fetchHeartRate(user!.usernameUuid);
      _calculateHeartRateData(data);
      setState(() {
        heartRateData = data.toString();
      });

      final rangeData =
          await UserDataService.fetchHeartRateRange(user.usernameUuid);
      _calculateHeartRateRangeData(rangeData);
      setState(() {
        heartRateRangeData = rangeData.toString();
      });

      final restingData =
          await UserDataService.fetchRestingHeartRate(user.usernameUuid);
      setState(() {
        restingHeartRateData = jsonEncode(restingData);
      });

      final rangeRestingData =
          await UserDataService.fetchRestingHeartRateRange(user.usernameUuid);
      _calculateRestingHeartRateRangeData(rangeRestingData);
      setState(() {
        restingHeartRateRangeData = rangeRestingData.toString();
      });
    } else {
      setState(() {
        heartRateData = 'Failed to authorize';
        heartRateRangeData = 'Failed to authorize';
      });
    }
  }

  void _calculateHeartRateData(dynamic data) {
    if (data['status'] == 'success' && data['code'] == 200) {
      List<dynamic> heartRateData = data['data']['data'];

      if (heartRateData.isNotEmpty) {
        int sum = 0;
        int count = heartRateData.length;
        int minHeartRate = heartRateData[0]['value'];
        int maxHeartRate = heartRateData[0]['value'];

        for (var entry in heartRateData) {
          int value = entry['value'];
          sum += value;
          if (value < minHeartRate) {
            minHeartRate = value;
          }
          if (value > maxHeartRate) {
            maxHeartRate = value;
          }
        }

        double averageHeartRate = sum / count;

        setState(() {
          _averageHeartRate = averageHeartRate.toStringAsFixed(1);
          _minHeartRate = minHeartRate;
          _maxHeartRate = maxHeartRate;
        });
      } else {
        print('No heart rate data available.');
      }
    } else {
      print('Failed to fetch data: ${data['message']}');
    }
  }

  void _calculateHeartRateRangeData(dynamic rangeData) {
    if (rangeData['status'] == 'success' && rangeData['code'] == 200) {
      List<dynamic> dataList = rangeData['data'];

      int sum = 0;
      int count = 0;
      int minHeartRate = dataList[0]['data'][0]['value'];
      int maxHeartRate = dataList[0]['data'][0]['value'];

      for (var data in dataList) {
        for (var entry in data['data']) {
          int value = entry['value'];
          sum += value;
          count++;
          if (value < minHeartRate) {
            minHeartRate = value;
          }
          if (value > maxHeartRate) {
            maxHeartRate = value;
          }
        }
      }

      double averageHeartRate = sum / count;

      setState(() {
        _averageRangeHeartRate = averageHeartRate.toStringAsFixed(1);
        _minRangeHeartRate = minHeartRate;
        _maxRangeHeartRate = maxHeartRate;
      });
    } else {
      print('Failed to fetch range data: ${rangeData['message']}');
    }
  }

  void _calculateRestingHeartRateRangeData(dynamic rangeData) {
    if (rangeData['status'] == 'success' && rangeData['code'] == 200) {
      List<dynamic> dataList = rangeData['data'];

      double sum = 0.0;
      int count = 0;
      double minHeartRate = double.infinity;
      double maxHeartRate = double.negativeInfinity;

      for (var data in dataList) {
        double value = data['data']['value'];
        sum += value;
        count += 1;

        if (value < minHeartRate) {
          minHeartRate = value;
        }

        if (value > maxHeartRate) {
          maxHeartRate = value;
        }
      }

      if (count > 0) {
        _averageRestingRangeHeartRate = (sum / count).toStringAsFixed(2);
        _minRestingRangeHeartRate = minHeartRate.toInt();
        _maxRestingRangeHeartRate = maxHeartRate.toInt();
      }
    } else {
      print('Failed to fetch range data: ${rangeData['message']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthenticationBloc bloc) => bloc.state.user);
    dynamic restingHeartRate;
    if (restingHeartRateData.isNotEmpty) {
      final decodedRestingHeartRateData = jsonDecode(restingHeartRateData);
      if (decodedRestingHeartRateData['status'] == 'success') {
        restingHeartRate = decodedRestingHeartRateData['data']['data']['value'];
      }
    }

    if (user!.role == 'hospital') {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text(
            'HealthHub',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                context.read<SignInBloc>().add(SignOutRequired());
              },
              icon: const Icon(CupertinoIcons.arrow_right_to_line),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: user != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.name}!',
                        style: TextStyle(fontSize: 24, color: Colors.black),
                      ),
                      SizedBox(height: 10),
                      ExpansionTile(
                        title: Text(
                          'Rajmonda Bardhi heart rate data',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        children: [
                          ListTile(
                            title: Text(
                              'Average Today: $_averageHeartRate',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'Min Today: $_minHeartRate',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'Max Today: $_maxHeartRate',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'Average Last Week: $_averageRangeHeartRate',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'Min Last Week: $_minRangeHeartRate',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'Max Last Week: $_maxRangeHeartRate',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'Resting Heart Rate: $restingHeartRate',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'Average Resting Last Week: $_averageRestingRangeHeartRate',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'Min Resting Last Week: $_minRestingRangeHeartRate',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'Max Resting Last Week: $_maxRestingRangeHeartRate',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              final Uri emailLaunchUri = Uri(
                                scheme: 'mailto',
                                path: 'rajmonda@gmail.com',
                              );
                              launch(emailLaunchUri.toString());
                            },
                            child: Text('Contact Patient'),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ],
                  )
                : Text(
                    'Welcome to the Home Screen!',
                    style: TextStyle(fontSize: 24, color: Colors.black),
                  ),
          ),
        ),
      );
    } else if (user.role == 'simple user') {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text(
            'HealthHub',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                context.read<SignInBloc>().add(SignOutRequired());
              },
              icon: const Icon(CupertinoIcons.arrow_right_to_line),
            ),
          ],
        ),
        body: Stack(
          children: [
            // Background Container
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.lightBlueAccent,
                    Colors.blueAccent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Blurred circles
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                height: MediaQuery.of(context).size.width,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                height: MediaQuery.of(context).size.width / 1.3,
                width: MediaQuery.of(context).size.width / 1.3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
              child: Container(),
            ),
            // Centered content
            Center(
              child: SingleChildScrollView(
                child: user != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome ${user.name}!',
                            style: TextStyle(fontSize: 24, color: Colors.white),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/img/heart.png',
                                height: 120,
                                width: 120,
                              ),
                            ],
                          ),
                          Container(
                            height: 100,
                            child: LayoutBuilder(
                              builder: (BuildContext context,
                                  BoxConstraints constraints) {
                                return Image.asset(
                                  'assets/img/ecg.png',
                                  height: 150,
                                  width: constraints.maxWidth * 0.8,
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 26.0),
                            child: Text(
                              "Today's heart rate",
                              style:
                                  TextStyle(fontSize: 24, color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 26.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Average',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '$_averageHeartRate',
                                          style: TextStyle(
                                              fontSize: 28,
                                              color: Colors.white),
                                        ),
                                        Text(
                                          'bpm',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Min',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                    Text(
                                      '$_minHeartRate',
                                      style: TextStyle(
                                          fontSize: 28, color: Colors.white),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Max',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                    Text(
                                      '$_maxHeartRate',
                                      style: TextStyle(
                                          fontSize: 28, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          SizedBox(height: 20),
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 26.0),
                            child: Text(
                              "Last week's heart rate",
                              style:
                                  TextStyle(fontSize: 24, color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 26.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Average',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '$_averageRangeHeartRate',
                                          style: TextStyle(
                                              fontSize: 28,
                                              color: Colors.white),
                                        ),
                                        Text(
                                          'bpm',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Min',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                    Text(
                                      '$_minRangeHeartRate',
                                      style: TextStyle(
                                          fontSize: 28, color: Colors.white),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Max',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                    Text(
                                      '$_maxRangeHeartRate',
                                      style: TextStyle(
                                          fontSize: 28, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 26.0),
                            child: Text(
                              "Resting today's heart rate",
                              style:
                                  TextStyle(fontSize: 24, color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 26.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Heart Rate:',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                    Text(
                                      '$restingHeartRate',
                                      style: TextStyle(
                                          fontSize: 28, color: Colors.white),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 26.0),
                                  child: Text(
                                    "Resting last's week heart rate",
                                    style: TextStyle(
                                        fontSize: 24, color: Colors.white),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Average',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '$_averageRestingRangeHeartRate',
                                          style: TextStyle(
                                              fontSize: 28,
                                              color: Colors.white),
                                        ),
                                        Text(
                                          'bpm',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Min',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                    Text(
                                      '$_minRestingRangeHeartRate',
                                      style: TextStyle(
                                          fontSize: 28, color: Colors.white),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Max',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                    Text(
                                      '$_maxRestingRangeHeartRate',
                                      style: TextStyle(
                                          fontSize: 28, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Welcome to the Home Screen!',
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text(
            'HealthHub',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                context.read<SignInBloc>().add(SignOutRequired());
              },
              icon: const Icon(CupertinoIcons.arrow_right_to_line),
            ),
          ],
        ),
        body: Center(
          child: Text('Undefined Role'),
        ),
      );
    }
  }
}
