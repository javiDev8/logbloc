import 'package:logize/features/feature_class.dart';

class Task {
  String id;
  bool isRoot;
  String title;
  bool done;
  int doneSubTasks;
  List<String> childrenIds;

  Task({
    required this.id,
    required this.isRoot,
    required this.title,
    required this.done,
    required this.doneSubTasks,
    required this.childrenIds,
  });

  factory Task.empty({required bool isRoot, List<String>? chIds}) => Task(
    id: Feature.genId(),
    isRoot: isRoot,
    title: '',
    done: false,
    doneSubTasks: 0,
    childrenIds: chIds ?? [],
  );

  factory Task.fromMap(Map<String, dynamic> map) => Task(
    id: map['id'] as String,
    isRoot: map['isRoot'] as bool,
    title: map['title'] as String,
    done: map['done'] as bool,
    doneSubTasks: map['doneSubTasks'] as int,
    childrenIds: List<String>.from(map['childrenIds'] as List),
  );

  serialize() => {
    'id': id,
    'isRoot': isRoot,
    'title': title,
    'done': done,
    'doneSubTasks': doneSubTasks,
    'childrenIds': childrenIds,
  };
}

class TaskListFt extends Feature {
  final Map<String, Task> tasks;
  TaskListFt({
    required super.id,
    required super.type,
    required super.pinned,
    required super.isRequired,
    required super.position,
    super.schedule,

    required this.tasks,
  });

  factory TaskListFt.fromBareFt(
    Feature ft, {
    required Map<String, Task> tasks,
  }) {
    return TaskListFt(
      id: ft.id,
      type: ft.type,
      pinned: ft.pinned,
      isRequired: ft.isRequired,
      position: ft.position,
      schedule: ft.schedule,

      tasks: tasks,
    );
  }

  @override
  factory TaskListFt.empty() {
    final rootTask = Task.empty(isRoot: true, chIds: []);
    return TaskListFt.fromBareFt(
      Feature.empty('task_list'),
      tasks: {rootTask.id: rootTask},
    );
  }

  @override
  factory TaskListFt.fromEntry(
    MapEntry<String, dynamic> entry,
    Map<String, dynamic>? recordFt,
  ) => TaskListFt.fromBareFt(
    Feature.fromEntry(entry),
    tasks: (recordFt == null
            ? entry.value['tasks'] as Map<String, dynamic>
            : recordFt['tasks'] as Map<String, dynamic>)
        .map(
          (key, value) =>
              MapEntry(key, Task.fromMap(value as Map<String, dynamic>)),
        ),
  );

  @override
  serialize() => {
    ...super.serialize(),
    'tasks': tasks.map((key, value) => MapEntry(key, value.serialize())),
  };

  @override
  Map<String, dynamic> makeRec() => serialize();

  addTask({required String parentId}) {
    final task = Task.empty(isRoot: false);
    tasks[task.id] = task;
    final parent = tasks[parentId]!;
    parent.childrenIds.add(task.id);
    if (parent.done) {
      parent.done = false;
      checkTask(parent);
    } else {
      updateTask(parent);
    }
  }

  updateTask(Task task) => tasks[task.id] = task;

  deleteTask(Task task) {
    deleteDown(Task dtask) {
      if (dtask.childrenIds.isNotEmpty) {
        final List<String> childrenIdsToDelete = List.from(
          dtask.childrenIds,
        );

        for (final childId in childrenIdsToDelete) {
          final childTask = tasks[childId];
          if (childTask != null) {
            deleteTask(childTask);
          }
        }
      }
      tasks.remove(dtask.id);
    }

    deleteDown(task);
    final parent = tasks.values.firstWhere(
      (t) => t.childrenIds.contains(task.id),
    );

    parent.childrenIds.removeWhere((i) => i == task.id);
    if (!parent.done &&
        parent.doneSubTasks > 0 &&
        parent.childrenIds.length == parent.doneSubTasks) {
      parent.done = true;
      checkTask(parent);
    } else {
      updateTask(parent);
    }
  }

  checkTask(Task task) {
    void checkUp(Task upTask) {
      try {
        final parentTask = tasks.values.firstWhere(
          (t) => t.childrenIds.contains(upTask.id),
        );
        parentTask.doneSubTasks += upTask.done ? 1 : -1;
        final bool parentShouldBeDone =
            parentTask.childrenIds.length == parentTask.doneSubTasks;
        if (parentShouldBeDone != parentTask.done) {
          parentTask.done = parentShouldBeDone;
          updateTask(parentTask);
          checkUp(parentTask);
        }
      } catch (e) {
        return;
      }
    }

    checkDown(Task downTask) {
      final children = downTask.childrenIds.map(
        (childId) => tasks[childId],
      );
      downTask.doneSubTasks = task.done ? downTask.childrenIds.length : 0;
      for (final childTask in children) {
        childTask!.done = downTask.done;
        checkDown(childTask);
      }
    }

    updateTask(task);
    checkUp(task);
    checkDown(task);
  }
}
