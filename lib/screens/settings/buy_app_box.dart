import 'package:flutter/material.dart';
import 'package:logbloc/apis/membership.dart';
import 'package:logbloc/screens/models/model_screen/schedules_view/schedule_widget.dart';
import 'package:logbloc/utils/feedback.dart';
import 'package:logbloc/widgets/design/button.dart';
import 'package:logbloc/widgets/design/none.dart';
import 'package:logbloc/widgets/design/txt.dart';

class BuyAppBox extends StatelessWidget {
  final Function reload;

  const BuyAppBox({super.key, required this.reload});

  @override
  Widget build(BuildContext context) {
    String? loading;
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
                Txt('You are currently limited to 3 logbooks', s: 16, w: 6),
                Txt(
                  'Unlock unlimited logbooks forever with a single low-cost purchase.',
                  s: 22,
                  w: 8,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],

              Row(
                children: [
                  if (membershipApi.currentPlan == 'free') ...[
                    Button(
                      'purchase',
                      disabled: loading != null,
                      onPressed: () async {
                        setState(() => loading = 'purchasing ');
                        try {
                          if (!(await membershipApi.theresInternet())) {
                            return setState(() => loading = null);
                          }

                          await membershipApi.upgrade();
                        } catch (e) {
                          feedback(
                            'Purchase cancelled',
                            type: FeedbackType.error,
                          );
                        }
                        setState(() => loading = null);
                      },
                    ),

                    Button(
                      'restore purchase',
                      filled: false,
                      disabled: loading != null,
                      onPressed: () async {
                        setState(() => loading = 'restoring purchase');
                        if (!(await membershipApi.theresInternet())) {
                          return setState(() => loading = null);
                        }
                        await membershipApi.restorePurchase();
                        setState(() => loading = null);
                      },
                    ),
                  ] else if (membershipApi.currentPlan == 'base')
                    Txt('you own this app for lifetime!'),
                ],
              ),

              if (loading != null)
                Padding(
                  padding: EdgeInsetsGeometry.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('$loading'),
                      Padding(
                        padding: EdgeInsetsGeometry.all(10),
                        child: CircularProgressIndicator(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
