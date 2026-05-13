import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:feddan/domain/entities/task_entity.dart';
import 'package:feddan/domain/usecases/complete_task_usecase.dart';
import 'package:feddan/domain/usecases/get_today_tasks_usecase.dart';
import 'package:feddan/presentation/blocs/task/task_bloc.dart';

class MockGetTodayTasksUseCase extends Mock implements GetTodayTasksUseCase {}
class MockCompleteTaskUseCase extends Mock implements CompleteTaskUseCase {}

TaskEntity _task({
  String id = 't1',
  String farmId = 'f1',
  TaskStatus status = TaskStatus.pending,
  TaskType type = TaskType.irrigate,
  TaskPriority priority = TaskPriority.normal,
}) =>
    TaskEntity(
      id: id,
      farmId: farmId,
      cropType: 'tomato',
      type: type,
      priority: priority,
      scheduledDate: DateTime(2025, 5, 10),
      messageAr: 'ري الطماطم',
      messageEn: 'Irrigate tomato',
      status: status,
      createdAt: DateTime(2025, 5, 10),
    );

void main() {
  late MockGetTodayTasksUseCase getTasks;
  late MockCompleteTaskUseCase completeTask;

  setUpAll(() {
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    getTasks = MockGetTodayTasksUseCase();
    completeTask = MockCompleteTaskUseCase();
  });

  TaskBloc build() => TaskBloc(
        getTodayTasks: getTasks,
        completeTask: completeTask,
      );

  group('TasksLoadRequested', () {
    blocTest<TaskBloc, TaskState>(
      'emits loading then loaded with tasks returned by use case',
      build: () {
        // Sorting is the use case's responsibility; bloc passes through
        when(() => getTasks(any())).thenAnswer((_) async => [
              _task(id: 't2', priority: TaskPriority.high),
              _task(id: 't1', priority: TaskPriority.normal),
            ]);
        return build();
      },
      act: (b) => b.add(const TasksLoadRequested(['f1'])),
      expect: () => [
        isA<TaskState>()
            .having((s) => s.status, 'status', TaskLoadStatus.loading),
        isA<TaskState>()
            .having((s) => s.status, 'status', TaskLoadStatus.loaded)
            .having((s) => s.tasks.length, 'tasks.length', 2),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'emits loading then loaded with empty list when farmIds empty',
      build: () {
        when(() => getTasks(any())).thenAnswer((_) async => []);
        return build();
      },
      act: (b) => b.add(const TasksLoadRequested([])),
      expect: () => [
        isA<TaskState>()
            .having((s) => s.status, 'status', TaskLoadStatus.loading),
        isA<TaskState>()
            .having((s) => s.status, 'status', TaskLoadStatus.loaded)
            .having((s) => s.tasks, 'tasks', isEmpty),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'emits failure when use case throws',
      build: () {
        when(() => getTasks(any())).thenThrow(Exception('network error'));
        return build();
      },
      act: (b) => b.add(const TasksLoadRequested(['f1'])),
      expect: () => [
        isA<TaskState>()
            .having((s) => s.status, 'status', TaskLoadStatus.loading),
        isA<TaskState>()
            .having((s) => s.status, 'status', TaskLoadStatus.failure),
      ],
    );
  });

  group('TaskCompleted', () {
    blocTest<TaskBloc, TaskState>(
      'optimistically marks task as done in the list',
      build: () {
        when(() => completeTask(
              farmId: any(named: 'farmId'),
              taskId: any(named: 'taskId'),
              skip: any(named: 'skip'),
            )).thenAnswer((_) async {});
        return build();
      },
      seed: () => TaskState(
        status: TaskLoadStatus.loaded,
        tasks: [_task(id: 't1', status: TaskStatus.pending)],
      ),
      act: (b) =>
          b.add(const TaskCompleted(farmId: 'f1', taskId: 't1')),
      expect: () => [
        isA<TaskState>().having(
          (s) => s.tasks.first.status,
          'status',
          TaskStatus.done,
        ),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'sets actionError when use case throws',
      build: () {
        when(() => completeTask(
              farmId: any(named: 'farmId'),
              taskId: any(named: 'taskId'),
              skip: any(named: 'skip'),
            )).thenThrow(Exception('offline'));
        return build();
      },
      seed: () => TaskState(
        status: TaskLoadStatus.loaded,
        tasks: [_task(id: 't1')],
      ),
      act: (b) =>
          b.add(const TaskCompleted(farmId: 'f1', taskId: 't1')),
      expect: () => [
        isA<TaskState>().having(
            (s) => s.actionError, 'actionError', isNotNull),
      ],
    );
  });

  group('TaskSkipped', () {
    blocTest<TaskBloc, TaskState>(
      'optimistically marks task as skipped',
      build: () {
        when(() => completeTask(
              farmId: any(named: 'farmId'),
              taskId: any(named: 'taskId'),
              skip: any(named: 'skip'),
            )).thenAnswer((_) async {});
        return build();
      },
      seed: () => TaskState(
        status: TaskLoadStatus.loaded,
        tasks: [_task(id: 't1', status: TaskStatus.pending)],
      ),
      act: (b) => b.add(const TaskSkipped(farmId: 'f1', taskId: 't1')),
      expect: () => [
        isA<TaskState>().having(
          (s) => s.tasks.first.status,
          'status',
          TaskStatus.skipped,
        ),
      ],
    );
  });
}
