import 'package:logize/pools/items/items_by_day_pool.dart';
import 'package:logize/pools/models/models_pool.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/pools/topbar_pool.dart';
import 'package:logize/screens/models/edit/model_edit_screen.dart';
import 'package:logize/utils/fmt_date.dart';
import 'package:logize/utils/nav.dart';
import 'package:logize/widgets/design/act_button.dart';
import 'package:logize/widgets/design/button.dart';
import 'package:logize/widgets/design/exp.dart';
import 'package:logize/widgets/design/pretty_date.dart';
import 'package:logize/widgets/design/txt.dart';
import 'package:logize/widgets/item_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:logize/widgets/model_edit_title.dart';

final int initPage = 999999999;
DateTime initDate = DateTime.now();
DateTime currentDate = initDate;

class DailyScreen extends StatelessWidget {
  DailyScreen({super.key});
  final pageController = PageController(initialPage: initPage);

  @override
  Widget build(BuildContext context) {
    timeDilation = 0.5;
    return LazySwimmer(
      pool: itemsByDayPool,
      listenedEvents: ['clean-up'],
      builder: (context, allItems) {
        return Stack(
          children: [
            PageView.builder(
              controller: pageController,
              onPageChanged: (currentPageIndex) {
                currentDate = initDate.add(
                  Duration(days: currentPageIndex - initPage),
                );
                topbarPool.setCurrentTitle(PrettyDate(date: currentDate));
              },
              itemBuilder: (context, pageIndex) {
                final DateTime date = initDate.add(
                  Duration(days: pageIndex - initPage),
                );
                final dateKey = strDate(date);
                final dayReloadPool = Pool<bool>(true);

                return Swimmer(
                  pool: dayReloadPool,
                  builder: (context, e) {
                    final items = itemsByDayPool.data[dateKey];
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
                                  ItemBox(
                                    key: UniqueKey(),
                                    item: item,
                                    screenTitle: item.model!.name,
                                  ),
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
                topbarPool.pushTitle(Text('add item'));
                showModalBottomSheet(
                  isDismissible: false,
                  enableDrag: false,
                  context: context,
                  builder: (context) => SizedBox(
                    height: MediaQuery.of(context).size.height / 2,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Center(
                        child: modelsPool.data!.values.isEmpty
                            ? Column(
                                children: [
                                  Row(
                                    children: [
                                      Exp(),
                                      IconButton(
                                        onPressed: () => navPop(),
                                        icon: Icon(Icons.close),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Txt('no models'),
                                        Button(
                                          'make your first model!',
                                          onPressed: () => navLink(
                                            rootIndex: 0,
                                            screen: ModelEditScreen(),
                                            title: ModelEditTitle(
                                              title: 'new model',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : ListView(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Select an available model',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => navPop(),
                                        icon: Icon(Icons.close),
                                      ),
                                    ],
                                  ),

                                  ...modelsPool.data!.values.map<Widget>(
                                    (model) => ListTile(
                                      title: Text(model.name),
                                      onTap: () {
                                        itemsByDayPool.scheduleModel(
                                          model,
                                          currentDate,
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
              icon: Icon(Icons.article, size: 30),
            ),
          ],
        );
      },
    );
  }
}
