import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:logbloc/config/locales.dart';
import 'package:logbloc/pools/items/items_by_day_pool.dart';
import 'package:logbloc/pools/models/models_pool.dart';
import 'package:logbloc/pools/pools.dart';
import 'package:logbloc/pools/tags/tags_pool.dart';
import 'package:logbloc/screens/models/model_screen/model_screen.dart';
import 'package:logbloc/utils/fmt_date.dart';
import 'package:logbloc/utils/nav.dart';
import 'package:logbloc/widgets/design/act_button.dart';
import 'package:logbloc/widgets/design/button.dart';
import 'package:logbloc/widgets/design/pretty_date.dart';
import 'package:logbloc/widgets/design/topbar_wrap.dart';
import 'package:logbloc/widgets/design/txt.dart';
import 'package:logbloc/widgets/item_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

final int initPage = 999999999;
DateTime initDate = DateTime.now();
final currentDatePool = Pool<DateTime>(initDate);

UniqueKey agendaKey = UniqueKey();

final agendaFilterPool = Pool<MapEntry<String, String?>>(
  MapEntry('all', null),
);

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
          return Stack(
            children: [
              Swimmer<MapEntry<String, String?>>(
                pool: agendaFilterPool,
                builder: (context, filter) => Column(
                  children: [
                    Padding(
                      padding: EdgeInsetsGeometry.only(bottom: 7),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: ['by tag', 'pending', 'all']
                                .map<Widget>(
                                  (opt) => Button(
                                    opt,
                                    variant: 0,
                                    filled: filter.key == opt,
                                    onPressed: () => agendaFilterPool.set(
                                      (f) => MapEntry(opt, f.value),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),

                          if (filter.key == 'by tag')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: tagsPool.data!
                                  .map(
                                    (tag) => Button(
                                      '#$tag',
                                      variant: 1,
                                      filled: filter.value == tag,
                                      onPressed: () =>
                                          agendaFilterPool.set(
                                            (f) => MapEntry(f.key, tag),
                                          ),
                                    ),
                                  )
                                  .toList(),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
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

                              if (items == null) {
                                itemsByDayPool.retrieve(dateKey);
                                Future.delayed(
                                  Duration(milliseconds: 100),
                                  () => dayReloadPool.emit(),
                                );
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (items.isEmpty) {
                                return Center(child: Text('no items'));
                              }

                              items.sort(
                                (a, b) => a.schedule.place.compareTo(
                                  b.schedule.place,
                                ),
                              );

                              final filteredItems = items.where((item) {
                                switch (agendaFilterPool.data.key) {
                                  case 'all':
                                    return true;
                                  case 'pending':
                                    return item.record == null;
                                  case 'by tag':
                                    return agendaFilterPool.data.value ==
                                            null ||
                                        item.model!.tags?.contains(
                                              agendaFilterPool.data.value,
                                            ) ==
                                            true;
                                  default:
                                    return false;
                                }
                              });

                              Widget printItem(item) => Row(
                                key: Key(item.id),
                                children: [
                                  ItemBox(key: UniqueKey(), item: item),
                                ],
                              );

                              return Padding(
                                padding: EdgeInsetsGeometry.symmetric(
                                  horizontal: 7,
                                ),
                                child: agendaFilterPool.data.key == 'all'
                                    ? ReorderableListView(
                                        onReorder:
                                            (oldIndex, newIndex) async {
                                              final itemToReorder =
                                                  items[oldIndex];
                                              await itemsByDayPool
                                                  .reorderItem(
                                                    strDay: dateKey,
                                                    item: itemToReorder,
                                                    index: newIndex,
                                                  );
                                            },
                                        children: items
                                            .map<Widget>(printItem)
                                            .toList(),
                                      )
                                    : ListView(
                                        children: filteredItems
                                            .map<Widget>(printItem)
                                            .toList(),
                                      ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
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
