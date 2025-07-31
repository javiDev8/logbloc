import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/pools/theme_mode_pool.dart';
import 'package:logize/pools/topbar_pool.dart';
import 'package:logize/utils/color_convert.dart';
import 'package:logize/utils/nav.dart';
import 'package:logize/widgets/design/button.dart';
import 'package:logize/widgets/design/exp.dart';
import 'package:flutter/material.dart';

class SetColorButton extends StatelessWidget {
  const SetColorButton({super.key});

  @override
  Widget build(BuildContext context) {
    return LazySwimmer(
      pool: modelEditPool,
      listenedEvents: ['color'],
      builder:
          (c, _) => Button(
            overwrittenColor: modelEditPool.data.color ?? Colors.grey,
            null,
            onPressed: () {
              topbarPool.pushTitle(Text('colors'));
              showModalBottomSheet(
                enableDrag: false,
                isDismissible: false,
                context: context,
                builder:
                    (context) => SizedBox(
                      height: 240,
                      child: Padding(
                        padding: EdgeInsets.only(top: 15, bottom: 15),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Pick a color',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Exp(),
                                  IconButton(
                                    onPressed: () => navPop(),
                                    icon: Icon(Icons.close),
                                  ),
                                ],
                              ),
                            ),
                            ...[0, 1, 2].map<Widget>(
                              (k) => Row(
                                children:
                                    List.generate(
                                      8,
                                      (i) => (130 / 8).round() * (i + 1),
                                    ).map<Widget>((j) {
                                      List<int> ca = [0, 0, 0];
                                      final prev = k == 0 ? 2 : k - 1;
                                      final next = k == 2 ? 0 : k + 1;
                                      ca[k] = 130;
                                      ca[prev] = j > 3 ? 50 : j;
                                      ca[next] = j > 3 ? j : 50;

                                      final c = Color.fromRGBO(
                                        ca[0],
                                        ca[1],
                                        ca[2],
                                        1,
                                      );
                                      final color =
                                          themeModePool.data ==
                                                  ThemeMode.dark
                                              ? c
                                              : enbrightColor(c);
                                      return IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(),
                                        color: color,
                                        onPressed: () {
                                          modelEditPool.setColor(color);
                                          navPop();
                                        },
                                        icon: Icon(Icons.circle),
                                      );
                                    }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              );
            },
            lead: (Icons.palette),
          ),
    );
  }
}
