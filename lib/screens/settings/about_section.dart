import 'package:flutter/material.dart';
import 'package:logbloc/widgets/design/http_link.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsetsGeometry.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              HttpLink(
                name: 'quick guide',
                url: 'https://logbloc.sweetfeatures.dev/quick-guide',
              ),
              HttpLink(
                name: 'user manual',
                url: 'https://logbloc.sweetfeatures.dev/user-manual',
              ),
              HttpLink(
                name: 'privacy policy',
                url: 'https://logbloc.sweetfeatures.dev/privacy-policy',
              ),
            ],
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('version 1.0.0')],
        ),
      ],
    );
  }
}
