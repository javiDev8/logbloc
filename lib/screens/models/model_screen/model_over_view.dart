import 'package:flutter/material.dart';
import 'package:logize/pools/models/model_class.dart';
import 'package:logize/screens/models/model_records_screen.dart';
import 'package:logize/utils/fmt_date.dart';
import 'package:logize/utils/nav.dart';
import 'package:logize/widgets/design/button.dart';
import 'package:logize/widgets/design/exp.dart';
import 'package:logize/widgets/design/section_divider.dart';
import 'package:logize/widgets/design/txt.dart';
import 'package:logize/widgets/design/txt_field.dart';

class ModelOverView extends StatelessWidget {
  final Model model;
  const ModelOverView({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> details = {
      'name': model.name,
      'records': model.recordCount.toString(),
      'features': model.features.length.toString(),
      'schedules': model.schedules?.length.toString() ?? '0',
      'created at': hdate(model.createdAt),
    };

    final color = model.color ?? model.tags?.values.first.color;

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 7, vertical: 20),
      child: ListView(
        children: [
          Row(
            children: [
              Expanded(
                child: TxtField(
		  round: false,
                  label: 'model name',
                  initialValue: model.name,
                  enabled: false,
                ),
              ),
              IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.palette, color: color ?? Colors.grey),
              ),
            ],
          ),

          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              IconButton(onPressed: () {}, icon: Icon(Icons.add)),
              if (model.tags?.isNotEmpty == true)
                ...model.tags!.values.map<Widget>((t) => Txt(t.name))
              else
                Txt('add tags'),
            ],
          ),

          Row(
            children: [
              Exp(),
              Button(
                'records (${model.recordCount})',
                lead: Icons.forward,
                onPressed: () => navPush(
                  context: context,
                  screen: ModelRecordsScreen(model: model),
                  title: Text('${model.name} records'),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsetsGeometry.all(10),
            child: Column(
              children: [
                SectionDivider(string: 'Details'),
                ...details.entries.map(
                  (de) => Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
                    child: Row(
                      children: [Txt(de.key, w: 8), Exp(), Txt(de.value)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
