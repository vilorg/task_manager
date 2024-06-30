// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/core/constants/importance_extension.dart';

import 'package:task_manager/core/logger.dart';
import 'package:task_manager/features/task/domain/cubit/task_cubit.dart';
import 'package:task_manager/features/task/domain/todo_model.dart';

class AddEditTaskPage extends StatefulWidget {
  final TodoModel? todo;

  const AddEditTaskPage({super.key, this.todo});

  @override
  State<AddEditTaskPage> createState() => _AddEditTaskPageState();
}

class _AddEditTaskPageState extends State<AddEditTaskPage> {
  late String _title;
  late TextEditingController titleController;
  Importance _importance = Importance.basic;
  DateTime? _deadline = DateTime.now();
  bool isNeedDeadline = false;

  Widget getImportanceWidget(Importance importance) {
    String importanceText = importance.getText(context);
    Color? importanceColor = importance.color(context);

    return Row(
      children: [
        importance == Importance.important
            ? SvgPicture.asset("assets/icons/hight_priority.svg")
            : importance == Importance.low
                ? SvgPicture.asset("assets/icons/low_priority.svg")
                : const SizedBox(),
        SizedBox(width: importance == Importance.basic ? 0 : 5),
        Text(
          importanceText,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: importanceColor),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      _title = widget.todo!.text;
      titleController = TextEditingController(text: widget.todo!.text);
      _importance = widget.todo!.importance;
      _deadline = widget.todo!.deadline != null
          ? DateTime.fromMillisecondsSinceEpoch(widget.todo!.deadline!)
          : null;
      isNeedDeadline = widget.todo!.deadline != null;
    } else {
      titleController = TextEditingController();
      _title = '';
    }
  }

  Future<bool> _saveTask() async {
    try {
      TodoModel? newTodo = widget.todo;
      if (widget.todo != null) {
        newTodo = widget.todo!.copyWith(
          text: _title,
          importance: _importance,
          deadline: isNeedDeadline ? _deadline?.millisecondsSinceEpoch : null,
          done: widget.todo?.done ?? false,
          createdAt:
              widget.todo?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
          changedAt: DateTime.now().millisecondsSinceEpoch,
          lastUpdatedBy: 'device_id',
        );
        await context.read<TaskCubit>().updateTask(newTodo);
      } else {
        newTodo = TodoModel(
          text: _title,
          importance: _importance,
          deadline: isNeedDeadline ? _deadline?.millisecondsSinceEpoch : null,
          done: widget.todo?.done ?? false,
          createdAt:
              widget.todo?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
          changedAt: DateTime.now().millisecondsSinceEpoch,
          lastUpdatedBy: 'device_id',
        );
        await context.read<TaskCubit>().addTask(newTodo);
      }
      logger.i(
          'Task "${newTodo.text}" saved with importance "${newTodo.importance}" and deadline "${newTodo.deadline}"');
      return true;
    } catch (e) {
      if (context.mounted) {
        return false;
      }
    }
    return false;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _deadline) {
      setState(() {
        _deadline = picked;
      });
      logger.i('Deadline set to "$_deadline"');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: (isNeedDeadline && _deadline == null) || _title.isEmpty
                ? null
                : () async {
                    bool result = await _saveTask();
                    if (result) {
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Failed to save task')));
                      }
                    }
                  },
            child: Text(
              AppLocalizations.of(context)!.save,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Что надо сделать…'),
              maxLines: 9,
              minLines: 3,
              style: Theme.of(context).textTheme.bodyMedium,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (v) => setState(() => _title = v),
            ),
            const SizedBox(height: 15),
            const Divider(),
            const SizedBox(height: 15),
            Text(
              AppLocalizations.of(context)!.importance,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            DropdownButtonFormField<Importance>(
              value: _importance,
              items: Importance.values.map((Importance importance) {
                return DropdownMenuItem<Importance>(
                  value: importance,
                  child: getImportanceWidget(importance),
                );
              }).toList(),
              selectedItemBuilder: (context) =>
                  Importance.values.map((Importance importance) {
                return getImportanceWidget(importance);
              }).toList(),
              dropdownColor: Theme.of(context).colorScheme.surface,
              onChanged: (Importance? newValue) {
                setState(() {
                  _importance = newValue!;
                });
              },
            ),
            const SizedBox(height: 15),
            const Divider(),
            const SizedBox(height: 15),
            _DeadlineWidget(
              isNeedDeadline: isNeedDeadline,
              selectDate: _selectDate,
              setIsNeedDeadline: (p0) => setState(
                () => isNeedDeadline = p0,
              ),
              deadline: _deadline,
            ),
            const SizedBox(height: 15),
            const Divider(),
            const SizedBox(height: 15),
            InkWell(
              onTap: widget.todo == null
                  ? null
                  : () async {
                      await context
                          .read<TaskCubit>()
                          .deleteTask(widget.todo!.id);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.delete,
                    color: widget.todo == null
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    AppLocalizations.of(context)!.remove,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: widget.todo == null
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.error,
                        ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _DeadlineWidget extends StatelessWidget {
  final bool isNeedDeadline;
  final Function(BuildContext) selectDate;
  final DateTime? deadline;
  final Function(bool) setIsNeedDeadline;

  const _DeadlineWidget({
    required this.isNeedDeadline,
    required this.selectDate,
    this.deadline,
    required this.setIsNeedDeadline,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat.yMMMMd(locale);

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.deadline,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            isNeedDeadline
                ? InkWell(
                    onTap: () => selectDate(context),
                    child: Text(
                      dateFormat.format(deadline ?? DateTime.now()),
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
        Switch(
          value: isNeedDeadline,
          onChanged: setIsNeedDeadline,
          activeColor: Theme.of(context).primaryColor,
          inactiveThumbColor: Theme.of(context).scaffoldBackgroundColor,
          inactiveTrackColor: Theme.of(context).colorScheme.secondary,
        )
      ],
    );
  }
}
