import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:logbloc/apis/membership.dart';
import 'package:logbloc/main.dart';
import 'package:logbloc/pools/theme_mode_pool.dart';
import 'package:logbloc/screens/welcome/welcome_page.dart';
import 'package:logbloc/widgets/design/button.dart';
import 'package:logbloc/widgets/design/http_link.dart';
import 'package:logbloc/widgets/design/txt.dart';

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
    return Scaffold(
      backgroundColor: detaTheme.colorScheme.tertiary,
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(vertical: 80),
        child: PageView(
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
                  Image.asset('assets/images/welcome.png', height: 120),
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
              title: 'How it works?',
              withNextBtn: true,
              index: 1,
              controller: controller,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Txt('I Design', s: 20, w: 6, p: EdgeInsets.all(0)),
                    Txt(
                      'Create a logbook, choose its features and schedules',
                      s: 15,
                      w: 5,
                      p: EdgeInsets.all(0),
                    ),
                    Txt(
                      'II Record',
                      s: 20,
                      w: 6,
                      p: EdgeInsets.only(top: 5),
                    ),
                    Txt(
                      'Use the logbook daily entries to create records',
                      s: 15,
                      w: 5,
                      p: EdgeInsets.all(0),
                    ),
                    Txt(
                      'III Insight',
                      s: 20,
                      w: 6,
                      p: EdgeInsets.only(top: 5),
                    ),
                    Txt(
                      'Check the records in many visual representations',
                      s: 15,
                      w: 5,
                      p: EdgeInsets.all(0),
                    ),

                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          HttpLink(
                            name: 'Check the official guides',
                            url: 'https://logbloc.app/guides',
                            color: Color.fromARGB(255, 220, 220, 220),
                            size: 15,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsetsGeometry.only(bottom: 10),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children: List.generate(3, (i) => i)
                                  .map<Widget>(
                                    (_) => Icon(
                                      MdiIcons.notebookOutline,
                                      size: 80,
                                      color: Color.fromARGB(
                                        255,
                                        220,
                                        220,
                                        220,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          Txt(
                            'Start your journey with 3 free logbooks.'
                            ' You can unlock unlimited logbooks with a single,'
                            ' low-cost purchase.',
                            s: 20,
                            w: 6,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Button('Start', onPressed: finish),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
