import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_recorder/core/colors.dart';
import 'package:flutter_recorder/core/constants.dart';
import 'package:flutter_recorder/core/services.dart';
import 'package:flutter_recorder/core/size_constants.dart';
import 'package:flutter_recorder/core/styles.dart';
import 'package:flutter_recorder/pages/audio_visualizer.dart';
import 'package:flutter_recorder/pages/recording_list.dart';
import 'package:flutter_recorder/widgets/reusable_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart' show DateFormat;

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({
    Key? key,
  }) : super(key: key);

  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  FlutterSoundRecorder _recordingSession = FlutterSoundRecorder();
  String? pathToAudio;
  bool _playAudio = false;
  String _timerText = initialTime;
  late Stream<double> amplitudeStream;
  double currentAmplitude = 0.0;
  bool _showVisualizer = false;
  StreamSubscription? recorderSubscription;

  Future<void> startRecording() async {
    Directory directory = Directory(path.dirname(pathToAudio!));
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    recorderSubscription = _recordingSession.onProgress!.listen((e) {
      var date = DateTime.fromMillisecondsSinceEpoch(
        e.duration.inMilliseconds,
        isUtc: true,
      );
      var timeText =
          DateFormat(RecorderConstants.dateTime, RecorderConstants.ng)
              .format(date);

      setState(() {
        _timerText = timeText.substring(0, 8);
        currentAmplitude = e.decibels!;
      });
    });
    await _recordingSession.startRecorder(
      toFile: pathToAudio,
      codec: Codec.pcm16WAV,
    );
  }

  Future<void> deleteAudio() async {
    try {
      if (pathToAudio != null) {
        final file = File(pathToAudio!);
        if (await file.exists()) {
          await file.delete();
          setState(() {
            _timerText = initialTime;
            _showVisualizer = false;
          });
          _showDeleteSuccessDialog();
        } else {
          _showDeleteErrorDialog(RecorderConstants.audioFileNotFound);
        }
      } else {
        _showDeleteErrorDialog(RecorderConstants.noAudioYet);
      }
    } catch (e) {
      _showDeleteErrorDialog('Error deleting audio: $e');
    }
  }

  Future<void> _showDialog({
    required String title,
    required String content,
    required bool isError,
    String? buttonText,
    String? errorMessage,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: isError ? Text(errorMessage ?? content) : Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (isError) {
                  setState(() {
                    _timerText = initialTime;
                    _showVisualizer = false;
                    _playAudio = false;
                  });
                }
              },
              child: Text(buttonText ?? RecorderConstants.ok),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteSuccessDialog() async {
    await _showDialog(
      title: RecorderConstants.successTitle,
      content: RecorderConstants.recordDeletedSuccess,
      isError: false,
    );
  }

  Future<void> _showDeleteErrorDialog(String message) async {
    await _showDialog(
      title: RecorderConstants.errorTitle,
      content: RecorderConstants.errorDesc,
      isError: true,
      errorMessage: message,
    );
  }

  void _showSaveErrorDialog(String message) {
    _showDialog(
      title: RecorderConstants.errorTitle,
      content: RecorderConstants.errorDesc,
      isError: true,
      errorMessage: message,
    );
  }

  void saveAudio() async {
    try {
      if (pathToAudio != null) {
        final file = File(pathToAudio!);
        if (await file.exists()) {
          final appDocDirectory = await getApplicationDocumentsDirectory();
          final recordingsDir = Directory('${appDocDirectory.path}/recordings');
          if (!(await recordingsDir.exists())) {
            await recordingsDir.create(recursive: true);
          }
          final timeStamp = DateTime.now().millisecondsSinceEpoch;
          final newFileName = 'recording_$timeStamp.wav';
          final newFilePath = '${recordingsDir.path}/$newFileName';
          await file.copy(newFilePath);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecordingList(recordings: [newFilePath]),
            ),
          );
        } else {
          _showSaveErrorDialog('Audio file not found.');
        }
      } else {
        _showSaveErrorDialog('No audio recorded yet.');
      }
    } catch (e) {
      print('Error saving audio: $e');
      _showSaveErrorDialog('Error saving audio: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    initializer();
    amplitudeStream = _recordAmplitude();
  }

  Stream<double> _recordAmplitude() async* {
    while (true) {
      await Future.delayed(const Duration(
          milliseconds: RecorderConstants.amplitudeCaptureRateInMilliSeconds));
      final simulatedAmplitude = Random().nextDouble() * 100;
      setState(() {
        currentAmplitude = simulatedAmplitude;
      });
      yield simulatedAmplitude;
    }
  }

  void initializer() async {
    Directory? appDocDirectory = await getExternalStorageDirectory();
    pathToAudio = path.join(appDocDirectory!.path, 'temp.wav');
    _recordingSession = FlutterSoundRecorder();
    await _recordingSession.openAudioSession(
        focus: AudioFocus.requestFocusAndStopOthers,
        category: SessionCategory.playAndRecord,
        mode: SessionMode.modeDefault,
        device: AudioDevice.speaker);
    await _recordingSession
        .setSubscriptionDuration(const Duration(milliseconds: 10));
    await initializeDateFormatting();
    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }

  bool _isRecording = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: SizeConstants.double70,
            ),
            Container(
              child: Text(
                'Voice Recorder',
                style: Styles.appTextStyle1,
              ),
            ),
            const SizedBox(
              height: SizeConstants.double40,
            ),
            Container(
              child: Center(
                child: Text(
                  _timerText,
                  style: Styles.appTextStyle2,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: SizeConstants.double60,
                right: SizeConstants.double20,
                top: SizeConstants.double80,
              ),
              child: _showVisualizer
                  ? StreamBuilder<double>(
                      stream: amplitudeStream,
                      initialData: RecorderConstants.decibleLimit,
                      builder: (context, snapshot) {
                        return AudioVisualizer(amplitude: snapshot.data);
                      },
                    )
                  : const SizedBox(),
            ),
            const SizedBox(
              height: SizeConstants.double20,
            ),
          ],
        ),
      ),
      bottomSheet: bottomSheetWidget(context),
    );
  }

  Container bottomSheetWidget(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 100,
        decoration: const BoxDecoration(color: AppColors.recordBlack),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ReusableCircleButton(
              iconWidget: const Icon(
                Icons.delete,
                color: AppColors.recorderWhite,
                size: SizeConstants.double15,
              ),
              onTap: deleteAudio,
            ),
            ReusableCircleButton(
              iconWidget: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                color: _isRecording
                    ? AppColors.recorderWhite
                    : AppColors.recordRed,
                size: SizeConstants.double24,
              ),
              onTap: () {
                if (_isRecording) {
                  AudioService().stopRecording();
                  setState(() {
                    _isRecording = false;
                    _showVisualizer = false;
                  });
                } else {
                  startRecording();
                  setState(() {
                    _isRecording = true;
                    _showVisualizer = true;
                  });
                }
              },
            ),
            ReusableCircleButton(
              onTap: () {
                saveAudio();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RecordingList(
                            recordings: [],
                          )),
                );
              },
              iconWidget: const Icon(
                Icons.save,
                color: AppColors.recorderWhite,
                size: SizeConstants.double15,
              ),
            )
          ],
        ));
  }
}
