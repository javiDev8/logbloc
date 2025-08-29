import 'package:flutter/material.dart';
import 'package:logbloc/apis/membership.dart';
import 'package:logbloc/pools/theme_mode_pool.dart';
import 'package:logbloc/screens/models/model_screen/schedules_view/schedule_widget.dart';
import 'package:logbloc/utils/feedback.dart';
import 'package:logbloc/widgets/design/button.dart';
import 'package:logbloc/widgets/design/none.dart';
import 'package:logbloc/widgets/design/txt.dart';

class BuyAppBox extends StatelessWidget {
  const BuyAppBox({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoading = false;
    if (membershipApi.currentPlan == 'base') {
      return None();
    }
    return ScheduleWrap(
      child: Padding(
        padding: EdgeInsetsGeometry.all(10),
        child: StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              if (membershipApi.currentPlan == 'free') ...[
                Txt('You are currently on the free trial'),
                Txt(
                  'Buy the app and unlock unlimited logbooks!',
                  s: 19,
                  w: 8,
                  color: seedColor,
                ),
              ],

              Row(
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
            ],
          ),
        ),
      ),
    );
  }
}
