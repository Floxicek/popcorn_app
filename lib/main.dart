import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';

void main() {
  runApp(const MaterialApp(
    home: MicPage(),
  ));
}

class MicPage extends StatefulWidget {
  const MicPage({super.key});

  @override
  State<MicPage> createState() => _MicPageState();
}

class _MicPageState extends State<MicPage> {
  Record myRecording = Record();
  Timer? timer;
  Stopwatch stopwatch = Stopwatch();

  double volume = 0.0;
  double minVolume = -200.0;

  startTimer() async {
    timer ??= Timer.periodic(
        const Duration(milliseconds: 50), (timer) => updateVolume());
  }

  updateVolume() async {
    Amplitude ampl = await myRecording.getAmplitude();
    setState(() {
      volume = ampl.current;
    });
    if (volume >= -10.0) {
      if (stopwatch.isRunning) {
        stopwatch.stop();
        stopwatch.reset();
      }
      stopwatch.start();
    }
  }

  Future<bool> startRecording() async {
    if (await myRecording.hasPermission()) {
      if (!await myRecording.isRecording()) {
        await myRecording.start();
      }
      startTimer();
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: startRecording(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          return Scaffold(
              body: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                Text(snapshot.hasData ? volume.toString() : 'No data'),
                Text(stopwatch.elapsed.toString()),
              ])));
        });
  }
}
