import 'package:flutter/material.dart';
import 'package:logbloc/widgets/design/http_link.dart';
import 'package:logbloc/widgets/design/txt.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HttpLink(name: 'guides', url: 'https://logbloc.app/guides'),
        HttpLink(name: 'contact', url: 'https://logbloc.app/contact'),
        HttpLink(
          name: 'privacy policy',
          url: 'https://logbloc.app/policy',
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Txt('version 1.0.2')],
        ),
      ],
    );
  }
}
