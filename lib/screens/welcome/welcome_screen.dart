import 'package:flutter/material.dart';
import 'package:logbloc/apis/membership.dart';
import 'package:logbloc/assets/asset_url_holder.dart';
import 'package:logbloc/main.dart';
import 'package:logbloc/pools/theme_mode_pool.dart';
import 'package:logbloc/screens/welcome/welcome_page.dart';
import 'package:logbloc/widgets/design/button.dart';
import 'package:logbloc/widgets/design/txt.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  late PageController controller;

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  finish() async {
    await sharedPrefs.setBool('welcomed', true);
    membershipApi.welcomed = true;
    themeModePool.emit();
  }

  @override
  Widget build(BuildContext context) {
    final ytController = YoutubePlayerController(
      initialVideoId: assetHolder.data['guide-video'],
    );

    return Scaffold(
      backgroundColor: detaTheme.colorScheme.tertiary,
      body: PageView(
        controller: controller,
        children: [
          WelcomePage(
            title: "Welcome to Logbloc",
            withNextBtn: true,
            index: 0,
            controller: controller,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(assetHolder.data['welcome-img']),
                Padding(
                  padding: EdgeInsetsGeometry.all(20),
                  child: Text(
                    'A simple yet scalable system to design and track routines',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          WelcomePage(
            title: 'Quick Start',
            withNextBtn: true,
            index: 1,
            controller: controller,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: YoutubePlayer(controller: ytController)),
                Padding(
                  padding: EdgeInsetsGeometry.all(20),
                  child: Text(
                    'Dont miss this really quick guide',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          WelcomePage(
            title: 'Ready?',
            withNextBtn: false,
            index: 2,
            controller: controller,
            child: Center(
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Txt(
                          '${assetHolder.data['free-txt']}',
                          s: 20,
                          w: 8,
                        ),
                        Image.network('${assetHolder.data['free-img']}'),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Button(
                          'start free trial',
                          filled: false,
                          onPressed: finish,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Button(
                          'buy app',
                          onPressed: () async {
                            await membershipApi.upgrade();
                            await finish();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
