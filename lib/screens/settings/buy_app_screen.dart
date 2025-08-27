import 'package:flutter/material.dart';
import 'package:logize/apis/membership.dart';
import 'package:logize/widgets/design/button.dart';
import 'package:logize/widgets/design/txt.dart';

class BuyAppScreen extends StatelessWidget {
  const BuyAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) => Row(
        children: [
          if (membershipApi.currentPlan == 'free')
            Button(
              'buy the app',
              onPressed: () async {
                await membershipApi.purchase();
                setState(() {});
              },
            )
          else if (membershipApi.currentPlan == 'base')
            Txt('you own this app for lifetime!'),
        ],
      ),
    );
  }
}
