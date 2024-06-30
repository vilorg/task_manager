// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import 'package:task_manager/features/task/domain/todo_model.dart';
import 'package:task_manager/features/task/presentation/pages/add_edit_task_page.dart';

class TaskItem extends StatelessWidget {
  final TodoModel todo;
  final Function(TodoModel) onToggleDone;
  final Function(TodoModel) onDelete;
  final bool isHidden;

  const TaskItem({
    super.key,
    required this.todo,
    required this.onToggleDone,
    required this.onDelete,
    required this.isHidden,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();

    return Dismissible(
      key: Key(todo.id),
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete(todo);
        }
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onToggleDone(todo);
          if (isHidden) return true;
          return false;
        } else if (direction == DismissDirection.endToStart) {
          return true;
        }
        return null;
      },
      background: Container(
        color: Theme.of(context).colorScheme.scrim,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Icon(
          Icons.done,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
      secondaryBackground: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Icon(
          Icons.delete,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddEditTaskPage(todo: todo)),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
            leading: Checkbox(
              value: todo.done,
              onChanged: (value) {
                onToggleDone(todo);
              },
              activeColor: Theme.of(context).colorScheme.scrim,
              fillColor: todo.importance == Importance.important && !todo.done
                  ? WidgetStateProperty.all(
                      Theme.of(context).colorScheme.error.withOpacity(.16),
                    )
                  : null,
              isError: todo.importance == Importance.important && !todo.done
                  ? true
                  : false,
            ),
            title: Row(
              children: [
                todo.done
                    ? const SizedBox()
                    : todo.importance == Importance.important
                        ? SvgPicture.asset("assets/icons/hight_priority.svg")
                        : todo.importance == Importance.low
                            ? SvgPicture.asset("assets/icons/low_priority.svg")
                            : const SizedBox(),
                SizedBox(
                  width:
                      todo.importance == Importance.basic || todo.done ? 0 : 5,
                ),
                Expanded(
                  child: Text(
                    todo.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          decoration:
                              todo.done ? TextDecoration.lineThrough : null,
                          decorationColor:
                              Theme.of(context).colorScheme.secondary,
                          color: todo.done
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            subtitle: todo.deadline != null
                ? Text(
                    DateFormat.yMMMMd(locale).format(
                        DateTime.fromMillisecondsSinceEpoch(todo.deadline!)),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  )
                : null,
            trailing: Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ),
    );
  }
}
