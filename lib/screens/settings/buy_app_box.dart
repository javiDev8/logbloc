import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:logbloc/apis/membership.dart';
import 'package:logbloc/screens/models/model_screen/schedules_view/schedule_widget.dart';
import 'package:logbloc/utils/feedback.dart';
import 'package:logbloc/utils/noticable_print.dart';
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
                Txt('You are currently limited to 3 logbooks'),
                Txt(
                  'Unlock unlimited logbooks with a one-time purchase'
                  '${membershipApi.productPrice == null ? '.' : ' of ${membershipApi.productPrice}'}',
                  s: 19,
                  w: 8,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],

              Row(
                children: [
                  if (membershipApi.currentPlan == 'free') ...[
                    Button(
                      'buy unlimited logbooks',
                      disabled: isLoading,
                      onPressed: () async {
                        setState(() => isLoading = true);
                        try {
                          if (!(await InternetConnection()
                              .hasInternetAccess)) {
                            setState(() => isLoading = false);
                            return feedback(
                              'you are offline, connect to internet',
                              type: FeedbackType.error,
                            );
                          }

                          if (membershipApi.productId == null) {
                            await membershipApi.getProduct();
                          }

                          await membershipApi.upgrade();
                          feedback(
                            'Successfully purchased',
                            type: FeedbackType.success,
                          );
                        } catch (e) {
                          nPrint('purchase error: $e');
                          feedback(
                            'Purchase cancelled',
                            type: FeedbackType.error,
                          );
                        }
                        setState(() => isLoading = false);
                      },
                    ),
                    if (isLoading)
                      Padding(
                        padding: EdgeInsetsGeometry.only(left: 20),
                        child: CircularProgressIndicator(),
                      ),
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
