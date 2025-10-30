import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:logbloc/pools/theme_mode_pool.dart';
import 'package:logbloc/utils/color_convert.dart';
import 'package:url_launcher/url_launcher.dart';

class HttpLink extends StatelessWidget {
  final String name;
  final String url;
  const HttpLink({super.key, required this.name, required this.url});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(5),
      child: RichText(
        text: TextSpan(
          text: name,
          style: TextStyle(
            color: enbrightColor(detaTheme.colorScheme.tertiary),
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.w700,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              final Uri u = Uri.parse(url);
              if (await canLaunchUrl(u)) {
                await launchUrl(u);
              } else {
                throw 'Could not launch $url';
              }
            },
        ),
      ),
    );
  }
}
