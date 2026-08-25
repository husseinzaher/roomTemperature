import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('bare LineChart renders', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: const [FlSpot(0, 22), FlSpot(1, 23), FlSpot(2, 24)],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  });
}
