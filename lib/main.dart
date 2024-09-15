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
  AudioRecorder myRecording = AudioRecorder();
  Timer? timer;

  double volume = 0.0;
  double minVolume = -45.0;

  startTimer() async {
    timer ??= Timer.periodic(
        const Duration(milliseconds: 50), (timer) => updateVolume());
  }

  updateVolume() async {
    Amplitude ampl = await myRecording.getAmplitude();
    if (ampl.current > minVolume) {
      setState(() {
        volume = (ampl.current - minVolume) / minVolume;
      });
      //print("Volume: $volume");
    }
  }

  int volume0to(int maxVolumeToDisplay) {
    return (volume * maxVolumeToDisplay).toInt().round().abs();
  }

  Future<bool> startRecording() async {
    if (await myRecording.hasPermission()) {
      if (!await myRecording.isRecording()) {
        await myRecording.start(const RecordConfig(), path: '/popcorn.m4a');
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
            child:
                Text(snapshot.hasData ? volume0to(100).toString() : 'No data'),
          ));
        });
  }
}
