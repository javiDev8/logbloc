import 'package:flutter/widgets.dart';
import 'package:logbloc/screens/welcome/welcome_screen.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class QuickStart extends StatelessWidget {
  const QuickStart({super.key});

  @override
  Widget build(BuildContext context) {
    final ytController = YoutubePlayerController(
      initialVideoId: guideVideoId!,
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: YoutubePlayer(controller: ytController)),
        Padding(
          padding: EdgeInsetsGeometry.all(20),
          child: Text(
            'Dont miss this really quick guide',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
          ),
        ),
      ],
    );
  }
}
