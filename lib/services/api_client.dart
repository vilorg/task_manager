import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:task_manager/features/task/domain/todo_model.dart';

class ApiClient {
  final Dio dio;
  int revision = 0;

  ApiClient({required String baseUrl, required String token})
      : dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        )) {
    // Добавим настройку для игнорирования ошибок проверки сертификатов
    if (!kReleaseMode) {
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final HttpClient client =
              HttpClient(context: SecurityContext(withTrustedRoots: false));
          client.badCertificateCallback =
              ((X509Certificate cert, String host, int port) => true);
          return client;
        },
      );
    }
  }

  Future<int> getApiRevision() async {
    try {
      final response = await dio.get('/list');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        revision = data['revision'] as int;
        return revision;
      } else {
        Logger().e('Failed to fetch revision: ${response.statusCode}');
        throw Exception('Failed to fetch todo list');
      }
    } on DioException catch (e) {
      Logger().e('Failed to get revision', error: e);
      throw Exception('Failed to get revision');
    }
  }

  Future<List<TodoModel>> getTodoList() async {
    try {
      final response = await dio.get('/list');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        revision = data['revision'] as int;
        return (data['list'] as List)
            .map((item) => TodoModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        Logger().e('Failed to fetch todo list: ${response.statusCode}');
        throw Exception('Failed to fetch todo list');
      }
    } on DioException catch (e) {
      Logger().e('Failed to get todo items', error: e);
      throw Exception('Failed to get todo items');
    }
  }

  Future<void> addTodoItem(TodoModel todo) async {
    try {
      final response = await dio.post(
        '/list',
        options: Options(headers: {'X-Last-Known-Revision': revision}),
        data: {'element': todo.toJson()},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        revision = data['revision'] as int;
        Logger().i('Todo item added successfully');
      } else {
        Logger().e('Failed to add todo item: ${response.statusCode}');
        throw Exception('Failed to add todo item');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 &&
          e.response?.data == 'unsynchronized data') {
        await handleUnsynchronizedData();
        await addTodoItem(todo);
      } else {
        Logger().e('Failed to add todo item', error: e);
        throw Exception('Failed to add todo item');
      }
    }
  }

  Future<void> updateTodoItem(TodoModel todo) async {
    try {
      final response = await dio.put(
        '/list/${todo.id}',
        options: Options(headers: {'X-Last-Known-Revision': revision}),
        data: {'element': todo.toJson()},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        revision = data['revision'] as int;
        Logger().i('Todo item updated successfully');
      } else {
        Logger().e('Failed to update todo item: ${response.statusCode}');
        throw Exception('Failed to update todo item');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 &&
          e.response?.data == 'unsynchronized data') {
        await handleUnsynchronizedData();
        await updateTodoItem(todo);
      } else {
        Logger().e('Failed to update todo item', error: e);
        throw Exception('Failed to update todo item');
      }
    }
  }

  Future<void> deleteTodoItem(String id) async {
    try {
      final response = await dio.delete(
        '/list/$id',
        options: Options(headers: {'X-Last-Known-Revision': revision}),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        revision = data['revision'] as int;
        Logger().i('Todo item deleted successfully');
      } else {
        Logger().e('Failed to delete todo item: ${response.statusCode}');
        throw Exception('Failed to delete todo item');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 &&
          e.response?.data == 'unsynchronized data') {
        await handleUnsynchronizedData();
        await deleteTodoItem(id);
      } else {
        Logger().e('Failed to delete todo item', error: e);
        throw Exception('Failed to delete todo item');
      }
    }
  }

  Future<void> handleUnsynchronizedData() async {
    Logger().i('Handling unsynchronized data');
    await getTodoList();
  }
}
