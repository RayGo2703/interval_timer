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
  final TextEditingController durationController = TextEditingController();
  IntervalTimer? intervalTimer;
  
  // Timer display variables
  int remainingMinutes = 0;
  int remainingSeconds = 0;
  bool isTimerRunning = false;
  bool isTimerPaused = false;
  Timer? displayTimer;
  int totalDurationSeconds = 0;
  int elapsedSeconds = 0;

  static String _formatTime(DateTime now) =>
      "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

  @override
  void initState() {
    super.initState();
    clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => timeString = _formatTime(DateTime.now()));
    });
    
    // Initialize with empty values
    remainingMinutes = 0;
    remainingSeconds = 0;
  }

  @override
  void dispose() {
    clockTimer.cancel();
    displayTimer?.cancel();
    intervalTimer?.stop();
    super.dispose();
  }

  void _startIntervalReminder() {
    final intervalSeconds = int.tryParse(intervalController.text);
    final totalMinutes = int.tryParse(durationController.text);

    if (intervalSeconds == null || intervalSeconds <= 0 || totalMinutes == null || totalMinutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter valid interval (sec) and duration (min)"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isTimerRunning = true;
      isTimerPaused = false;
      if (elapsedSeconds == 0) {
        // Starting fresh
        totalDurationSeconds = totalMinutes * 60;
        elapsedSeconds = 0;
        remainingMinutes = totalMinutes;
        remainingSeconds = 0;
      }
    });

    intervalTimer?.stop();
    intervalTimer = IntervalTimer(
      intervalSeconds: intervalSeconds,
      totalDuration: Duration(seconds: totalDurationSeconds - elapsedSeconds),
      onEnd: _onTimerEnd,
    );
    intervalTimer!.start();

    // Start countdown display
    displayTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        elapsedSeconds++;
        int remaining = totalDurationSeconds - elapsedSeconds;
        
        if (remaining <= 0) {
          remainingMinutes = 0;
          remainingSeconds = 0;
          timer.cancel();
        } else {
          remainingMinutes = remaining ~/ 60;
          remainingSeconds = remaining % 60;
        }
      });
    });
  }

  void _onTimerEnd() {
    setState(() {
      isTimerRunning = false;
      isTimerPaused = false;
      remainingMinutes = 0;
      remainingSeconds = 0;
      elapsedSeconds = 0;
    });
    displayTimer?.cancel();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Timer completed!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _pauseTimer() {
    setState(() {
      isTimerRunning = false;
      isTimerPaused = true;
    });
    intervalTimer?.stop();
    displayTimer?.cancel();
  }

  void _stopIntervalReminder() {
    setState(() {
      isTimerRunning = false;
      isTimerPaused = false;
      elapsedSeconds = 0;
    });
    intervalTimer?.stop();
    displayTimer?.cancel();
    
    // Reset to original duration
    final totalMinutes = int.tryParse(durationController.text) ?? 0;
    setState(() {
      if (totalMinutes > 0) {
        remainingMinutes = totalMinutes;
        remainingSeconds = 0;
      }
    });
  }

  void _deleteSettings() {
    setState(() {
      intervalController.clear();
      durationController.clear();
      remainingMinutes = 0;
      remainingSeconds = 0;
      isTimerRunning = false;
      isTimerPaused = false;
      elapsedSeconds = 0;
    });
    intervalTimer?.stop();
    displayTimer?.cancel();
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C1E),
          title: const Text(
            'Timer Settings',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: intervalController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Interval (seconds)",
                  labelStyle: TextStyle(color: Colors.white60),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Duration (minutes)",
                  labelStyle: TextStyle(color: Colors.white60),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                final totalMinutes = int.tryParse(durationController.text) ?? 0;
                setState(() {
                  if (totalMinutes > 0) {
                    remainingMinutes = totalMinutes;
                    remainingSeconds = 0;
                  }
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // Current time
            Text(
              timeString,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Main timer circle
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: isTimerRunning ? null : _showSettingsDialog,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer circle
                      Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.withAlpha(76),
                            width: 4,
                          ),
                        ),
                      ),
                      
                      // Timer content
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Interval indicator
                          Text(
                            intervalController.text.isEmpty ? 'Tap to set interval' : '${intervalController.text} s',
                            style: TextStyle(
                              color: intervalController.text.isEmpty ? Colors.blue : Colors.white60,
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Main timer display
                          Text(
                            '${remainingMinutes.toString().padLeft(2, '0')} : ${remainingSeconds.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 2,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Duration indicator
                          Text(
                            durationController.text.isEmpty ? 'Tap to set duration' : '${durationController.text} m',
                            style: TextStyle(
                              color: durationController.text.isEmpty ? Colors.blue : Colors.white60,
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Bell icon when timer is running
                          if (isTimerRunning)
                            const Icon(
                              Icons.notifications_outlined,
                              color: Colors.white60,
                              size: 20,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Delete/Stop button
                GestureDetector(
                  onTap: () {
                    if (isTimerRunning || isTimerPaused) {
                      _stopIntervalReminder();
                    } else {
                      _deleteSettings();
                    }
                  },
                  child: Container(
                    width: 120,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Text(
                        (isTimerRunning || isTimerPaused) ? 'Stop' : 'Delete',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Start/Pause/Resume button
                GestureDetector(
                  onTap: () {
                    if (isTimerRunning) {
                      _pauseTimer();
                    } else if (isTimerPaused) {
                      _startIntervalReminder();
                    } else if (intervalController.text.isNotEmpty && durationController.text.isNotEmpty) {
                      _startIntervalReminder();
                    }
                  },
                  child: Container(
                    width: 120,
                    height: 50,
                    decoration: BoxDecoration(
                      color: (intervalController.text.isEmpty || durationController.text.isEmpty) && !isTimerPaused
                          ? const Color(0xFF2C2C2E)
                          : const Color(0xFF007AFF),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Text(
                        isTimerRunning ? 'Pause' : (isTimerPaused ? 'Resume' : 'Start'),
                        style: TextStyle(
                          color: (intervalController.text.isEmpty || durationController.text.isEmpty) && !isTimerPaused
                              ? Colors.white60
                              : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}