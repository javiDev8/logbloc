import 'package:flutter/material.dart';
import 'package:logbloc/apis/membership.dart';
import 'package:logbloc/main.dart';
import 'package:logbloc/pools/theme_mode_pool.dart';
import 'package:logbloc/screens/welcome/welcome_page.dart';
import 'package:logbloc/widgets/design/button.dart';
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
                Image.asset('assets/images/welcome.png'),
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
                        Txt(
                          'Explore Logbloc with 3 free logbooks. If you like it,'
                          ' get unlimited logbooks with a small one-time purchase.',
                          s: 20,
                          w: 8,
                        ),
                        Image.asset('assets/images/freelogbooks.png'),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Button(
                          'start free trial',
                          onPressed: finish,
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
