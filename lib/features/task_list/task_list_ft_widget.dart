import 'package:logize/features/feature_widget.dart';
import 'package:logize/features/task_list/task_list_ft_class.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/widgets/design/menu_button.dart';
import 'package:logize/widgets/design/txt.dart';
import 'package:logize/widgets/design/txt_field.dart';
import 'package:flutter/material.dart';

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

    final childrenTasks =
        task.childrenIds
            .map<Task>((id) => tasks.values.firstWhere((t) => t.id == id))
            .toList();

    final renameTogglePool = Pool<bool>(false);

    return Column(
      children: [
        Row(
          children: [
            if (!task.isRoot)
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
            Swimmer<bool>(
              pool: renameTogglePool,
              builder:
                  (ctx, renaming) => Expanded(
                    child:
                        ftLock.model && !renaming && task.title != ''
                            ? Txt(task.title, w: 8)
                            : TxtField(
                              validator:
                                  (str) => str!.isEmpty ? 'empty!' : null,
                              round: task.isRoot,
                              hint:
                                  task.isRoot ? 'list title' : 'task name',
                              onTapOutside: (_) {
                                updateList(
                                  action: 'update',
                                  payload: task,
                                );
                              },
                              onChanged: (text) {
                                task.title = text;
                              },
                              initialValue: task.title,
                            ),
                  ),
            ),

            if (task.childrenIds.isNotEmpty)
              Text(
                '(${ftLock.model && !detailed ? '${task.doneSubTasks}/' : ''}${task.childrenIds.length})',
              ),

            if (task.isRoot && !ftLock.model)
              IconButton(
                onPressed:
                    () => updateList(action: 'add', payload: task.id),
                icon: Icon(Icons.add),
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
                  if (!task.isRoot)
                    MenuOption(
                      value: 'delete',
                      widget: ListTile(
                        title: Text('delete'),
                        leading: Icon(Icons.close),
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
                    value: 'add',
                    widget: ListTile(
                      title: Text(
                        task.isRoot ? 'add task' : 'add subtask',
                      ),
                      leading: Icon(Icons.add),
                    ),
                  ),
                ],
              ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: task.isRoot ? 0 : 30),
          child: Column(
            children:
                childrenTasks
                    .map((t) => TaskWidget(task: t, key: Key(t.id)))
                    .toList(),
          ),
        ),
      ],
    );
  }
}

class TaskListFtWidget extends StatelessWidget {
  final FeatureLock lock;
  final TaskListFt ft;
  final bool detailed;
  const TaskListFtWidget({
    super.key,
    required this.lock,
    required this.ft,
    required this.detailed,
  });

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (ctx, setState) {
        updateList({required String action, required payload}) {
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
          child: TaskWidget(
            task: ft.tasks.values.firstWhere((task) => task.isRoot),
          ),
        );
      },
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
    final InheritedTaskList? result =
        context.dependOnInheritedWidgetOfExactType<InheritedTaskList>();
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
