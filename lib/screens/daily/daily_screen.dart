import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:logize/config/locales.dart';
import 'package:logize/pools/items/items_by_day_pool.dart';
import 'package:logize/pools/models/models_pool.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/screens/models/model_screen/model_screen.dart';
import 'package:logize/utils/fmt_date.dart';
import 'package:logize/utils/nav.dart';
import 'package:logize/utils/noticable_print.dart';
import 'package:logize/widgets/design/act_button.dart';
import 'package:logize/widgets/design/pretty_date.dart';
import 'package:logize/widgets/design/topbar_wrap.dart';
import 'package:logize/widgets/design/txt.dart';
import 'package:logize/widgets/item_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

final int initPage = 999999999;
DateTime initDate = DateTime.now();
final currentDatePool = Pool<DateTime>(initDate);

UniqueKey agendaKey = UniqueKey();

class DailyScreen extends StatelessWidget {
  DailyScreen({super.key});
  final pageController = PageController(initialPage: initPage);

  @override
  Widget build(BuildContext context) {
    timeDilation = 0.5;
    return Scaffold(
      appBar: wrapBar(
        backable: false,
        children: [
          Expanded(
            child: Swimmer<DateTime>(
              pool: currentDatePool,
              builder: (context, date) => PrettyDate(date: date),
            ),
          ),
        ],
      ),
      body: LazySwimmer(
        pool: itemsByDayPool,
        listenedEvents: ['clean-up'],
        builder: (context, allItems) {
          nPrint('on clean up');
          return Stack(
            children: [
              PageView.builder(
                key: agendaKey,
                controller: pageController,
                onPageChanged: (currentPageIndex) {
                  currentDatePool.set(
                    (_) => initDate.add(
                      Duration(days: currentPageIndex - initPage),
                    ),
                  );
                },
                itemBuilder: (context, pageIndex) {
                  final DateTime date = initDate.add(
                    Duration(days: pageIndex - initPage),
                  );
                  final dateKey = strDate(date);
                  final dayReloadPool = Pool<bool>(true);

                  return Swimmer(
                    key: UniqueKey(),
                    pool: dayReloadPool,
                    builder: (context, e) {
                      final items = itemsByDayPool.data[dateKey];

                      nPrint(
                        'ITEMS ON DAILY: ${items?.map((i) => '\n id: ${i.id}, place: ${i.schedule.place}')}',
                      );

                      if (items == null) {
                        itemsByDayPool.retrieve(dateKey);
                        Future.delayed(
                          Duration(milliseconds: 100),
                          () => dayReloadPool.emit(),
                        );
                        return Center(child: CircularProgressIndicator());
                      }
                      if (items.isEmpty) {
                        return Center(child: Text('no items'));
                      }

                      items.sort(
                        (a, b) =>
                            a.schedule.place.compareTo(b.schedule.place),
                      );

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 7),
                        child: ReorderableListView(
                          onReorder: (oldIndex, newIndex) async {
                            final itemToReorder = items[oldIndex];
                            await itemsByDayPool.reorderItem(
                              strDay: dateKey,
                              item: itemToReorder,
                              index: newIndex,
                            );
                          },
                          children: items
                              .map<Widget>(
                                (item) => Row(
                                  key: Key(item.id),
                                  children: [
                                    ItemBox(key: UniqueKey(), item: item),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      );
                    },
                  );
                },
              ),
              ActButton(
                onPressed: () {
                  showModalBottomSheet(
                    isDismissible: false,
                    showDragHandle: true,
                    context: context,
                    builder: (context) => SizedBox(
                      height: modelsPool.data!.length * 50 + 100,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Center(
                          child: ListView(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Txt(
                                      'Pick a ${Tr.model.getString(context)}',
                                      w: 7,
                                      s: 16,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => navLink(
                                      rootIndex: 0,
                                      screen: ModelScreen(),
                                    ),
                                    icon: Icon(Icons.add),
                                  ),
                                ],
                              ),

                              ...modelsPool.data!.values.map<Widget>(
                                (model) => ListTile(
                                  title: Text(model.name),
                                  onTap: () {
                                    itemsByDayPool.scheduleModel(
                                      model,
                                      currentDatePool.data,
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
                icon: Icon(MdiIcons.cardPlusOutline, size: 30),
              ),
            ],
          );
        },
      ),
    );
  }
}
