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
    final seconds = int.tryParse(intervalController.text);
    if (seconds == null || seconds <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid number of seconds")),
      );
      return;
    }

    intervalTimer?.stop(); // reset if already running
    intervalTimer = IntervalTimer(seconds: seconds);
    intervalTimer!.start();
  }

  void _stopIntervalReminder() {
    intervalTimer?.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Interval Clock")),
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
                labelText: "Interval in seconds", // ✅ Updated label
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
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
