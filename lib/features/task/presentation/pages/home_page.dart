import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/core/constants/shadows.dart';
import 'package:task_manager/features/task/domain/cubit/task_cubit.dart';
import 'package:task_manager/features/task/domain/todo_model.dart';
import 'package:task_manager/features/task/presentation/pages/add_edit_task_page.dart';
import 'package:task_manager/features/task/presentation/widgets/todo_custom_sliver_header.dart';
import 'package:task_manager/features/task/presentation/widgets/task_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isHidden = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskLoaded) {
            List<TodoModel> todos = state.tasks;
            List<TodoModel> currentTasks = todos.toList();
            if (isHidden) {
              currentTasks = todos.where((e) => !e.done).toList();
            }
            return CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  delegate: TodoCustomSliverHeader(
                    topPadding: MediaQuery.of(context).padding.top,
                    doneCount: todos.where((e) => e.done).length,
                    isHidden: isHidden,
                    onTap: () => setState(() => isHidden = !isHidden),
                  ),
                  pinned: true,
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(15.0),
                  sliver: DecoratedSliver(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary,
                      boxShadow: AppShadows.tileShadow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          for (var todo in currentTasks)
                            TaskItem(
                              todo: todo,
                              onToggleDone: (todo) {
                                context.read<TaskCubit>().updateTask(
                                    todo.copyWith(done: !todo.done));
                              },
                              onDelete: (todo) {
                                context.read<TaskCubit>().deleteTask(todo.id);
                              },
                              isHidden: isHidden,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                    padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom,
                )),
              ],
            );
          } else if (state is TaskError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No tasks'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddEditTaskPage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
