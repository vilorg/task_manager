import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_manager/core/logger.dart';
import 'package:task_manager/core/network_info.dart';
import 'package:task_manager/features/task/data/task_repository.dart';
import 'package:task_manager/features/task/domain/todo_model.dart';
import 'package:task_manager/services/api_client.dart';

part 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final ApiClient apiClient;
  final TaskRepository taskRepository;
  final String deviceId;
  final NetworkInfo networkInfo;
  StreamSubscription<bool>? _connectivitySubscription;

  TaskCubit(
      this.apiClient, this.taskRepository, this.networkInfo, this.deviceId)
      : super(TaskInitial()) {
    _connectivitySubscription =
        networkInfo.onConnectivityChanged.listen((isConnected) {
      if (isConnected) {
        syncOfflineChanges();
      }
    });
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }

  Future<bool> syncOfflineChanges() async {
    logger.i('Syncing offline changes');
    final offlineChanges = taskRepository.getOfflineChanges();
    for (var change in offlineChanges) {
      try {
        if (change['type'] == 'add') {
          final task = TodoModel.fromJson(change['data']);
          await apiClient.addTodoItem(task);
        } else if (change['type'] == 'update') {
          final task = TodoModel.fromJson(change['data']);
          await apiClient.updateTodoItem(task);
        } else if (change['type'] == 'delete') {
          final id = change['data'] as String;
          await apiClient.deleteTodoItem(id);
        }
      } catch (e) {
        logger.e('Failed to sync change', error: e);
        return false;
      }
    }
    await taskRepository.clearOfflineChanges();
    final revision = await taskRepository.getRevision();
    return await _checkAndUpdateData(revision);
  }

  Future<void> fetchTasks() async {
    try {
      emit(TaskLoading());
      logger.i('Fetching tasks from local storage');
      final tasks = await taskRepository.getTasks();
      final revision = await taskRepository.getRevision();
      apiClient.revision = revision;
      logger.i(
          'Fetched ${tasks.length} tasks from local storage with revision $revision');

      if (await networkInfo.isConnected()) {
        if (await syncOfflineChanges()) {
          return;
        }
      }
      emit(TaskLoaded(tasks));
    } catch (e) {
      logger.e('Failed to fetch tasks', error: e);
      emit(const TaskError('Failed to fetch tasks'));
    }
  }

  Future<void> addTask(TodoModel task) async {
    final newTask = task.copyWith(lastUpdatedBy: deviceId);
    await taskRepository.addTask(newTask);
    final currentState = state;
    if (currentState is TaskLoaded) {
      final updatedTasks = List<TodoModel>.from(currentState.tasks)
        ..add(newTask);
      emit(TaskLoaded(updatedTasks));
    }

    if (await networkInfo.isConnected()) {
      try {
        await apiClient.addTodoItem(newTask);
        await taskRepository.updateRevision(apiClient.revision);
      } catch (e) {
        logger.e('Failed to add task online', error: e);
      }
    } else {
      await taskRepository.addOfflineChange('add', newTask.toJson());
      logger.i('No internet connection. Task added offline');
    }
  }

  Future<void> updateTask(TodoModel task) async {
    final updatedTask = task.copyWith(lastUpdatedBy: deviceId);
    await taskRepository.updateTask(updatedTask);
    final currentState = state;
    if (currentState is TaskLoaded) {
      final updatedTasks = currentState.tasks
          .map((t) => t.id == updatedTask.id ? updatedTask : t)
          .toList();
      emit(TaskLoaded(updatedTasks));
    }

    if (await networkInfo.isConnected()) {
      try {
        await apiClient.updateTodoItem(updatedTask);
        await taskRepository.updateRevision(apiClient.revision);
      } catch (e) {
        logger.e('Failed to update task online', error: e);
      }
    } else {
      await taskRepository.addOfflineChange('update', updatedTask.toJson());
      logger.i('No internet connection. Task updated offline');
    }
  }

  Future<void> deleteTask(String id) async {
    await taskRepository.deleteTask(id);
    final currentState = state;
    if (currentState is TaskLoaded) {
      final updatedTasks =
          currentState.tasks.where((task) => task.id != id).toList();
      emit(TaskLoaded(updatedTasks));
    }

    if (await networkInfo.isConnected()) {
      try {
        await apiClient.deleteTodoItem(id);
        await taskRepository.updateRevision(apiClient.revision);
      } catch (e) {
        logger.e('Failed to delete task online', error: e);
      }
    } else {
      await taskRepository.addOfflineChange('delete', id);
      logger.i('No internet connection. Task deleted offline');
    }
  }

  Future<bool> _checkAndUpdateData(int localRevision) async {
    try {
      logger.i('Checking for updates from server');
      final serverTasks = await apiClient.getTodoList();
      final serverRevision = await apiClient.getApiRevision();
      logger.i(
          'Server revision: $serverRevision, Local revision: $localRevision');

      if (serverRevision != localRevision) {
        logger.i('Revisions do not match. Updating local data');
        await taskRepository.updateRevision(serverRevision);
        await taskRepository.replaceLocalData(serverTasks);
        emit(TaskLoaded(serverTasks));
        return true;
      } else {
        logger.i('Revisions match. No update needed');
        return false;
      }
    } catch (e) {
      logger.e('Failed to check and update data', error: e);
      emit(const TaskError('Failed to check and update data'));
      return false;
    }
  }
}
