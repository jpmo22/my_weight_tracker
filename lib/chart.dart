import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:flutter/material.dart';

class MyChart extends StatefulWidget {
  
  final List<double> data;
  MyChart({this.data});

  @override
  State<StatefulWidget> createState() => _MyChartState();
}

class _MyChartState extends State<MyChart> {
  @override
  Widget build(BuildContext context) {
    return Sparkline(
      pointsMode: PointsMode.last,
      pointColor: Colors.amber,
      pointSize: 10.0,
      lineWidth: 5.0,
      lineGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.teal, Colors.tealAccent],
      ),
      data: widget.data,
    );
  }

}