import 'package:flutter/material.dart';
import 'package:logize/features/feature_switch.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/pools/models/model_edit_pool.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/pools/topbar_pool.dart';
import 'package:logize/utils/nav.dart';
import 'package:logize/widgets/design/exp.dart';
import 'package:logize/widgets/design/none.dart';
import 'package:logize/widgets/design/txt.dart';

class ModelTitle extends StatelessWidget {
  const ModelTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LazySwimmer<Model>(
          pool: modelEditPool,
          listenedEvents: ['name'],
          builder: (context, model) => Txt(model.name),
        ),
        Exp(),
        LazySwimmer<Model>(
          pool: modelEditPool,
          listenedEvents: ['dirty'],
          builder: (context, model) => modelEditPool.dirty
              ? IconButton(
                  onPressed: () {
                    modelEditPool.save();
                  },
                  icon: Icon(Icons.check_circle_outlined),
                )
              : None(),
        ),
      ],
    );
  }
}

openFts(BuildContext context) {
  topbarPool.pushTitle(Text('features'));
  showModalBottomSheet(
    isDismissible: false,
    enableDrag: false,
    context: context,
    builder: (context) => SizedBox(
      height: availableFtTypes.length * 50 + 100,
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
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      onPressed: () => navPop(context: context),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              ...availableFtTypes.map(
                (ftType) => ListTile(
                  title: featureSwitch(parseType: 'label', ftType: ftType),
                  leading: Icon(
                    (featureSwitch(parseType: 'icon', ftType: ftType)),
                  ),
                  onTap: () {
                    modelEditPool.setFeature(
                      featureSwitch(parseType: 'class', ftType: ftType),
                    );
                    navPop(context: context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
