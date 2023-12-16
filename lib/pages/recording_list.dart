import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recorder/core/colors.dart';
import 'package:flutter_recorder/core/styles.dart';
import 'package:flutter_recorder/pages/recording_screen.dart';

class RecordingList extends StatefulWidget {
  final List<String> recordings;

  const RecordingList({Key? key, required this.recordings}) : super(key: key);

  @override
  State<RecordingList> createState() => _RecordingListState();
}

class _RecordingListState extends State<RecordingList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.recordBlack,
      bottomSheet: Container(
        width: MediaQuery.of(context).size.width,
        height: 150,
        color: AppColors.recordBlack,
        child: SizedBox(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const RecordingScreen()),
              );
            },
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.recordRed,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(width: 4, color: AppColors.recorderWhite),
                ),
                child: Center(
                    child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                )),
              ),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        leading:
            const Icon(Icons.arrow_back_ios, color: AppColors.recorderWhite),
        title: Text(
          'All Recordings',
          style: Styles.appTextStyle3,
        ),
      ),
      body: ListView.builder(
        itemCount: widget.recordings.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Recording ${index + 1}', style: Styles.appTextStyle3),
            leading: const Icon(
              Icons.mic,
              color: AppColors.recordGrey,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.play_arrow,
                      color: AppColors.recorderWhite),
                  onPressed: () {
                    playRecord(widget.recordings[index]);
                  },
                ),
                IconButton(
                  icon:
                      const Icon(Icons.delete, color: AppColors.recorderWhite),
                  onPressed: () {
                    deleteRecord(index);
                  },
                ),
              ],
            ),
            onTap: () {},
          );
        },
      ),
    );
  }

  void playRecord(String filePath) {
    final assetsAudioPlayer = AssetsAudioPlayer();
    assetsAudioPlayer.open(
      Audio.file(filePath),
      showNotification: true,
      autoStart: true,
    );
  }

  void deleteRecord(int index) {
    setState(() {
      widget.recordings.removeAt(index);
    });
  }
}
