import 'package:flutter/material.dart';
import 'package:logbloc/apis/membership.dart';
import 'package:logbloc/utils/feedback.dart';
import 'package:logbloc/widgets/design/button.dart';
import 'package:logbloc/widgets/design/txt.dart';

class BuyAppScreen extends StatelessWidget {
  const BuyAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoading = false;
    return StatefulBuilder(
      builder: (context, setState) => Row(
        children: [
          if (membershipApi.currentPlan == 'free') ...[
            Button(
              'buy the app',
              disabled: isLoading,
              onPressed: () async {
                setState(() => isLoading = true);
                try {
                  await membershipApi.upgrade();
                  setState(() => isLoading = false);
                } catch (e) {
                  feedback('Purchase failed: $e');
                }
              },
            ),
            if (isLoading) ...[
              Txt('loading purchase'),
              CircularProgressIndicator(),
            ],
          ] else if (membershipApi.currentPlan == 'base')
            Txt('you own this app for lifetime!'),
        ],
      ),
    );
  }
}
