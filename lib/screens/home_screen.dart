import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/interval_timer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer clockTimer;
  String timeString = _formatTime(DateTime.now());
  final TextEditingController intervalController = TextEditingController();
  final TextEditingController totalDurationController = TextEditingController();
  IntervalTimer? intervalTimer;

  static String _formatTime(DateTime now) =>
      "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

  @override
  void initState() {
    super.initState();
    clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => timeString = _formatTime(DateTime.now()));
    });
  }

  @override
  void dispose() {
    clockTimer.cancel();
    intervalTimer?.stop();
    super.dispose();
  }

  void _startIntervalReminder() {
    final intervalSeconds = int.tryParse(intervalController.text);
    final totalMinutes = int.tryParse(totalDurationController.text);

    if (intervalSeconds == null || intervalSeconds <= 0 || totalMinutes == null || totalMinutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid interval and total duration")),
      );
      return;
    }

    intervalTimer?.stop(); // reset if already running
    intervalTimer = IntervalTimer(
      intervalSeconds: intervalSeconds,
      totalMinutes: totalMinutes,
    );
    intervalTimer!.start();
  }

  void _stopIntervalReminder() {
    intervalTimer?.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Interval Timer Clock")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(timeString, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 40),
            TextField(
              controller: intervalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Interval (in seconds)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: totalDurationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Total Duration (in minutes)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: _startIntervalReminder,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Start Reminder"),
                ),
                ElevatedButton.icon(
                  onPressed: _stopIntervalReminder,
                  icon: const Icon(Icons.stop),
                  label: const Text("Stop Reminder"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
