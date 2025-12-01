import 'package:logbloc/features/feature_class.dart';

class TaskListFt extends Feature {
  final Map<String, Task> tasks;

  @override
  double get completeness {
    if (tasks.isEmpty) return 0;

    // recursive completeness calculation
    getTaskCompleteness(Task task) {
      if (task.childrenIds.isEmpty) {
        return task.done ? 1.0 : 0.0;
      } else {
        double total = 0.0;
        for (final childId in task.childrenIds) {
          final childTask = tasks[childId]!;
          total += getTaskCompleteness(childTask);
        }
        return total / task.childrenIds.length;
      }
    }

    final rootTasks = tasks.values.where((task) => task.isRoot).toList();
    double totalCompleteness = 0.0;
    for (final task in rootTasks) {
      totalCompleteness += getTaskCompleteness(task);
    }

    return totalCompleteness / rootTasks.length;
  }

  TaskListFt({
    required super.id,
    required super.type,
    required super.title,
    required super.pinned,
    required super.isRequired,
    required super.position,

    required this.tasks,
  });

  factory TaskListFt.fromBareFt(
    Feature ft, {
    required Map<String, Task> tasks,
  }) {
    return TaskListFt(
      id: ft.id,
      type: ft.type,
      title: ft.title,
      pinned: ft.pinned,
      isRequired: ft.isRequired,
      position: ft.position,

      tasks: tasks,
    );
  }

  @override
  factory TaskListFt.empty() =>
      TaskListFt.fromBareFt(Feature.empty('task_list'), tasks: {});

  @override
  factory TaskListFt.fromEntry(
    MapEntry<String, dynamic> entry,
    Map<String, dynamic>? recordFt,
  ) => TaskListFt.fromBareFt(
    Feature.fromEntry(entry),
    tasks: Map.fromEntries(
      (recordFt == null
              ? entry.value['tasks'] as Map<String, dynamic>
              : recordFt['tasks'] as Map<String, dynamic>)
          .entries
          .map((entry) => MapEntry(entry.key, Task.fromEntry(entry))),
    ),
  );

  @override
  serialize() => {
    ...super.serialize(),
    'tasks': Map<String, dynamic>.fromEntries(
      tasks.values.map((task) => task.serialize()),
    ),
  };

  @override
  Map<String, dynamic> makeRec() => {
    ...super.makeRec(),
    'tasks': Map.fromEntries(tasks.values.map((task) => task.serialize())),
  };

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
    final parent = tasks.values
        .toList()
        .where((t) => t.childrenIds.contains(task.id))
        .firstOrNull;

    if (parent == null) return;

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

  List<Task> getRoots({bool? done}) => tasks.values
      .where((task) => task.isRoot && (done == true ? (task.done) : true))
      .toList();
}

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

  factory Task.fromEntry(MapEntry<String, dynamic> entry) {
    final map = entry.value;
    return Task(
      id: entry.key,
      isRoot: map['isRoot'] as bool,
      title: map['title'] as String,
      done: map['done'] as bool,
      doneSubTasks: map['doneSubTasks'] as int,
      childrenIds: List<String>.from(map['childrenIds'] as List),
    );
  }

  MapEntry<String, dynamic> serialize() => MapEntry(id, {
    'isRoot': isRoot,
    'title': title,
    'done': done,
    'doneSubTasks': doneSubTasks,
    'childrenIds': childrenIds,
  });
}
