import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../utils/get_size.dart';


class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xff151515),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ThirdLineChartWidget(),
        ],
      ),
    );
  }
}


class ThirdLineChartWidget extends StatefulWidget {
  const ThirdLineChartWidget({super.key});

  @override
  State<ThirdLineChartWidget> createState() => ThirdLineChartWidgetState();
}

class ThirdLineChartWidgetState extends State<ThirdLineChartWidget> {
  final limitCount = 25;
  final List<FlSpot> linePoints = [];
  final List<FlSpot> linePoints2 = [];

  double xValue = 0;
  final double step = 0.6;

  late Timer timer;

  bool isLine2 = false;

  late io.Socket socket;

  connectSocket() {
    // Initialize the socket connection
    socket = io.io('http://3.89.249.227:3001', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    // Connect to the socket server
    socket.connect();

    // Listen for the 'randomIntegers' message
    socket.on('randomInteger', (data) {
      log('Received randomIntegers: $data');
      generateSpots(data);
      // Handle the received data
    });

    // Handle connection
    socket.onConnect((_) {
      log('Connected to the socket server');
    });

    // Handle disconnection
    socket.onDisconnect((_) {
      log('Disconnected from the socket server');
    });
  }

  generateSpots(int number) {
    setState(() {
      if (!isLine2) {
        linePoints.add(
          FlSpot(xValue, number.toDouble()),
        );
      } else {
        linePoints2.add(
          FlSpot(xValue, number.toDouble()),
        );
      }
      xValue += step;
      log("length: ${linePoints.length} == $xValue == $isLine2");
    });
    if (isLine2) {
      linePoints.removeAt(0);
    } else {
      if (linePoints2.isNotEmpty) {
        linePoints2.removeAt(0);
      }
    }
    if (xValue > limitCount) {
      xValue = 0;
      isLine2 = !isLine2;
      // comp = true;
    }
  }

  @override
  void initState() {
    super.initState();
    connectSocket();
    // startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(
      const Duration(milliseconds: 80),
          (timer) async {
        setState(() {
          if (!isLine2) {
            linePoints.add(
              FlSpot(xValue, math.Random().nextInt(10).toDouble()),
            );
          } else {
            linePoints2.add(
              FlSpot(xValue, math.Random().nextInt(10).toDouble()),
            );
          }
          xValue += step;
          log("length: ${linePoints.length} == $xValue == $isLine2");
        });
        if (isLine2) {
          linePoints.removeAt(0);
        } else {
          if (linePoints2.isNotEmpty) {
            linePoints2.removeAt(0);
          }
        }
        if (xValue > limitCount) {
          xValue = 0;
          isLine2 = !isLine2;
          // comp = true;
        }
      },
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return linePoints.isNotEmpty
        ? Column(
      children: [
        const SizedBox(height: 25),
        SizedBox(
          height: getHeight(context) * 0.1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: LineChart(
              chartData,
              // duration: Duration(milliseconds: 5000),
            ),
          ),
        ),
      ],
    )
        : Container();
  }

  LineChartData get chartData => LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: const FlTitlesData(show: false),
      lineBarsData: [
        if (linePoints.isNotEmpty) lineChartBar(linePoints),
        if (linePoints2.isNotEmpty) lineChartBar(linePoints2),
      ],
      minY: 0,
      maxY: 100,
      minX: 0,
      maxX: limitCount.toDouble()
    // maxX: limitCount * step,
  );

  LineChartBarData lineChartBar(List<FlSpot> spots) {
    return LineChartBarData(
      isCurved: true,
      dotData: const FlDotData(show: false),
      gradient: const LinearGradient(
        colors: [
          // Colors.green.withOpacity(0),
          Colors.indigoAccent,
          Colors.indigoAccent,
        ],
        stops: [0.1, 1.0],
      ),
      barWidth: 3.3,
      spots: spots,
      curveSmoothness: 0.6,
    );
  }

  LineChartBarData lineChartBar2(List<FlSpot> spots) {
    return LineChartBarData(
      isCurved: false,
      dotData: const FlDotData(show: false),
      gradient: const LinearGradient(
        colors: [
          // Colors.green.withOpacity(0),
          Colors.green,
          Colors.green,
        ],
        stops: [0.1, 1.0],
      ),
      barWidth: 5,
      curveSmoothness: 0.4,
      spots: spots,
    );
  }
}

