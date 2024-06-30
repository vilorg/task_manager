import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:task_manager/features/task/domain/todo_model.dart';

extension CatExtension on Importance {
  String getText(BuildContext context) {
    switch (this) {
      case Importance.important:
        return AppLocalizations.of(context)!.imporanceHight;
      case Importance.low:
        return AppLocalizations.of(context)!.imporanceLow;
      case Importance.basic:
        return AppLocalizations.of(context)!.importanceNone;
    }
  }

  Color? color(BuildContext context) {
    Color? importanceColor = Theme.of(context).textTheme.bodyMedium?.color;

    if (this == Importance.important) {
      importanceColor = Theme.of(context).colorScheme.error;
    }
    return importanceColor;
  }
}
