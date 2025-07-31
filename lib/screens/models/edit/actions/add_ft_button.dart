import 'package:logize/features/feature_switch.dart';
import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/pools/topbar_pool.dart';
import 'package:logize/utils/nav.dart';
import 'package:logize/widgets/design/button.dart';
import 'package:flutter/material.dart';

class AddFtButton extends StatelessWidget {
  const AddFtButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Button(
      null,
      //'add feature',
      lead: Icons.add,
      onPressed: () {
        topbarPool.pushTitle(Text('features'));

        showModalBottomSheet(
          isDismissible: false,
          enableDrag: false,
          context: context,
          builder:
              (context) => SizedBox(
                height: MediaQuery.sizeOf(context).height / 2,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Center(
                    child: ListView(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Select a feature',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => navPop(),
                                icon: Icon(Icons.close),
                              ),
                            ],
                          ),
                        ),

                        ...availableFtTypes.map(
                          (ftType) => ListTile(
                            title: featureSwitch(
                              parseType: 'label',
                              ftType: ftType,
                            ),
                            leading: Icon(
                              (featureSwitch(
                                parseType: 'icon',
                                ftType: ftType,
                              )),
                            ),
                            onTap: () {
                              modelEditPool.setFeature(
                                featureSwitch(
                                  parseType: 'class',
                                  ftType: ftType,
                                ),
                              );
                              navPop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        );
      },
    );
  }
}
