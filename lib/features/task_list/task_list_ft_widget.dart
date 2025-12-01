import 'package:logbloc/features/feature_widget.dart';
import 'package:logbloc/features/task_list/task_list_ft_class.dart';
import 'package:logbloc/pools/pools.dart';
import 'package:logbloc/widgets/design/exp.dart';
import 'package:logbloc/widgets/design/menu_button.dart';
import 'package:logbloc/widgets/design/txt.dart';
import 'package:logbloc/widgets/design/txt_field.dart';
import 'package:flutter/material.dart';

class TaskListFtWidget extends StatelessWidget {
  final FeatureLock lock;
  final TaskListFt ft;
  final bool detailed;
  final void Function()? dirt;

  const TaskListFtWidget({
    super.key,
    required this.lock,
    required this.ft,
    required this.detailed,
    this.dirt,
  });

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (ctx, setState) {
        updateList({required String action, required payload}) {
          dirt!();
          setState(() {
            switch (action) {
              case 'add':
                ft.addTask(parentId: payload);
                break;

              case 'update':
                ft.updateTask(payload);
                break;

              case 'check':
                ft.checkTask(payload);
                break;

              case 'delete':
                ft.deleteTask(payload);
                break;
            }
          });
        }

        return InheritedTaskList(
          detailed: detailed,
          ftLock: lock,
          tasks: ft.tasks,
          updateList: updateList,
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (lock.model && !lock.record && ft.tasks.isEmpty)
                      Checkbox(
                        value: ft.done,
                        onChanged: (val) {
                          dirt!();
                          setState(() {
                            ft.done = val ?? false;
                          });
                        },
                      ),
                    if (lock.model && !lock.record) Txt(ft.title, w: 8),

                    if (!lock.model)
                      Expanded(
                        child: TxtField(
                          round: true,
                          label: 'list title',
                          initialValue: ft.title,
                          validator: (str) =>
                              str?.isNotEmpty != true ? 'empty!' : null,
                          onChanged: (str) {
                            ft.setTitle(str);
                            dirt!();
                          },
                        ),
                      ),
                    if (ft.tasks.isNotEmpty)
                      Txt(
                        '(${lock.model ? '${ft.getRoots(done: true).length} / ' : ''}'
                        '${ft.getRoots().length})',
                        w: 8,
                      ),

                    if (lock.model && !lock.record) Exp(),

                    if (!lock.model || !lock.record)
                      IconButton(
                        onPressed: () {
                          final newRootTask = Task.empty(isRoot: true);
                          ft.tasks[newRootTask.id] = newRootTask;
                          setState(() => {});
                        },
                        icon: Icon(Icons.add),
                      ),
                  ],
                ),
                ...ft.tasks.values
                    .where((task) => task.isRoot)
                    .map((t) => TaskWidget(task: t)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TaskWidget extends StatelessWidget {
  final Task task;
  const TaskWidget({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final inherited = InheritedTaskList.of(context);
    final tasks = inherited.tasks;
    final updateList = inherited.updateList;
    final ftLock = inherited.ftLock;
    final detailed = inherited.detailed;

    final childrenTasks = task.childrenIds
        .map<Task>((id) => tasks.values.firstWhere((t) => t.id == id))
        .toList();

    final renameTogglePool = Pool<bool>(task.title.isEmpty);

    return Column(
      children: [
        Swimmer<bool>(
          pool: renameTogglePool,
          builder: (context, renaming) => SizedBox(
            height: renaming || !ftLock.model ? null : 45,
            child: Row(
              children: [
                Checkbox(
                  value: task.done,
                  onChanged:
                      (!ftLock.model || (ftLock.model && ftLock.record))
                      ? null
                      : (val) {
                          task.done = val ?? false;
                          updateList(action: 'check', payload: task);
                        },
                ),
                Expanded(
                  child: ftLock.model && !renaming && task.title != ''
                      ? Txt(task.title, w: 6)
                      : TxtField(
                          validator: (str) =>
                              str!.isEmpty ? 'empty!' : null,
                          label: 'task name',
                          onTapOutside: (_) {
                            updateList(action: 'update', payload: task);
                          },
                          onChanged: (text) {
                            task.title = text;
                          },
                          initialValue: task.title,
                        ),
                ),

                if (task.childrenIds.isNotEmpty)
                  Text(
                    '(${ftLock.model && !detailed ? '${task.doneSubTasks}/' : ''}${task.childrenIds.length})',
                  ),

                if (ftLock.model != ftLock.record)
                  MenuButton(
                    onSelected: (value) {
                      switch (value) {
                        case 'add':
                          updateList(action: 'add', payload: task.id);
                          if (ftLock.model) {
                            renameTogglePool.set((_) => true);
                          }
                          break;
                        case 'delete':
                          updateList(action: 'delete', payload: task);
                          break;
                        case 'edit':
                          renameTogglePool.set((_) => true);
                          break;
                        default:
                          break;
                      }
                    },
                    options: [
                      MenuOption(
                        value: 'add',
                        widget: ListTile(
                          title: Text('add subtask'),
                          leading: Icon(Icons.add),
                        ),
                      ),

                      if (ftLock.model)
                        MenuOption(
                          value: 'edit',
                          widget: ListTile(
                            title: Text('rename'),
                            leading: Icon(Icons.edit),
                          ),
                        ),
                      MenuOption(
                        value: 'delete',
                        widget: ListTile(
                          title: Text('remove'),
                          leading: Icon(Icons.close),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 30),
          child: Column(
            children: childrenTasks
                .map((t) => TaskWidget(task: t, key: Key(t.id)))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class InheritedTaskList extends InheritedWidget {
  final Map<String, Task> tasks;
  final void Function({required String action, required dynamic payload})
  updateList;
  final FeatureLock ftLock;
  final bool detailed;

  const InheritedTaskList({
    super.key,
    required super.child,
    required this.tasks,
    required this.updateList,
    required this.ftLock,
    required this.detailed,
  }) : super();

  static InheritedTaskList of(BuildContext context) {
    final InheritedTaskList? result = context
        .dependOnInheritedWidgetOfExactType<InheritedTaskList>();
    assert(
      result != null,
      'No TaskListFtInheritedWidget found in context',
    );
    return result!;
  }

  @override
  bool updateShouldNotify(InheritedTaskList oldWidget) {
    return tasks != oldWidget.tasks;
  }
}
